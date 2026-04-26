# greenbook

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/greenbook)](https://CRAN.R-project.org/package=greenbook)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

Cost-benefit analysis primitives from the HM Treasury Green Book.
Implements the kinked Social Time Preference Rate (STPR), discount
factors, net present value, equivalent annual cost, GDP-deflator
rebasing, optimism bias, distributional weighting, Marginal Excess
Tax Burden, and a one-call full appraisal. Pure computation, no
network. Bundled parameter tables carry vintage metadata for
reproducibility.

## Installation

```r
# install.packages("greenbook")  # not yet on CRAN
# Development version:
# install.packages("devtools")
devtools::install_github("charlescoverdale/greenbook")
```

## Why this package?

UK central government appraisal practitioners hand-roll Green Book
discount factors, optimism bias multipliers, distributional weights,
and rebasing arithmetic in spreadsheets. `greenbook` puts the
primitives in code, with vintage metadata on every parameter table,
so appraisals are reproducible, testable, and version-controlled.

## Quick start

```r
library(greenbook)

# A 10-year cashflow: capex in years 0-2, benefits in years 3-9
costs    <- c(100, 50, 50, 0, 0, 0, 0, 0, 0, 0)
benefits <- c(0, 0, 0, 30, 30, 30, 30, 30, 30, 30)

# One-call full appraisal with optimism bias and METB
app <- gb_appraise(
  costs, benefits,
  ob = "non_standard_buildings", ob_mitigation = 0.5,
  metb = TRUE,
  base_year = 2024
)
summary(app)

# Equivalent annual net benefit
gb_eanc(app)

# Distributional weighting
gb_dist_weighted_npv(
  cashflow = rep(30, 5),
  recipient_income = rep(15000, 5),
  income_data = seq(10000, 100000, length.out = 10)
)

# Real-terms rebasing
gb_real(c(100, 110, 120), year = 2020:2022, base_year = 2024)

# Inspect bundled vintages
gb_data_versions()
```

## Function inventory

| Family | Functions |
|---|---|
| Discounting | `gb_stpr()`, `gb_discount_factor()`, `gb_discount()`, `gb_npv()`, `gb_eanc()` |
| Real / nominal | `gb_deflator()`, `gb_real()`, `gb_rebase()` |
| Optimism bias | `gb_optimism_bias()`, `gb_apply_ob()`, `gb_categories()` |
| Distributional | `gb_dist_weight()`, `gb_dist_weighted_npv()` |
| Adjustments | `gb_metb()` |
| High-level | `gb_appraise()` |
| Lookups | `gb_schedule_table()`, `gb_data_versions()` |

## Roadmap

- v0.3.0: Valuation library: WELLBY, VPF, QALY, DESNZ carbon values.
- v0.4.0: Switching values, sensitivity grids, Monte Carlo, plot
  methods.
- v1.0.0: 2026 Green Book discount-rate review incorporated; JOSS
  paper.

## Source documents

- [HM Treasury Green Book (2026)](https://www.gov.uk/government/publications/the-green-book-appraisal-and-evaluation-in-central-government/the-green-book-2026)
- [Supplementary Green Book Guidance: discounting](https://www.gov.uk/government/publications/green-book-supplementary-guidance-discounting)
- [Supplementary Green Book Guidance: optimism bias](https://www.gov.uk/government/publications/green-book-supplementary-guidance-optimism-bias)

## Issues

Report bugs or request features at
[GitHub Issues](https://github.com/charlescoverdale/greenbook/issues).

## Keywords

cost-benefit-analysis, appraisal, hm-treasury, green-book, public-policy,
economics, discounting, npv, social-time-preference-rate, optimism-bias,
distributional-weighting
