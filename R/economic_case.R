#' Render an appraisal as a Five Case Model economic case
#'
#' Wraps a `gb_appraisal` with the structural sections HMT business
#' case guidance expects in the Economic Case (the second of the
#' five cases in the Five Case Model: Strategic, Economic,
#' Commercial, Financial, Management).
#'
#' @param appraisal A `gb_appraisal` (typically from `gb_appraise()`
#'   or `gb_compare()`).
#' @param critical_success_factors Character vector of CSFs.
#' @param options_considered Character vector of long-listed option
#'   names.
#' @param non_monetised_impacts Optional data frame with columns
#'   `impact`, `direction` (`"+"`/`"-"`), `materiality`
#'   (`"H"`/`"M"`/`"L"`), `notes`.
#' @param recommendation Optional character: the preferred option
#'   and rationale.
#' @param vfm_statement Optional character: the value-for-money
#'   judgment.
#'
#' @return A `gb_economic_case` object.
#'
#' @details
#' The Five Case Model is HM Treasury's standard structure for
#' business cases. The Economic Case is the part where Green Book
#' appraisal sits: monetised costs and benefits, non-monetised
#' impacts, switching values, sensitivity tests, value for money
#' judgment, recommended option. `gb_economic_case` wraps the
#' appraisal with the sections a reviewer expects to see.
#'
#' @references HM Treasury (2018). Guide to Developing the Project
#'   Business Case (Five Case Model).
#'
#' @family appraisal
#' @seealso [gb_appraise()], [gb_compare()].
#'
#' @export
#' @examples
#' app <- gb_appraise(c(100, 0, 0, 0, 0), c(0, 30, 30, 30, 30))
#' gb_economic_case(
#'   app,
#'   critical_success_factors = c("Strategic fit", "Value for money", "Achievability"),
#'   options_considered = c("Do nothing", "Do minimum", "Do maximum"),
#'   recommendation = "Do maximum: positive NPV and BCR > 1.5"
#' )
gb_economic_case <- function(appraisal,
                             critical_success_factors = NULL,
                             options_considered = NULL,
                             non_monetised_impacts = NULL,
                             recommendation = NULL,
                             vfm_statement = NULL) {
  if (!inherits(appraisal, "gb_appraisal") &&
      !inherits(appraisal, "gb_comparison")) {
    cli::cli_abort(
      "{.arg appraisal} must be a {.cls gb_appraisal} or {.cls gb_comparison}."
    )
  }

  out <- list(
    appraisal = appraisal,
    critical_success_factors = critical_success_factors,
    options_considered = options_considered,
    non_monetised_impacts = non_monetised_impacts,
    recommendation = recommendation,
    vfm_statement = vfm_statement
  )
  class(out) <- c("gb_economic_case", "list")
  out
}

#' @export
print.gb_economic_case <- function(x, ...) {
  cli::cli_h1("Economic Case (Five Case Model)")

  cli::cli_h2("Critical success factors")
  if (!is.null(x$critical_success_factors)) {
    for (csf in x$critical_success_factors) cli::cli_li(csf)
  } else {
    cli::cli_alert_info("Not specified")
  }

  cli::cli_h2("Options considered")
  if (!is.null(x$options_considered)) {
    for (o in x$options_considered) cli::cli_li(o)
  } else {
    cli::cli_alert_info("Not specified")
  }

  cli::cli_h2("Monetised summary")
  print(x$appraisal)

  if (!is.null(x$non_monetised_impacts)) {
    cli::cli_h2("Non-monetised impacts")
    print(x$non_monetised_impacts, row.names = FALSE)
  }

  if (!is.null(x$vfm_statement)) {
    cli::cli_h2("Value for money")
    cli::cli_text(x$vfm_statement)
  }

  if (!is.null(x$recommendation)) {
    cli::cli_h2("Recommendation")
    cli::cli_text(x$recommendation)
  }

  invisible(x)
}
