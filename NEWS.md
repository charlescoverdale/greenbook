# greenbook 0.1.0

* Initial release.
* `gb_stpr()`, `gb_discount_factor()`, `gb_discount()`: Green Book Social Time
  Preference Rate kinked schedule (standard, health, catastrophic-risk
  variants) and discount factors.
* `gb_npv()`, `gb_eanc()`: net present value and equivalent annual net cost.
* `gb_deflator()`, `gb_real()`, `gb_rebase()`: real-terms rebasing using a
  bundled GDP deflator vintage.
* `gb_schedule_table()`, `gb_data_versions()`: lookup helpers exposing
  bundled parameter tables and their vintages.
* `gb_appraisal` S3 class with `print()`, `summary()`, `format()` methods,
  carrying provenance: methodology vintage, schedule, base year.
