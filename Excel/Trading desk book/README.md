# Equity Trading Desk Book (Excel)

An Excel model of a bank's equity trading book. Starting from a list of trades, it keeps track of positions, works out P&L with the average-cost method, revalues the book every day, measures market risk with both Parametric and Historical VaR and checks every risk limit with a traffic-light monitor.

The book holds **5 real FTSE MIB stocks**, priced with real daily closes from Yahoo Finance. It includes long positions and one short.

## Features
- **Trade blotter**: you enter 5 fields per trade (date, ticker, side, quantity, price). The sheet then works out the signed quantity, commission, cash flow, running position, cost basis, average cost and **realized P&L** for each trade, for both long and short positions. A check column flags unknown tickers, invalid quantities and dates that aren't trading days.
- **Positions at any valuation date**: net quantity, long/short, average cost, market price, market value, **unrealized, realized and total P&L**, plus long, short, net and gross exposure. 
- **Daily P&L history**: the book is revalued at every close, by computing the daily P&L 
- **Market risk (VaR)**:
  - daily and annual volatility of each stock, and a correlation matrix shown as a heat map
  - **parametric VaR** (variance-covariance method), next to the standalone VaR of each stock, showing the **diversification benefit**
  - **historical-simulation VaR**: today's book replayed through each past day.
- **Limit monitor**: position size per stock, desk gross exposure, 1-day VaR and stop-loss, each with its utilization and an **OK / WARNING / BREACH** status.


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


## How to use
1. **Your own trades:** replace the trades in **Trading Desk**, columns A–F, in date order. Every other sheet updates automatically. Check that the *Check* column says OK on every row.
2. **A different date:** change the valuation date on **Open Positions** to see the book, P&L and limits on any past day.
3. **New market data:** run `get_real_data.py` (Python, using `yfinance`) and paste the prices into the **Data** sheet as values. Change the tickers in the security master on **INPUTS** to use other stocks.

```
pip install yfinance pandas openpyxl
python get_real_data.py
```

