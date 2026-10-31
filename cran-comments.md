# CRAN submission comments: greenbook 0.2.0

## Purpose

HM Treasury revised the Green Book discount rate on 28 October 2026
(3.5 percent to 3.0 percent, with a flatter declining schedule capped at
125 years, and no separate health rate). This release makes the revised
schedule the default so that users following current UK government
guidance get correct results, and keeps the previous schedule available
through a `vintage` argument for reproducing earlier appraisals.

The default results of `gb_npv()`, `gb_appraise()`,
`gb_dist_weighted_npv()` and the discount-factor functions change as a
result. This is intentional and is documented in NEWS.md. The bundled
GDP deflator is also refreshed to the October 2026 release.

## R CMD check results

0 errors | 0 warnings | 0 notes (CRAN settings, R 4.5.2, macOS).

## Downstream dependencies

None on CRAN.
