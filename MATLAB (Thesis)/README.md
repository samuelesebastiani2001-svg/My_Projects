# Monte Carlo Evaluation of External-Instrument SVAR and Local Projections

**BOTH MATLAB AND DYNARE ARE NEEDED TO RUN THE SCRIPT**

MATLAB code for the Monte Carlo experiments in my master's thesis (Applied Economics and Markets).
The script evaluates how well a monetary policy shock and its impulse responses (IRFs) are recovered when the shock is identified with a **noisy external instrument** (proxy-SVAR / SVAR-IV), and compares two ways of using a partially available instrument in a **Local Projection (LP)** framework: the *Short* and the *Long* method.

The data generating process (DGP) is a New Keynesian model with Calvo pricing, solved and simulated with Dynare. The "true" IRFs come directly from the model, so every estimator can be benchmarked against the truth.

---

## Repository contents

| File | Description |
|---|---|
| `Thesis_full.m` | Main script: runs the whole project and produces all figures and summary statistics. |
| `LP_longdiff_IRF.m` | Code that computes the IRF function in the local-projections called by the script (**must be on the MATLAB path --> change it to your path in at the start**). |
| `NK_noK_CRS.mod` | Dynare model (NK, Calvo pricing) used as DGP (**must be run before the script**). |
| `oo_.mat`, `M_.mat` | Dynare output structures saved from the model run, loaded by the script. |

---

## What the script does

### Part 1: Proxy-SVAR Monte Carlo

For each of the `simulations` replications (each with `T` observations):

1. Estimate a reduced-form **VAR(p)** on `[y, R, Pi]` (output, interest rate, inflation) by OLS.
2. Identify the monetary policy **impact vector** from the covariance between the VAR residuals and the external instrument `z_t`.
3. Build the IRFs recursively from the VAR companion coefficient matrices. IRFs are normalised so that the impact response of `R` equals the true one from Dynare.
4. Reconstruct the structural shock from the instrument and compute its correlation with the true shock. The raw correlation between the instrument and the true shock is also stored as a relevance diagnostic.

The instrument is generated internally:

```
z_t = zt_rel * em_t + zt_noise * eta_t * std(zt_rel * em_t),   eta_t ~ N(0,1)
```

An optional fraction of the instrument observations can be randomly set to zero (`params.zeros`) to mimic an instrument that is only available for part of the sample.

**Outputs of Part 1**

- Figure: true vs. mean estimated IRFs, with Monte Carlo quantile bands (5–95% and 16–84%).
- Figure: distribution of `corr(em_hat, em)` and `corr(z, em)` across simulations.
- Console table: average bias and RMSE of the IRFs by variable, plus mean/std of the shock and instrument correlations.

### Part 2: Short vs. Long Local Projections

- **Short method**: LP of each variable on the instrument, estimated on the short sample only.
- **Long method**: the instrument on the short sample is used to project the VAR residuals and recover the structural shock (`em_hat`) over the **full** sample. The LP is then run on the full sample using `em_hat` as the regressor.

The parameter "alpha" is related to the ratio between the sample size of the instrument over the sample size of the other variables. If "alpha" is less than one, the Short method (which uses the raw instrument) will have less sample available.

For each variable and horizon the script computes **variance, bias and MSE** of the two methods against the true Dynare IRFs:

- `VarRatio`: ratio of IRF variances (> 1 means the Short method is better, < 1 means the Long method is better).
- `BiasRatio`: ratio of RMS bias (< 1 means the Long method is less biased).
- `MSERatio`: ratio of total MSE (< 1 means the Long method has lower total error).

---

## Requirements

- **MATLAB**.
- **Dynare**. The script adds Dynare to the path with a hard-coded line:
  ```matlab
  addpath('/Applications/Dynare/6.5-x86_64/matlab')
  ```
  Edit this line to match your own Dynare installation path.

---

## Main parameters

All parameters are set at the top of `Thesis_full.m`.

| Parameter | Default | Meaning |
|---|---|---|
| `T` | 250 | Observations per simulated sample |
| `simulations` | 2000 | Number of Monte Carlo replications |
| `p` | 2 | VAR lag order (also used for the LP controls) |
| `H` / `horz` | 33 | IRF horizon |
| `nvar` / `N` | 3 | Number of variables (`y`, `R`, `Pi`) |
| `params.zt_rel` | 1 | Weight of the true shock in the instrument (relevance) |
| `params.zt_noise` | 0.5 | Weight of the added noise, relative to the signal |
| `params.zeros` | 0 | Fraction of instrument observations randomly set to zero, in [0, 1) |
| `q_outer`, `q_inner` | [0.05 0.95], [0.16 0.84] | Quantiles for the Monte Carlo bands |
| `alpha` | 0.5 | Short/long sample ratio (Part 2) |
| `longdiff`, `lineardetrend` | `false`, `false` | Options passed to `LP_longdiff_IRF` |


Basic input checks (`assert`) are included for `params.zeros`, `params.zt_rel`, `params.zt_noise` and `T > p`.

---

## Outputs

**Figures**

1. True vs. mean estimated IRFs with Monte Carlo quantile bands (Part 1).
2. Distribution of the correlation between estimated/true shock and instrument/true shock.
3. Average IRFs of the Short and Long LP methods vs. the true IRFs.
4. Variance of the IRF estimates, Short vs. Long.
5. Variance / bias / MSE by horizon, for each variable (3×3 grid).

**Console output**

- Part 1 summary: average bias and RMSE by variable, mean and std of shock/instrument correlations.
- Part 2 summary: bias and MSE by variable for both methods, and the table of `BiasRatio`, `VarRatio`, `MSERatio`.

