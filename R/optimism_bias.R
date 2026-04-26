#' Optimism bias upper bound for a project category
#'
#' Returns the indicative upper-bound optimism bias percentage from
#' HM Treasury Supplementary Green Book Guidance: Optimism Bias
#' (Mott MacDonald 2002, Annex A1). The upper bound is the starting
#' value for ex-ante uplift; mitigation factors reduce it as project
#' definition matures through SOC, OBC, and FBC stages.
#'
#' @param category Character. One of
#'   `"standard_buildings"`, `"non_standard_buildings"`,
#'   `"standard_civil_engineering"`,
#'   `"non_standard_civil_engineering"`,
#'   `"equipment_development"`, `"outsourcing"`.
#' @param dimension Character. `"capex"` (default) for capital
#'   expenditure uplift, or `"duration"` for works-duration uplift.
#'
#' @return Numeric scalar: the upper-bound percentage as a decimal
#'   (e.g. 0.51 for 51 percent).
#'
#' @references
#' HM Treasury (2003). Supplementary Green Book Guidance: Optimism
#' Bias.
#'
#' Mott MacDonald (2002). Review of Large Public Procurement in the
#' UK. Report commissioned by HM Treasury.
#'
#' @family optimism bias
#' @seealso [gb_apply_ob()], [gb_categories()], [gb_appraise()].
#'
#' @export
#' @examples
#' gb_optimism_bias("non_standard_buildings")
#' gb_optimism_bias("standard_civil_engineering", dimension = "duration")
gb_optimism_bias <- function(category, dimension = "capex") {
  dimension <- match.arg(dimension, c("capex", "duration"))
  tbl <- .read_optimism_bias()
  category <- match.arg(category, tbl$category)
  col <- if (dimension == "capex") "capex_upper" else "duration_upper"
  tbl[[col]][tbl$category == category]
}

#' Apply an optimism bias uplift to a cost stream
#'
#' Applies an OB uplift, optionally with a mitigation factor that
#' represents progress on risk identification and management:
#' `cost_with_ob = cost_baseline * (1 + ob_pct * (1 - mitigation))`.
#'
#' @param values Numeric vector of baseline cost values.
#' @param ob_pct Numeric scalar. Optimism bias percentage as a
#'   decimal. Pass `gb_optimism_bias(category)` to use the published
#'   upper bound.
#' @param mitigation Numeric scalar in `[0, 1]`. Fraction of the
#'   upper bound that has been mitigated through project definition
#'   and risk management. Default `0` (no mitigation; full upper
#'   bound applied).
#'
#' @return A numeric vector the same length as `values`, with the
#'   uplift applied.
#'
#' @references HM Treasury (2003). Supplementary Green Book Guidance:
#'   Optimism Bias, Annex A2 on mitigation factors.
#'
#' @family optimism bias
#' @seealso [gb_optimism_bias()], [gb_appraise()].
#'
#' @export
#' @examples
#' costs <- c(100, 50, 50)
#' ob <- gb_optimism_bias("non_standard_buildings")
#' gb_apply_ob(costs, ob)
#' gb_apply_ob(costs, ob, mitigation = 0.5)
gb_apply_ob <- function(values, ob_pct, mitigation = 0) {
  validate_numeric(values, "values")
  validate_numeric(ob_pct, "ob_pct")
  validate_numeric(mitigation, "mitigation")
  if (length(ob_pct) != 1L) cli::cli_abort("{.arg ob_pct} must be scalar.")
  if (length(mitigation) != 1L) cli::cli_abort("{.arg mitigation} must be scalar.")
  if (mitigation < 0 || mitigation > 1) {
    cli::cli_abort("{.arg mitigation} must be in [0, 1].")
  }
  values * (1 + ob_pct * (1 - mitigation))
}

#' Available optimism bias categories
#'
#' Returns the bundled OB category lookup as a data frame.
#'
#' @return A data frame with columns `category`, `description`,
#'   `capex_upper`, `duration_upper`.
#'
#' @references HM Treasury (2003). Supplementary Green Book Guidance:
#'   Optimism Bias.
#'
#' @family optimism bias
#' @seealso [gb_optimism_bias()].
#'
#' @export
#' @examples
#' gb_categories()
gb_categories <- function() {
  tbl <- .read_optimism_bias()
  tbl[, c("category", "description", "capex_upper", "duration_upper")]
}
