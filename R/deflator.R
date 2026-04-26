#' GDP deflator factor between two years
#'
#' Returns the multiplicative factor to convert a value expressed in
#' year `from` prices to year `to` prices, using the bundled UK GDP
#' deflator at market prices (ONS series). Multiply a nominal value
#' from year `from` by this factor to express it in year `to`.
#'
#' @param from Integer year of the input value.
#' @param to Integer year to express the value in.
#' @param source Character. `"bundled"` uses the CSV shipped in
#'   `inst/extdata/`. Future versions will accept `"inflateR"` to use
#'   the live ONS series via the `inflateR` package.
#'
#' @return A numeric scalar: the deflator factor.
#'
#' @export
#' @examples
#' gb_deflator(from = 2020, to = 2024)
gb_deflator <- function(from, to, source = "bundled") {
  source <- match.arg(source, c("bundled"))
  if (length(from) != 1L || length(to) != 1L) {
    cli::cli_abort("{.arg from} and {.arg to} must be scalar.")
  }
  validate_year(from, "from", min_year = 1900L)
  validate_year(to, "to", min_year = 1900L)

  defl <- .read_deflator()
  rng <- range(defl$year)
  if (!(from %in% defl$year) || !(to %in% defl$year)) {
    cli::cli_abort(
      "{.arg from}/{.arg to} ({from}, {to}) outside bundled deflator range ({rng[1]} to {rng[2]})."
    )
  }
  defl$value[defl$year == to] / defl$value[defl$year == from]
}

#' Convert nominal values to real
#'
#' Converts nominal values at year-of-occurrence prices to real values
#' at a chosen base year, using the bundled GDP deflator.
#'
#' @param nominal_values Numeric vector of nominal values.
#' @param year Integer scalar or vector matching `nominal_values`,
#'   giving the year at which each value is expressed in nominal terms.
#' @param base_year Integer scalar: the base year to convert to.
#' @param source Character. `"bundled"` only in v0.1.0.
#'
#' @return A numeric vector of real values, in `base_year` prices.
#'
#' @export
#' @examples
#' gb_real(nominal_values = c(100, 110, 120),
#'         year = 2020:2022,
#'         base_year = 2024)
gb_real <- function(nominal_values, year, base_year, source = "bundled") {
  validate_numeric(nominal_values, "nominal_values")
  if (length(year) == 1L) year <- rep_len(year, length(nominal_values))
  if (length(year) != length(nominal_values)) {
    cli::cli_abort("{.arg year} must be scalar or same length as {.arg nominal_values}.")
  }
  validate_year(base_year, "base_year", min_year = 1900L)
  if (length(base_year) != 1L) cli::cli_abort("{.arg base_year} must be scalar.")

  factors <- vapply(
    year,
    function(y) gb_deflator(from = y, to = base_year, source = source),
    numeric(1)
  )
  nominal_values * factors
}

#' Rebase a real-terms series to a different base year
#'
#' Multiplies values currently in `from`-year real prices by the
#' deflator factor to express them in `to`-year real prices.
#'
#' @param values Numeric vector of real-terms values.
#' @param from Integer base year of the input series.
#' @param to Integer target base year.
#'
#' @return A numeric vector of values in `to`-year real prices.
#'
#' @export
#' @examples
#' gb_rebase(c(100, 200, 300), from = 2020, to = 2024)
gb_rebase <- function(values, from, to) {
  validate_numeric(values, "values")
  values * gb_deflator(from = from, to = to)
}
