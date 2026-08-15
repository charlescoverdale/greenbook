# CRAN submission comments: greenbook 0.1.1

## Maintainer email change

**This submission changes the maintainer address**, from
`charles.f.coverdale@gmail.com` (the address on the 0.1.0 CRAN record)
to `charlesfcoverdale@gmail.com`.

Both addresses are the same Gmail inbox: Gmail ignores dots in the local
part, so mail to either is delivered to me. Every other package I
maintain on CRAN uses the undotted form, and the dotted form on this one
record places greenbook on a separate maintainer check-results page from
the other 28, which makes it easy to miss when reviewing check status.
This submission aligns greenbook with the rest.

I understand CRAN will send a confirmation to the previous address. I
have access to it and will confirm.

## Also in this release

Corrections to documentation and to the metadata of one bundled
parameter table. No returned value changes anywhere in the package, and
the bundled STPR schedule is unchanged, so numeric results are identical
to 0.1.0. One new warning is signalled, noted below.

* The `"catastrophic"` STPR schedule was described as being "for
  projects where catastrophic risk dominates". That inverts the
  guidance. The 3.0 percent schedule is the standard schedule with the
  catastrophic-risk element of pure time preference removed, intended
  for appraisals that already model catastrophic risk explicitly so that
  it is not counted twice, once in the cashflows and again in the rate.
  As written, the documentation would have led a user to apply a lower
  discount rate precisely where no adjustment was warranted. Corrected
  in `gb_stpr()` and `gb_discount_factor()`, with a `@details` note
  identifying the 0.5 percentage point difference between the two
  baselines.

* Refreshed every Green Book citation to the 2026 edition, published 5
  February 2026. This was not a year swap. The 2026 edition merges most
  annexes into the core chapters, leaving "Annex A: Private finance
  models" as the only surviving annex, so the previous references to
  "Annex A6" and "Annex A3" no longer resolve and one further reference
  to an appraisal annex would now resolve to private finance models.
  Each citation was rechecked against the 2026 text: discounting and
  inflation to chapter 6, distributional analysis to chapter 7,
  valuation of social costs and benefits to chapter 8, options analysis
  to chapters 5 and 6. Equivalent annual cost does not appear in the
  2026 main text, so `gb_eanc()` now cites the supplementary discounting
  guidance instead.

* Replaced the superseded "HM Treasury (2003). Green Book Supplementary
  Guidance: Discounting" reference with the current supplementary
  guidance and its gov.uk link.

* `gb_metb()` no longer presents 20 percent as a figure set by the 2026
  Green Book. The 2026 edition specifies no marginal excess tax burden
  and states that "Practitioners should not generally include these
  costs in appraisal", since most proposals are funded from
  pre-determined departmental budgets and the cost of raising the funds
  therefore does not differ between the options being compared (chapter
  6). The one exception it gives is private finance model options. The
  bundled note for the 2026 vintage previously read "Maintained at 20
  percent in Green Book 2026", which was wrong, and a user appraising on
  a 2026 basis would have applied an uplift the current guidance directs
  them to leave out, overstating costs.

  **This is the one behavioural change in the release.** The rate is
  left at 0.20 so existing code keeps working and the returned value is
  unchanged, but `gb_metb(vintage = "2026")` now emits a warning saying
  the figure is carried forward from 2022 rather than set by the 2026
  edition. Only that explicit argument triggers it: the default `rate`
  path is silent, and `gb_appraise()` passes `rate` rather than
  `vintage`, so no existing appraisal workflow starts warning. A new
  documentation section explains when the function still applies.

## R CMD check results

0 errors | 0 warnings | 0 notes (CRAN default settings, R 4.5.2, macOS).

## Downstream dependencies

None on CRAN.
