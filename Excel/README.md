# Excel-Projects (Work in Progress)

A collection of Excel models built to develop my spreadsheet skills in finance, banking, financial markets and macroeconomic analysis. Every model is built with formulas only (no macros or VBA), so every number can be traced back to its inputs.


Below is a list of the projects, with a short description of each:

## 1. [Loan & mortgage amortization model](loan_amortization/)

A model that builds a full amortization schedule for any fixed-rate loan or mortgage, based on the loan amount, interest rate, term, payment frequency and start date. It compares results with and without an extra payment per period (total interest, payoff date and time saved), and summarizes interest and principal paid in each calendar year, with charts.

## 2. [Equity trading desk book](trading_desk_book/)

A model of a bank's equity trading book, built on real FTSE MIB prices from Yahoo Finance. From a blotter of trades it tracks positions and calculates P&L with the average-cost method, for both long and short positions. It revalues the book every day and measures market risk with parametric and historical-simulation Value at Risk, including the diversification benefit and a simple backtest. A limit monitor then compares position size, gross exposure, VaR and stop-loss against the desk's limits, with an OK / WARNING / BREACH status for each.
