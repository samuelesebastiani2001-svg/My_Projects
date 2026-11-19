# Bond Pricing & Yield Curve (Excel)

An Excel model that prices government bonds, measures their interest-rate risk and values a small bond portfolio off a yield curve. It covers the core tools of a fixed-income desk: price, yield, accrued interest, duration, convexity, DV01 and rate-shock scenarios.

## Features
- **Bond calculator**: clean and dirty price, accrued interest, yield to maturity, standard and modified duration, convexity and DV01.
- **Price-yield table and chart**: the exact price for the bond compared with the duration-only and duration + convexity approximations, for yield shifts from −250 to +250 bp.
- **Yield curve**: government bond yields from 1 to 30 years, discount factors and slopes. 
- **Bond portfolio**: 5 bonds, each priced at the curve yield for its maturity (**linear interpolation** between curve points), with market value, modified duration, DV01 and portfolio totals.
- **Parallel-shift scenario**: every bond is re-priced with yields up and down by a chosen shift. The model compares the exact P&L with the duration estimate, which shows the effect of convexity.

## Workbook structure
| Sheet | Contents |
|---|---|
| **Bond Calculator** | Inputs, results, cross-checks and the cash-flow table for one bond |
| **Price yield chart** | Price vs yield: the exact price, the duration approximation, duration + convexity, and their errors |
| **Yield Curve** | Yields by maturity, discount factors, curve slope and shape, and the chart |
| **Portfolio** | 5 bonds priced off the curve, risk measures, and the parallel-shift scenario |


## Data and assumptions
- **The yields on the Yield Curve sheet are illustrative.** They have the usual shape of the euro-area government curve. Replace them with real market yields (for example the ECB euro-area yield curve, or BTP / Bund yields) and the whole portfolio reprices automatically.
- The portfolio bonds are fictional and pay **one coupon a year**. The example bond in the calculator pays twice a year, like an Italian BTP.
- Day count: **Actual/Actual** (basis 1), the convention for euro government bonds.
- The scenario is an **instantaneous parallel shift**: every yield moves by the same amount and no time passes.

