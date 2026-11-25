"""
Apple (or any listed company) figures for the DCF model (Excel project 5).

Downloads the last annual financial statements and market data from Yahoo Finance
and writes company_data.xlsx with two sheets:
  Historicals -> one column per fiscal year (oldest to newest), $ billions
  Market      -> share price, shares, beta, market cap, US 10-year yield

Copy the numbers into the DCF Inputs / FCF sheets with Paste Special -> Values.

Usage:  pip install yfinance pandas openpyxl
        python get_apple_data.py            (Apple)
        python get_apple_data.py MSFT       (any other ticker)
"""
import sys

import pandas as pd
import yfinance as yf

TICKER = sys.argv[1] if len(sys.argv) > 1 else "AAPL"
BN = 1e9   # report in billions

t = yf.Ticker(TICKER)
inc, cf, bs = t.income_stmt, t.cashflow, t.balance_sheet


def row(df, names, label):
    """First matching line item, as a Series by year (None if not found)."""
    for n in names:
        if n in df.index:
            return df.loc[n]
    print(f"  ! '{label}' not found. Available lines include: {list(df.index)[:12]} ...")
    return pd.Series(index=df.columns, dtype=float)


lines = {
    "Revenue": row(inc, ["Total Revenue", "Operating Revenue"], "Revenue"),
    "Operating income (EBIT)": row(inc, ["Operating Income", "EBIT"], "EBIT"),
    "D&A": row(cf, ["Depreciation And Amortization", "Depreciation Amortization Depletion"], "D&A"),
    "Capex (negative = cash out)": row(cf, ["Capital Expenditure"], "Capex"),
    "Accounts receivable": row(bs, ["Accounts Receivable", "Receivables"], "Receivables"),
    "Inventory": row(bs, ["Inventory"], "Inventory"),
    "Accounts payable": row(bs, ["Accounts Payable", "Payables"], "Payables"),
    "Total debt": row(bs, ["Total Debt"], "Debt"),
    "Cash + short-term investments": row(bs, ["Cash Cash Equivalents And Short Term Investments",
                                              "Cash And Cash Equivalents"], "Cash"),
    "Tax provision": row(inc, ["Tax Provision"], "Tax"),
    "Pre-tax income": row(inc, ["Pretax Income"], "Pre-tax income"),
    "Diluted shares (billions)": row(inc, ["Diluted Average Shares"], "Shares"),
}
hist = pd.DataFrame(lines).T
hist = hist[sorted(hist.columns)]                       # oldest -> newest
hist.columns = [f"FY{c.year}" for c in hist.columns]
hist = hist.apply(pd.to_numeric, errors="coerce") / BN

# derived lines, so you can check them against the model
hist.loc["EBITDA"] = hist.loc["Operating income (EBIT)"] + hist.loc["D&A"]
hist.loc["Net working capital (AR + inv. - AP)"] = (hist.loc["Accounts receivable"] + hist.loc["Inventory"]
                                                    - hist.loc["Accounts payable"])
hist.loc["Net debt (debt - cash & ST inv.)"] = hist.loc["Total debt"] - hist.loc["Cash + short-term investments"]
hist.loc["Effective tax rate"] = (hist.loc["Tax provision"] / hist.loc["Pre-tax income"]) * BN / BN
hist = hist.round(3)

info = t.info
tnx = yf.Ticker("^TNX").history(period="5d")["Close"].dropna()
market = pd.DataFrame({
    "Value": [info.get("currentPrice"), info.get("sharesOutstanding", float("nan")) / BN,
              info.get("beta"), info.get("marketCap", float("nan")) / BN,
              float(tnx.iloc[-1]) / 100 if len(tnx) else None, info.get("currency")],
}, index=["Share price", "Shares outstanding (billions)", "Beta", "Market cap ($ bn)",
          "US 10-year Treasury yield", "Currency"])

with pd.ExcelWriter("company_data.xlsx", engine="openpyxl") as xw:
    hist.to_excel(xw, sheet_name="Historicals")
    market.to_excel(xw, sheet_name="Market")

print(f"\n{TICKER}: saved company_data.xlsx")
print(hist.to_string())
print()
print(market.to_string())
print("\nNote: marketable securities held long-term are NOT in 'cash + ST investments'.",
      "For Apple, check the 10-K balance sheet and add them if you want a full net cash figure.")
