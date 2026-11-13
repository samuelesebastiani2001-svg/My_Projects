# DCF Valuation Engine

A Python tool that performs a **Discounted Cash Flow (DCF) valuation** for a list of stocks and exports the results to a formatted Excel spreadsheet. For each company, it fetches live financial data, computes the implied share price, and generates a sensitivity analysis table across different growth and discount rate assumptions.


**`dcf_functions.py`** — contains three core functions:

- `info_calculator`: takes the firm (from the ticker) and computes its share value.
- `compute_dcf`: fetches live data from Yahoo Finance (balance sheet, cash flows, income statement) and computes the WACC, projected free cash flows, terminal value, and implied share price.
- `write_excel_table`: writes the DCF inputs and outputs (WACC, implied price, enterprise value, terminal value) into a formatted Excel sheet. It also generates a sensitivity table showing implied share prices across a grid of growth rate and discount rate combinations.

**`dcf_engine.py`** — the main script. Iterates over a list of tickers, runs the full DCF for each, and saves everything into a single Excel workbook with one sheet per company.

## Libraries used:

- `yfinance`
- `openpyxl`

## Usage

Edit the ticker list and sensitivity parameters at the top of `dcf_engine.py`:
```python
ticker = ["AAPL", "TSLA", "MSFT"]
lowest_growth_rate = 0.02 
lowest_discount_rate = 0.07
growth_rate_steps = 8
discount_rate_steps = 10
sensitivity_step = 0.01
```

Then run:
```
dcf_engine.py
```

This will generate an Excel file (e.g. `['AAPL', 'TSLA', 'MSFT']_DCF.xlsx`) with one sheet per company.

