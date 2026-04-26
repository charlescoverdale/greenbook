#' Full Green Book appraisal in one call
#'
#' Runs an end-to-end appraisal: optionally applies optimism bias to
#' costs, optionally applies METB, computes NPV under the kinked
#' STPR, and returns BCR alongside provenance.
#'
#' @param costs Numeric vector of cost values per period (real
#'   terms, base year fixed). Sign convention: enter as positive
#'   numbers; `gb_appraise()` handles the netting.
#' @param benefits Numeric vector of benefit values per period.
#'   Same length as `costs`.
#' @param years Optional integer vector of years. Defaults to
#'   `0:(length(costs) - 1)`.
#' @param schedule One of `"standard"`, `"health"`, `"catastrophic"`.
#' @param ob Optional. Either a category name (character) or a
#'   numeric percentage. If supplied, optimism bias uplift is
#'   applied to `costs`.
#' @param ob_dimension One of `"capex"` (default) or `"duration"`.
#'   Only used when `ob` is a category name.
#' @param ob_mitigation Numeric in `[0, 1]`. Mitigation fraction.
#' @param metb Logical. If `TRUE`, applies METB uplift to costs.
#' @param metb_rate Numeric. METB rate when `metb = TRUE`. Default
#'   `0.20` per Green Book 2022.
#' @param base_year Optional integer base year.
#' @param vintage Methodology vintage label. Default `"2022"`.
#'
#' @return A `gb_appraisal` object with extra fields `bcr`,
#'   `pv_costs`, `pv_benefits`, `costs`, `benefits`,
#'   `optimism_bias`, `metb_applied`.
#'
#' @export
#' @examples
#' costs <- c(100, 50, 50, 0, 0, 0, 0, 0, 0, 0)
#' benefits <- c(0, 0, 0, 30, 30, 30, 30, 30, 30, 30)
#' app <- gb_appraise(costs, benefits, ob = "non_standard_buildings",
#'                    ob_mitigation = 0.5, base_year = 2024)
#' app
gb_appraise <- function(costs, benefits,
                        years = NULL,
                        schedule = "standard",
                        ob = NULL,
                        ob_dimension = "capex",
                        ob_mitigation = 0,
                        metb = FALSE,
                        metb_rate = 0.20,
                        base_year = NULL,
                        vintage = "2022") {
  validate_numeric(costs, "costs")
  validate_numeric(benefits, "benefits")
  if (length(costs) != length(benefits)) {
    cli::cli_abort("{.arg costs} and {.arg benefits} must have equal length.")
  }
  schedule <- match.arg(schedule, c("standard", "health", "catastrophic"))

  costs_adj <- costs
  ob_pct_used <- NULL
  if (!is.null(ob)) {
    if (is.character(ob)) {
      ob_pct_used <- gb_optimism_bias(ob, dimension = ob_dimension)
    } else if (is.numeric(ob) && length(ob) == 1L) {
      ob_pct_used <- ob
    } else {
      cli::cli_abort("{.arg ob} must be a category name or a numeric scalar.")
    }
    costs_adj <- gb_apply_ob(costs_adj, ob_pct_used, mitigation = ob_mitigation)
  }

  if (isTRUE(metb)) {
    costs_adj <- gb_metb(costs_adj, rate = metb_rate)
  }

  net <- benefits - costs_adj
  if (is.null(years)) years <- seq_along(net) - 1L

  pv_net <- gb_discount(net, years = years, schedule = schedule)
  pv_costs <- sum(gb_discount(costs_adj, years = years, schedule = schedule))
  pv_benefits <- sum(gb_discount(benefits, years = years, schedule = schedule))

  out <- list(
    npv = sum(pv_net),
    bcr = if (pv_costs > 0) pv_benefits / pv_costs else NA_real_,
    pv_costs = pv_costs,
    pv_benefits = pv_benefits,
    cashflow = net,
    costs = costs_adj,
    benefits = benefits,
    years = years,
    pv = pv_net,
    schedule = schedule,
    base_year = base_year,
    vintage = vintage,
    optimism_bias = ob_pct_used,
    metb_applied = isTRUE(metb)
  )
  class(out) <- c("gb_appraisal", "list")
  out
}
