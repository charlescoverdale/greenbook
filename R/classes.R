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
  if (!is.null(object$bcr) && !is.na(object$bcr)) {
    cat(sprintf("BCR          : %.2f\n", object$bcr))
  }
  cat(sprintf("Schedule     : %s\n", object$schedule))
  cat(sprintf("Horizon      : %d years (year %s to %s)\n",
              length(object$cashflow),
              object$years[1],
              object$years[length(object$years)]))
  if (!is.null(object$base_year)) {
    cat(sprintf("Base year    : %s\n", object$base_year))
  }
  cat(sprintf("Vintage      : Green Book %s\n", object$vintage))
  if (!is.null(object$pv_costs)) {
    cat(sprintf("PV costs     : %s\n", .format_gbp(object$pv_costs)))
    cat(sprintf("PV benefits  : %s\n", .format_gbp(object$pv_benefits)))
  } else {
    cat(sprintf("Total inflow : %s\n",
                .format_gbp(sum(object$cashflow[object$cashflow > 0]))))
    cat(sprintf("Total outflow: %s\n",
                .format_gbp(sum(object$cashflow[object$cashflow < 0]))))
  }
  if (!is.null(object$optimism_bias)) {
    cat(sprintf("Optimism bias: %.1f percent uplift on costs\n",
                100 * object$optimism_bias))
  }
  if (isTRUE(object$metb_applied)) {
    cat("METB         : applied to costs\n")
  }
  if (!is.null(object$eta)) {
    cat(sprintf("Distrib. eta : %.2f\n", object$eta))
    if (!is.null(object$unweighted_npv)) {
      cat(sprintf("NPV unweighted: %s\n", .format_gbp(object$unweighted_npv)))
    }
  }
  invisible(object)
}

#' @export
format.gb_appraisal <- function(x, ...) {
  sprintf("<gb_appraisal: NPV = %s, %d years, %s>",
          .format_gbp(x$npv),
          length(x$cashflow),
          x$schedule)
}
