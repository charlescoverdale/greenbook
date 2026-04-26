#' Track an appraisal across SOC, OBC, and FBC stages
#'
#' Builds a `gb_progression` showing how NPV, BCR, and key
#' parameters evolve across the three Green Book business case
#' stages: Strategic Outline Case (SOC), Outline Business Case
#' (OBC), and Full Business Case (FBC). Useful for both authoring
#' a multi-stage appraisal and reviewing how figures have moved
#' between gateway approvals.
#'
#' @param soc Strategic Outline Case `gb_appraisal`.
#' @param obc Outline Business Case `gb_appraisal`. Optional.
#' @param fbc Full Business Case `gb_appraisal`. Optional.
#'
#' @return A `gb_progression` object with elements `stages`,
#'   `evolution` (data frame), `delta_npv`, `delta_costs`.
#'
#' @details
#' At each stage, optimism bias mitigation typically increases as
#' project definition firms up. Cost estimates converge towards
#' base-cost reality; benefit estimates may also shift as evidence
#' accumulates. The `evolution` table makes the trajectory visible.
#'
#' @references HM Treasury (2018). Guide to Developing the Project
#'   Business Case (Green Book supplementary guidance).
#'
#' @family appraisal
#' @seealso [gb_appraise()].
#'
#' @export
#' @examples
#' soc <- gb_appraise(c(100, 0, 0, 0, 0), c(0, 30, 30, 30, 30),
#'                    ob = "non_standard_buildings", ob_mitigation = 0)
#' obc <- gb_appraise(c(100, 0, 0, 0, 0), c(0, 30, 30, 30, 30),
#'                    ob = "non_standard_buildings", ob_mitigation = 0.5)
#' fbc <- gb_appraise(c(100, 0, 0, 0, 0), c(0, 30, 30, 30, 30),
#'                    ob = "non_standard_buildings", ob_mitigation = 0.9)
#' gb_progression(soc, obc, fbc)
gb_progression <- function(soc, obc = NULL, fbc = NULL) {
  if (!inherits(soc, "gb_appraisal")) {
    cli::cli_abort("{.arg soc} must be a {.cls gb_appraisal}.")
  }
  stages <- list(SOC = soc)
  if (!is.null(obc)) {
    if (!inherits(obc, "gb_appraisal")) {
      cli::cli_abort("{.arg obc} must be a {.cls gb_appraisal}.")
    }
    stages$OBC <- obc
  }
  if (!is.null(fbc)) {
    if (!inherits(fbc, "gb_appraisal")) {
      cli::cli_abort("{.arg fbc} must be a {.cls gb_appraisal}.")
    }
    stages$FBC <- fbc
  }

  rows <- lapply(seq_along(stages), function(i) {
    a <- stages[[i]]
    data.frame(
      stage = names(stages)[i],
      npv = a$npv,
      bcr = a$bcr %||% NA_real_,
      pv_costs = a$pv_costs %||% NA_real_,
      pv_benefits = a$pv_benefits %||% NA_real_,
      ob_pct = a$optimism_bias %||% NA_real_,
      stringsAsFactors = FALSE
    )
  })
  evolution <- do.call(rbind, rows)

  delta_npv <- if (length(stages) >= 2L) diff(evolution$npv) else numeric(0)
  delta_costs <- if (length(stages) >= 2L) diff(evolution$pv_costs) else numeric(0)

  out <- list(
    stages = stages,
    evolution = evolution,
    delta_npv = delta_npv,
    delta_costs = delta_costs
  )
  class(out) <- c("gb_progression", "list")
  out
}

#' @export
print.gb_progression <- function(x, ...) {
  cli::cli_h1("Business case progression")
  cli::cli_text("Stages: {.val {names(x$stages)}}")
  cat("\n")
  print(x$evolution, row.names = FALSE)
  if (length(x$delta_npv) > 0L) {
    cat("\n")
    cli::cli_text("NPV changes: {paste(sprintf('%+.1f', x$delta_npv), collapse = ' -> ')}")
  }
  invisible(x)
}
