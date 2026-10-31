#' Tibble of the STPR schedule
#'
#' Returns the bundled STPR kinked schedule as a data frame: one row
#' per band, columns `year_from`, `year_to`, and (depending on
#' `schedule`) either all three rate variants or just the requested
#' one.
#'
#' @param schedule Optional. One of `"standard"`, `"health"`,
#'   `"catastrophic"`. If `NULL` (default), all three columns are
#'   returned. The `"2026-10"` vintage has only `"standard"`; its other
#'   two columns are `NA`.
#' @param vintage Discounting vintage, `"2026-10"` (default) or `"2003"`.
#'   See [gb_stpr()].
#'
#' @return A data frame.
#'
#' @family lookups
#' @seealso [gb_stpr()], [gb_data_versions()].
#'
#' @export
#' @examples
#' gb_schedule_table()
#' gb_schedule_table("health", vintage = "2003")
gb_schedule_table <- function(schedule = NULL, vintage = "2026-10") {
  vintage <- .stpr_vintage(vintage)
  tbl <- .read_stpr()
  tbl <- tbl[tbl$vintage == vintage, setdiff(names(tbl), "vintage")]
  rownames(tbl) <- NULL
  if (!is.null(schedule)) {
    schedule <- match.arg(schedule, c("standard", "health", "catastrophic"))
    .check_schedule_vintage(schedule, vintage)
    tbl <- tbl[, c("year_from", "year_to", schedule)]
    names(tbl)[3] <- "rate"
  }
  tbl
}

#' Vintage of bundled parameter tables
#'
#' Returns a data frame describing the source and last-updated date
#' of every CSV bundled in `inst/extdata/`. Critical for
#' reproducibility: every appraisal can record which vintage of
#' Green Book parameters it used.
#'
#' @return A data frame with columns `dataset`, `source`,
#'   `last_updated`, `notes`.
#'
#' @family lookups
#' @seealso [gb_schedule_table()].
#'
#' @export
#' @examples
#' gb_data_versions()
gb_data_versions <- function() {
  .read_data_versions()
}
