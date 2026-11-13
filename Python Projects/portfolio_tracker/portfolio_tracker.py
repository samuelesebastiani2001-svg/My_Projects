import pandas as pd
import matplotlib.pyplot as plt
import yfinance as yf

# list of Stocks in my portfolio
Microsoft = {"ticker": "MSFT", "shares": 10, "buy_price": 150}
Apple = {"ticker": "AAPL", "shares": 5, "buy_price": 200}
Tesla = {"ticker": "TSLA", "shares": 3, "buy_price": 70}
my_portfolio = [Microsoft, Apple, Tesla]

# compute for each stock: current value, gain/loss of the position, percentage returns
results = []
for item in my_portfolio:
    stock = yf.Ticker(item["ticker"])
    price_now = stock.fast_info.last_price

    current_value =  price_now * item["shares"]
    gain_loss = (price_now - item["buy_price"]) * item["shares"]
    return_pct = (gain_loss / (item["buy_price"]*item["shares"]) * 100)
    result_dict = {"ticker": item["ticker"], "price_now": price_now, "current_val": current_value, "gain/loss": gain_loss, "return_pct": return_pct}
    results.append(result_dict) # this lets me add the values inside the list "results" in each iteration of the loop

df = pd.DataFrame(results) # use a dataframe to display the results
pd.options.display.float_format = "{:.2f}".format # only show 2 decimals

plt.bar(df["ticker"], df["return_pct"])
plt.title("stock Returns in my portfolio")
plt.xlabel("Stock")
plt.ylabel("percentage returns")
print(df)
plt.show()
