# Excel-Projects (Work in Progress)

A collection of Excel models built to develop my spreadsheet skills in finance, banking, financial markets and macroeconomic analysis. Every model is built with formulas only (no macros or VBA), so every number can be traced back to its inputs.


Below is a list of the projects, with a short description of each:

## 1. [Loan & mortgage amortization model](Loan%20Amortization/)

A model that builds a full amortization schedule for any fixed-rate loan or mortgage, based on the loan amount, interest rate, term, payment frequency and start date. It compares results with and without an extra payment per period (total interest, payoff date and time saved), and summarizes interest and principal paid in each calendar year, with charts.

## 2. [Equity trading desk book](Trading%20desk%20book/)

A model of a bank's equity trading book, built on real FTSE MIB prices from Yahoo Finance. From a blotter of trades it tracks positions and calculates P&L with the average-cost method, for both long and short positions. It revalues the book every day and measures market risk with parametric and historical-simulation Value at Risk, including the diversification benefit and a simple backtest. A limit monitor then compares position size, gross exposure, VaR and stop-loss against the desk's limits, with an OK / WARNING / BREACH status for each.

## 3. [Bond pricing & yield curve](Bond%20Curve/)

A fixed-income model that prices government bonds and measures their interest-rate risk. A bond calculator works out clean and dirty price, accrued interest, yield to maturity, duration, convexity and DV01, and checks every result against a full cash-flow table. A yield curve from 1 to 30 years gives the slope and shape of the market. A small portfolio is priced off that curve by linear interpolation, and a parallel rate-shock scenario compares the exact P&L with the duration estimate to show the effect of convexity.

## 4. [Treasury & hedging desk](Treasury%20and%20hedging%20desk/)

A model of a corporate trading desk that hedges currency and energy risk with OTC contracts. It monitors equities, rates, FX and commodities, records FX forwards and commodity swaps with their confirmation status, prices forwards from interest rate parity, marks every open position to market, calculates rollovers, and reports open risk, maturities and MTM on a dashboard.
