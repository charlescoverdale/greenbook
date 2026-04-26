#' Compare multiple appraisal options
#'
#' Builds a side-by-side comparison of two or more `gb_appraisal`
#' objects. Returns a `gb_comparison` with a ranked summary table
#' and the preferred option under both NPV and BCR criteria.
#'
#' @param ... `gb_appraisal` objects to compare. Pass as named
#'   arguments to control labels (e.g. `do_minimum = app1`).
#' @param by Character. Ranking criterion: one of `"npv"` (default)
#'   or `"bcr"`.
#'
#' @return A `gb_comparison` object: a list with class
#'   `c("gb_comparison", "list")` and elements `options`,
#'   `summary_table`, `preferred_npv`, `preferred_bcr`, `by`.
#'
#' @details
#' Every Green Book economic case must compare at least Do Minimum
#' against one or more Do Something options. `gb_compare()`
#' standardises the comparison: NPV, BCR, EANC, PV costs, PV benefits,
#' and rank under both NPV and BCR. The `summary()` method renders a
#' one-page table suitable for a Five Case Model economic case.
#'
#' @references
#' HM Treasury (2022). The Green Book: Central Government Guidance
#' on Appraisal and Evaluation, chapter on options analysis.
#'
#' @family appraisal
#' @seealso [gb_appraise()], [gb_economic_case()].
#'
#' @export
#' @examples
#' do_minimum <- gb_appraise(c(50, 0, 0, 0, 0), c(0, 20, 20, 20, 20))
#' do_max <- gb_appraise(c(150, 0, 0, 0, 0), c(0, 50, 50, 50, 50))
#' gb_compare(do_minimum = do_minimum, do_max = do_max)
gb_compare <- function(..., by = "npv") {
  by <- match.arg(by, c("npv", "bcr"))
  options <- list(...)
  if (length(options) < 2L) {
    cli::cli_abort("{.fn gb_compare} requires at least two appraisals.")
  }
  if (is.null(names(options)) || any(!nzchar(names(options)))) {
    names(options) <- paste0("option_", seq_along(options))
  }
  for (i in seq_along(options)) {
    if (!inherits(options[[i]], "gb_appraisal")) {
      cli::cli_abort("All inputs must be {.cls gb_appraisal} objects.")
    }
  }

  rows <- lapply(seq_along(options), function(i) {
    a <- options[[i]]
    horizon <- length(a$cashflow)
    eanc <- tryCatch(
      gb_eanc(a, years = horizon - 1L),
      error = function(e) NA_real_
    )
    data.frame(
      option = names(options)[i],
      npv = a$npv,
      bcr = a$bcr %||% NA_real_,
      eanc = eanc,
      pv_costs = a$pv_costs %||% NA_real_,
      pv_benefits = a$pv_benefits %||% NA_real_,
      stringsAsFactors = FALSE
    )
  })
  tbl <- do.call(rbind, rows)

  tbl$rank_npv <- rank(-tbl$npv, ties.method = "min", na.last = "keep")
  tbl$rank_bcr <- rank(-tbl$bcr, ties.method = "min", na.last = "keep")

  preferred_npv <- tbl$option[which.max(tbl$npv)]
  preferred_bcr <- if (any(!is.na(tbl$bcr))) tbl$option[which.max(tbl$bcr)] else NA_character_

  out <- list(
    options = options,
    summary_table = tbl,
    preferred_npv = preferred_npv,
    preferred_bcr = preferred_bcr,
    by = by
  )
  class(out) <- c("gb_comparison", "list")
  out
}

#' @export
print.gb_comparison <- function(x, ...) {
  cli::cli_h1("Green Book option comparison")
  cli::cli_text("{.val {length(x$options)}} options compared, ranked by {.field {x$by}}")
  cli::cli_text("Preferred (NPV): {.val {x$preferred_npv}}")
  if (!is.na(x$preferred_bcr)) {
    cli::cli_text("Preferred (BCR): {.val {x$preferred_bcr}}")
  }
  cat("\n")
  print(x$summary_table, row.names = FALSE)
  invisible(x)
}

#' @export
summary.gb_comparison <- function(object, ...) {
  cat("Green Book option comparison\n")
  cat("----------------------------\n")
  cat(sprintf("Options    : %d\n", length(object$options)))
  cat(sprintf("Ranked by  : %s\n", object$by))
  cat(sprintf("Preferred (NPV): %s\n", object$preferred_npv))
  if (!is.na(object$preferred_bcr)) {
    cat(sprintf("Preferred (BCR): %s\n", object$preferred_bcr))
  }
  cat("\n")
  print(object$summary_table, row.names = FALSE)
  invisible(object)
}
