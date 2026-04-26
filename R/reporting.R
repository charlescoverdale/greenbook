#' One-page headline summary of an appraisal
#'
#' Returns the headline numbers a Green Book reviewer or steering
#' committee expects: NPV, BCR, EANC, payback period, optimism bias
#' applied, vintage. Suitable for a slide or executive summary.
#'
#' @param appraisal A `gb_appraisal` object.
#'
#' @return A `gb_headline` object with elements `npv`, `bcr`,
#'   `eanc`, `payback_year`, `optimism_bias`, `metb_applied`,
#'   `vintage`, `base_year`, `horizon`.
#'
#' @family reporting
#' @seealso [gb_appraise()], [gb_to_latex()], [gb_to_excel()].
#'
#' @export
#' @examples
#' app <- gb_appraise(c(100, 0, 0, 0, 0), c(0, 30, 30, 30, 30))
#' gb_headline(app)
gb_headline <- function(appraisal) {
  if (!inherits(appraisal, "gb_appraisal")) {
    cli::cli_abort("{.arg appraisal} must be a {.cls gb_appraisal}.")
  }
  horizon <- length(appraisal$cashflow)
  cumulative <- cumsum(appraisal$pv)
  payback_year <- if (any(cumulative > 0)) {
    appraisal$years[which(cumulative > 0)[1]]
  } else {
    NA_integer_
  }
  eanc <- tryCatch(
    gb_eanc(appraisal, years = horizon - 1L),
    error = function(e) NA_real_
  )

  out <- list(
    npv = appraisal$npv,
    bcr = appraisal$bcr %||% NA_real_,
    eanc = eanc,
    payback_year = payback_year,
    optimism_bias = appraisal$optimism_bias,
    metb_applied = isTRUE(appraisal$metb_applied),
    vintage = appraisal$vintage,
    base_year = appraisal$base_year,
    horizon = horizon
  )
  class(out) <- c("gb_headline", "list")
  out
}

#' @export
print.gb_headline <- function(x, ...) {
  npv_str <- .format_gbp(x$npv)
  bcr_str <- if (!is.na(x$bcr)) sprintf("%.2f", x$bcr) else NA
  eanc_str <- if (!is.na(x$eanc)) .format_gbp(x$eanc) else NA
  ob_str <- if (!is.null(x$optimism_bias))
    sprintf("%.0f%%", 100 * x$optimism_bias) else NA
  cli::cli_h1("Appraisal headline")
  cli::cli_text("NPV: {.val {npv_str}}")
  if (!is.na(x$bcr)) cli::cli_text("BCR: {.val {bcr_str}}")
  if (!is.na(x$eanc)) cli::cli_text("EANC: {.val {eanc_str}}")
  if (!is.na(x$payback_year)) {
    cli::cli_text("Payback: year {.val {x$payback_year}}")
  } else {
    cli::cli_text("Payback: never (cumulative PV does not turn positive)")
  }
  if (!is.null(x$optimism_bias)) {
    cli::cli_text("Optimism bias applied: {ob_str}")
  }
  if (x$metb_applied) cli::cli_text("METB applied to costs")
  cli::cli_text("Horizon: {.val {x$horizon}} years")
  if (!is.null(x$base_year)) cli::cli_text("Base year: {.val {x$base_year}}")
  cli::cli_text("Vintage: Green Book {.val {x$vintage}}")
  invisible(x)
}

#' Cost per unit delivered
#'
#' Computes a cost-effectiveness ratio: total real cost (PV) per
#' unit of monetised or non-monetised output. Standard cross-scheme
#' comparator used by HM Treasury reviewers.
#'
#' @param appraisal A `gb_appraisal` object.
#' @param units_delivered Numeric scalar. The total quantity of the
#'   output being delivered (e.g. QALYs gained, tCO2e abated,
#'   WELLBYs added, jobs created).
#' @param unit Character. Label for the unit (used in print).
#'
#' @return Numeric scalar: PV cost / units delivered, in GBP per
#'   unit.
#'
#' @family reporting
#' @seealso [gb_appraise()].
#'
#' @export
#' @examples
#' app <- gb_appraise(c(100, 0, 0, 0, 0), c(0, 0, 0, 0, 0))
#' gb_cost_per_unit(app, units_delivered = 50, unit = "QALY")
gb_cost_per_unit <- function(appraisal, units_delivered, unit = "unit") {
  if (!inherits(appraisal, "gb_appraisal")) {
    cli::cli_abort("{.arg appraisal} must be a {.cls gb_appraisal}.")
  }
  validate_numeric(units_delivered, "units_delivered", require_positive = TRUE)
  if (length(units_delivered) != 1L) {
    cli::cli_abort("{.arg units_delivered} must be scalar.")
  }
  pv_costs <- appraisal$pv_costs %||% sum(pmax(-appraisal$pv, 0))
  pv_costs / units_delivered
}

#' Render an appraisal as a LaTeX table
#'
#' @param appraisal A `gb_appraisal` object.
#' @param caption Optional table caption.
#' @param label Optional LaTeX label for cross-referencing.
#'
#' @return A character scalar containing a LaTeX `tabular`
#'   environment. Wrap in `\\begin{table}...\\end{table}` for a
#'   floating table.
#'
#' @family reporting
#' @seealso [gb_to_excel()].
#'
#' @export
#' @examples
#' app <- gb_appraise(c(100, 0, 0, 0, 0), c(0, 30, 30, 30, 30))
#' cat(gb_to_latex(app, caption = "Worked example"))
gb_to_latex <- function(appraisal, caption = NULL, label = NULL) {
  if (!inherits(appraisal, "gb_appraisal")) {
    cli::cli_abort("{.arg appraisal} must be a {.cls gb_appraisal}.")
  }

  rows <- c(
    sprintf("NPV & %s \\\\", .format_gbp(appraisal$npv)),
    if (!is.null(appraisal$bcr) && !is.na(appraisal$bcr)) {
      sprintf("BCR & %.2f \\\\", appraisal$bcr)
    },
    sprintf("Schedule & %s \\\\", appraisal$schedule),
    sprintf("Horizon & %d years \\\\", length(appraisal$cashflow)),
    if (!is.null(appraisal$base_year)) {
      sprintf("Base year & %s \\\\", appraisal$base_year)
    },
    sprintf("Vintage & Green Book %s \\\\", appraisal$vintage),
    if (!is.null(appraisal$optimism_bias)) {
      sprintf("Optimism bias & %.0f\\%% \\\\", 100 * appraisal$optimism_bias)
    },
    if (isTRUE(appraisal$metb_applied)) {
      "METB & applied \\\\"
    }
  )
  rows <- rows[!vapply(rows, is.null, logical(1))]

  body <- paste(rows, collapse = "\n")
  preamble <- "\\begin{tabular}{ll}\n\\hline\nMetric & Value \\\\\n\\hline\n"
  closing <- "\n\\hline\n\\end{tabular}"

  out <- paste0(preamble, body, closing)
  if (!is.null(caption) || !is.null(label)) {
    cap <- if (!is.null(caption)) sprintf("\\caption{%s}\n", caption) else ""
    lab <- if (!is.null(label)) sprintf("\\label{%s}\n", label) else ""
    out <- sprintf("\\begin{table}[h]\n\\centering\n%s%s%s\n\\end{table}",
                   out, cap, lab)
  }
  out
}

#' Export an appraisal to Excel
#'
#' Writes a multi-sheet workbook: summary, cashflow, present
#' values, provenance.
#'
#' @param appraisal A `gb_appraisal` object.
#' @param file Output file path (must end in `.xlsx`).
#'
#' @return Invisibly, the file path.
#'
#' @details
#' Requires the `openxlsx` package (in Suggests). Install with
#' `install.packages("openxlsx")` if not present.
#'
#' @family reporting
#' @seealso [gb_to_latex()], [gb_to_word()].
#'
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("openxlsx", quietly = TRUE)) {
#'   app <- gb_appraise(c(100, 0, 0, 0, 0), c(0, 30, 30, 30, 30))
#'   tmp <- tempfile(fileext = ".xlsx")
#'   gb_to_excel(app, tmp)
#' }
#' }
gb_to_excel <- function(appraisal, file) {
  if (!requireNamespace("openxlsx", quietly = TRUE)) {
    cli::cli_abort(
      "Package {.pkg openxlsx} is required for {.fn gb_to_excel}. Install with {.code install.packages('openxlsx')}."
    )
  }
  if (!inherits(appraisal, "gb_appraisal")) {
    cli::cli_abort("{.arg appraisal} must be a {.cls gb_appraisal}.")
  }
  if (!grepl("\\.xlsx$", file)) {
    cli::cli_abort("{.arg file} must end in {.val .xlsx}.")
  }

  summary_df <- data.frame(
    metric = c("NPV", "BCR", "Schedule", "Horizon", "Base year",
               "Vintage", "Optimism bias", "METB applied"),
    value = c(
      .format_gbp(appraisal$npv),
      if (!is.null(appraisal$bcr) && !is.na(appraisal$bcr))
        sprintf("%.2f", appraisal$bcr) else NA,
      appraisal$schedule,
      length(appraisal$cashflow),
      appraisal$base_year %||% NA,
      appraisal$vintage,
      if (!is.null(appraisal$optimism_bias))
        sprintf("%.0f%%", 100 * appraisal$optimism_bias) else "none",
      if (isTRUE(appraisal$metb_applied)) "yes" else "no"
    ),
    stringsAsFactors = FALSE
  )

  cashflow_df <- data.frame(
    year = appraisal$years,
    cashflow = appraisal$cashflow,
    discount_factor = gb_discount_factor(appraisal$years, schedule = appraisal$schedule),
    pv = appraisal$pv,
    stringsAsFactors = FALSE
  )

  provenance <- gb_data_versions()

  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "Summary")
  openxlsx::addWorksheet(wb, "Cashflow")
  openxlsx::addWorksheet(wb, "Provenance")
  openxlsx::writeData(wb, "Summary", summary_df)
  openxlsx::writeData(wb, "Cashflow", cashflow_df)
  openxlsx::writeData(wb, "Provenance", provenance)
  openxlsx::saveWorkbook(wb, file, overwrite = TRUE)

  invisible(file)
}

#' Export an appraisal to Word
#'
#' Writes a one-page Word document with the appraisal headline and
#' cashflow table.
#'
#' @param appraisal A `gb_appraisal` object.
#' @param file Output file path (must end in `.docx`).
#'
#' @return Invisibly, the file path.
#'
#' @details
#' Requires the `officer` and `flextable` packages (both in Suggests).
#'
#' @family reporting
#' @seealso [gb_to_latex()], [gb_to_excel()].
#'
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("officer", quietly = TRUE) &&
#'     requireNamespace("flextable", quietly = TRUE)) {
#'   app <- gb_appraise(c(100, 0, 0, 0, 0), c(0, 30, 30, 30, 30))
#'   tmp <- tempfile(fileext = ".docx")
#'   gb_to_word(app, tmp)
#' }
#' }
gb_to_word <- function(appraisal, file) {
  if (!requireNamespace("officer", quietly = TRUE) ||
      !requireNamespace("flextable", quietly = TRUE)) {
    cli::cli_abort(
      "Packages {.pkg officer} and {.pkg flextable} are required for {.fn gb_to_word}."
    )
  }
  if (!inherits(appraisal, "gb_appraisal")) {
    cli::cli_abort("{.arg appraisal} must be a {.cls gb_appraisal}.")
  }
  if (!grepl("\\.docx$", file)) {
    cli::cli_abort("{.arg file} must end in {.val .docx}.")
  }

  summary_df <- data.frame(
    Metric = c("NPV", "BCR", "Schedule", "Horizon", "Base year", "Vintage"),
    Value = c(
      .format_gbp(appraisal$npv),
      if (!is.null(appraisal$bcr) && !is.na(appraisal$bcr))
        sprintf("%.2f", appraisal$bcr) else "n/a",
      appraisal$schedule,
      sprintf("%d years", length(appraisal$cashflow)),
      as.character(appraisal$base_year %||% "not set"),
      sprintf("Green Book %s", appraisal$vintage)
    ),
    stringsAsFactors = FALSE
  )

  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc, "Green Book Appraisal", style = "heading 1")
  doc <- flextable::body_add_flextable(doc, flextable::flextable(summary_df))
  doc <- officer::body_add_par(doc, "")
  doc <- officer::body_add_par(doc, "Cashflow", style = "heading 2")
  cashflow_df <- data.frame(
    Year = appraisal$years,
    Cashflow = appraisal$cashflow,
    PV = appraisal$pv
  )
  doc <- flextable::body_add_flextable(doc, flextable::flextable(cashflow_df))
  print(doc, target = file)

  invisible(file)
}
