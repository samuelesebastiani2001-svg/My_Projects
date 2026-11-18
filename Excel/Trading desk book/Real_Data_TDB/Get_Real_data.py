"""
Real market data for the Trading Desk Book (Excel project 2).

Downloads daily closing prices for 5 FTSE MIB stocks from Yahoo Finance.

Output: real_data.xlsx (in the same folder as this script), with 2 sheets:
  Securities -> INPUTS sheet, security master   (Ticker, Company, Sector, Currency)
  Prices     -> Data sheet, dates + 5 price columns (127 trading days)

Usage:  pip install yfinance pandas openpyxl
        python get_real_data.py
"""
import pandas as pd
import yfinance as yf

# ---- settings you can change ------------------------------------------------------
END_DATE = "2026-10-27"   # last trading day to include
N_DAYS = 127              # keep 127 so the Excel ranges don't need resizing

STOCKS = [
    ("ISP.MI",   "ISP",   "Intesa Sanpaolo",    "Financials"),
    ("ENI.MI",   "ENI",   "Eni",                "Energy"),
    ("STMMI.MI", "STM",   "STMicroelectronics", "Technology"),
    ("REC.MI",   "REC",   "Recordati",          "Healthcare"),
    ("MONC.MI",  "MONC",  "Moncler",            "Consumer"),
]
# ------------------------------------------------------------------------------------

yahoo = [s[0] for s in STOCKS]
end_exclusive = (pd.Timestamp(END_DATE) + pd.Timedelta(days=1)).strftime("%Y-%m-%d")
raw = yf.download(yahoo, start="2025-12-01", end=end_exclusive, auto_adjust=False, progress=False)
px = raw["Close"][yahoo].dropna().tail(N_DAYS)
if len(px) < N_DAYS:
    raise SystemExit(f"Only {len(px)} trading days found - move END_DATE or lower N_DAYS.")
px.columns = [s[1] for s in STOCKS]
px = px.round(3)

# Security master
securities = pd.DataFrame([(s[1], s[2], s[3], "EUR") for s in STOCKS],
                          columns=["Ticker", "Company", "Sector", "Currency"])

# Prices (real dates, real numbers)
prices = px.copy()
prices.index = prices.index.tz_localize(None).normalize()
prices.index.name = "Date"

with pd.ExcelWriter("real_data.xlsx", engine="openpyxl", datetime_format="DD/MM/YYYY") as xl:
    securities.to_excel(xl, sheet_name="Securities", index=False)
    prices.to_excel(xl, sheet_name="Prices")


print(f"Saved real_data.xlsx ({len(px)} days: {px.index[0]:%d/%m/%Y} to {px.index[-1]:%d/%m/%Y})")
