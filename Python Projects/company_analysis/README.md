# Comparable Company Analysis Tool

A Python tool that performs comparable company analysis by pulling real-time financial data, computing trading multiples, and outputting an implied valuation range for a target company.

## What it does

1. Fetches live financial data for a peer set using `yfinance`
2. Computes key trading multiples: **EV/EBITDA**, **P/E**, and **P/B**
3. Builds a formatted comps table
4. Applies peer median multiples to a target company to produce implied share prices
5. Exports results to a two-sheet Excel file


## Output example

**Comps table:**
```
      Enterprise Value  EV/EBITDA      P/E     P/B  Current Price
AAPL      4.58e+12      28.63       37.23    42.80     311.57
MSFT      3.16e+12      17.11       24.82     7.50     415.32
...
```

**Valuation summary Example (target: AAPL):**
```
                   Value for AAPL
Current Price              311.57
Implied P/B price          119.72
Implied P/E price          834.95
Implied EV/EBITDA price    767.34
```


## Libraries Used:
- `yfinance`
- `openpyxl`
- `pandas`

