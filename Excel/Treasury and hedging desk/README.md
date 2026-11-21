# Treasury & Hedging Desk (Excel)

An Excel model of a corporate trading and treasury desk that hedges currency and energy risk with OTC contracts. It covers the daily workflow of a junior trader: monitoring the markets, recording FX forwards and commodity swaps, valuing open positions at market prices, rolling maturing hedges, and reporting everything on one dashboard.

## Features
- **Market monitor**: equities (FTSE MIB, Euro Stoxx 50, S&P 500), FX (EUR/USD, EUR/GBP, EUR/CHF), commodities (Brent, TTF gas, gold) and rates (Euribor, BTP, Bund, US Treasury), with 1-day, 1-week, 1-month and year-to-date moves (% for prices, basis points for rates), green/red formatting, the **BTP–Bund spread** and the day's biggest mover.
- **OTC contract blotter**: FX forwards and commodity swaps with their terms, confirmation status, days to maturity and maturity bucket.
  - **Forward price** from covered interest parity: spot × (1 + r_foreign × days/360) / (1 + r_EUR × days/360)
  - **Mark-to-market** in euros for every open contract, discounted to today
  - Closed deals (settled, rolled or expired) drop out of the risk figures automatically
- **Rollover calculator**: pick a maturing deal and a new maturity date. The model shows the close-out P&L at spot, the new forward rate and the forward points.
- **Dashboard**: open deals, total MTM, deals awaiting confirmation, deals maturing this week, a maturity ladder (count and MTM by bucket), net position and MTM by underlying, and a chart.

## Example output (valuation date 20/11/2026)
| Metric | Value |
|---|---|
| Open deals | 7 |
| Total MTM of open deals | −€102,140 |
| Deals awaiting confirmation | 2 |
| Deals maturing this week | 1 |
| Net EUR/USD position | +$3.5m bought forward |
| Net TTF gas position | +35,000 MWh hedged |
| BTP–Bund spread | 72 bp |
| Example rollover (D001) | close-out −€19,609 · new 98-day forward 1.1640 (+60 pips) |

## Workbook structure
| Sheet | Contents |
|---|---|
| **Market monitor** | Watch list with price and rate moves, spreads, and the money-market rates used for forward pricing |
| **OTC contracts** | Deal blotter: terms, confirmation status, maturity bucket, forward price, discount factor, MTM |
| **Rollover** | Close-out and re-pricing of a maturing contract |
| **Dashboard** | Summary figures, maturity ladder, exposure and MTM by underlying, chart |

## Excel skills used
| Area | Functions and techniques |
|---|---|
| Lookups | `INDEX`/`MATCH` (prices by instrument, deal details by ID), `RIGHT`/`LEFT` to read currency codes |
| Aggregation | `SUMIFS`, `COUNTIFS`, `COUNTIF` with several conditions (`"<>"`, `"<>Closed"`) |
| Logic | nested `IF`, `OR` for status and maturity buckets |
| Pricing | covered interest parity, discount factors, MTM for forwards and swaps |
| Model design | named ranges, one input area driving every sheet, closed deals handled automatically |
| Presentation | custom number formats (+/−, bp), conditional formatting (whole-row rules with formulas), data validation dropdowns, charts, sentences built with `&` and `FIXED` |

## Data and assumptions
- **Market prices and interest rates are illustrative.** Replace them with real closing prices: `get_market_data.py` downloads equities, FX and commodities from Yahoo Finance. Euribor, BTP and Bund yields must be typed in by hand.
- **The deals and counterparties are fictional.**
- Commodity forwards are approximated by today's market price (a real desk would use the futures curve). Brent MTM is converted from USD to EUR at spot.
- Money-market convention: simple interest, Act/360.

## How to use
1. **Market monitor:** update the prices and the valuation date. Every sheet revalues automatically.
2. **OTC contracts:** add new deals in the input columns, and update their confirmation status as they are confirmed or settled.
3. **Rollover:** choose a deal and a new maturity date to see the close-out P&L and the new forward rate.
4. **Dashboard:** check open risk, upcoming maturities and the deals that need action.

## Tools
Microsoft Excel (formulas only, no macros) · Python (`yfinance`) for the market-data download.
