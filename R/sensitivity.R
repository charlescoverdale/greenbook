#' Optimism bias sensitivity sweep
#'
#' Recomputes an appraisal across a vector of optimism bias
#' mitigation factors. Convenience wrapper for the standard HMT
#' OB sensitivity test required at SOC, OBC, and FBC stages.
#'
#' @param costs Numeric vector of cost values.
#' @param benefits Numeric vector of benefit values.
#' @param ob Either a category name or a numeric OB percentage.
#' @param mitigations Numeric vector in `[0, 1]`. Mitigation
#'   fractions to test. Default `c(0, 0.25, 0.5, 0.75, 1.0)`.
#' @param ... Passed to `gb_appraise()`.
#'
#' @return A `gb_sensitivity_ob` object: a list with elements
#'   `mitigations`, `npv`, `bcr`, `costs_pv`.
#'
#' @family appraisal
#' @seealso [gb_appraise()], [gb_apply_ob()].
#'
#' @export
#' @examples
#' costs <- c(100, 50, 50, 0, 0, 0, 0, 0, 0, 0)
#' benefits <- c(0, 0, 0, 30, 30, 30, 30, 30, 30, 30)
#' gb_sensitivity_ob(costs, benefits, ob = "non_standard_buildings")
gb_sensitivity_ob <- function(costs, benefits,
                              ob,
                              mitigations = c(0, 0.25, 0.5, 0.75, 1.0),
                              ...) {
  validate_numeric(mitigations, "mitigations")
  if (any(mitigations < 0 | mitigations > 1)) {
    cli::cli_abort("{.arg mitigations} must all be in [0, 1].")
  }

  results <- lapply(mitigations, function(m) {
    app <- gb_appraise(costs, benefits, ob = ob, ob_mitigation = m, ...)
    data.frame(
      mitigation = m,
      npv = app$npv,
      bcr = app$bcr %||% NA_real_,
      pv_costs = app$pv_costs %||% NA_real_,
      stringsAsFactors = FALSE
    )
  })
  tbl <- do.call(rbind, results)

  out <- list(
    mitigations = mitigations,
    table = tbl,
    npv = tbl$npv,
    bcr = tbl$bcr
  )
  class(out) <- c("gb_sensitivity_ob", "list")
  out
}

#' @export
print.gb_sensitivity_ob <- function(x, ...) {
  cli::cli_h1("Optimism bias sensitivity")
  cat("\n")
  print(x$table, row.names = FALSE)
  invisible(x)
}
