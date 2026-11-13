# Mean-Variance Portfolio Optimizer

An implementation of Markowitz portfolio optimization using `numpy` and `scipy`, validated against the `PyPortfolioOpt` library.

## What it does

- Pulls historical price data for a basket of assets via `yfinance`
- Computes log returns, expected return vector (mu), and covariance matrix (sigma)
- Maximizes the Sharpe ratio using `scipy.optimize.minimize`
- Plots the efficient frontier by minimizing variance across a range of target returns
- Replicates the same optimization using `PyPortfolioOpt` and compares results

## Libraries used

- `yfinance` — historical price data
- `numpy` — return and covariance computation
- `scipy.optimize` — constrained optimization
- `matplotlib` — efficient frontier plot
- `PyPortfolioOpt` — library comparison
