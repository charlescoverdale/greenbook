#' Social Time Preference Rate
#'
#' Returns the HM Treasury Green Book Social Time Preference Rate (STPR)
#' for a vector of years from a base year. The schedule is kinked: the
#' rate steps down at 30, 75, 125, 200, and 300 years. Three variants
#' are supported.
#'
#' @param years Integer vector of years from the base year (year 0 is
#'   the base year). Must be non-negative.
#' @param schedule One of `"standard"` (default, 3.5 percent baseline),
#'   `"health"` (1.5 percent baseline, used in DHSC supplementary
#'   guidance), or `"catastrophic"` (3.0 percent, for projects where
#'   catastrophic risk dominates).
#'
#' @return A numeric vector of discount rates (decimals, e.g. 0.035 for
#'   3.5 percent), one per element of `years`.
#'
#' @details
#' The STPR is composed of pure time preference plus a wealth-effect
#' adjustment for expected per-capita consumption growth. The kink
#' reflects increasing uncertainty over the constituent parameters at
#' longer horizons.
#'
#' @references
#' HM Treasury (2022). The Green Book: Central Government Guidance on
#' Appraisal and Evaluation, Annex A6.
#'
#' HM Treasury (2003). Green Book Supplementary Guidance: Discounting.
#'
#' @family discounting
#' @seealso [gb_discount_factor()], [gb_discount()], [gb_npv()].
#'
#' @export
#' @examples
#' gb_stpr(0:5)
#' gb_stpr(c(10, 30, 31, 75, 76))
#' gb_stpr(c(10, 30, 31, 75, 76), schedule = "health")
gb_stpr <- function(years, schedule = "standard") {
  schedule <- match.arg(schedule, c("standard", "health", "catastrophic"))
  validate_year(years, arg = "years", min_year = 0L)

  schedule_table <- .read_stpr()

  out <- numeric(length(years))
  for (i in seq_along(years)) {
    y <- years[i]
    row_idx <- which(y >= schedule_table$year_from & y <= schedule_table$year_to)
    if (length(row_idx) == 0L) {
      cli::cli_abort(
        "Year {.val {y}} is outside the supported STPR schedule (max: {.val {max(schedule_table$year_to)}})."
      )
    }
    out[i] <- schedule_table[[schedule]][row_idx[[1]]]
  }
  out
}
