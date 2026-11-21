# Treasury & Hedging Desk (Excel)

An Excel model of a corporate trading and treasury desk that hedges currency and energy risk with OTC contracts. It covers daily trading tasks, such as monitoring the markets, recording FX forwards and commodity swaps, valuing open positions at market prices, rolling maturing hedges, and reporting everything on a dashboard.

## Features
- **Market monitor**: equities (FTSE MIB, Euro Stoxx 50, S&P 500), FX (EUR/USD, EUR/GBP, EUR/CHF), commodities (Brent, TTF gas, gold) and rates (Euribor, BTP, Bund, US Treasury), with 1-day, 1-week, 1-month and year-to-date moves (% for prices, basis points for rates).
- **OTC contract blotter**: FX forwards and commodity swaps with their terms, confirmation status, days to maturity and maturity bucket.
  - **Mark-to-market** in euros for every open contract, discounted to the valuation date
  - Closed deals (settled, rolled or expired) drop out of the risk figures automatically
- **Rollover calculator**: pick a maturing deal and a new maturity date. The model shows the close-out P&L at spot, the new forward rate and the forward points.
- **Dashboard**: open deals, total MTM, deals awaiting confirmation, deals maturing this week, net position and MTM by underlying, and a chart.


## Workbook structure
| Sheet | Contents |
|---|---|
| **Market monitor** | Watch list with price and rate moves, spreads, and the money-market rates used for forward pricing |
| **OTC contracts** | Deal blotter: terms, confirmation status, maturity bucket, forward price, discount factor, MTM |
| **Rollover** | Close-out and re-pricing of a maturing contract |
| **Dashboard** | Summary figures, maturity ladder, exposure and MTM by underlying, chart |


## Data and assumptions
- **Market prices and interest rates are illustrative.** Replace them with real closing prices: `get_market_data.py` downloads equities, FX and commodities from Yahoo Finance. Euribor, BTP and Bund yields must be typed in by hand.
- **The deals and counterparties are fictional.**
- Money-market convention: simple interest, Act/360.

## How to use
1. **Market monitor:** update the prices and the valuation date. Every sheet revalues automatically.
2. **OTC contracts:** add new deals in the input columns, and update their confirmation status as they are confirmed or settled.
3. **Rollover:** choose a deal and a new maturity date to see the close-out P&L and the new forward rate.
4. **Dashboard:** check open risk, upcoming maturities and the deals that need action.

## Tools
Microsoft Excel (formulas only, no macros) · Python (`yfinance`) for the market-data download.
