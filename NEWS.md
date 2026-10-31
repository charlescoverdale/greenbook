# greenbook 0.2.0

HM Treasury changed the Green Book discount rate on 28 October 2026,
adopting the recommendations of the Green Book Discount Rate Review 2026
(Freeman and Groom). This release makes the new schedule the default.
**Results change**: any appraisal run with default arguments now
discounts at a lower rate, so NPVs of projects with long-dated benefits
rise.

## Discounting

* New default schedule (`vintage = "2026-10"`): 3.00 percent for years 1
  to 30, 2.50 percent for years 31 to 75 and 2.25 percent for years 76 to
  125. It reproduces the discount factors in Annex A of the October 2026
  supplementary guidance to four decimal places.

* The October 2026 guidance says discounting is not meaningful beyond
  year 125 and that one rate applies to all proposals. Under the default
  vintage, years above 125 and the `"health"` and `"catastrophic"`
  schedules are therefore errors with a message pointing to the
  guidance, rather than being silently extrapolated or applied.

* The earlier schedule (3.5 percent declining to 1.0 percent, with the
  health and catastrophic-risk variants) is kept as `vintage = "2003"`.
  The edition labels `"2018"`, `"2020"`, `"2022"` and `"2026-02"` map to
  it, the February 2026 edition having kept the 3.5 percent rate.

* `gb_stpr()`, `gb_discount_factor()`, `gb_discount()`,
  `gb_schedule_table()`, `gb_carbon_npv()` and `gb_eanc()` gain a
  `vintage` argument. In `gb_npv()`, `gb_appraise()` and
  `gb_dist_weighted_npv()`, `vintage` was previously a label stored on
  the result; it now selects the schedule, and defaults to `"2026-10"`
  instead of `"2022"`. An unknown vintage is now an error at the point
  of appraisal.

* `gb_validate()` recognises the new vintages and reports, as
  information, when an appraisal uses the pre-October 2026 schedule.

## Distributional weights

* The default elasticity of marginal utility in `gb_dist_weight()` and
  `gb_dist_weighted_npv()` is now 1.25, the value in the updated Green
  Book, down from 1.3. Pass `eta = 1.3` to reproduce earlier results.

## Data

* GDP deflator refreshed to HM Treasury's October 2026 (Budget) release:
  ONS outturn to 2025 (2025 = 100) and, new, OBR forecasts for 2026 to
  2031, chained from the published growth rates. `gb_deflator()`,
  `gb_real()` and `gb_rebase()` can now express values in 2025 and 2026
  prices; previously they stopped at 2024. A `type` column marks forecast
  years. `data-raw/gdp_deflator.R` now locates the latest release through
  the GOV.UK Content API.

* `inst/CITATION` takes the version number from `DESCRIPTION`.

# greenbook 0.1.1

* Maintainer email corrected to `charlesfcoverdale@gmail.com`. The CRAN
  record for 0.1.0 carried `charles.f.coverdale@gmail.com`, which put
  greenbook on a separate maintainer check-results page from the rest of
  my packages. Both addresses reach the same inbox; this aligns the CRAN
  record with every other package I maintain.

* Corrected the description of the `"catastrophic"` STPR schedule in
  `gb_stpr()` and `gb_discount_factor()`. It previously read as the
  schedule to use "for projects where catastrophic risk dominates",
  which inverts the guidance. The 3.0 percent schedule is the standard
  schedule with the catastrophic-risk element of pure time preference
  removed, and is for appraisals that already model that risk
  explicitly, so it is not counted twice. Using it because a project
  looks risky would understate the discount rate. Added a `@details`
  note identifying the 0.5 percentage point difference.

* Refreshed every Green Book citation to the 2026 edition (published 5
  February 2026). The 2026 edition is a substantial restructuring: most
  annexes were merged into the core chapters, and the only surviving annex
  is "Annex A: Private finance models". References to "Annex A6"
  (discounting) and "Annex A3" (distributional analysis) therefore no
  longer resolve, and "Annex A on appraisal: equivalent annual cost" would
  now point at private finance models. Each citation was rechecked against
  the 2026 text rather than having its year swapped: discounting and
  inflation now sit in chapter 6, distributional analysis in chapter 7, and
  valuation of social costs and benefits in chapter 8. Equivalent annual
  cost does not appear in the 2026 main text, so `gb_eanc()` now cites the
  supplementary discounting guidance.

* Replaced the superseded "HM Treasury (2003). Green Book Supplementary
  Guidance: Discounting" reference in `gb_stpr()` and
  `gb_discount_factor()` with the current supplementary guidance and its
  gov.uk link.

* `gb_metb()` no longer claims 20 percent as a 2026 Green Book figure. The
  2026 edition specifies no uplift at all and states that "Practitioners
  should not generally include these costs in appraisal", because most
  proposals are funded from pre-determined departmental budgets so the cost
  of raising the funds does not differ between the options being compared.
  The one exception it gives is private finance model options. The bundled
  `metb.csv` note for 2026 previously read "Maintained at 20 percent in
  Green Book 2026", which was wrong. `vintage = "2026"` now warns that the
  figure is carried forward from 2022 rather than set by the 2026 edition,
  and a new documentation section explains when the function still applies.
  The returned value is unchanged, so existing code keeps working.

No changes to any returned value. The STPR schedule itself is unchanged.

# greenbook 0.1.0

* Initial release. Implements Phase 1 to Phase 3 cost-benefit
  analysis primitives from HM Treasury Green Book guidance.

## Discounting

* `gb_stpr()`, `gb_discount_factor()`, `gb_discount()`: kinked
  Social Time Preference Rate (standard, health, catastrophic-risk
  variants) and discount factors.
* `gb_npv()`, `gb_eanc()`: net present value and equivalent annual
  net cost.

## Real-terms rebasing

* `gb_deflator()`, `gb_real()`, `gb_rebase()`: GDP-deflator factors
  and real-terms conversion against a bundled vintage.

## Optimism bias

* `gb_optimism_bias()`, `gb_apply_ob()`, `gb_categories()`: lookups
  for the Mott MacDonald (2002) upper bounds across six project
  categories with mitigation factor support.

## Distributional analysis

* `gb_dist_weight()`, `gb_dist_weighted_npv()`: iso-elastic
  distributional weights using Green Book default eta = 1.3.

## Adjustments

* `gb_metb()`: Marginal Excess Tax Burden uplift with vintage
  lookup (20 percent in 2018+, 30 percent historical).

## Valuation library

* `gb_wellby()`: WELLBY conversion to GBP per HMT Wellbeing
  Guidance (July 2021). Central GBP 13,000 in 2019 prices.
* `gb_vpf()`: Value of Preventing a Fatality per DfT TAG.
  GBP 2.153 million in 2024 prices.
* `gb_qaly()`: Quality-Adjusted Life Year per DHSC supplementary
  Green Book guidance (GBP 70k) plus NICE thresholds.

## Carbon

* `gb_carbon_value()`: DESNZ Carbon Values for Appraisal,
  central / low / high paths, traded and non-traded sectors.
* `gb_carbon_npv()`: NPV of an emissions path with full
  discounting and rebasing.

## High-level appraisal

* `gb_appraise()`: end-to-end appraisal in one call. Optionally
  applies optimism bias and METB to costs, then computes NPV
  and BCR with full provenance.
* `gb_compare()`: side-by-side comparison of two or more options
  with NPV / BCR / EANC ranking and preferred-option selection.
* `gb_progression()`: track an appraisal across SOC, OBC, FBC
  business case stages.
* `gb_place_based()`: aggregate sub-projects into a place-based
  business case (per Green Book 2026), with optional synergy uplift.
* `gb_economic_case()`: wrap an appraisal in Five Case Model
  Economic Case structure (CSFs, options, monetised summary,
  non-monetised, VfM, recommendation).
* `gb_validate()`: lint an appraisal for sign-convention,
  base-year, schedule, and consistency errors.

## Risk

* `gb_risk_register()`: build a risk register with monetised
  exposure (probability x impact), aggregate by category, and
  optionally risk-adjust an appraisal NPV.

## Sensitivity

* `gb_sensitivity_ob()`: optimism bias sensitivity sweep across
  a vector of mitigation factors. Required at every Green Book
  business case gateway.

## Reporting

* `gb_headline()`: one-page summary with NPV, BCR, EANC, payback,
  and provenance.
* `gb_cost_per_unit()`: cost-effectiveness ratio (PV cost per
  QALY, WELLBY, tCO2e, etc.).
* `gb_to_latex()`: render an appraisal as a LaTeX table.
* `gb_to_excel()`: multi-sheet Excel export (requires
  `openxlsx`).
* `gb_to_word()`: one-page Word document export (requires
  `officer` and `flextable`).

## Lookups and provenance

* `gb_schedule_table()`, `gb_data_versions()`: tibble of the STPR
  schedule and vintage metadata for all eight bundled parameter
  tables (STPR, GDP deflator, optimism bias, METB, WELLBY, VPF,
  QALY, carbon values).
* `gb_appraisal` S3 class with `print()`, `summary()`, `format()`
  methods. The `summary()` method renders BCR, optimism bias,
  METB, distributional eta, and unweighted NPV when present.
