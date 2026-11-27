# Euro-Area Macro Dashboard: Italy, Germany, France, Spain (Excel)

An interactive macroeconomic dashboard built on official Eurostat and ECB data (2010–2026). A single dropdown switches every table, chart and regression between Italy, Germany, France, Spain and the euro area. The workbook also tests two classic macro relationships on real data: **Okun's law** (GDP growth vs unemployment) and the **Taylor rule** (Computing the CB interest rate and following the difference w.r.t. the deposit rates set by the European Central Bank).

## Features
- **Dashboard**
  - Country dropdown driving the whole workbook
  - KPI table for GDP growth, HICP inflation, unemployment, 10-year government bond yield, spread vs the German Bund and the ECB deposit rate: latest value and date, value one year earlier, change, minimum and maximum since 2010, and gap vs the euro area
  - Five charts with dynamic titles: GDP growth, inflation, unemployment, 10Y yields with the ECB rate, and the spread vs the Bund
- **Okun's law**
  - Quarterly regression of the change in unemployment (pp, y/y) on real GDP growth (% y/y) for the selected country
  - Slope, intercept, R², number of observations and the growth rate that keeps unemployment stable (−α/β)
  - Switch to exclude the COVID quarters (2020–2021), when job-retention schemes broke the usual relationship
  - Scatter plot with trend line and a regression label linked to the results cells, so it updates with the country
- **Taylor rule**
  - Euro-area policy rate implied by i = r\* + π + 0.5 × (π − π\*) + 0.5 × growth gap, against the actual ECB deposit rate
  - Editable parameters (neutral rate, inflation target, weights, potential growth)
  - Latest implied vs actual rate, and the quarter in which the ECB was most "behind the curve"
- **Data layer**
  - Monthly data (inflation, unemployment, 10Y yields, ECB rate) and quarterly GDP growth as downloaded
  - Spreads vs the Bund computed in basis points
  - Monthly series converted into quarterly averages (unemployment, inflation) and quarter-end values (ECB rate)


Spain's labour market is the most sensitive to growth (many temporary contracts), while Germany's barely reacts (short-time work schemes keep workers employed). Italy needs only about 0.4% growth to keep unemployment stable, close to estimates of its potential growth.

**Taylor rule (euro area)**
- Largest gap: **Q2 2022**, when inflation averaged 8.1% and the deposit rate was still −0.50%. The rule implied 13.25%, so policy was **13.75 pp looser** than the rule: the ECB was behind the curve before its 2022–2023 hiking cycle.
- Latest quarter (Q3 2026): rule 4.60% vs actual 2.50%, a gap of −2.10 pp, as inflation picks up again.

## Workbook structure
| Sheet | Contents |
|---|---|
| **Dashboard** | Country selector, KPI table with helper columns, summary charts, country lists |
| **Okun's Law** | Quarterly table, COVID switch, regression results and scatter plot |
| **Taylor Rule** | Parameters, quarterly Taylor rate vs ECB rate, results box and chart |
| **Chart_data** | Helper columns feeding the Dashboard charts for the selected country |
| **Quarterly_data** | GDP growth, quarterly averages of unemployment and inflation, quarter-end ECB rate |
| **Monthly_data** | Monthly series from Eurostat and the ECB, plus computed spreads vs the Bund |


## Data and assumptions
- **Sources**
- The data is downloaded by `get_macro_data.py` (Python, `requests` + `pandas`) into `macro_data.xlsx`, then pasted into the data sheets.
- **Okun's law** uses quarterly averages of monthly unemployment, so that both variables are year-on-year and cover the same period.
- **Taylor rule** parameters follow Taylor (1993): weights of 0.5 on the inflation and growth gaps, an inflation target of 2%, a neutral real rate r\* of 0.5% and potential growth of 1%. The output gap is proxied by GDP growth minus potential growth, a simplification of the true output gap (actual vs potential GDP level). r\* and potential growth cannot be observed and are assumptions; the 2022 result holds for any reasonable choice.

## How to use
1. Choose a country in the Dashboard dropdown. The KPIs, charts and Okun regression update.
2. On the Okun sheet, switch the COVID exclusion on or off to see its effect on the slope and R².
3. On the Taylor sheet, change the yellow parameters to test other assumptions.
4. To update the data, run `get_macro_data.py` and paste the new Monthly and Quarterly sheets into `Monthly_data` and `Quarterly_data`.

