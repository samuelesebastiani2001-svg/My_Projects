import yfinance as yf
import pandas as pd
import openpyxl as op


ticker_input = ["AAPL", "MSFT", "TSLA", "AMD", "NVDA"]



def get_financials(tickers: list):
    result = {} # this dictionary will contain a dictionary for each company
    for item in tickers:
        data = yf.Ticker(item)
        if not data.info or data.info.get("marketCap") is None:
            print (f"Skipping {item}: missing data or invalid ticker")
            continue
        #if data.info (which is a dictionary) doesnt exist, its considered false
        result[item] = {
            "market_cap": data.info.get("marketCap"),
            "total_debt": data.info.get("totalDebt"),
            "ebitda": data.info.get("ebitda"),
            "book_value": data.info.get("bookValue"),
            "shares_outstanding": data.info.get("sharesOutstanding"),
            "net_income": data.info.get("netIncomeToCommon"),
            "cash": data.info.get("totalCash")
            }
        # result[item] means i create a dictionary for each item (ticker) with the information
    return result



def calculate_multiples(financials: dict):
    multiples = {} # another empty dictionary created to store the results
    for ticker, data in financials.items():
        # ticker, data lets me grab both the outer group (a single ticker string from the list) and the data for each group

        ev = data["market_cap"] + data["total_debt"] - data["cash"]
        multiples[ticker] = {
            "Enterprise Value": ev,
            "EV/EBITDA": ev / data["ebitda"],
            "P/E ratio": data["market_cap"] / data["net_income"],
            "P/B ratio": data["market_cap"] / (data["book_value"] * data["shares_outstanding"]),
            "Current Price": data["market_cap"] / data["shares_outstanding"]
        }
        # same principle as before: multiples[ticker] is a "section" of the dictionary for each ticker (company)

    return multiples


financials = (get_financials(tickers=ticker_input))
multiples = calculate_multiples(financials)

def build_comps_table(multiples: dict):
    dataset = pd.DataFrame.from_dict(multiples, orient="index").round(2)

    return dataset

comps = build_comps_table(multiples=multiples)

def implied_valuation(target: str, financials: dict, multiples: dict):
    not_target_dict = {}
    for item, data in multiples.items(): #item = the outer space (Ticker), #data = inner space (info for each ticker)
        if item != target:
            not_target_dict[item] = data
            continue
    medians = pd.DataFrame.from_dict(not_target_dict, orient="index").median()

    implied_ev = medians["EV/EBITDA"] * financials[target]["ebitda"]
    impl_ev_price = (implied_ev - financials[target]["total_debt"] + financials[target]["cash"]) / financials[target]["shares_outstanding"]
    impl_pe_price = (medians["P/E ratio"] * financials[target]["net_income"]) / financials[target]["shares_outstanding"]
    impl_pb_price = medians["P/B ratio"] * financials[target]["book_value"]
    current_price = multiples[target]["Current Price"]

    output =  {
        "Current Price": current_price,
        "Implied P/B price": impl_pb_price,
        "Implied P/E price": impl_pe_price,
        "Implied E/V price": impl_ev_price
    }
    dataset = pd.DataFrame.from_dict(output, orient="index").round(2)
    dataset.columns = [f"Value for {target}"]
    return dataset

valuation = implied_valuation(target="AAPL",financials=financials, multiples=multiples)

def export_to_excel(comps: pd.DataFrame, valuation:pd.DataFrame,filename:str):
    with pd.ExcelWriter(filename, engine="openpyxl") as writer:
        comps.to_excel(writer, sheet_name="comps")
        valuation.to_excel(writer, sheet_name="valuation")

export_to_excel(comps=comps, valuation=valuation, filename="output.xlsx")
