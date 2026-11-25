import scipy.optimize
import yfinance as yf
import numpy as np
from datetime import datetime
from scipy.optimize import minimize
import matplotlib.pyplot as plt
from pypfopt import EfficientFrontier, expected_returns, risk_models, plotting

#---------------------------#
# Extracting information
# trading period from 1/1/2022 to 1/1/2025
#---------------------------#
tickers = ["AAPL", "MSFT", "TSLA", "AMD", "NVDA"]
start_sample = datetime(year=2022, month=1, day=1)
end_sample = datetime(year=2025, month=1, day=1)
data = yf.download(tickers=tickers, start=start_sample, end = end_sample)
price = data["Close"]
log_returns = np.log(price / price.shift(1)).dropna()

#---------------------------#
# annualized mean vector, covariance matrix and risk-free rate
#---------------------------#
mu = log_returns.mean() * 252
cov_matrix = log_returns.cov() * 252
data_rf = yf.Ticker("^TNX").history(start=start_sample, end=end_sample)["Close"]
risk_free = data_rf.mean() / 100
#---------------------------#

# neg_sharpe returns the negative sharpe ratio
# and by minimizing the negative sharpe, we max. sharpe ratio
#---------------------------#
def neg_sharpe(w: list):
    pf_returns = mu @ w
    excess_returns = pf_returns - risk_free
    sigma_p = np.sqrt(w @ cov_matrix @ w)

    sharpe_ratio = excess_returns / sigma_p
    return -sharpe_ratio

#---------------------------#
# optimizing the function
#---------------------------#
w = np.ones(len(tickers)) / len(tickers) # initial conditions, each weight is equal

results = scipy.optimize.minimize(fun = neg_sharpe, x0 = w, constraints= {
    "type":"eq", "fun": lambda w: np.sum(w) -1},
    bounds = [(0,1)] * len(tickers) )

optimal_weights = results.x

def min_variance(w: list):
    return w @ cov_matrix @ w

range_returns = np.linspace(min(mu), max(mu))
frontier = []
for value in range_returns:
    result = scipy.optimize.minimize(fun = min_variance, x0 = w, constraints = [{
        "type": "eq", "fun": lambda w, v=value: mu @ w - v},
        {"type": "eq", "fun": lambda w: np.sum(w) -1}],
        bounds = [(0,1)]*len(tickers) )
    port_return = value
    port_risk = np.sqrt(result.fun)
    frontier.append((port_return, port_risk))
#---------------------------##---------------------------#
# constraints mean that the 2 equations are put to 0, so np.sum(w) - 1 means the sum of weights = 1
# and mu @ w - v means the same expected returns as the value.
# we can then get the return as "value" (is the value in the loop)
# and we get risk as "result.fun" because the function is "min_variance", so the fun value is variance
# bounds = [(0,1)]*len(tickers) --> len(tickers) because bounds are for each stock
# for matrix multiplication, we use @
#---------------------------##---------------------------#
# Efficient frontier
#---------------------------#
fr_return, fr_risk = zip(*frontier)

plt.plot(fr_risk, fr_return)
plt.xlabel("Risk (std. deviation)")
plt.ylabel("Expected returns")
plt.title("Efficient Frontier")

#---------------------------#
# now using PyPortfolioOpt
#---------------------------#
mu_pf = expected_returns.mean_historical_return(price)
cov_pf = risk_models.sample_cov(price)

ef = EfficientFrontier(mu_pf, cov_pf)
ef.max_sharpe(risk_free_rate=risk_free)
ef.portfolio_performance(verbose=True, risk_free_rate=risk_free)

ef2 = EfficientFrontier(mu_pf, cov_pf)
ax = plotting.plot_efficient_frontier(ef2, show=False)
plt.show()







