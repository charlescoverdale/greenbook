# CRAN submission comments: greenbook 0.1.0

## New submission

This is a new package providing cost-benefit analysis primitives from HM
Treasury Green Book guidance (UK central government appraisal): kinked
Social Time Preference Rate, discount factors, net present value,
equivalent annual cost, and GDP-deflator rebasing.

## R CMD check results

0 errors | 0 warnings | 0 notes

## Test suite

100+ expectations under testthat 3rd edition. All tests are pure
computation (no network, no API). Known-value tests verify the STPR
kinked schedule against Green Book Annex A6 published values.

## Notes on data access

No network access. All bundled parameter tables (STPR schedule, GDP
deflator) ship in `inst/extdata/` as CSV with vintage metadata,
refreshed via `data-raw/` scripts.

## Downstream dependencies

None.
