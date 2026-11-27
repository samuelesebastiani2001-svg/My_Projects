"""
get_macro_data.py
Downloads euro-area macro data from official sources and writes macro_data.xlsx

  Eurostat : real GDP growth (quarterly, % change vs same quarter of previous year)
             unemployment rate (monthly, seasonally adjusted, %)
  ECB      : HICP inflation (monthly, annual rate of change, %, dataset HICP)
             10-year government bond yields (monthly, %)
             ECB deposit facility rate (month-end, %)

Countries: Italy, Germany, France, Spain, Euro area
Usage:     python get_macro_data.py            (data from 2010)
           python get_macro_data.py 2005       (data from another start year)
Needs:     pip install pandas requests openpyxl
"""

import io
import sys
from datetime import date

import pandas as pd
import requests

START = sys.argv[1] if len(sys.argv) > 1 else "2010"
COUNTRIES = ["IT", "DE", "FR", "ES", "EA"]           # EA = euro area
EUROSTAT = "https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data"
ECB = "https://data-api.ecb.europa.eu/service/data"
EA_CODES_EUROSTAT = ["EA", "EA21", "EA20", "EA19"]    # euro area code changes with enlargements
EA_CODE_ECB = "U2"                                    # ECB code for the euro area
OUT = "macro_data.xlsx"
log = []


# ---------------------------------------------------------------- Eurostat
def eurostat_series(dataset, filters, geo):
    """One country from a Eurostat dataset -> pandas Series indexed by period string."""
    params = {**filters, "geo": geo, "format": "JSON", "lang": "EN",
              "sinceTimePeriod": START}
    r = requests.get(f"{EUROSTAT}/{dataset}", params=params, timeout=60)
    r.raise_for_status()
    j = r.json()
    ids, sizes, dims = j["id"], j["size"], j["dimension"]

    def labels(d):                       # position -> code for one dimension
        idx = dims[d]["category"]["index"]
        if isinstance(idx, list):
            return dict(enumerate(idx))
        return {pos: code for code, pos in idx.items()}

    cats = {d: labels(d) for d in ids}
    out = {}
    for flat, value in j.get("value", {}).items():
        k, coords = int(flat), {}
        for d, s in zip(reversed(ids), reversed(sizes)):  # unravel the flat index
            coords[d] = cats[d][k % s]
            k //= s
        out[coords["time"]] = value
    if not out:
        raise ValueError("no observations returned")
    return pd.Series(out).sort_index()


def eurostat_all(dataset, filters, name):
    cols = {}
    for c in COUNTRIES:
        codes = EA_CODES_EUROSTAT if c == "EA" else [c]
        for code in codes:
            try:
                cols[f"{name} {c}"] = eurostat_series(dataset, filters, code)
                log.append(f"OK   {name} {c}  (Eurostat {dataset}, geo={code})")
                break
            except Exception as e:
                last = e
        else:
            log.append(f"FAIL {name} {c}  (Eurostat {dataset}): {last}")
    return cols


# --------------------------------------------------------------------- ECB
def ecb_series(flow, key):
    url = f"{ECB}/{flow}/{key}"
    r = requests.get(url, params={"format": "csvdata", "startPeriod": START},
                     headers={"Accept": "text/csv"}, timeout=60)
    r.raise_for_status()
    df = pd.read_csv(io.StringIO(r.text))
    s = pd.Series(df["OBS_VALUE"].values, index=df["TIME_PERIOD"].astype(str))
    if s.empty:
        raise ValueError("no observations returned")
    return s.sort_index()


def ecb_all(flow, key_template, name, countries=COUNTRIES):
    cols = {}
    for c in countries:
        code = EA_CODE_ECB if c == "EA" else c
        key = key_template.format(code)
        try:
            cols[f"{name} {c}"] = ecb_series(flow, key)
            log.append(f"OK   {name} {c}  (ECB {flow}.{key})")
        except Exception as e:
            log.append(f"FAIL {name} {c}  (ECB {flow}.{key}): {e}")
    return cols


# ---------------------------------------------------------------- download
print(f"Downloading data from {START}...")

# Quarterly: real GDP, chain-linked volumes, % change on same quarter of previous year
gdp = eurostat_all("namq_10_gdp",
                   {"unit": "CLV_PCH_SM", "s_adj": "SCA", "na_item": "B1GQ"},
                   "GDP growth")

# Monthly: unemployment rate, seasonally adjusted, total population, % of labour force
unemp = eurostat_all("une_rt_m",
                     {"s_adj": "SA", "age": "TOTAL", "sex": "T", "unit": "PC_ACT"},
                     "Unemployment")

# Monthly: HICP all-items, annual rate of change
# Since February 2026 (new COICOP 2018 classification) the ECB publishes HICP in the
# "HICP" dataset; the old "ICP" series stop in December 2025 and are only a fallback.
hicp = ecb_all("HICP", "M.{}.N.000000.4D0.ANR", "Inflation")
for c in COUNTRIES:
    if f"Inflation {c}" not in hicp:
        hicp.update(ecb_all("ICP", "M.{}.N.000000.4.ANR", "Inflation", countries=[c]))

# Monthly: 10-year government bond yield (convergence criterion series)
y10 = ecb_all("IRS", "M.{}.L.L40.CI.0000.EUR.N.Z", "10Y yield",
              countries=["IT", "DE", "FR", "ES"])

# Daily: ECB deposit facility rate -> keep the last value of each month
dfr = {}
try:
    d = ecb_series("FM", "D.U2.EUR.4F.KR.DFR.LEV")
    d.index = pd.to_datetime(d.index)
    # the series only has dates when the rate changed: fill forward to every month-end
    today = pd.Timestamp(date.today())
    d = d.reindex(pd.date_range(d.index.min(), today, freq="D")).ffill()
    d = d.groupby(d.index.to_period("M")).last()
    d.index = d.index.strftime("%Y-%m")
    dfr["ECB deposit rate"] = d
    log.append("OK   ECB deposit rate  (ECB FM.D.U2.EUR.4F.KR.DFR.LEV)")
except Exception as e:
    log.append(f"FAIL ECB deposit rate: {e}")


# ------------------------------------------------------------- build sheets
def to_month_end(period_str, freq):
    return pd.Period(period_str.replace("-Q", "Q"), freq=freq).end_time.normalize()


monthly = pd.DataFrame({**hicp, **unemp, **y10, **dfr})
monthly = monthly[monthly.index >= START]
monthly.index = [to_month_end(p, "M") for p in monthly.index]
monthly.index.name = "Date"
if {"10Y yield IT", "10Y yield DE"} <= set(monthly.columns):
    monthly["BTP-Bund spread (bp)"] = (monthly["10Y yield IT"] - monthly["10Y yield DE"]) * 100

quarterly = pd.DataFrame(gdp)
quarterly.index = [to_month_end(p, "Q") for p in quarterly.index]
quarterly.index.name = "Quarter end"

# drop trailing rows where everything is empty
monthly = monthly.dropna(how="all").round(2)
quarterly = quarterly.dropna(how="all").round(2)

sources = pd.DataFrame({
    "Series": ["GDP growth", "Unemployment", "Inflation", "10Y yield", "ECB deposit rate"],
    "Source": ["Eurostat namq_10_gdp (CLV_PCH_SM, SCA, B1GQ)",
               "Eurostat une_rt_m (SA, TOTAL, T, PC_ACT)",
               "ECB HICP (all items, annual rate of change)",
               "ECB IRS (long-term interest rate, convergence criterion)",
               "ECB FM.D.U2.EUR.4F.KR.DFR.LEV (month-end level)"],
    "Unit": ["% y/y", "% of labour force", "% y/y", "% per year", "% per year"],
})
sources.loc[len(sources)] = ["Downloaded", date.today().isoformat(), ""]

with pd.ExcelWriter(OUT, engine="openpyxl", datetime_format="DD/MM/YYYY") as xw:
    monthly.to_excel(xw, sheet_name="Monthly")
    quarterly.to_excel(xw, sheet_name="Quarterly")
    sources.to_excel(xw, sheet_name="Sources", index=False)
    for ws in xw.book.worksheets:
        ws.column_dimensions["A"].width = 14
        for col in ws.iter_cols(min_col=2, max_col=ws.max_column):
            ws.column_dimensions[col[0].column_letter].width = 16
        ws.freeze_panes = "B2"

print("\n".join(log))
print(f"\nMonthly:   {monthly.index.min():%m/%Y} to {monthly.index.max():%m/%Y}, {monthly.shape[1]} series")
print(f"Quarterly: {quarterly.index.min():%m/%Y} to {quarterly.index.max():%m/%Y}, {quarterly.shape[1]} series")
print(f"Saved {OUT}")
