# CRAN submission comments — greenbook 0.1.1

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

Two documentation corrections, no change to any returned value:

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

* Replaced the superseded "HM Treasury (2003). Green Book Supplementary
  Guidance: Discounting" reference with the current supplementary
  guidance and its gov.uk link.

The bundled STPR schedule is unchanged, so results are identical to
0.1.0.

## R CMD check results

0 errors | 0 warnings | 0 notes (CRAN default settings, R 4.5.2, macOS).

## Downstream dependencies

None on CRAN.
