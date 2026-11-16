# Loan & Mortgage Amortization Model (Excel)

An Excel model that builds a full amortization schedule for any fixed-rate loan or mortgage, summarizes it year by year, and shows how much interest and time you save by paying extra every period.

## Features
- **Fixed payment calculation** for any loan amount, interest rate, term and payment frequency (annual, semi-annual, quarterly or monthly)
- **Dynamic amortization schedule**: one row per payment, with payment dates, interest, principal, extra payment and remaining balance. Rows switch off automatically once the loan is paid off.
- **Extra-payment analysis**: compares results with and without an extra payment per period (total interest, total paid, payoff date, time saved)
- **Annual review**: principal and interest paid in each calendar year, ending balance and interest share of payments
- **Charts**: interest vs principal paid each year (stacked column) and the remaining balance by year

## Example: $250,000 · 4.5% · 25 years · monthly payments
| | No extra payment | +$200 per month |
|---|---|---|
| Payment per period | $1,389.58 | $1,589.58 |
| Number of payments | 300 | 239 |
| Payoff date | Jan 2051 | Dec 2045 |
| Total interest paid | $166,874 | $128,416 |
| Interest saved | – | $38,458 (23%) |
| Time saved | – | 5.1 years |

## Workbook structure
| Sheet | Contents |
|---|---|
| **INPUTS** | Input cells with notes, results without extra payment and results with extra payment |
| **Amortization schedule** | The full payment-by-payment schedule |
| **Annual Review** | Yearly totals and charts |

## Excel skills used
- **Financial functions**: `PMT`
- **Logic**: nested `IF` statements to switch rows off once the balance reaches zero, and `MIN`/`MAX` to cap the final payment
- **Dates**: `EDATE` for payment dates, `YEAR` to group payments by calendar year
- **Aggregation**: `SUMIFS` to build the annual review from the schedule, plus `SUM` and `MAX`
- **Model design**: named ranges (e.g. `LoanAmt`, `PER.IR`, `PER.Payment`), absolute and relative references, separate input / calculation / output areas, formulas instead of hard-coded values
- **Usability**: data validation (dropdown for the payment frequency), freeze panes, charts

## How to use
1. Open `Loan_Amortization_Model.xlsx` and go to the **INPUTS** sheet.
2. Enter the loan amount, annual interest rate, term (years), payments per year and start date.
3. Optionally enter an **extra payment** per period to see the new payoff date and how much interest you save.
4. The schedule, annual review and charts update automatically.

## Tools
Microsoft Excel (formulas only, no macros or VBA).
