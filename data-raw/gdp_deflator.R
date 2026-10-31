# Refresh GDP deflator series.
#
# Source: HM Treasury, "GDP deflators at market prices, and money GDP".
# Updated quarterly and at each fiscal event. Most recent: October 2026
# (Budget), outturn consistent with the ONS Quarterly National Accounts
# of 30 September 2026, forecasts consistent with the OBR October 2026
# Economic and Fiscal Outlook.
# Page: https://www.gov.uk/government/collections/gdp-deflators-at-market-prices-and-money-gdp
#
# Reads the calendar-year deflator series and writes the bundled CSV.
# Outturn years carry the published index (2025 = 100). Forecast years
# are published only as percentage changes, so their index is the last
# outturn value chained forward by those changes. The `type` column
# records which is which.

library(readxl)

# The attachment URL changes with each release; resolve the latest
# statistics page from the collection via the GOV.UK Content API.
collection <- jsonlite::fromJSON(
  "https://www.gov.uk/api/content/government/collections/gdp-deflators-at-market-prices-and-money-gdp"
)
docs <- collection$links$documents
docs <- docs[grepl("^GDP deflators at market prices, and money GDP", docs$title), ]
latest <- docs$base_path[which.max(as.POSIXct(docs$public_updated_at))]
page <- jsonlite::fromJSON(paste0("https://www.gov.uk/api/content", latest))
url <- grep("\\.xlsx$", page$details$attachments$url, value = TRUE)[1]
message("Using ", url)

local_file <- tempfile(fileext = ".xlsx")
download.file(url, local_file, mode = "wb", quiet = TRUE)

raw <- read_excel(local_file, skip = 7, col_names = FALSE,
                  .name_repair = "minimal")

# Calendar-year block: column 7 = year label, 8 = index, 9 = percent
# change on the previous year. Forecast labels carry footnote markers,
# e.g. "2026 (1), (2)".
year_lab <- trimws(as.character(raw[[7]]))
yr <- suppressWarnings(as.integer(substr(year_lab, 1, 4)))
keep <- !is.na(yr) & grepl("^[0-9]{4}( |$)", year_lab)
cal <- data.frame(
  year  = yr[keep],
  index = suppressWarnings(as.numeric(raw[[8]][keep])),
  pct   = suppressWarnings(as.numeric(raw[[9]][keep]))
)
cal$type <- ifelse(is.na(cal$index), "forecast", "outturn")

for (i in which(cal$type == "forecast")) {
  cal$index[i] <- cal$index[i - 1L] * (1 + cal$pct[i] / 100)
}

defl <- cal[cal$year >= 1990, c("year", "index", "type")]
names(defl)[2] <- "value"
defl$value <- round(defl$value, 4)
stopifnot(!anyNA(defl$value), !is.unsorted(defl$year))

write.csv(defl, "inst/extdata/gdp_deflator.csv", row.names = FALSE)
