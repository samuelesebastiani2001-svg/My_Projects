#-----------------------#
import yfinance as yf
from openpyxl.styles import Font
#-----------------------#
# info_calculator is a function that takes the information from the firm
# and computes its share value,
# given the assumptions of growth rates and discount rates
# the information can be obtained by using the other function, dcf_data_collector


def info_calculator(fcf_last, projection_years, growth_rate, discount_rate, terminal_growth_rate, total_debt, cash, shares_outstanding):
    projected_fcf = []
    for n in range(projection_years):
        fcf_last = fcf_last * (1+growth_rate)
        projected_fcf.append(fcf_last)

    terminal_value = projected_fcf[-1] * (1 + growth_rate) / (discount_rate - terminal_growth_rate)
    present_value_fcf = []
    for n in range(len(projected_fcf)):
        present_value_fcf.append(projected_fcf[n] / (1+discount_rate)**(n+1))
    present_value_fcf.append(terminal_value / (1+discount_rate)**(projection_years))
    total_present_value = sum(present_value_fcf)
    share_price = (total_present_value - total_debt + cash) / shares_outstanding

    return share_price
#-----------------------#
# compute.dcf is a function that takes the ticker object fetches/computes basic information about the company.
# the outputs are:
# Risk-free rate, cost of equity and cost of debt, wacc, list of cash flows and the implied share price,
#-----------------------#
def compute_dcf (ticker, projection_years = 5, dcf_growth_rate = 0.05, dcf_terminal_growth = 0.025, market_return = 0.1):

    data = yf.Ticker(ticker)
    balance_sheet = data.balance_sheet
    cashflow = data.cashflow
    income_stmt = data.income_stmt
    fcf = cashflow.loc["Free Cash Flow"].dropna()
    last_fcf = fcf.iloc[0]
    original_fcf = fcf.iloc[0] # saves it so only last_fcf is modified

    interest_exp = abs(income_stmt.loc["Interest Expense"].dropna().iloc[0])
    total_debt = balance_sheet.loc["Total Debt"].dropna().iloc[0]
    tax_rate = income_stmt.loc["Tax Rate For Calcs"].dropna().iloc[0]
    equity_cap = data.info.get("marketCap")
    beta = data.info.get("beta")
    data_rf = yf.Ticker("^TNX")
    risk_free = data_rf.info.get("regularMarketPrice") / 100

    ### COMPUTING WACC ###
    # WACC = Ke * (E/V) + Kd * (D/V) * (1 - t)
    # Ke = cost of equity, Kd = cost of debt, t = taxation

    equity_cost = risk_free + beta * (market_return - risk_free)  # cost of equity (Ke)
    debt_cost = interest_exp / total_debt  # cost of debt (Kd)
    market_value = equity_cap + total_debt  # V

    wacc = equity_cost * (equity_cap / market_value) + debt_cost * (total_debt / market_value) * (1 - tax_rate)

    ### DISCOUNTED CASH FLOW ###
    # list of free cash flows for projection years
    fcf_list = []
    for n in range(projection_years):
        last_fcf = last_fcf * (1 + dcf_growth_rate)
        fcf_list.append(last_fcf)

    # computing Terminal Value
    terminal_value = fcf_list[-1] * (1 + dcf_terminal_growth) / (wacc - dcf_terminal_growth)

    # computing the present value of all cash flows
    pv_cashflows = []
    for n in range(len(fcf_list)):
        pv_cashflows.append(fcf_list[n] / (1 + wacc) ** (n + 1))
    pv_cashflows.append(terminal_value / (1 + wacc) ** projection_years)
    total_pv = sum(pv_cashflows)

    ### IMPLIED SHARE PRICE ###
    cash = balance_sheet.loc["Cash And Cash Equivalents"].dropna().iloc[0]
    shares_outstanding = data.info.get("sharesOutstanding")
    share_price = (total_pv - total_debt + cash) / shares_outstanding

    return {
        "ticker": ticker,
        "beta": beta,
        "risk_free": risk_free,
        "equity_cost": equity_cost,
        "debt_cost": debt_cost,
        "wacc": wacc,
        "fcf_list": fcf_list,
        "terminal_value": terminal_value,
        "cash": cash,
        "shares_outstanding": shares_outstanding,
        "share_price": share_price,
        "projection_years": projection_years,
        "dcf_growth_rate": dcf_growth_rate,
        "dcf_terminal_growth": dcf_terminal_growth,
        "total_debt": total_debt,
        "original_fcf": original_fcf,
        "total_pv": total_pv
    }

#-----------------------#
#-----------------------#
# write_excel_table is a function that takes the information produced from compute_dcf
# and produces an excel spreadsheet.
# it also takes results as well as a list of growth and discount rates
# and produces a table of implied share prices for each combination.
#-----------------------#
def write_excel_table(results, ws, discount_rates, growth_rates):
    ws.column_dimensions["A"].width = 25
    ws.column_dimensions["B"].width = 20
    ws.title = f"DCF Model for {results["ticker"]}"
    ws["A1"] = "DCF valuation model"
    ws["A1"].font = Font(bold=True)
    ws["A3"] = "INPUTS"
    ws["A3"].font = Font(bold=True)
    ws["A4"] = "Ticker"
    ws["B4"] = results["ticker"]
    ws["A5"] = "Beta"
    ws["B5"] = results["beta"]
    ws["A6"] = "Cost of Equity"
    ws["B6"] = results["equity_cost"]
    ws["A7"] = "Cost of debt"
    ws["B7"] = results["debt_cost"]
    ws["A8"] = "WACC"
    ws["B8"] = results["wacc"]
    ws["A9"] = "Growth rate"
    ws["B9"] = results["dcf_growth_rate"]
    ws["A10"] = "Terminal growth rate"
    ws["B10"] = results["dcf_terminal_growth"]

    # Outputs
    ws["A12"] = "OUTPUTS"
    ws["A12"].font = Font(bold=True)
    ws["A13"] = "Implied share price"
    ws["B13"] = results["share_price"]
    ws["A14"] = "Enterprise value"
    ws["B14"] = results["total_pv"]
    ws["A15"] = "Terminal value"
    ws["B15"] = results["terminal_value"]

    # PROJECTED FCF
    ws["A17"] = "projected FCFs"
    for n in range(len(results["fcf_list"])):
        ws.cell(row=18 + n, column=1, value=f"Year {n + 1}")
        ws.cell(row=18 + n, column=2, value=results["fcf_list"][n])

    sensitivity_table = []
    for growth in growth_rates:
        row_growth_rate = []
        for discount in discount_rates:
            price = info_calculator(fcf_last=results["original_fcf"],
                                   projection_years=results["projection_years"],
                                   growth_rate=growth,
                                   discount_rate=discount,
                                   total_debt=results["total_debt"],
                                   terminal_growth_rate=results["dcf_terminal_growth"],
                                   cash=results["cash"],
                                   shares_outstanding=results["shares_outstanding"])
            row_growth_rate.append(price)
        sensitivity_table.append(row_growth_rate)

    ws["B25"] = "Sensitivity Table"
    ws["B25"].font = Font(bold=True)
    for n in range(len(discount_rates)):
        ws.cell(row=26, column=3 + n, value=discount_rates[n])
    for n in range(len(growth_rates)):
        ws.cell(row=27 + n, column=2, value=growth_rates[n])
        # i = values from 0 to 7, for each row of the table. each "i" has a fixed growth rate and different discount rate.
        # j = values from 0 to 7, for each item INSIDE THE ROW [i]. has the same discount rate and different growth rate.

    for i in range(len(sensitivity_table)):
        for j in range(len(sensitivity_table[i])):
            ws.cell(row=27 + i, column=3 + j, value=sensitivity_table[i][j]).number_format = "0.00"
#-----------------------##-----------------------##-----------------------#
