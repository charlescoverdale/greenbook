# greenbook

[![CRAN status](https://www.r-pkg.org/badges/version/greenbook)](https://CRAN.R-project.org/package=greenbook) [![CRAN downloads](https://cranlogs.r-pkg.org/badges/greenbook)](https://cran.r-project.org/package=greenbook) [![Total Downloads](https://cranlogs.r-pkg.org/badges/grand-total/greenbook)](https://CRAN.R-project.org/package=greenbook) [![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Cost-benefit analysis primitives from the HM Treasury Green Book, in R.


## What is the Green Book?

The [Green Book](https://www.gov.uk/government/publications/the-green-book-appraisal-and-evaluation-in-central-government) is HM Treasury's guidance on how to appraise and evaluate proposals involving UK public spending. It sets the rules every central-government department, devolved administration, and arm's-length body follows when deciding whether a policy, programme, or capital project is worth funding. The latest edition was published in 2026.

The guidance covers six core areas:

- **Discounting**: the kinked Social Time Preference Rate (STPR), stepping from 3.5 percent for the first 30 years down to 1.0 percent beyond year 300.
- **Real-terms appraisal**: rebasing nominal cashflows using the GDP deflator at market prices.
- **Optimism bias**: standard uplifts on capital cost and works-duration estimates, by project category (Mott MacDonald 2002).
- **Distributional analysis**: iso-elastic weights on net benefits accruing to different income groups.
- **Adjustments**: the Marginal Excess Tax Burden (METB) on revenue raised through distortionary taxation.
- **Monetised valuation**: WELLBYs for wellbeing, Value of Preventing a Fatality (VPF) for life-safety, Quality-Adjusted Life Years (QALYs) for health, DESNZ carbon values for emissions.

The Green Book is supplemented by topic-specific guidance from HMT, DESNZ, DfT, and DHSC.


## How is it used?

A practitioner appraising a public-spending option typically:

1. Builds a profile of costs and benefits in real terms, by year, in a fixed price base.
2. Discounts each year's cashflow under the kinked STPR to compute net present value (NPV) and benefit-cost ratio (BCR).
3. Uplifts ex-ante cost estimates by an optimism bias percentage matched to the project category.
4. Applies distributional weights if the option is regressive across income groups.
5. Runs sensitivity tests on the largest assumptions and computes switching values.

Today this is mostly done in spreadsheets, with discount factors and parameter tables hand-typed from PDFs. `greenbook` puts the same primitives in R so an appraisal becomes code that can be tested, reviewed, and reproduced.


## Why this package?

No existing R or Python package implements the Green Book. UK appraisal practitioners hand-roll the same discount factors and parameter lookups every time. The arithmetic is simple but the parameters change: STPR is kinked across six bands, optimism bias has a six-category schedule, DESNZ publishes a carbon path to 2100, METB shifted from 30 to 20 percent in 2018.

`greenbook` solves three problems:

- **Reproducibility**: every `gb_appraisal` carries vintage metadata for the parameter tables it used. `gb_data_versions()` shows source and last-updated date for every bundled table.
- **Auditability**: appraisals are code, not spreadsheets. Reviewers can run the tests, inspect the inputs, verify the outputs.
- **Maintenance**: when HM Treasury updates the Green Book, you bump the package and your existing appraisals stay aligned.

The package is pure computation: no network calls, no API keys. Bundled parameter tables in `inst/extdata/` are refreshed via `data-raw/` scripts.


## Installation

```r
# install.packages("greenbook")  # not yet on CRAN
# Development version:
devtools::install_github("charlescoverdale/greenbook")
```


## Quick start

```r
library(greenbook)

# 10-year cashflow: capex in years 0-2, benefits in years 3-9
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

# Carbon emissions
gb_carbon_npv(rep(100, 7), 2024:2030, base_year = 2024)

# Wellbeing
gb_wellby(1, persons = 100, years = 5, base_year = 2024)

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
| Valuation | `gb_wellby()`, `gb_vpf()`, `gb_qaly()` |
| Carbon | `gb_carbon_value()`, `gb_carbon_npv()` |
| Adjustments | `gb_metb()` |
| Appraisal | `gb_appraise()`, `gb_compare()`, `gb_progression()`, `gb_place_based()`, `gb_economic_case()`, `gb_validate()` |
| Risk | `gb_risk_register()` |
| Sensitivity | `gb_sensitivity_ob()` |
| Reporting | `gb_headline()`, `gb_cost_per_unit()`, `gb_to_latex()`, `gb_to_excel()`, `gb_to_word()` |
| Lookups | `gb_schedule_table()`, `gb_data_versions()` |


## Bundled data sources

Every parameter table is sourced from a published HMT, DfT, or DESNZ workbook. `gb_data_versions()` returns the full provenance.

| Table | Source |
|---|---|
| STPR schedule | HMT Green Book 2022 Annex A6 |
| GDP deflator (1990-2024, 2024 = 100) | HMT GDP deflators, December 2025 Quarterly National Accounts release |
| Optimism bias upper bounds | HMT Supplementary Green Book Guidance: Optimism Bias (Mott MacDonald 2002) |
| METB | HMT Green Book 2022 |
| WELLBY (10k / 13k / 16k, 2019 prices) | HMT Wellbeing Guidance for Appraisal, July 2021 |
| QALY (DHSC 70k / NICE 20k, 30k) | DHSC Supplementary Green Book Guidance + NICE HTA |
| VPF (anchored 2023 = GBP 2,474,341) | DfT TAG data book v2.03FC, December 2025, Table A4.1.1 (WTP element) |
| DESNZ carbon (2020-2050, 2022 prices) | DESNZ Valuation of Energy Use and GHG Emissions for Appraisal, November 2023, Table 3 |

`data-raw/` contains the refresh scripts: each downloads the published workbook, parses the relevant sheet, and rewrites the bundled CSV.

## Limitations

- VPF series interpolates between published anchors at 2 percent real GDP per head growth (TAG's stated methodology). For sub-annual precision consult the TAG data book directly.
- Bundled DESNZ carbon path covers 2020 to 2050. The November 2023 publication extends to 2100; the 2050-2100 portion will be added in a future refresh.
- Long-horizon (50+ year) lower-rate sensitivity awaits the 2026 HMT discount-rate review.


## Source documents

- [HM Treasury Green Book (2026)](https://www.gov.uk/government/publications/the-green-book-appraisal-and-evaluation-in-central-government/the-green-book-2026)
- [Supplementary Green Book Guidance: discounting](https://www.gov.uk/government/publications/green-book-supplementary-guidance-discounting)
- [Supplementary Green Book Guidance: optimism bias](https://www.gov.uk/government/publications/green-book-supplementary-guidance-optimism-bias)
- [Wellbeing Guidance for Appraisal: Supplementary Green Book Guidance, July 2021](https://www.gov.uk/government/publications/green-book-supplementary-guidance-wellbeing)
- [DESNZ Valuation of Energy Use and GHG Emissions for Appraisal, November 2023](https://www.gov.uk/government/publications/valuation-of-energy-use-and-greenhouse-gas-emissions-for-appraisal)
- [DfT Transport Analysis Guidance (TAG)](https://www.gov.uk/guidance/transport-analysis-guidance-tag)


## Related packages

| Package | Description |
|---|---|
| [`magentabook`](https://github.com/charlescoverdale/magentabook) | Companion: HM Treasury Magenta Book evaluation primitives (appraisal-to-evaluation spine) |
| [`obr`](https://github.com/charlescoverdale/obr) | OBR fiscal forecasts (CBA inputs, public finances) |
| [`ons`](https://github.com/charlescoverdale/ons) | UK Office for National Statistics data (GDP deflator, CPI, demography) |
| [`inflateR`](https://github.com/charlescoverdale/inflateR) | Inflation adjustment for real-terms cashflows |
| [`inflationkit`](https://github.com/charlescoverdale/inflationkit) | Inflation analysis (deflators, persistence) |
| [`debtkit`](https://github.com/charlescoverdale/debtkit) | Debt sustainability analysis (links public-sector NPV to debt path) |
| [`ivcheck`](https://github.com/charlescoverdale/ivcheck) | IV diagnostics (for causal impact estimates feeding the appraisal) |


## Citation

If you use `greenbook` in published work, please cite via:

```r
citation("greenbook")
```

The package citation and the underlying HM Treasury Green Book are both returned.


## Issues

Report bugs or request features at [GitHub Issues](https://github.com/charlescoverdale/greenbook/issues).


## Keywords

cost-benefit-analysis, appraisal, hm-treasury, green-book, public-policy, economics, discounting, npv, social-time-preference-rate, optimism-bias, distributional-weighting, wellby, value-of-statistical-life, carbon-valuation, desnz
