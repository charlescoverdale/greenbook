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
