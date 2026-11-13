# Portfolio Tracker

A simple Python script to track the performance of a personal stock portfolio. It fetches live market prices and calculates the current value, gain/loss, and percentage return for each position, then displays the results in a table and a bar chart.

For each stock in the portfolio, the script:
- Fetches the current price using the `yfinance` library
- Calculates the current market value of the position
- Calculates the total gain or loss compared to the purchase price
- Calculates the percentage return

Results are printed as a formatted table (via `pandas`) and visualized as a bar chart (via `matplotlib`).

## Usage

Edit the portfolio at the top of the script to match your own holdings:
```python
Microsoft = {"ticker": "MSFT", "shares": 10, "buy_price": 150}
Apple = {"ticker": "AAPL", "shares": 5, "buy_price": 200}
Tesla = {"ticker": "TSLA", "shares": 3, "buy_price": 70}
```

Then simply run: "portfolio_tracker.py"

