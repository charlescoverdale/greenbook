#' @export
print.gb_appraisal <- function(x, ...) {
  npv_str <- .format_gbp(x$npv)
  horizon <- length(x$cashflow)
  year_first <- x$years[1]
  year_last <- x$years[length(x$years)]
  cli::cli_h1("Green Book appraisal")
  cli::cli_text("NPV (real, {.field {x$schedule}} schedule): {.val {npv_str}}")
  cli::cli_text("Horizon: {.val {horizon}} years (year {.val {year_first}} to {.val {year_last}})")
  if (!is.null(x$base_year)) {
    cli::cli_text("Base year: {.val {x$base_year}}")
  }
  cli::cli_text("Vintage: Green Book {.val {x$vintage}}")
  invisible(x)
}

#' @export
summary.gb_appraisal <- function(object, ...) {
  cat("Green Book appraisal\n")
  cat("--------------------\n")
  cat(sprintf("NPV          : %s\n", .format_gbp(object$npv)))
  cat(sprintf("Schedule     : %s\n", object$schedule))
  cat(sprintf("Horizon      : %d years (year %s to %s)\n",
              length(object$cashflow),
              object$years[1],
              object$years[length(object$years)]))
  if (!is.null(object$base_year)) {
    cat(sprintf("Base year    : %s\n", object$base_year))
  }
  cat(sprintf("Vintage      : Green Book %s\n", object$vintage))
  cat(sprintf("Total inflow : %s\n",
              .format_gbp(sum(object$cashflow[object$cashflow > 0]))))
  cat(sprintf("Total outflow: %s\n",
              .format_gbp(sum(object$cashflow[object$cashflow < 0]))))
  invisible(object)
}

#' @export
format.gb_appraisal <- function(x, ...) {
  sprintf("<gb_appraisal: NPV = %s, %d years, %s>",
          .format_gbp(x$npv),
          length(x$cashflow),
          x$schedule)
}
