# greenbook: HM Treasury Green Book CBA primitives in R

Scoping and design plan for a new R package wrapping HMT Green Book and supplementary guidance for cost-benefit analysis. Pure compute, no network. Compute archetype, sibling to `debtkit`, `inflationkit`, `climatekit`, `inequality`, `nowcast`.

Author: Charles Coverdale (London). GitHub: `charlescoverdale/greenbook` (empty repo confirmed). CRAN name: `greenbook` (404 confirmed: available).

Plan dated 2026-04-26. Targets v0.1.0 CRAN submission within 4 weeks of scaffolding; v1.0.0 + JOSS in 2027 Q1 to Q2.

## 1. Verdict

Build it. There is no R package on CRAN that implements Green Book primitives. UK consultancies, government analysts, and academic CBA researchers hand-roll discount factors, optimism bias multipliers, distributional weights, and carbon valuation in spreadsheets. With the 2026 Green Book just published (40 percent shorter, place-based business cases, lower-rate discount sensitivity for horizons beyond 50 years), there is a clean window to be the canonical R reference. The package fits the existing portfolio: pure-compute archetype like `debtkit` and `inflationkit`, dependencies limited to `cli`, `stats`, `tools`, sibling integration with `inflateR` (deflators), `obr` (forecasts), `ons` (income data). Target users: HMT GAD economists, IFS, Resolution Foundation, Centre for Cities, NIESR, OBR, BoE, large consultancies (WSP, Mott MacDonald, KPMG, Frontier Economics, Arup), academic CBA researchers. Realistic monthly downloads at maturity: 200 to 600 within 18 months of v1.0.0.

## 2. Catalogue of HMT Green Book primitives

### 2.1 Social Time Preference Rate (STPR)

The headline discount rate. A kinked schedule reflecting time preference and uncertainty over long horizons. Three variants.

| Years from base | Standard | Health | Catastrophic-risk |
|---|---|---|---|
| 0 to 30 | 3.5 percent | 1.5 percent | 3.0 percent |
| 31 to 75 | 3.0 percent | 1.29 percent | 2.57 percent |
| 76 to 125 | 2.5 percent | 1.07 percent | 2.14 percent |
| 126 to 200 | 2.0 percent | 0.86 percent | 1.71 percent |
| 201 to 300 | 1.5 percent | 0.64 percent | 1.29 percent |
| 301+ | 1.0 percent | 0.43 percent | 0.86 percent |

Source: Green Book 2022 Annex A6.2 and the supplementary discounting guidance. The 2026 Green Book commits to an independent academic review of the discount rate and recommends a lower-rate sensitivity test for projects with horizons beyond 50 years (rate to be specified by the review).

Update cadence: stable since 2003; under active review in 2026. Computational subtlety: the schedule is applied year-by-year, not through a single rate. Discount factors are products of annual factors: `prod(1 / (1 + r_t))`. Closed-form NPV across kinks is awkward, so a vectorised year-loop is the correct implementation.

### 2.2 Optimism bias upper bounds

From Mott MacDonald (2002) and HMT supplementary guidance. Indicative starting values for capital expenditure and works-duration uplifts, by project category. Mitigated downward through sensitivity analysis as risk allocation matures through SOC, OBC, and FBC stages.

| Category | Capex upper bound | Duration upper bound |
|---|---|---|
| Standard buildings | 24 percent | 4 percent |
| Non-standard buildings | 51 percent | 39 percent |
| Standard civil engineering | 44 percent | 20 percent |
| Non-standard civil engineering | 66 percent | 25 percent |
| Equipment / development | 200 percent | 54 percent |
| Outsourcing | 41 percent | 15 percent |

Source: HMT Supplementary Green Book Guidance: Optimism Bias. Update cadence: unchanged since 2003; DfT operates its own OB schedule via TAG (typically lower than HMT bounds for transport schemes).

Computational subtlety: OB applies to ex-ante cost estimates. Mitigation factors reduce the uplift as project definition matures: typically captured as a percentage reduction off the upper bound. Result: `cost_with_ob = cost_baseline * (1 + ob_pct * (1 - mitigation))`.

### 2.3 Distributional weighting

Eta = 1.3 (income elasticity of marginal utility of income) per Green Book main text Annex A3. Weight applied to net benefits accruing to a recipient income decile or cell:

`w_i = (y_med / y_i) ^ eta`

where `y_i` is the recipient's pre-tax-and-benefit equivalised household income and `y_med` is the median.

The 2025 Green Book Review and academic literature (Acland and Greenberg 2024) point to higher central values around 1.5 to 1.6 with sensitivity over 1.2 to 2.0, but the 2026 Green Book retains 1.3. Source for the income distribution: ONS Household Disposable Income Quintiles. Computational subtlety: weights apply only when distributional analysis is requested; the unweighted appraisal remains the headline measure.

### 2.4 Real versus nominal rebasing

Green Book appraisal is conducted in real terms using GDP deflator at market prices (HMT publishes quarterly; OBR forecasts the forward path). Use the GDP deflator at market prices, not CPI, for cross-government appraisal.

Computational subtlety: appraisals must clearly state real / nominal status and base year. Sibling package `inflateR` already exposes this; can be used as a Suggests-only helper.

### 2.5 Switching values and sensitivity testing

Switching values are the values of a parameter at which the NPV equals zero or the BCR equals 1. Sensitivity tests vary one parameter at a time across a defined range and tabulate the resulting NPV. Standard practice tests capex, opex, demand, discount rate, and key benefit values. The 2026 Green Book strengthens the requirement for switching values on the largest non-monetised impacts.

Computational subtlety: switching values typically need root-finding (`stats::uniroot`). For multi-parameter sensitivity, fan diagrams or tornado plots are conventional outputs.

### 2.6 Wellbeing valuation (WELLBY)

Since the July 2021 supplementary guidance, life-satisfaction changes are monetised as WELLBYs: a one-point change in life satisfaction on a 0 to 10 scale, for one person for one year. Central value: GBP 13,000 in 2019 prices; sensitivity range GBP 10,000 to GBP 16,000. In 2024 prices the central is approximately GBP 15,300 (low GBP 11,800, high GBP 18,800).

Source: HMT Wellbeing Guidance for Appraisal (July 2021). Computational subtlety: total WELLBY value = points change times persons times years times unit value, then discounted using the standard STPR. Watch base year of unit value and base year of cash flow stream are the same.

### 2.7 Health appraisal

Quality-Adjusted Life Years (QALYs) for health interventions, monetised at GBP 70,000 per QALY (2024 prices) per DHSC supplementary guidance. The Value of a Statistical Life (VSL) and Value of a Life Year (VOLY) are alternative units in some contexts.

Computational subtlety: NICE uses GBP 20,000 to GBP 30,000 per QALY for health technology assessment, but cross-government appraisal uses higher figures. Document the source for every monetisation.

### 2.8 Risk to life

Value of Preventing a Fatality (VPF): approximately GBP 2,153,000 in 2024 prices (DfT TAG data book), updated annually for GDP per head growth. HSE applies a multiplier (typically 2x) for high-aversion contexts (cancer, terrorism, major hazards).

### 2.9 Environmental valuation: carbon

DESNZ Carbon Values for Appraisal (formerly BEIS) publishes central, low, and high paths for the traded and non-traded sectors out to 2100. 2024 central traded value: approximately GBP 280 per tCO2e in 2024 prices, rising to GBP 480 by 2050. Reviewed every five years aligned to carbon-budget setting; latest values September 2021, refreshed methodologically in November 2023.

Computational subtlety: emissions in physical units must be converted to carbon-equivalent (GHG protocol) before applying values. The traded versus non-traded distinction is being phased out as UK ETS coverage expands; bundle both for now.

### 2.10 Equivalent annual cost / annualisation

EANC = NPV / annuity factor at STPR over project life. Used for comparing options with different durations.

### 2.11 Marginal Excess Tax Burden (METB)

Adjustment for the welfare cost of distortionary taxation. Current Green Book guidance: 20 percent uplift on revenue raised through the tax system (reduced from the historical 30 percent). Applied to net public expenditure when comparing spending versus tax-cutting options.

### 2.12 Adjustment factors

- Place-based weighting: new in 2026 Green Book; allows uplift for transformational regional investment, but no central numerical default. Methodology is qualitative.
- Long-horizon sensitivity: lower discount rate test for 50+ year horizons (rate to be set by the commissioned 2026 review).
- Capital appraisal: capex profiled across construction period, then operating costs and benefits across operating life.

## 3. Competitive landscape

### 3.1 CRAN

| Package | Scope | Last update | Verdict |
|---|---|---|---|
| `tvm` | Time value of money: rate conversions, NPV, IRR | 2025-07-22 | Generic finance utility. No appraisal context, no STPR, no OB. |
| `FinCal` | CFA-curriculum finance functions | Stale | Generic finance, US-flavoured. No CBA primitives. |
| `tvmComp` | Compounding and discounting reference | Active | Pedagogical. Single discount rate only. |
| `dynamicpv` | NPV with stochastic cashflows | Niche | Monte Carlo NPV but no Green Book guidance. |
| `hesim` | Health-economic simulation, ICER framing | Active | Cost-effectiveness (CEA), not cost-benefit (CBA). |
| `BCEA` | Bayesian cost-effectiveness | Active | Same as `hesim`: ICER, NICE-style, not cross-government appraisal. |

No CRAN package implements: STPR kinked schedule, optimism bias tables, distributional weights with eta, WELLBY, DESNZ carbon path, switching values, METB, place-based business cases. Names available: `greenbook`, `appraise`, `cba` (verified for `greenbook`).

### 3.2 GitHub and non-CRAN

A scattering of personal repos with hand-rolled `discount_factor()` functions; nothing maintained or comprehensive. PolicyEngine UK and UKMOD address the upstream microsim layer (income deciles, tax-benefit reform impact) but do not implement appraisal primitives.

### 3.3 Adjacent jurisdictions

- **EU Better Regulation Toolbox 9**: structurally similar (NPV, distributional analysis, cost-effectiveness). No R package.
- **OECD Cost-Benefit Analysis and the Environment**: methodology only, no software.
- **US OMB Circular A-4 / A-94**: discount rates of 3 percent and 7 percent; no R package.
- **World Bank ESF and Australia OBPR**: methodology documents, no software.
- **Python**: no PyPI equivalent. PolicyEngine has CBA-adjacent tools but not Green Book scope.

### 3.4 HMT internal

HMT models are spreadsheet-based (Workbook 1, Workbook 2 templates circulated with supplementary guidance). No published R or Python tooling.

### 3.5 Honest closest competitor

The closest CRAN match is `tvm` (for the discounting primitive only). It does roughly 5 percent of what `greenbook` would do. The closest published methodology resource is the HMT supplementary guidance PDFs themselves: there is no published code. White space confirmed.

## 4. Architecture proposal

### 4.1 Name and prefix

**Name**: `greenbook`. Verified available on CRAN and GitHub. One word, evocative, instantly recognisable to UK appraisal practitioners. Alternatives considered and rejected: `hmtgreenbook` (ugly, redundant), `appraise` (too generic, statistical-appraisal collision), `cba` (too generic, claims wider scope), `gbook` (cryptic).

**Prefix**: `gb_`. Two-letter prefix matches portfolio convention (`dk_`, `ik_`, `nc_`, `yc_`, `ci_`). Short, unambiguous, no clash with R base or any sibling. Functions read naturally: `gb_npv()`, `gb_optimism_bias()`, `gb_dist_weight()`.

### 4.2 Archetype

**Compute**. No network calls, no API. All Green Book parameters (STPR schedule, OB tables, eta, METB) are bundled. Annually-updated tables (DESNZ carbon values, GDP deflator, VPF, WELLBY adjusted to current prices) are bundled in `inst/extdata/` as CSV with explicit version metadata, refreshed in `data-raw/` scripts. This matches `debtkit`, `inflationkit`, `climatekit`.

### 4.3 Dependencies

- **Imports**: `cli`, `stats`, `tools`. No more.
- **Suggests**: `inflateR` (live deflator), `obr` (forecast paths for sensitivity ranges), `ons` (income decile data for distributional analysis), `testthat` (>= 3.0.0), `knitr`, `rmarkdown`, `ggplot2`.

The `inflateR` integration is conditional. If installed, `gb_real()` and `gb_rebase()` use live deflator data; otherwise fall back to the bundled deflator vintage with a one-line `cli::cli_alert_info()` noting the bundle date.

### 4.4 S3 classes

- **`gb_appraisal`**: result of `gb_npv()`, `gb_appraise()`. Carries provenance: methodology version (Green Book year), base year, discount schedule used, optimism bias applied, distributional weighting applied, deflator vintage, METB applied flag. Methods: `print`, `summary`, `format`, `plot`. The provenance in `gb_appraisal` is the headline differentiator from spreadsheets: every appraisal is self-describing and auditable.
- **`gb_value`**: a monetised series with associated base year, real / nominal flag, and source (e.g. WELLBY 2024 prices, DESNZ central traded path 2024 prices). Constructor `as_gb_value()`. Methods: `print`, `format`.

### 4.5 Static data

Bundled in `inst/extdata/` as CSV (machine-readable, easy for users to inspect):

- `stpr_schedule.csv`: STPR by year and variant
- `optimism_bias.csv`: OB upper bounds by category and dimension
- `carbon_values.csv`: DESNZ central / low / high paths to 2100, traded and non-traded
- `gdp_deflator.csv`: ONS GDP deflator at market prices
- `wellby_values.csv`: WELLBY central / low / high in successive base-year prices
- `vpf_series.csv`: VPF in successive base-year prices
- `qaly_values.csv`: QALY values per DHSC supplementary guidance
- `metb.csv`: METB rate by Green Book vintage
- `data_versions.csv`: vintage metadata for all of the above

Lazy-loaded via internal helpers (`.read_stpr()`, `.read_carbon()` etc.) with a single source-of-truth `gb_data_versions()` for end users to interrogate vintage.

### 4.6 File structure

```
greenbook/
DESCRIPTION
LICENSE
NAMESPACE
NEWS.md
README.md
_pkgdown.yml
R/
  greenbook-package.R
  stpr.R              # gb_stpr, gb_discount_factor, gb_discount
  npv.R               # gb_npv, gb_appraise, gb_eanc
  optimism_bias.R     # gb_optimism_bias, gb_apply_ob, gb_categories
  distributional.R    # gb_dist_weight, gb_dist_weighted_npv
  valuation.R         # gb_wellby, gb_vpf, gb_qaly
  carbon.R            # gb_carbon_value, gb_carbon_npv
  deflator.R          # gb_deflator, gb_real, gb_rebase
  sensitivity.R       # gb_switching_value, gb_sensitivity_table, gb_monte_carlo
  adjustments.R       # gb_metb
  classes.R           # gb_appraisal, gb_value constructors and methods
  lookups.R           # gb_schedule_table, gb_carbon_table, gb_data_versions
  utils.R             # internal
data-raw/
  stpr.R, optimism_bias.R, carbon_values.R, gdp_deflator.R,
  wellby.R, vpf.R, qaly.R, metb.R
inst/
  extdata/  (CSV files as above)
  CITATION
man/  (Roxygen-generated)
tests/testthat/
  test-stpr.R, test-npv.R, test-optimism_bias.R,
  test-distributional.R, test-valuation.R, test-carbon.R,
  test-deflator.R, test-sensitivity.R, test-adjustments.R,
  test-classes.R
vignettes/
  greenbook.Rmd                   # quickstart
  full-appraisal.Rmd              # worked example end-to-end
  distributional-analysis.Rmd
  carbon-and-environment.Rmd
  sensitivity-and-switching.Rmd
cran-comments.md
```

## 5. Function inventory

Twenty-five exported functions across nine families. All names use `gb_` prefix.

### 5.1 Discounting (5)

| Function | Signature | Description |
|---|---|---|
| `gb_stpr()` | `gb_stpr(years, schedule = "standard")` | STPR for a vector of years; vectorised over `schedule` if passed as character vector |
| `gb_discount_factor()` | `gb_discount_factor(years, schedule = "standard", base_year = 0)` | Discount factor for each year |
| `gb_discount()` | `gb_discount(values, years = seq_along(values) - 1, schedule = "standard")` | Apply discount factors to a stream |
| `gb_npv()` | `gb_npv(cashflow, years = NULL, schedule = "standard", ...)` | Single NPV; returns `gb_appraisal` |
| `gb_eanc()` | `gb_eanc(npv, years, schedule = "standard")` | Equivalent annual net cost given NPV and life |

### 5.2 Optimism bias (3)

| Function | Signature | Description |
|---|---|---|
| `gb_optimism_bias()` | `gb_optimism_bias(category, dimension = "capex")` | Lookup OB upper bound percentage |
| `gb_apply_ob()` | `gb_apply_ob(values, ob_pct, mitigation = 0)` | Apply OB to a cost stream with optional mitigation |
| `gb_categories()` | `gb_categories()` | List available categories with one-line descriptions |

### 5.3 Distributional (2)

| Function | Signature | Description |
|---|---|---|
| `gb_dist_weight()` | `gb_dist_weight(income, eta = 1.3, reference = "median", income_data = NULL)` | Weight per recipient |
| `gb_dist_weighted_npv()` | `gb_dist_weighted_npv(cashflow, recipient_income, eta = 1.3, schedule = "standard")` | NPV with distributional weighting |

### 5.4 Valuation (3)

| Function | Signature | Description |
|---|---|---|
| `gb_wellby()` | `gb_wellby(life_satisfaction_change, persons, years = 1, base_year = NULL, scenario = "central")` | WELLBY in GBP |
| `gb_vpf()` | `gb_vpf(year = NULL, gdp_uprate = TRUE)` | VPF in real terms; uprated for GDP per head if requested |
| `gb_qaly()` | `gb_qaly(qalys, base_year = NULL, scenario = "central")` | QALY in GBP per DHSC supplementary guidance |

### 5.5 Carbon (2)

| Function | Signature | Description |
|---|---|---|
| `gb_carbon_value()` | `gb_carbon_value(year, scenario = "central", series = "traded")` | DESNZ value per tCO2e |
| `gb_carbon_npv()` | `gb_carbon_npv(emissions, years, scenario = "central", series = "traded", schedule = "standard")` | NPV of an emissions path |

### 5.6 Real / nominal (3)

| Function | Signature | Description |
|---|---|---|
| `gb_deflator()` | `gb_deflator(from, to, source = "bundled")` | GDP deflator factor; `source = "inflateR"` if package available |
| `gb_real()` | `gb_real(nominal_values, year, base_year, source = "bundled")` | Nominal to real |
| `gb_rebase()` | `gb_rebase(values, from, to)` | Change base year |

### 5.7 Sensitivity (3)

| Function | Signature | Description |
|---|---|---|
| `gb_switching_value()` | `gb_switching_value(appraisal, parameter, range, target = 0)` | Find the parameter value that makes NPV = 0 |
| `gb_sensitivity_table()` | `gb_sensitivity_table(appraisal, parameters, ranges)` | One-at-a-time sensitivity grid |
| `gb_monte_carlo()` | `gb_monte_carlo(appraisal, distributions, n = 10000, seed = NULL)` | MC simulation; returns NPV distribution |

### 5.8 Adjustments and high-level (2)

| Function | Signature | Description |
|---|---|---|
| `gb_metb()` | `gb_metb(values, rate = 0.20, vintage = "2022")` | Apply METB uplift to net public expenditure |
| `gb_appraise()` | `gb_appraise(costs, benefits, years = NULL, schedule = "standard", ob = NULL, dist_weights = NULL, metb = FALSE)` | One-call full appraisal returning `gb_appraisal` with NPV, BCR, EANC, sensitivity hooks |

### 5.9 Lookups (3)

| Function | Signature | Description |
|---|---|---|
| `gb_schedule_table()` | `gb_schedule_table(schedule = "standard")` | Tibble of years and rates |
| `gb_carbon_table()` | `gb_carbon_table(years = 2024:2050, scenario = "central")` | Tibble of carbon path |
| `gb_data_versions()` | `gb_data_versions()` | Vintage of all bundled tables, with last-updated dates |

### 5.10 S3 methods (registered, not separately exported)

`print.gb_appraisal()`, `summary.gb_appraisal()`, `format.gb_appraisal()`, `plot.gb_appraisal()`, `print.gb_value()`, `format.gb_value()`.

## 6. Phased roadmap

Five phases from v0.1.0 (CRAN MVP) to v1.0.0 (JOSS publication-ready).

### Phase 1: v0.1.0: Discounting MVP

**Scope**: STPR, discount factors, NPV, deflator, EANC. The minimum that lets a user run a basic Green Book CBA in R.

**Functions** (8): `gb_stpr`, `gb_discount_factor`, `gb_discount`, `gb_npv`, `gb_eanc`, `gb_deflator`, `gb_real`, `gb_rebase`.

**Bundled data**: STPR schedule, GDP deflator (vintage frozen at v0.1.0 release).

**Tests**: 80 to 100. Known-value tests against worked examples in Green Book Annex A6 and the supplementary discounting guidance. Edge cases: zero years, negative years, mixed real / nominal inputs, base-year alignment.

**Vignette**: `greenbook.Rmd` quickstart.

**Target**: CRAN submission within 4 weeks of scaffolding. v0.1.0 first release per CRAN convention.

### Phase 2: v0.2.0: Bias and distributional analysis

**Scope**: Optimism bias, distributional weighting, METB, high-level appraise.

**Functions** (+6): `gb_optimism_bias`, `gb_apply_ob`, `gb_categories`, `gb_dist_weight`, `gb_dist_weighted_npv`, `gb_metb`, `gb_appraise`.

**Bundled data**: optimism bias upper bounds, METB schedule.

**Tests**: +60 to 70. Known-value tests against the optimism bias Mott MacDonald worked examples.

**Vignette**: `distributional-analysis.Rmd`, `full-appraisal.Rmd`.

**Target**: 6 to 8 weeks after v0.1.0.

### Phase 3: v0.3.0: Valuation library

**Scope**: WELLBY, VPF, QALY, DESNZ carbon. The bundled data tables that make `greenbook` indispensable.

**Functions** (+5): `gb_wellby`, `gb_vpf`, `gb_qaly`, `gb_carbon_value`, `gb_carbon_npv`.

**Bundled data**: WELLBY values series, VPF series, QALY values, DESNZ carbon values (full series to 2100, all scenarios, traded and non-traded).

**Tests**: +50 to 60. Known-value tests against published HMT and DESNZ tables.

**Vignette**: `carbon-and-environment.Rmd`.

**Target**: 8 to 10 weeks after v0.2.0.

### Phase 4: v0.4.0: Sensitivity and Monte Carlo

**Scope**: Switching values, sensitivity grid, Monte Carlo, S3 plot methods.

**Functions** (+3): `gb_switching_value`, `gb_sensitivity_table`, `gb_monte_carlo`.

**S3**: `plot.gb_appraisal` (tornado, fan, MC density), `summary.gb_appraisal` enriched.

**Tests**: +30 to 40.

**Vignette**: `sensitivity-and-switching.Rmd`.

**Target**: 6 weeks after v0.3.0.

### Phase 5: v1.0.0: JOSS publication-ready

**Scope**: 2026 Green Book review of discount rates incorporated; place-based business case scaffolding (qualitative table support); CITATION.cff; full vignette set; `pkgdown` site.

**Functions**: net new = 0; refactor and signature additions only. Final-form S3 print methods.

**Tests**: total target 220 to 250. Cross-package integration tests with `inflateR`, `obr`, `ons`.

**JOSS paper**: methods paper covering Green Book primitive coverage, comparison to spreadsheet workflow, reproducibility benefits. Submit when discount rate review lands and queue position permits (after `climatekit`, `nowcast`, `mpshock`, `inequality` per existing publications order).

**Target**: 2027 Q1 to Q2.

### 6.1 Definition of done

- v0.1.0: 80+ tests passing, R CMD check 0/0/0 (2 benign NOTEs allowed for first submission), vignettes build clean, README with quickstart, NEWS.md, cran-comments.md
- v1.0.0: 220+ tests passing, four published vignettes, CITATION + CITATION.cff, JOSS submission accepted

### 6.2 Implementation order

Build STPR first, then discount factor, then NPV. Defer the `gb_appraisal` S3 class until NPV works on raw vectors: the class wraps the primitive, not vice versa. Add the bundled-data harness (`.read_*` helpers, `gb_data_versions`) before any function that depends on bundled data, so vintage management is centralised from day one.

## 7. Decision points and risks

Eight decisions a maintainer needs to make. None are blockers; all need an explicit call.

### 7.1 Bundle versus fetch DESNZ carbon values

**Decision**: bundle the September 2021 DESNZ central / low / high paths in `inst/extdata/`, refreshed annually via `data-raw/carbon_values.R`, OR build a `desnz` companion package that wraps the GOV.UK download.

**Recommendation**: bundle for v0.1.0 to v1.0.0. Carbon values change every five years (next: 2026). Bundling keeps the package compute-only with no network. Defer `desnz` API package as a separate project if download cadence rises.

### 7.2 Eta default for distributional weighting

**Decision**: default `eta = 1.3` (current Green Book) or `1.5` (HMT 2020 review preferred) or `1.6` (Acland and Greenberg 2024 academic central)?

**Recommendation**: `eta = 1.3` as default with `eta = 1.5` and `eta = 2.0` as named scenarios via argument. Document the tension in the function help. Switch the default if the post-2026-review guidance shifts.

### 7.3 GDP deflator: bundle versus depend on inflateR

**Decision**: bundle the deflator series in `greenbook` (vintage frozen) or require `inflateR` as Imports for live data.

**Recommendation**: bundle as fallback; use `inflateR` if available. `inflateR` in Suggests, not Imports. Keeps `greenbook` standalone and CRAN-friendly. Vintage clearly tagged in `gb_data_versions()`.

### 7.4 Multi-vintage Green Book support

**Decision**: support pre-2022 STPR schedules and OB tables explicitly (e.g. `gb_npv(schedule = "green_book_2018")`) for back-comparisons, or always use latest.

**Recommendation**: add `vintage` argument from Phase 2 onward, defaulting to the most recent. Keep older schedules as named tables in the bundled CSV. Useful for users replicating historic appraisals.

### 7.5 Internationalisation

**Decision**: stay UK-pure or add EU Better Regulation / OECD / US OMB shims.

**Recommendation**: UK-pure for v1.0.0. Branding and naming presume Green Book context. International parameters (EU 4 percent, US OMB 3 / 7 percent) belong in a separate `cba` package later if there is demand.

### 7.6 Long-horizon discount rate sensitivity

**Decision**: hard-code a lower-rate sensitivity option (e.g. 1 percent flat for 50+ year horizons) or wait for the commissioned 2026 review to publish a number.

**Recommendation**: wait. Ship `gb_npv()` with an optional `lower_rate` argument from v0.4.0 that defaults to NULL. When the user supplies it, run a parallel NPV at the lower rate as a sensitivity output. Update default once the 2026 review reports.

### 7.7 Place-based and transformational adjustments

**Decision**: implement now (v1.0.0) or defer.

**Recommendation**: defer. The 2026 Green Book makes the requirement qualitative, with no central numerical default. Provide an `appraisal$narrative` slot in `gb_appraisal` to capture place-based and transformational considerations textually. Revisit when HMT publishes implementation guidance.

### 7.8 METB rate default

**Decision**: 20 percent (Green Book 2022 default), 30 percent (historic), or scenarios.

**Recommendation**: 20 percent default with `gb_metb(rate = ...)` user-overridable, plus a named `vintage = "2022"` lookup that returns 0.20.

### 7.9 Risks

- 2026 Green Book review of discount rates may invalidate STPR schedule mid-year. Mitigation: vintage support per 7.4 means old appraisals are reproducible; a `greenbook` patch bumps the default schedule when guidance lands.
- DESNZ may republish carbon values in 2026 to align with the seventh carbon budget. Mitigation: bundled CSV with vintage metadata; patch release on update.
- WELLBY, VPF, QALY values diverge across departments (DfT, DHSC, HMT). Mitigation: clearly document source for each `gb_*` function; expose source as argument.
- Bus factor of one. Mitigation: pkgdown site, CITATION, JOSS paper, tests are level 2 minimum (known values, not just smoke tests). Repo public from v0.1.0.

## 8. Sources

- [The Green Book (2026): GOV.UK landing page](https://www.gov.uk/government/publications/the-green-book-appraisal-and-evaluation-in-central-government/the-green-book-2026)
- [The Green Book 2026 PDF, HM Treasury](https://assets.publishing.service.gov.uk/media/698dbcd17da91680ad7f4308/The_Green_Book_2026.pdf)
- [Green Book discount rate review 2026: GOV.UK](https://www.gov.uk/government/publications/green-book-discount-rate-review-2026)
- [Green Book Review 2025: Findings and actions](https://www.gov.uk/government/publications/green-book-review-2025-findings-and-actions/green-book-review-2025-findings-and-actions)
- [Supplementary Green Book Guidance: Optimism Bias, PDF](https://assets.publishing.service.gov.uk/media/5a74dae740f0b65f61322c72/Optimism_bias.pdf)
- [Green Book supplementary guidance: optimism bias, GOV.UK](https://www.gov.uk/government/publications/green-book-supplementary-guidance-optimism-bias)
- [Green Book supplementary guidance: discounting, GOV.UK](https://www.gov.uk/government/publications/green-book-supplementary-guidance-discounting)
- [Wellbeing Guidance for Appraisal: Supplementary Green Book Guidance, July 2021, PDF](https://assets.publishing.service.gov.uk/media/60fa9169d3bf7f0448719daf/Wellbeing_guidance_for_appraisal_-_supplementary_Green_Book_guidance.pdf)
- [DESNZ Valuation of Energy Use and GHG Emissions for Appraisal, November 2023, PDF](https://assets.publishing.service.gov.uk/media/65aadd020ff90c000f955f17/valuation-of-energy-use-and-greenhouse-gas-emissions-for-appraisal.pdf)
- [DfT Transport Analysis Guidance (TAG): GOV.UK](https://www.gov.uk/guidance/transport-analysis-guidance-tag)
- [The 2026 Green Book: Not a Rewrite, but a Reframing, Major Projects Association](https://majorprojects.org/blog/the-2026-green-book-not-a-rewrite-but-a-reframing/)
- [Acland and Greenberg, The Elasticity of Marginal Utility of Income for Distributional Weighting and Social Discounting: A Meta-Analysis, JBCA](https://www.cambridge.org/core/journals/journal-of-benefit-cost-analysis/article/elasticity-of-marginal-utility-of-income-for-distributional-weighting-and-social-discounting-a-metaanalysis/D94D3809CDAB8437BCCB366D30337A6F)
- [tvm package: CRAN](https://cran.r-project.org/package=tvm)
- [FinCal package: CRAN](https://cran.r-project.org/package=FinCal)
- [hesim package: CRAN](https://cran.r-project.org/package=hesim)
