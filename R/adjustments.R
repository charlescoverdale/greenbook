#' Apply Marginal Excess Tax Burden to public expenditure
#'
#' Uplifts net public expenditure (or revenue raised) to reflect
#' the welfare cost of distortionary taxation. Default rate is
#' 20 percent per Green Book 2022 / 2026. The historic value (2003)
#' was 30 percent.
#'
#' @param values Numeric vector of expenditure values.
#' @param rate Numeric scalar. METB rate as a decimal. Default
#'   `0.20`.
#' @param vintage Optional character. One of `"2003"`, `"2018"`,
#'   `"2022"`, `"2026"`. If supplied, overrides `rate` with the
#'   bundled value for that vintage.
#'
#' @return A numeric vector the same length as `values`, with the
#'   METB uplift applied.
#'
#' @export
#' @examples
#' gb_metb(c(100, 200))
#' gb_metb(c(100, 200), vintage = "2003")
gb_metb <- function(values, rate = 0.20, vintage = NULL) {
  validate_numeric(values, "values")

  if (!is.null(vintage)) {
    metb_tbl <- .read_metb()
    if (!vintage %in% metb_tbl$vintage) {
      cli::cli_abort(
        "Unknown vintage. Available: {paste(metb_tbl$vintage, collapse = ', ')}."
      )
    }
    rate <- metb_tbl$rate[metb_tbl$vintage == vintage]
  }

  validate_numeric(rate, "rate")
  if (length(rate) != 1L) cli::cli_abort("{.arg rate} must be scalar.")
  if (rate < 0 || rate > 1) cli::cli_abort("{.arg rate} must be in [0, 1].")

  values * (1 + rate)
}
