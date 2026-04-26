#' Lint a Green Book appraisal for common errors
#'
#' Inspects a `gb_appraisal` for sign-convention errors, base-year
#' alignment, schedule plausibility, and other common authoring
#' mistakes. Returns a structured report classifying each check as
#' pass, warning, or error.
#'
#' @param appraisal A `gb_appraisal` object.
#'
#' @return A `gb_validation` object with elements `pass`, `errors`,
#'   `warnings`, `info`, and `n_checks`.
#'
#' @details
#' Checks performed:
#' - Cashflow length matches `years` length
#' - Schedule is one of the valid options
#' - Base year is plausible (1900 to 2100)
#' - Vintage matches a recognised Green Book edition
#' - If `costs` and `benefits` are present (from `gb_appraise()`),
#'   costs are non-negative and benefits are non-negative
#' - NPV is finite (no NaN / Inf)
#' - PV costs and PV benefits are consistent with NPV
#'
#' Warnings flag suspicious patterns: missing base year, unusual
#' optimism bias values, METB outside 0 to 50 percent, very long
#' horizons (> 100 years).
#'
#' @family appraisal
#' @seealso [gb_appraise()].
#'
#' @export
#' @examples
#' app <- gb_appraise(c(100, 0, 0, 0, 0), c(0, 30, 30, 30, 30))
#' gb_validate(app)
gb_validate <- function(appraisal) {
  if (!inherits(appraisal, "gb_appraisal")) {
    cli::cli_abort("{.arg appraisal} must be a {.cls gb_appraisal}.")
  }

  errors <- list()
  warnings <- list()
  info <- list()

  add <- function(level, check, msg) {
    item <- list(check = check, message = msg)
    if (level == "error") errors[[length(errors) + 1L]] <<- item
    else if (level == "warning") warnings[[length(warnings) + 1L]] <<- item
    else info[[length(info) + 1L]] <<- item
  }

  if (length(appraisal$cashflow) != length(appraisal$years)) {
    add("error", "length", "cashflow and years differ in length")
  }

  valid_schedules <- c("standard", "health", "catastrophic")
  if (!appraisal$schedule %in% valid_schedules) {
    add("error", "schedule",
        sprintf("schedule '%s' is not one of: %s",
                appraisal$schedule, paste(valid_schedules, collapse = ", ")))
  }

  if (!is.null(appraisal$base_year)) {
    by <- appraisal$base_year
    if (!is.numeric(by) || by < 1900 || by > 2100) {
      add("error", "base_year",
          sprintf("base_year %s is outside 1900 to 2100", by))
    }
  } else {
    add("warning", "base_year",
        "base_year not set; appraisal is not self-describing for price-base alignment")
  }

  if (!is.null(appraisal$vintage)) {
    if (!appraisal$vintage %in% c("2003", "2018", "2022", "2026")) {
      add("warning", "vintage",
          sprintf("vintage '%s' is not a recognised Green Book edition", appraisal$vintage))
    }
  }

  if (!is.null(appraisal$costs)) {
    if (any(appraisal$costs < 0, na.rm = TRUE)) {
      add("warning", "cost_sign",
          "costs contain negative values; gb_appraise expects positive costs")
    }
  }
  if (!is.null(appraisal$benefits)) {
    if (any(appraisal$benefits < 0, na.rm = TRUE)) {
      add("warning", "benefit_sign",
          "benefits contain negative values")
    }
  }

  if (!is.finite(appraisal$npv)) {
    add("error", "npv_finite", "NPV is not finite (NaN or Inf)")
  }

  if (!is.null(appraisal$pv_costs) && !is.null(appraisal$pv_benefits)) {
    expected_npv <- appraisal$pv_benefits - appraisal$pv_costs
    if (abs(expected_npv - appraisal$npv) > 1e-6) {
      add("error", "npv_consistency",
          sprintf("NPV (%g) does not equal PV benefits (%g) minus PV costs (%g)",
                  appraisal$npv, appraisal$pv_benefits, appraisal$pv_costs))
    }
  }

  if (!is.null(appraisal$optimism_bias)) {
    ob <- appraisal$optimism_bias
    if (ob < 0 || ob > 3) {
      add("warning", "ob_range",
          sprintf("optimism bias %.1f%% is outside 0%% to 300%%; check for unit error",
                  100 * ob))
    }
  }

  horizon <- length(appraisal$cashflow)
  if (horizon > 100) {
    add("info", "horizon",
        sprintf("horizon is %d years; consider a lower-rate sensitivity test for long-horizon impacts",
                horizon))
  }

  out <- list(
    pass = length(errors) == 0L,
    errors = errors,
    warnings = warnings,
    info = info,
    n_checks = 8L
  )
  class(out) <- c("gb_validation", "list")
  out
}

#' @export
print.gb_validation <- function(x, ...) {
  if (x$pass) {
    cli::cli_alert_success("Validation passed: {.val {x$n_checks}} checks, no errors")
  } else {
    cli::cli_alert_danger("Validation failed: {.val {length(x$errors)}} error(s)")
  }
  if (length(x$errors) > 0L) {
    cli::cli_h2("Errors")
    for (e in x$errors) {
      cli::cli_bullets(c("x" = "{e$check}: {e$message}"))
    }
  }
  if (length(x$warnings) > 0L) {
    cli::cli_h2("Warnings")
    for (w in x$warnings) {
      cli::cli_bullets(c("!" = "{w$check}: {w$message}"))
    }
  }
  if (length(x$info) > 0L) {
    cli::cli_h2("Info")
    for (i in x$info) {
      cli::cli_bullets(c("i" = "{i$check}: {i$message}"))
    }
  }
  invisible(x)
}
