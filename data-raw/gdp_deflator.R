# Refresh GDP deflator series.
#
# Source: HM Treasury, "GDP deflators at market prices, and money GDP".
# Updated quarterly. Most recent reference: December 2025 Quarterly
# National Accounts.
# Page: https://www.gov.uk/government/collections/gdp-deflators-at-market-prices-and-money-gdp
#
# Reads the calendar-year deflator series from the GOV.UK XLSX
# attachment and writes the bundled CSV.

library(readxl)

# Find the latest XLSX URL on the GDP deflators landing page (the
# attachment URL changes with each release). Update this URL when a
# new quarterly publication lands.
url <- "https://assets.publishing.service.gov.uk/media/695ced916056a077857e735e/CGDP_Deflators_Qtrly_National_Accounts_December_2025_update.xlsx"

local_file <- tempfile(fileext = ".xlsx")
download.file(url, local_file, mode = "wb", quiet = TRUE)

raw <- read_excel(local_file, skip = 6, col_names = FALSE,
                  .name_repair = "minimal")

# Calendar-year columns (7 = year, 8 = deflator index, 2024-25 = 100)
defl <- data.frame(
  year = suppressWarnings(as.integer(raw[[7]])),
  value = suppressWarnings(as.numeric(raw[[8]]))
)
defl <- defl[!is.na(defl$year) & !is.na(defl$value) & defl$year >= 1990, ]
defl$value <- round(defl$value, 4)

write.csv(defl, "inst/extdata/gdp_deflator.csv", row.names = FALSE)
