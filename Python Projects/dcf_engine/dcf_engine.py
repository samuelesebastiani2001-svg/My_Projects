import openpyxl as op
from dcf_functions import compute_dcf
from dcf_functions import write_excel_table


ticker = ["AAPL", "TSLA", "MSFT"]

##-----------------------------##
# INPUTS
growth_rate_steps = 8
discount_rate_steps = 10
lowest_growth_rate = 0.02
lowest_discount_rate = 0.07
sensitivity_step = 0.01
growth_rates = [round(lowest_growth_rate + i * sensitivity_step, 2) for i in range(growth_rate_steps)]
discount_rates = [round(lowest_discount_rate + i * sensitivity_step, 2) for i in range(discount_rate_steps)]

##-----------------------------##
# Excel spreadsheet
wb = op.Workbook()
del wb[wb.sheetnames[0]]
ws = wb.active
##-----------------------------##
##-----------------------------##
# Extracting information and making an Excel Spreadsheet for each company
for item in ticker:
    results = compute_dcf(ticker=item)
    ws = wb.create_sheet(title=f"DCF Model {results["ticker"]}")
    write_excel_table(results=results, growth_rates=growth_rates, discount_rates=discount_rates, ws=ws)

wb.save(f"{ticker}_DCF.xlsx")
##-----------------------------##



