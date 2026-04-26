#' DESNZ carbon value for appraisal
#'
#' Returns the DESNZ (formerly BEIS) Carbon Value for Appraisal in
#' GBP per tonne of CO2-equivalent at the published base year prices.
#' Three scenarios (low, central, high) and two series (traded,
#' non-traded). The traded / non-traded distinction is being phased
#' out as UK ETS coverage expands; the bundled values converge.
#'
#' @param year Integer scalar or vector. Year of the emission.
#' @param scenario One of `"low"`, `"central"` (default), `"high"`.
#' @param series One of `"traded"` (default), `"non_traded"`.
#' @param base_year Optional integer to rebase the value via
#'   `gb_deflator()`. If `NULL`, the published base year is used.
#'
#' @return Numeric vector of GBP per tCO2e values.
#'
#' @references DESNZ (2023). Valuation of Energy Use and Greenhouse
#'   Gas Emissions for Appraisal (November 2023).
#'
#' @export
#' @examples
#' gb_carbon_value(2024)
#' gb_carbon_value(2020:2030)
#' gb_carbon_value(2030, scenario = "high")
gb_carbon_value <- function(year, scenario = "central", series = "traded",
                            base_year = NULL) {
  scenario <- match.arg(scenario, c("low", "central", "high"))
  series <- match.arg(series, c("traded", "non_traded"))
  validate_year(year, "year", min_year = 1900L)

  tbl <- .read_carbon()
  rng <- range(tbl$year)
  if (any(year < rng[1]) || any(year > rng[2])) {
    cli::cli_abort(
      "{.arg year} outside bundled carbon value range ({rng[1]} to {rng[2]})."
    )
  }

  rows <- tbl$series == series & tbl$scenario == scenario
  sub <- tbl[rows, ]
  pub_base <- sub$base_year[1]

  out <- vapply(year, function(y) {
    val <- sub$value_gbp_per_tco2e[sub$year == y]
    if (length(val) == 0L) {
      cli::cli_abort("No bundled value for year {.val {y}}.")
    }
    val
  }, numeric(1))

  if (!is.null(base_year) && base_year != pub_base) {
    out <- out * gb_deflator(pub_base, base_year)
  }
  out
}

#' Net present value of an emissions path
#'
#' Multiplies an emissions vector (tCO2e per year) by the DESNZ
#' carbon value at each year, then discounts under the kinked STPR.
#' Returns a `gb_appraisal` object.
#'
#' @param emissions Numeric vector of emissions per year, in tCO2e
#'   (positive = emitted, negative = avoided / abated).
#' @param years Integer vector of years matching `emissions`.
#' @param scenario One of `"low"`, `"central"` (default), `"high"`.
#' @param series One of `"traded"` (default), `"non_traded"`.
#' @param schedule One of `"standard"` (default), `"health"`,
#'   `"catastrophic"`.
#' @param base_year Optional integer base year for monetary values
#'   (e.g. `2024`). If supplied, carbon values are rebased via
#'   `gb_deflator()`.
#' @param sign Character. `"cost"` (default) treats positive
#'   `emissions` as a cost (negative cashflow); `"benefit"` treats
#'   positive as avoided emissions (positive cashflow).
#'
#' @return A `gb_appraisal` object.
#'
#' @export
#' @examples
#' # 100 tCO2e emitted each year from 2024 to 2030
#' emissions <- rep(100, 7)
#' years <- 2024:2030
#' gb_carbon_npv(emissions, years, base_year = 2024)
gb_carbon_npv <- function(emissions, years,
                          scenario = "central", series = "traded",
                          schedule = "standard",
                          base_year = NULL,
                          sign = "cost") {
  validate_numeric(emissions, "emissions")
  validate_year(years, "years", min_year = 1900L)
  if (length(emissions) != length(years)) {
    cli::cli_abort("{.arg emissions} and {.arg years} must have equal length.")
  }
  sign <- match.arg(sign, c("cost", "benefit"))

  values_per_t <- gb_carbon_value(years, scenario = scenario,
                                  series = series, base_year = base_year)
  cashflow <- emissions * values_per_t
  if (sign == "cost") cashflow <- -cashflow

  rel_years <- years - min(years)
  app <- gb_npv(cashflow, years = rel_years, schedule = schedule,
                base_year = base_year %||% min(years))
  app$emissions <- emissions
  app$years_calendar <- years
  app$carbon_scenario <- scenario
  app$carbon_series <- series
  app$emissions_sign <- sign
  app
}
