# DCF Valuation: Apple Inc. (Excel)

A discounted cash flow (DCF) model of Apple (AAPL) built on real financial statements. It projects five years of unlevered free cash flow, discounts it at a WACC derived from CAPM, adds a Gordon-growth terminal value and walks from enterprise value to a value per share, which is then compared with the market price. A sensitivity table shows how the result changes with the two most important assumptions.

## Features
- **Historical data (FY2023–FY2026)**: revenue, EBIT, D&A, capex, receivables, inventory, payables, debt, cash and taxes downloaded from Yahoo Finance, with derived EBITDA, net working capital, net debt, margins and effective tax rate.
- **Assumptions sheet**: revenue growth, EBITDA margin, D&A, capex and NWC as a % of revenue for 2027E–2031E, each with a note explaining how it was chosen from the historical ratios.
- **WACC**: cost of equity from CAPM (US 10-year Treasury as risk-free rate, Yahoo beta, equity risk premium), cost of debt as risk-free rate + credit spread, after-tax cost of debt, market-value capital weights.
- **Free cash flow**: revenue → EBITDA → EBIT → NOPAT → + D&A − capex ± change in NWC = **unlevered free cash flow**, shown next to the historical years with growth and FCF margins.
- **Valuation**:
  - Discount factors 1/(1+WACC)^t and present value of each year's cash flow
  - Terminal value with the Gordon growth formula: FCF₂₀₃₁ × (1+g) / (WACC − g)
  - Implied exit multiple (TV / final-year EBITDA) as a sanity check on the terminal value
  - Bridge from enterprise value to equity value (− debt + cash) and value per diluted share
  - Upside/downside against the market price, and the terminal value's share of EV
- **Sensitivity table**: value per share for WACC ±2% and terminal growth 1.5%–3.5%. Every cell recomputes the full DCF (cash flows and terminal value) at its own WACC and g.

## Results (valuation date 30/09/2026, $ billions)
| Metric | Value |
|---|---|
| WACC | 10.24% |
| Terminal growth rate | 2.5% |
| PV of 2027E–2031E cash flows | 604.7 |
| PV of terminal value | 1,520.1 |
| Enterprise value | 2,124.8 |
| Equity value | 2,101.4 |
| **Value per share** | **$142.76** |
| Market price | $349.08 |
| Upside / downside | −59% |
| Terminal value as % of EV | 72% |
| Implied exit multiple (TV / EBITDA 2031) | 9.8x |

**Sensitivity of value per share ($)**

| WACC \ g | 1.5% | 2.0% | 2.5% | 3.0% | 3.5% |
|---|---|---|---|---|---|
| 8.24% | 170.5 | 181.5 | 194.4 | 209.7 | 228.3 |
| 9.24% | 147.6 | 155.6 | 164.7 | 175.3 | 187.8 |
| **10.24%** | 130.1 | 136.0 | **142.8** | 150.4 | 159.2 |
| 11.24% | 116.1 | 120.7 | 125.8 | 131.6 | 138.1 |
| 12.24% | 104.7 | 108.4 | 112.4 | 116.8 | 121.8 |

**Interpretation.** With US 10-year yields near 5%, the WACC is above 10%, and the model values Apple far below its market price. The implied exit multiple of about 10x EBITDA, compared with roughly 30x for Apple today, shows that the gap comes from the terminal assumptions: even the most generous corner of the sensitivity table ($228) is below the market price. The market is therefore pricing either a much lower cost of capital or high growth and margins lasting well beyond the five-year forecast.

## Workbook structure
| Sheet | Contents |
|---|---|
| **AAPL_Data** | Historical financial statements and derived ratios (growth, margins, D&A, capex and NWC as % of revenue) |
| **Inputs** | Company data, valuation date, operating assumptions 2027E–2031E, cost of capital and terminal growth |
| **Wacc** | Cost of equity (CAPM), after-tax cost of debt, capital weights, WACC |
| **FCF** | Historical and projected income items, NOPAT, capex, NWC and unlevered free cash flow, FCF chart |
| **Data valuation** | Discounting, terminal value, EV-to-equity bridge, value per share, upside/downside, sensitivity table |

## Excel skills used
| Area | Functions and techniques |
|---|---|
| Lookups | `INDEX`/`MATCH` with exact match to pull cash flows by year |
| Finance | CAPM, WACC, discount factors, Gordon growth terminal value, EV-to-equity bridge |
| Arrays | `SUMPRODUCT` to discount a whole row of cash flows in one formula |
| Sensitivity analysis | two-way table with mixed references (`$B40`, `D$39`) recomputing the full DCF per cell |
| Model design | named ranges (`wacc`, `Terminal_GR`, `Tax_rate`, `Shares_billions`…), inputs separated from calculations, consistent sign convention, notes beside every assumption |
| Presentation | dynamic labels built with `&`, custom number formats (`x` multiples, %), charts |

## Data and assumptions
- **Financial statements** come from Yahoo Finance via `get_apple_data.py` (`yfinance`). Figures are in $ billions; Apple's fiscal year ends in late September.
- **Risk-free rate**: US 10-year Treasury yield (4.89%, 24/11/2026). Equity risk premium 5%, beta 1.089 (Yahoo). Credit spread 0.6% over the risk-free rate (Apple is rated AA+).
- **Capital weights**: current market values (debt / (debt + market cap)) used as the target structure, giving about 1.5% debt.
- **Tax rate**: average effective tax rate FY2023–FY2026 (17.9%).
- **Growth** fades from 10% to 6% over the forecast; the EBITDA margin rises from 35% to 36%; D&A and capex use their historical averages.
- **Net working capital** is negative for Apple (suppliers finance its operations). It is assumed to normalise from −4% to 0% of revenue by 2031, which absorbs cash every year and is a conservative choice.
- **Net debt** uses cash and short-term investments only. Apple's long-term marketable securities are excluded; including them would raise the value by about $6 per share.

## How to use
1. Run `get_apple_data.py` (or pass another ticker) and paste the output into **AAPL_Data**.
2. Update the valuation date, share price and risk-free rate in **Inputs**.
3. Change the blue assumptions in **Inputs** to test your own view. Every sheet recalculates.
4. Read the value per share, upside/downside and sensitivity table in **Data valuation**.

## Tools
Microsoft Excel (formulas only, no macros) · Python (`yfinance`) for the financial data download.
