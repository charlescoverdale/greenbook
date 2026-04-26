# greenbook 0.1.0

* Initial release. Implements the Phase 1 and Phase 2 cost-benefit
  analysis primitives from HM Treasury Green Book guidance.

## Discounting

* `gb_stpr()`, `gb_discount_factor()`, `gb_discount()`: kinked Social
  Time Preference Rate (standard, health, catastrophic-risk variants)
  and discount factors that handle band transitions correctly.
* `gb_npv()`, `gb_eanc()`: net present value and equivalent annual
  net cost.

## Real-terms rebasing

* `gb_deflator()`, `gb_real()`, `gb_rebase()`: GDP-deflator factors
  and real-terms conversion against a bundled vintage. Future
  versions will pull live data via the `inflateR` package
  (Suggests).

## Optimism bias

* `gb_optimism_bias()`, `gb_apply_ob()`, `gb_categories()`: lookups
  for the Mott MacDonald (2002) upper bounds across six project
  categories, with mitigation factor support.

## Distributional analysis

* `gb_dist_weight()`, `gb_dist_weighted_npv()`: iso-elastic
  distributional weights using Green Book default eta = 1.3, with
  flexible reference-income strategies.

## Adjustments

* `gb_metb()`: Marginal Excess Tax Burden uplift, with vintage
  lookup for 2003 / 2018 / 2022 / 2026 Green Book editions.

## High-level appraisal

* `gb_appraise()`: end-to-end appraisal in one call. Optionally
  applies optimism bias and METB to costs, then computes NPV and
  BCR with full provenance.

## Lookups and provenance

* `gb_schedule_table()`, `gb_data_versions()`: tibble of the STPR
  schedule and vintage metadata for every bundled parameter table.
* `gb_appraisal` S3 class with `print()`, `summary()`, `format()`
  methods. The `summary()` method renders BCR, optimism bias,
  METB, and distributional eta when present.
