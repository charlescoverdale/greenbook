#' Aggregate sub-projects into a place-based business case
#'
#' Combines multiple `gb_appraisal` objects into a single portfolio
#' appraisal. Introduced in the 2026 Green Book as a recognised
#' business case structure for places (city deals, devolved
#' settlements, regional packages) where individual projects are
#' interdependent.
#'
#' @param ... `gb_appraisal` objects representing sub-projects.
#'   Pass as named arguments to label each.
#' @param place Character scalar. Place name (e.g. `"Greater
#'   Manchester"`). Optional.
#' @param synergy Numeric scalar in `[-0.5, 0.5]`. Optional uplift
#'   applied to aggregate benefits to capture cross-project synergy
#'   or drag. Default `0` (additive aggregation).
#'
#' @return A `gb_place_based` object with elements `projects`,
#'   `place`, `aggregate_npv`, `aggregate_bcr`, `per_project`,
#'   `synergy`.
#'
#' @references HM Treasury (2026). The Green Book, on place-based
#'   business cases.
#'
#' @family appraisal
#' @seealso [gb_appraise()], [gb_compare()].
#'
#' @export
#' @examples
#' transport <- gb_appraise(c(100, 0, 0, 0, 0), c(0, 30, 30, 30, 30))
#' housing <- gb_appraise(c(50, 0, 0, 0, 0), c(0, 20, 20, 20, 20))
#' skills <- gb_appraise(c(20, 20, 0, 0, 0), c(0, 0, 15, 15, 15))
#' gb_place_based(transport = transport, housing = housing,
#'                skills = skills, place = "Example City")
gb_place_based <- function(..., place = NULL, synergy = 0) {
  validate_numeric(synergy, "synergy")
  if (length(synergy) != 1L) cli::cli_abort("{.arg synergy} must be scalar.")
  if (synergy < -0.5 || synergy > 0.5) {
    cli::cli_abort("{.arg synergy} must be in [-0.5, 0.5].")
  }

  projects <- list(...)
  if (length(projects) < 1L) {
    cli::cli_abort("{.fn gb_place_based} requires at least one project.")
  }
  if (is.null(names(projects)) || any(!nzchar(names(projects)))) {
    names(projects) <- paste0("project_", seq_along(projects))
  }
  for (i in seq_along(projects)) {
    if (!inherits(projects[[i]], "gb_appraisal")) {
      cli::cli_abort("All inputs must be {.cls gb_appraisal} objects.")
    }
  }

  rows <- lapply(seq_along(projects), function(i) {
    a <- projects[[i]]
    data.frame(
      project = names(projects)[i],
      npv = a$npv,
      bcr = a$bcr %||% NA_real_,
      pv_costs = a$pv_costs %||% NA_real_,
      pv_benefits = a$pv_benefits %||% NA_real_,
      stringsAsFactors = FALSE
    )
  })
  tbl <- do.call(rbind, rows)

  total_pv_costs <- sum(tbl$pv_costs, na.rm = TRUE)
  total_pv_benefits <- sum(tbl$pv_benefits, na.rm = TRUE) * (1 + synergy)
  aggregate_npv <- total_pv_benefits - total_pv_costs
  aggregate_bcr <- if (total_pv_costs > 0) total_pv_benefits / total_pv_costs else NA_real_

  out <- list(
    projects = projects,
    place = place,
    aggregate_npv = aggregate_npv,
    aggregate_bcr = aggregate_bcr,
    per_project = tbl,
    synergy = synergy
  )
  class(out) <- c("gb_place_based", "list")
  out
}

#' @export
print.gb_place_based <- function(x, ...) {
  npv_str <- .format_gbp(x$aggregate_npv)
  bcr_str <- sprintf("%.2f", x$aggregate_bcr)
  syn_str <- sprintf("%+.0f%%", 100 * x$synergy)
  n_proj <- nrow(x$per_project)
  cli::cli_h1("Place-based business case")
  if (!is.null(x$place)) cli::cli_text("Place: {.field {x$place}}")
  cli::cli_text("Projects: {.val {n_proj}}")
  cli::cli_text("Aggregate NPV: {.val {npv_str}}")
  if (!is.na(x$aggregate_bcr)) {
    cli::cli_text("Aggregate BCR: {.val {bcr_str}}")
  }
  if (x$synergy != 0) {
    cli::cli_text("Synergy uplift: {.val {syn_str}}")
  }
  cat("\n")
  print(x$per_project, row.names = FALSE)
  invisible(x)
}
