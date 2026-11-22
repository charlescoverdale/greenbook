# Refresh DESNZ Carbon Values for Appraisal.
#
# Source: DESNZ "Valuation of Energy Use and Greenhouse Gas
# Emissions for Appraisal" (updated 2 November 2026), Data tables
# 1 to 18 (October 2026), Table 3.
# Page: https://www.gov.uk/government/publications/valuation-of-energy-use-and-greenhouse-gas-emissions-for-appraisal
#
# DESNZ moved to a single consolidated carbon value series in
# November 2023, superseding the historical traded / non-traded
# split. The October 2026 tables restate the same real path in 2025
# prices, converted with the ONS September 2026 GDP deflator series.

library(readxl)

url <- "https://assets.publishing.service.gov.uk/media/6ae35a4b83b993d8d93eb791/data_tables_1-18-oct-2026.xlsx"

local_file <- tempfile(fileext = ".xlsx")
download.file(url, local_file, mode = "wb", quiet = TRUE)

raw <- read_excel(local_file, sheet = "Table 3", col_names = FALSE,
                  .name_repair = "minimal")

years <- suppressWarnings(as.integer(raw[[1]]))
year_rows <- which(!is.na(years))

carbon_long <- do.call(rbind, lapply(year_rows, function(i) {
  data.frame(
    year = years[i],
    base_year = 2025L,
    series = "consolidated",
    scenario = c("low", "central", "high"),
    value_gbp_per_tco2e = round(c(
      as.numeric(raw[[2]][i]),
      as.numeric(raw[[3]][i]),
      as.numeric(raw[[4]][i])
    ), 2)
  )
}))
carbon_long <- carbon_long[!is.na(carbon_long$value_gbp_per_tco2e), ]

write.csv(carbon_long, "inst/extdata/carbon_values.csv", row.names = FALSE)
