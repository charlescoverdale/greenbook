#' Social Time Preference Rate
#'
#' Returns the HM Treasury Green Book Social Time Preference Rate (STPR)
#' for a vector of years from a base year. The schedule is kinked: the
#' rate steps down as the horizon lengthens. Two vintages are bundled.
#'
#' @param years Integer vector of years from the base year (year 0 is
#'   the base year). Must be non-negative.
#' @param schedule One of `"standard"` (default), `"health"` or
#'   `"catastrophic"`. The `"health"` (1.5 percent baseline, from DHSC
#'   supplementary guidance) and `"catastrophic"` (3.0 percent baseline,
#'   the standard schedule with the catastrophic-risk element of pure
#'   time preference excluded) schedules exist only in the `"2003"`
#'   vintage. The October 2026 guidance withdrew them: practitioners
#'   "should not use different discount rates for different types of
#'   proposals" (paragraph 3.2).
#' @param vintage Discounting vintage. `"2026-10"` (default) is the
#'   schedule HM Treasury published on 28 October 2026 following the
#'   Green Book Discount Rate Review 2026: 3.00 percent for years 1 to
#'   30, 2.50 percent for years 31 to 75 and 2.25 percent for years 76
#'   to 125. `"2003"` is the schedule in force from the 2003 Green Book
#'   until October 2026: 3.5 percent declining to 1.0 percent. `"2026"`
#'   is accepted for `"2026-10"`, and `"2018"`, `"2020"`, `"2022"` and
#'   `"2026-02"` (the February 2026 edition, which kept the 3.5 percent
#'   schedule) are accepted for `"2003"`.
#'
#' @return A numeric vector of discount rates (decimals, e.g. 0.03 for
#'   3 percent), one per element of `years`.
#'
#' @details
#' The STPR is derived from the Ramsey formula: a risk-free rate (pure
#' time preference, plus a wealth effect from expected per-capita
#' consumption growth, plus an adjustment for rare disaster risk) and a
#' systematic risk premium. In the 2026-10 vintage these are 0.50,
#' 1.875, -0.50 and 1.00 percent. HM Treasury raises the resulting
#' risk-free rate by 0.125 percentage points to 2.00 percent after
#' triangulating against real gilt yields, which gives 3.00 percent.
#' The kink reflects uncertainty about long-run growth and gilt yields.
#'
#' The 2026-10 schedule stops at year 125. HM Treasury advises that
#' discounting "is not an analytically meaningful technique" beyond
#' that point (paragraph 3.10), so years above 125 are an error under
#' that vintage rather than being silently extrapolated. Appraise
#' later effects by other means, or use `vintage = "2003"` to reproduce
#' an appraisal made under the earlier guidance.
#'
#' @references
#' HM Treasury (2026). The Green Book: Central Government Guidance on
#' Appraisal and Evaluation, updated 28 October 2026.
#'
#' HM Treasury (2026). Green Book supplementary guidance: discounting,
#' updated 28 October 2026, paragraphs 3.2, 3.8 and 3.10.
#' \url{https://www.gov.uk/government/publications/green-book-supplementary-guidance-discounting}
#'
#' Freeman, M. C. and Groom, B. (2026). Green Book Discount Rate Review:
#' Summary of Findings and Recommendations. HM Treasury.
#'
#' @family discounting
#' @seealso [gb_discount_factor()], [gb_discount()], [gb_npv()].
#'
#' @export
#' @examples
#' gb_stpr(0:5)
#' gb_stpr(c(10, 30, 31, 75, 76))
#' gb_stpr(c(10, 30, 31, 75, 76), vintage = "2003")
#' gb_stpr(c(10, 30, 31), schedule = "health", vintage = "2003")
gb_stpr <- function(years, schedule = "standard", vintage = "2026-10") {
  schedule <- match.arg(schedule, c("standard", "health", "catastrophic"))
  vintage <- .stpr_vintage(vintage)
  validate_year(years, arg = "years", min_year = 0L)
  .check_schedule_vintage(schedule, vintage)

  tbl <- .read_stpr()
  tbl <- tbl[tbl$vintage == vintage, , drop = FALSE]

  out <- numeric(length(years))
  for (i in seq_along(years)) {
    y <- years[i]
    row_idx <- which(y >= tbl$year_from & y <= tbl$year_to)
    if (length(row_idx) == 0L) {
      if (identical(vintage, "2026-10")) {
        cli::cli_abort(c(
          "Year {.val {y}} is beyond the 125-year horizon of the October 2026 STPR schedule.",
          "i" = "HM Treasury advises against discounting beyond year 125 (supplementary guidance on discounting, paragraph 3.10).",
          "i" = "Use {.code vintage = \"2003\"} to reproduce an appraisal made under the earlier guidance."
        ))
      }
      cli::cli_abort(
        "Year {.val {y}} is outside the supported STPR schedule (max: {.val {max(tbl$year_to)}})."
      )
    }
    out[i] <- tbl[[schedule]][row_idx[[1]]]
  }
  out
}

# Map a user-supplied vintage label onto a bundled STPR vintage.
#' @noRd
.stpr_vintage <- function(vintage) {
  if (!is.character(vintage) || length(vintage) != 1L || is.na(vintage)) {
    cli::cli_abort("{.arg vintage} must be a single character string.")
  }
  aliases <- c(
    "2026-10" = "2026-10", "2026" = "2026-10",
    "2003" = "2003", "2018" = "2003", "2020" = "2003",
    "2022" = "2003", "2026-02" = "2003"
  )
  if (!vintage %in% names(aliases)) {
    cli::cli_abort(c(
      "Unknown discounting vintage {.val {vintage}}.",
      "i" = "Use {.val 2026-10} (current) or {.val 2003} (pre-October 2026)."
    ))
  }
  unname(aliases[[vintage]])
}

#' @noRd
.check_schedule_vintage <- function(schedule, vintage) {
  if (!identical(schedule, "standard") && identical(vintage, "2026-10")) {
    cli::cli_abort(c(
      "The {.val {schedule}} schedule was withdrawn in October 2026.",
      "i" = "HM Treasury now applies one STPR to all proposals (supplementary guidance on discounting, paragraph 3.2).",
      "i" = "Use {.code vintage = \"2003\"} to reproduce an appraisal made under the earlier guidance."
    ))
  }
  invisible(NULL)
}
