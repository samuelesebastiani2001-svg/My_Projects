# My Projects

Portfolio of data, finance and econometrics projects by **Samuele Sebastiani**.
The repository collects work in **MATLAB**, **Python** and **Excel**, with a focus on macroeconometrics, financial markets and valuation.

---

## Repository structure

```
My_Projects/
├── Thesis/              MATLAB + Dynare: Monte Carlo experiment on external-instrument SVAR and local projections
├── Python_Projects/     Finance and economics projects in Python
└── Excel/               Excel projects (coming soon)
```

---

## Thesis (MATLAB / Dynare)

**Local Projections with External Instruments: Raw Instrument vs. VAR-reconstructed Shock, a Monte Carlo Experiment**

Master's thesis in empirical macroeconometrics. The code simulates a New Keynesian model (Calvo pricing) and runs 2,000 Monte Carlo replications to study how well a monetary policy shock and its impulse responses are recovered when the shock is identified with a noisy external instrument. Two local-projection estimators (Short and Long) are compared in terms of bias, variance and MSE, across different instrument quality levels and sample-split ratios.

- **Tools:** MATLAB, Dynare
- **Topics:** SVAR-IV / proxy-SVAR, local projections, impulse response functions, Monte Carlo simulation
- **Details and instructions:** see the [README in the Thesis folder](Thesis/README.md)

---

## Python Projects

Finance and economics projects built with Python (pandas, matplotlib, yfinance, scipy).

| Project | Description |
|---|---|
| Portfolio tracker | Stock portfolio tracker that pulls market data with `yfinance` and shows a summary table and a bar chart. |
| GDP and life expectancy | Exploratory analysis of the relationship between GDP and life expectancy using Gapminder data. |
| S&P 500 implied volatility | Charts of implied volatility for the S&P 500. |
| Efficient frontier | Portfolio optimisation and efficient frontier, built with `scipy` and `PyPortfolioOpt`. |
| Comparable companies analysis | Valuation multiples (EV/EBITDA, P/E, P/B) for a set of peers, exported to Excel. |
| DCF valuation | Discounted cash flow valuation engine with a sensitivity table, exported to Excel. |

- **Tools:** Python, pandas, matplotlib, yfinance, scipy, PyPortfolioOpt
- **Topics:** portfolio analysis, market data, equity valuation, data visualisation

---

## Excel

Coming soon.

---
