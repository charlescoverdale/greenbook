#' Tibble of the STPR schedule
#'
#' Returns the bundled STPR kinked schedule as a data frame: one row
#' per band, columns `year_from`, `year_to`, and (depending on
#' `schedule`) either all three rate variants or just the requested
#' one.
#'
#' @param schedule Optional. One of `"standard"`, `"health"`,
#'   `"catastrophic"`. If `NULL` (default), all three columns are
#'   returned.
#'
#' @return A data frame.
#'
#' @export
#' @examples
#' gb_schedule_table()
#' gb_schedule_table("health")
gb_schedule_table <- function(schedule = NULL) {
  tbl <- .read_stpr()
  if (!is.null(schedule)) {
    schedule <- match.arg(schedule, c("standard", "health", "catastrophic"))
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
#' @export
#' @examples
#' gb_data_versions()
gb_data_versions <- function() {
  .read_data_versions()
}
