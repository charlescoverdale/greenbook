#' Discount factor under the kinked STPR
#'
#' Returns the present-value discount factor for each year, applying
#' the kinked Social Time Preference Rate schedule annually.
#'
#' @param years Integer vector of years from the base year. Must be
#'   `>= base_year`.
#' @param schedule One of `"standard"`, `"health"`, `"catastrophic"`.
#' @param base_year Integer base year offset. Default `0`.
#'
#' @return A numeric vector of discount factors. `1` for `years == base_year`.
#'
#' @details
#' The discount factor at year `t` is computed as the reciprocal of the
#' cumulative product of `(1 + r_k)` for periods `k = 1, ..., t`, where
#' `r_k` is the STPR for year `k`. This handles the kinked schedule
#' correctly across band transitions (e.g. year 30 to year 31).
#'
#' @export
#' @examples
#' gb_discount_factor(0:5)
#' gb_discount_factor(c(0, 30, 31, 75, 76))
gb_discount_factor <- function(years, schedule = "standard", base_year = 0L) {
  validate_year(years, arg = "years", min_year = -.Machine$integer.max)
  validate_year(base_year, arg = "base_year", min_year = -.Machine$integer.max)
  if (length(base_year) != 1L) {
    cli::cli_abort("{.arg base_year} must be scalar.")
  }
  if (any(years < base_year)) {
    cli::cli_abort("All {.arg years} must be {.code >=} {.arg base_year} ({.val {base_year}}).")
  }

  rel <- as.integer(years - base_year)
  if (length(rel) == 0L) return(numeric(0))

  max_y <- max(rel)
  if (max_y == 0L) return(rep_len(1, length(rel)))

  period_rates <- gb_stpr(seq_len(max_y), schedule = schedule)
  cumulative <- cumprod(1 + period_rates)

  out <- numeric(length(rel))
  out[rel == 0L] <- 1
  nonzero <- rel > 0L
  out[nonzero] <- 1 / cumulative[rel[nonzero]]
  out
}

#' Apply discount factors to a stream
#'
#' @param values Numeric vector of nominal cashflow values (in real
#'   terms, base year fixed).
#' @param years Integer vector of years from the base year. Defaults to
#'   `0, 1, 2, ...`.
#' @param schedule One of `"standard"`, `"health"`, `"catastrophic"`.
#'
#' @return A numeric vector of discounted (present-value) cashflows.
#' @export
#' @examples
#' gb_discount(c(0, 100, 100, 100))
gb_discount <- function(values, years = seq_along(values) - 1L, schedule = "standard") {
  validate_numeric(values, "values")
  validate_year(years, "years", min_year = -.Machine$integer.max)
  if (length(values) != length(years)) {
    cli::cli_abort("{.arg values} and {.arg years} must have equal length.")
  }
  values * gb_discount_factor(years, schedule = schedule)
}

#' Net present value
#'
#' Computes the net present value of a cashflow stream under the
#' Green Book STPR. Returns a `gb_appraisal` object carrying the NPV,
#' the input cashflow, the discount factors, the schedule used, and
#' methodology vintage.
#'
#' @param cashflow Numeric vector of net cashflows in real terms (one
#'   value per year).
#' @param years Integer vector of years matching `cashflow`. Defaults
#'   to `0, 1, ..., length(cashflow) - 1`.
#' @param schedule One of `"standard"`, `"health"`, `"catastrophic"`.
#' @param base_year Optional integer recording the price base year for
#'   the cashflow (e.g. `2024`). Stored on the returned object.
#' @param vintage Character. Methodology vintage label. Defaults to
#'   `"2022"`.
#'
#' @return A `gb_appraisal` object: a list with class
#'   `c("gb_appraisal", "list")` and elements
#'   `npv`, `cashflow`, `years`, `pv`, `schedule`, `base_year`, `vintage`.
#'
#' @export
#' @examples
#' costs    <- c(100, 50, 50, 0, 0, 0, 0, 0, 0, 0)
#' benefits <- c(0, 0, 0, 30, 30, 30, 30, 30, 30, 30)
#' gb_npv(benefits - costs)
gb_npv <- function(cashflow,
                   years = NULL,
                   schedule = "standard",
                   base_year = NULL,
                   vintage = "2022") {
  validate_numeric(cashflow, "cashflow")
  schedule <- match.arg(schedule, c("standard", "health", "catastrophic"))
  if (is.null(years)) years <- seq_along(cashflow) - 1L
  pv <- gb_discount(cashflow, years, schedule = schedule)

  out <- list(
    npv = sum(pv),
    cashflow = cashflow,
    years = years,
    pv = pv,
    schedule = schedule,
    base_year = base_year,
    vintage = vintage
  )
  class(out) <- c("gb_appraisal", "list")
  out
}

#' Equivalent annual net cost (or benefit)
#'
#' Converts a present value to an annualised equivalent over a fixed
#' horizon under the STPR. Used to compare options of different
#' durations.
#'
#' @param npv Either a numeric scalar NPV, or a `gb_appraisal` object.
#' @param years Project horizon in years. If `npv` is a `gb_appraisal`
#'   and `years` is missing, `length(npv$cashflow) - 1L` is used.
#' @param schedule One of `"standard"`, `"health"`, `"catastrophic"`.
#'
#' @return A numeric scalar: the equivalent annual amount in real
#'   terms, base year aligned with the input.
#'
#' @export
#' @examples
#' app <- gb_npv(c(-100, 30, 30, 30, 30, 30))
#' gb_eanc(app)
gb_eanc <- function(npv, years, schedule = "standard") {
  if (inherits(npv, "gb_appraisal")) {
    npv_val <- npv$npv
    if (missing(years) || is.null(years)) {
      years <- length(npv$cashflow) - 1L
    }
    schedule <- npv$schedule %||% schedule
  } else if (is.numeric(npv) && length(npv) == 1L) {
    npv_val <- npv
  } else {
    cli::cli_abort("{.arg npv} must be a numeric scalar or a {.cls gb_appraisal}.")
  }
  validate_year(years, "years", min_year = 1L)
  if (length(years) != 1L) {
    cli::cli_abort("{.arg years} must be scalar.")
  }

  factors <- gb_discount_factor(seq_len(years), schedule = schedule)
  npv_val / sum(factors)
}
