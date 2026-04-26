#' Wellbeing valuation in GBP (WELLBY)
#'
#' Monetises a life-satisfaction change as Well-being Adjusted
#' Life Years (WELLBYs) per HMT Wellbeing Guidance for Appraisal
#' (July 2021). One WELLBY equals a one-point change in life
#' satisfaction on a 0 to 10 scale, for one person, for one year.
#' The central published unit value is GBP 13,000 in 2019 prices,
#' with a low-high sensitivity of GBP 10,000 to GBP 16,000.
#'
#' @param life_satisfaction_change Numeric scalar or vector. Change
#'   in life satisfaction on the 0 to 10 scale (signed; can be
#'   positive or negative).
#' @param persons Number of people experiencing the change.
#' @param years Duration in years. Default `1`.
#' @param base_year Optional integer base year to express the
#'   monetary value in. If `NULL` (default), the published 2019
#'   price is returned. Otherwise the value is uplifted via
#'   `gb_deflator()` to `base_year` prices.
#' @param scenario One of `"low"`, `"central"` (default), `"high"`.
#'
#' @return A numeric scalar or vector: the WELLBY value in GBP at
#'   the requested base year.
#'
#' @references HM Treasury (2021). Wellbeing Guidance for Appraisal:
#'   Supplementary Green Book Guidance.
#'
#' @family valuation
#' @seealso [gb_vpf()], [gb_qaly()].
#'
#' @export
#' @examples
#' # 1-point lift in life satisfaction for 100 people for 5 years
#' gb_wellby(1, persons = 100, years = 5)
#' gb_wellby(1, persons = 100, years = 5, scenario = "low")
#' # Express in 2024 prices
#' gb_wellby(1, persons = 100, years = 5, base_year = 2024)
gb_wellby <- function(life_satisfaction_change, persons, years = 1,
                      base_year = NULL, scenario = "central") {
  validate_numeric(life_satisfaction_change, "life_satisfaction_change")
  validate_numeric(persons, "persons", require_positive = FALSE)
  validate_numeric(years, "years")
  scenario <- match.arg(scenario, c("low", "central", "high"))

  tbl <- .read_wellby()
  unit_2019 <- tbl$value_gbp[tbl$scenario == scenario]
  pub_base <- tbl$base_year[tbl$scenario == scenario]

  if (!is.null(base_year) && base_year != pub_base) {
    unit <- unit_2019 * gb_deflator(pub_base, base_year)
  } else {
    unit <- unit_2019
  }

  life_satisfaction_change * persons * years * unit
}

#' Value of Preventing a Fatality
#'
#' Returns the DfT TAG-published Value of Preventing a Fatality
#' (VPF) in real terms for a given year. The published 2024 value
#' is GBP 2.153 million; the historical 2018 value (DfT TAG) is
#' GBP 1.958 million. Years between bundled publication dates are
#' filled by an annual real uplift of approximately 2 percent
#' (proxy for real GDP per head growth).
#'
#' @param year Integer scalar. The year in which the value is
#'   expressed. Default `2024` (the most recent DfT-published
#'   value).
#' @param series Character. `"central"` (default). Reserved for
#'   future expansion (DfT cancer / aversion multipliers).
#'
#' @return Numeric scalar: the VPF in GBP at year `year` prices.
#'
#' @references Department for Transport. Transport Analysis
#'   Guidance (TAG) data book.
#'
#' @family valuation
#' @seealso [gb_wellby()], [gb_qaly()].
#'
#' @export
#' @examples
#' gb_vpf()
#' gb_vpf(2018)
gb_vpf <- function(year = 2024, series = "central") {
  series <- match.arg(series, c("central"))
  validate_year(year, "year", min_year = 1900L)
  if (length(year) != 1L) cli::cli_abort("{.arg year} must be scalar.")

  tbl <- .read_vpf()
  if (!(year %in% tbl$year)) {
    cli::cli_abort(
      "Year {.val {year}} outside bundled VPF range ({min(tbl$year)} to {max(tbl$year)})."
    )
  }
  tbl$value_gbp[tbl$year == year]
}

#' Value of a Quality-Adjusted Life Year
#'
#' Returns the QALY value in GBP at the published base year. The
#' DHSC supplementary Green Book guidance specifies GBP 70,000 per
#' QALY in 2024 prices for cross-government appraisal. NICE Health
#' Technology Assessment uses lower thresholds (GBP 20,000 to
#' GBP 30,000 per QALY).
#'
#' @param qalys Numeric scalar or vector. Quality-Adjusted Life
#'   Years gained or lost.
#' @param scenario One of `"dhsc"` (default, GBP 70k 2024 prices,
#'   cross-government), `"nice_lower"` (GBP 20k), `"nice_upper"`
#'   (GBP 30k).
#' @param base_year Optional integer base year. If `NULL`, the
#'   published base year for the chosen scenario is used.
#'
#' @return A numeric scalar or vector: monetised value in GBP.
#'
#' @references DHSC Supplementary Green Book Guidance on health
#'   appraisal. NICE methods guides for technology appraisal.
#'
#' @family valuation
#' @seealso [gb_wellby()], [gb_vpf()].
#'
#' @export
#' @examples
#' gb_qaly(1)
#' gb_qaly(1, scenario = "nice_upper")
gb_qaly <- function(qalys, scenario = "dhsc", base_year = NULL) {
  validate_numeric(qalys, "qalys")
  scenario <- match.arg(scenario, c("dhsc", "nice_lower", "nice_upper"))

  tbl <- .read_qaly()
  unit <- tbl$value_gbp[tbl$scenario == scenario]
  pub_base <- tbl$base_year[tbl$scenario == scenario]

  if (!is.null(base_year) && base_year != pub_base) {
    unit <- unit * gb_deflator(pub_base, base_year)
  }

  qalys * unit
}
