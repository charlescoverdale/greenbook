#' Apply Marginal Excess Tax Burden to public expenditure
#'
#' Uplifts net public expenditure (or revenue raised) to reflect
#' the welfare cost of distortionary taxation. Default rate is
#' 20 percent, the value set out in the 2018 and 2022 Green Book
#' editions. The historic value (2003) was 30 percent.
#'
#' @section Status under the 2026 Green Book:
#' The 2026 Green Book does not specify an uplift, and states that
#' "Practitioners should not generally include these costs in
#' appraisal", on the grounds that most proposals are funded from
#' pre-determined departmental budgets so the cost of raising the funds
#' does not differ between the options being compared (chapter 6,
#' "Costs of raising public funds"). The one exception it gives is the
#' appraisal of private finance model options.
#'
#' This function is therefore retained for historic and private-finance
#' work rather than as a routine step. Applying it to a conventional
#' 2026-basis appraisal will overstate costs. Requesting
#' `vintage = "2026"` warns for that reason: the 20 percent figure is
#' carried forward from 2022, not a value the 2026 edition sets.
#'
#' @param values Numeric vector of expenditure values.
#' @param rate Numeric scalar. METB rate as a decimal. Default
#'   `0.20`.
#' @param vintage Optional character. One of `"2003"`, `"2018"`,
#'   `"2022"`, `"2026"`. If supplied, overrides `rate` with the
#'   bundled value for that vintage. `"2026"` warns: see the section
#'   below.
#'
#' @return A numeric vector the same length as `values`, with the
#'   METB uplift applied.
#'
#' @details
#' The METB captures the welfare loss arising from raising one extra
#' GBP of revenue through the tax system, beyond the GBP itself.
#' Estimates depend on the elasticity of taxable income, the marginal
#' tax rate, and the distortionary margin. The Green Book reduced the
#' headline value from 30 percent (2003) to 20 percent (2018) in
#' light of post-2008 evidence.
#'
#' @references HM Treasury (2026). The Green Book: Central Government
#'   Guidance on Appraisal and Evaluation, chapter 6 (Shortlist
#'   appraisal), section on the costs of raising public funds.
#'
#' @family adjustments
#' @seealso [gb_appraise()].
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

    if (identical(as.character(vintage), "2026")) {
      cli::cli_warn(c(
        "The 2026 Green Book does not set a marginal excess tax burden.",
        "i" = "It states that the costs of raising public funds should not
               generally be included in appraisal, the exception being
               private finance model options (chapter 6).",
        "i" = "The {.val 0.2} rate returned here is carried forward from the
               2022 edition."
      ))
    }
  }

  validate_numeric(rate, "rate")
  if (length(rate) != 1L) cli::cli_abort("{.arg rate} must be scalar.")
  if (rate < 0 || rate > 1) cli::cli_abort("{.arg rate} must be in [0, 1].")

  values * (1 + rate)
}
