# greenbook

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/greenbook)](https://CRAN.R-project.org/package=greenbook)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

Cost-benefit analysis primitives from the HM Treasury Green Book. Implements
the kinked Social Time Preference Rate (STPR), discount factors, net present
value, equivalent annual cost, and GDP-deflator rebasing. Pure computation,
no network. Bundled parameter tables carry vintage metadata for
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
discount factors, optimism bias multipliers, and rebasing arithmetic in
spreadsheets. `greenbook` puts the primitives in code, with vintage
metadata on every parameter table, so appraisals are reproducible,
testable, and version-controlled. v0.1.0 ships the discounting MVP;
later releases add optimism bias, distributional weighting, WELLBY,
DESNZ carbon values, and Monte Carlo sensitivity.

## Quick start

```r
library(greenbook)

# A 10-year cashflow, costs in years 0 to 2, benefits in years 3 to 9
costs    <- c(100, 50, 50, 0, 0, 0, 0, 0, 0, 0)
benefits <- c(0, 0, 0, 30, 30, 30, 30, 30, 30, 30)
net      <- benefits - costs

appraisal <- gb_npv(net)
appraisal
#> Green Book appraisal
#> NPV (real, schedule = "standard"): GBP 8.51
#> Horizon: 10 years
#> Vintage: Green Book 2022

# Equivalent annual net benefit over 10 years
gb_eanc(appraisal, years = 10)

# Inspect the kinked discount schedule
gb_schedule_table()

# Real-terms rebasing using the bundled GDP deflator
gb_real(nominal_values = c(100, 110, 120), year = 2020:2022, base_year = 2024)

# Vintage of bundled parameter tables
gb_data_versions()
```

## Function inventory (v0.1.0)

| Family | Function | Purpose |
|---|---|---|
| Discounting | `gb_stpr()` | STPR for a vector of years |
| Discounting | `gb_discount_factor()` | Discount factor under the kinked schedule |
| Discounting | `gb_discount()` | Apply discount factors to a stream |
| Discounting | `gb_npv()` | Net present value, returns `gb_appraisal` |
| Discounting | `gb_eanc()` | Equivalent annual net cost |
| Deflator | `gb_deflator()` | GDP deflator factor between years |
| Deflator | `gb_real()` | Convert nominal to real |
| Deflator | `gb_rebase()` | Change base year |
| Lookups | `gb_schedule_table()` | Tibble of years and STPR rates |
| Lookups | `gb_data_versions()` | Vintage of bundled tables |

## Roadmap

- v0.2.0: Optimism bias (Mott MacDonald upper bounds), distributional
  weights (eta-based), Marginal Excess Tax Burden, high-level
  `gb_appraise()`.
- v0.3.0: Valuation library: WELLBY, VPF, QALY, DESNZ carbon values.
- v0.4.0: Switching values, sensitivity grids, Monte Carlo, plot
  methods.
- v1.0.0: 2026 Green Book discount-rate review incorporated; JOSS paper.

## Source documents

- [HM Treasury Green Book (2026)](https://www.gov.uk/government/publications/the-green-book-appraisal-and-evaluation-in-central-government/the-green-book-2026)
- [Supplementary Green Book Guidance: discounting](https://www.gov.uk/government/publications/green-book-supplementary-guidance-discounting)
- [Supplementary Green Book Guidance: optimism bias](https://www.gov.uk/government/publications/green-book-supplementary-guidance-optimism-bias)

## Issues

Report bugs or request features at
[GitHub Issues](https://github.com/charlescoverdale/greenbook/issues).

## Keywords

cost-benefit-analysis, appraisal, hm-treasury, green-book, public-policy,
economics, discounting, npv, social-time-preference-rate
