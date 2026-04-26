# CRAN submission comments: greenbook 0.1.0

## New submission

This is a new package providing cost-benefit analysis primitives from
HM Treasury Green Book guidance (UK central government appraisal):
the kinked Social Time Preference Rate, discount factors, net present
value, equivalent annual cost, GDP-deflator rebasing, optimism bias,
distributional weighting, Marginal Excess Tax Burden, WELLBY wellbeing
valuation, VPF, QALY, DESNZ carbon values, and a one-call full
appraisal with multi-option comparison and Five Case Model wrappers.

## R CMD check results

0 errors | 0 warnings | 1 note (anticipated: new submission)

Local `R CMD check --as-cran` is clean apart from the expected
"New submission" note.

## Test suite

307 expectations under testthat 3rd edition. All tests are pure
computation (no network, no API). Known-value tests verify the STPR
kinked schedule, optimism bias upper bounds, WELLBY central / low /
high values, VPF anchor, and DESNZ carbon path against the published
HMT, DfT, DESNZ, and Mott MacDonald source values. Invariant tests
cross-check against closed-form annuity factors.

## Notes on data access

No network access. All bundled parameter tables (STPR, GDP deflator,
optimism bias, METB, WELLBY, VPF, QALY, DESNZ carbon path) ship in
`inst/extdata/` as CSV with vintage metadata exposed via
`gb_data_versions()`. Refresh scripts in `data-raw/` download the
published HMT, DfT, and DESNZ workbooks and regenerate the bundled
CSVs.

## Suggested packages

`openxlsx`, `officer`, and `flextable` are in Suggests for optional
Excel and Word export. Functions guard with `requireNamespace()` and
skip tests when the optional package is unavailable.

## Downstream dependencies

None.
