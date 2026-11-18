# Equity Trading Desk Book (Excel)

An Excel model of a bank's equity trading book, as a middle-office or risk team would run it. Starting from a list of trades, it keeps track of positions, works out P&L with the average-cost method, revalues the book every day, measures market risk with **Value at Risk** (parametric and historical) and checks every risk limit with a traffic-light monitor.

The book holds **5 real FTSE MIB stocks**, priced with real daily closes from Yahoo Finance. It includes long positions and one short.

## Features
- **Trade blotter**: you enter 6 fields per trade (date, ticker, side, quantity, price). The sheet then works out the signed quantity, commission, cash flow, running position, cost basis, average cost and **realized P&L** for each trade, for both long and short positions. A check column flags unknown tickers, invalid quantities and dates that aren't trading days.
- **Positions at any valuation date**: net quantity, long/short, average cost, market price, market value, **unrealized, realized and total P&L**, plus long, short, net and gross exposure. Pick a past date and the whole sheet shows the book as it was on that day.
- **Daily P&L history**: the book is revalued at every close: daily P&L = change in market value − cash spent on trades − commissions. It comes with cumulative and daily P&L charts. Its final cumulative P&L matches the total P&L on the Positions sheet, which is a reconciliation between two independent methods.
- **Market risk (VaR)**:
  - daily and annual volatility of each stock, and a correlation matrix shown as a heat map
  - **parametric VaR** (variance-covariance method), next to the standalone VaR of each stock, showing the **diversification benefit**
  - **historical-simulation VaR**: today's book replayed through each past day
  - a simple **backtest**: the number of days with a loss bigger than VaR, compared with the number expected
- **Limit monitor**: position size per stock, desk gross exposure, 1-day VaR and stop-loss, each with its utilization and an **OK / WARNING / BREACH** status.

## Results (valuation date 27/10/2026)
| Metric | Value |
|---|---|
| Gross exposure | €944,137 |
| Net exposure | €668,782 (long €806,460 · short −€137,678) |
| Total P&L | −€11,220 (unrealized −€30,417 · realized +€20,953 · commissions −€1,756) |
| 1-day 99% parametric VaR | €27,677 |
| 1-day 99% historical VaR | €25,465 |
| Diversification benefit | €17,128 (38% of the sum of standalone VaRs) |
| Limit status | 2 breaches (Intesa Sanpaolo position, desk VaR) · 1 warning (STMicroelectronics position) |

The breaches are kept on purpose. They show the monitor working: the desk would have to reduce its Intesa Sanpaolo position and cut its overall risk.

## Workbook structure
| Sheet | Contents |
|---|---|
| **INPUTS** | Desk parameters (commissions, VaR confidence and horizon), risk limits and the security master (the 5 stocks) |
| **Data** | Daily closing prices and simple returns |
| **Trading Desk** | The trade blotter, with average-cost position accounting |
| **Open Positions** | Positions and P&L as of the valuation date, plus a book summary |
| **P&L History** | Daily revaluation of the book, daily and cumulative P&L, and charts |
| **RisK (VaR)** | Volatility, correlation matrix, parametric VaR, historical VaR and the backtest |
| **Limits** | Limit utilization and traffic-light status |

## Excel skills used
| Area | Functions and techniques |
|---|---|
| Conditional aggregation | `SUMIFS` with date criteria (`"<="&date`), **expanding ranges** (`G$5:G5`) for running totals, `SUMIF`, `COUNTIF` |
| Lookups | `INDEX`/`MATCH` (exact and approximate), **2-D lookups** (date × ticker), `INDEX(range, 0, n)` to pull out a whole column |
| Array maths | `SUMPRODUCT`, including `SUMPRODUCT(ABS(...))` for gross exposure |
| Statistics | `STDEV.S`, `CORREL`, `NORM.S.INV`, `PERCENTILE.INC`, `SQRT` |
| Logic | nested `IF`, `AND`, `OR`, `SIGN`, `ABS`, text built with `&` |
| Model design | named ranges, mixed references (`B$5`, `$A6`) filling whole grids, helper columns, one input area driving every sheet, a reconciliation check |
| Presentation | conditional formatting (traffic lights, colour scales, data bars), data validation dropdowns, freeze panes, charts |

## Data
- **Prices:** daily closing prices from **Yahoo Finance**, 04/05/2026 – 27/10/2026 (127 trading days), **not adjusted for dividends**. They were downloaded with `get_real_data.py`.
- **Stocks:** Intesa Sanpaolo (ISP), Eni (ENI), STMicroelectronics (STM), Recordati (REC, held short) and Moncler (MONC): one per sector.
- **Trades:** the 21 trades are **illustrative**, not real trades. Each is priced at that day's close ± 0.2%.

## How to use
1. **Your own trades:** replace the trades in **Trading Desk**, columns A–F, in date order. Every other sheet updates automatically. Check that the *Check* column says OK on every row.
2. **A different date:** change the valuation date on **Open Positions** to see the book, P&L and limits on any past day.
3. **New market data:** run `get_real_data.py` (Python, using `yfinance`) and paste the prices into the **Data** sheet as values. Change the tickers in the security master on **INPUTS** to use other stocks.

```
pip install yfinance pandas openpyxl
python get_real_data.py
```

## Limitations
- Dividends, financing costs and corporate actions are not modelled.
- VaR uses today's positions and all the returns in the sample (126 days). Banks usually use 250 days or more.
- Parametric VaR assumes normally distributed returns, so it can underestimate large losses (fat tails).
- A trade that flips a position from long to short has to be entered as two separate trades.

## Tools
Microsoft Excel (formulas only, no macros) · Python (`yfinance`, `pandas`) for the data download.
