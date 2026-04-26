#' Build a risk register with monetised exposure
#'
#' Creates a `gb_risk_register` from a data frame of project risks.
#' Computes expected loss per risk (probability times impact) and
#' aggregate exposure. Optionally applied to a `gb_appraisal` to
#' produce a risk-adjusted NPV.
#'
#' @param risks A data frame with columns `id`, `description`,
#'   `probability` (numeric in `[0, 1]`), `impact_gbp` (numeric).
#'   Optional columns: `category`, `mitigation` (character).
#' @param appraisal Optional `gb_appraisal`. If supplied, returns a
#'   risk-adjusted NPV: `appraisal$npv - sum(probability * impact)`.
#'
#' @return A `gb_risk_register` object.
#'
#' @details
#' HM Treasury business case guidance requires a risk register with
#' monetised exposure for the OBC and FBC stages. `gb_risk_register`
#' standardises the structure: every risk has an id, a probability,
#' a monetary impact, and an expected loss. Aggregation is by category
#' if the column is present.
#'
#' @references HM Treasury (2018). The Orange Book: Management of
#'   Risk - Principles and Concepts.
#'
#' @family appraisal
#' @seealso [gb_appraise()].
#'
#' @export
#' @examples
#' risks <- data.frame(
#'   id = c("R1", "R2", "R3"),
#'   description = c("Planning delay", "Cost overrun", "Lower demand"),
#'   category = c("schedule", "cost", "demand"),
#'   probability = c(0.30, 0.50, 0.20),
#'   impact_gbp = c(2e6, 5e6, 10e6)
#' )
#' gb_risk_register(risks)
gb_risk_register <- function(risks, appraisal = NULL) {
  if (!is.data.frame(risks)) {
    cli::cli_abort("{.arg risks} must be a data frame.")
  }
  required <- c("id", "description", "probability", "impact_gbp")
  missing <- setdiff(required, names(risks))
  if (length(missing) > 0L) {
    cli::cli_abort("{.arg risks} is missing column(s): {paste(missing, collapse = ', ')}.")
  }
  validate_numeric(risks$probability, "probability")
  validate_numeric(risks$impact_gbp, "impact_gbp")
  if (any(risks$probability < 0 | risks$probability > 1)) {
    cli::cli_abort("{.arg probability} must be in [0, 1].")
  }

  risks$expected_loss <- risks$probability * risks$impact_gbp
  expected_value <- sum(risks$expected_loss)
  total_exposure <- sum(risks$impact_gbp)

  by_category <- NULL
  if ("category" %in% names(risks)) {
    by_category <- stats::aggregate(
      cbind(impact_gbp, expected_loss) ~ category,
      data = risks,
      FUN = sum
    )
  }

  risk_adjusted_npv <- NULL
  if (!is.null(appraisal)) {
    if (!inherits(appraisal, "gb_appraisal")) {
      cli::cli_abort("{.arg appraisal} must be a {.cls gb_appraisal}.")
    }
    risk_adjusted_npv <- appraisal$npv - expected_value
  }

  out <- list(
    risks = risks,
    expected_value = expected_value,
    total_exposure = total_exposure,
    by_category = by_category,
    risk_adjusted_npv = risk_adjusted_npv
  )
  class(out) <- c("gb_risk_register", "list")
  out
}

#' @export
print.gb_risk_register <- function(x, ...) {
  n_risks <- nrow(x$risks)
  exp_str <- .format_gbp(x$expected_value)
  exposure_str <- .format_gbp(x$total_exposure)
  cli::cli_h1("Risk register")
  cli::cli_text("Risks identified: {.val {n_risks}}")
  cli::cli_text("Expected loss (sum of probability x impact): {.val {exp_str}}")
  cli::cli_text("Maximum exposure (sum of impacts): {.val {exposure_str}}")
  if (!is.null(x$risk_adjusted_npv)) {
    adj_str <- .format_gbp(x$risk_adjusted_npv)
    cli::cli_text("Risk-adjusted NPV: {.val {adj_str}}")
  }
  cat("\n")
  print(x$risks[, c("id", "description", "probability", "impact_gbp", "expected_loss")],
        row.names = FALSE)
  if (!is.null(x$by_category)) {
    cat("\nBy category:\n")
    print(x$by_category, row.names = FALSE)
  }
  invisible(x)
}
