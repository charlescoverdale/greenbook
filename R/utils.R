# Internal helpers (not exported)

`%||%` <- function(a, b) if (is.null(a)) b else a

# Path to bundled CSV in inst/extdata
.gb_extdata <- function(file) {
  path <- system.file("extdata", file, package = "greenbook")
  if (!nzchar(path)) {
    cli::cli_abort("Bundled data file {.val {file}} not found in greenbook extdata.")
  }
  path
}

# Lazy readers for bundled tables
.read_stpr <- function() {
  utils::read.csv(.gb_extdata("stpr_schedule.csv"))
}

.read_deflator <- function() {
  utils::read.csv(.gb_extdata("gdp_deflator.csv"))
}

.read_data_versions <- function() {
  utils::read.csv(.gb_extdata("data_versions.csv"))
}

.read_optimism_bias <- function() {
  utils::read.csv(.gb_extdata("optimism_bias.csv"), stringsAsFactors = FALSE)
}

.read_metb <- function() {
  utils::read.csv(.gb_extdata("metb.csv"), stringsAsFactors = FALSE)
}

# Validate numeric vector input
validate_numeric <- function(x, arg = "x", allow_na = FALSE, require_positive = FALSE) {
  if (!is.numeric(x)) {
    cli::cli_abort("{.arg {arg}} must be a numeric vector.")
  }
  if (!allow_na && anyNA(x)) {
    cli::cli_abort("{.arg {arg}} contains {.val NA} values.")
  }
  if (require_positive && any(x <= 0, na.rm = TRUE)) {
    cli::cli_abort("{.arg {arg}} must be strictly positive.")
  }
  invisible(x)
}

# Validate year vector
validate_year <- function(years, arg = "years", min_year = 0L, max_year = NULL) {
  validate_numeric(years, arg = arg)
  if (any(years < min_year)) {
    cli::cli_abort("{.arg {arg}} must be >= {min_year}.")
  }
  if (!is.null(max_year) && any(years > max_year)) {
    cli::cli_abort("{.arg {arg}} must be <= {max_year}.")
  }
  if (any(years != as.integer(years))) {
    cli::cli_abort("{.arg {arg}} must be integer-valued.")
  }
  invisible(years)
}

# GBP formatter for print methods. Charles's house style: "GBP 45m" / "GBP 250k".
.format_gbp <- function(x, digits = 1) {
  if (length(x) != 1L || !is.finite(x)) return(format(x))
  if (abs(x) >= 1e9) return(sprintf("GBP %.2fbn", x / 1e9))
  if (abs(x) >= 1e6) return(sprintf("GBP %.2fm", x / 1e6))
  if (abs(x) >= 1e3) return(sprintf("GBP %.1fk", x / 1e3))
  sprintf(paste0("GBP %.", digits, "f"), x)
}
