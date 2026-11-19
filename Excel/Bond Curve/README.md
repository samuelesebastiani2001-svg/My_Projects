# Bond Pricing & Yield Curve (Excel)

An Excel model that prices government bonds, measures their interest-rate risk and values a small bond portfolio off a yield curve. It covers the core tools of a fixed-income desk: price ↔ yield, accrued interest, duration, convexity, DV01 and rate-shock scenarios.

## Features
- **Bond calculator**: clean and dirty price, accrued interest, yield to maturity, Macaulay and modified duration, **convexity** and DV01, plus remaining coupons and coupon dates.
- **Self-checking**: every result is computed twice, with Excel's bond functions (`PRICE`, `DURATION`) and from a full **cash-flow table** (dates, time to each payment, discount factors, present values). The two must agree.
- **Price-yield table and chart**: the exact price compared with the duration-only and duration + convexity approximations, for yield shifts from −250 to +250 bp. Convexity shows up as the gap between the curve and the straight line.
- **Yield curve**: government bond yields from 1 to 30 years, discount factors, 2s10s and 10s30s slopes, an automatic shape label (normal / flat / inverted) and a chart with a dynamic title.
- **Bond portfolio**: 5 bonds, each priced at the curve yield for its maturity (**linear interpolation** between curve points), with market value, modified duration, DV01 and portfolio totals.
- **Parallel-shift scenario**: every bond is re-priced with yields up and down by a chosen shift. The model compares the exact P&L with the duration estimate, which shows the effect of convexity.

## Results (settlement 19/11/2026, illustrative curve)
| Metric | Value |
|---|---|
| Example bond: 3.50% 01-Mar-2034, semi-annual, yield 3.20% | clean price 101.93 · dirty 102.70 · modified duration 6.35 · convexity 46.75 |
| Portfolio market value | €27.4m |
| Portfolio modified duration | 4.92 |
| Portfolio DV01 | €13,505 per bp |
| Yields +100 bp | P&L −€1,278,292 (duration estimate −€1,350,521) |
| Yields −100 bp | P&L +€1,431,695 (duration estimate +€1,350,521) |

A fall in yields gains more than the same rise loses. That asymmetry is convexity, and it favours the bondholder.

## Workbook structure
| Sheet | Contents |
|---|---|
| **Bond Calculator** | Inputs, results, cross-checks and the cash-flow table for one bond |
| **Price yield chart** | Price vs yield: the exact price, the duration approximation, duration + convexity, and their errors |
| **Yield Curve** | Yields by maturity, discount factors, curve slope and shape, and the chart |
| **Portfolio** | 5 bonds priced off the curve, risk measures, and the parallel-shift scenario |

## Excel skills used
| Area | Functions and techniques |
|---|---|
| Bond functions | `PRICE`, `YIELD`, `DURATION`, `MDURATION`, `COUPNUM`, `COUPNCD`, `COUPPCD`, `COUPDAYS`, `COUPDAYBS`, `COUPDAYSNC`, `YEARFRAC`, `EDATE` |
| Lookups and interpolation | `MATCH` (approximate match on a sorted list), `INDEX`, linear interpolation between curve points, `IFERROR` / `MIN` / `ROWS` as safety nets |
| Aggregation | `SUM`, `SUMPRODUCT` (market-value-weighted duration) |
| Model design | named ranges, one input cell per assumption, cross-checks between two independent methods, a scenario driven by a single input cell |
| Presentation | scatter charts, a dynamic chart title built with `&`, number formats for prices, yields and basis points |

## Data and assumptions
- **The yields on the Yield Curve sheet are illustrative.** They have the usual shape of the euro-area government curve. Replace them with real market yields (for example the ECB euro-area yield curve, or BTP / Bund yields) and the whole portfolio reprices automatically.
- The portfolio bonds are fictional and pay **one coupon a year**. The example bond in the calculator pays twice a year, like an Italian BTP.
- Day count: **Actual/Actual** (basis 1), the convention for euro government bonds.
- The scenario is an **instantaneous parallel shift**: every yield moves by the same amount and no time passes.

## How to use
1. **Bond Calculator:** change the maturity, coupon, frequency or yield. Every result, the cash-flow table and the chart update.
2. **Yield Curve:** type in today's yields for the 9 maturities.
3. **Portfolio:** edit the bonds (coupon, maturity, nominal) and change the **shift** (bp) to test different rate moves.

## Tools
Microsoft Excel (formulas only, no macros).
