# Refresh DESNZ Carbon Values for Appraisal.
#
# Source: DESNZ "Valuation of Energy Use and Greenhouse Gas
# Emissions for Appraisal" (November 2023), Data Tables 1-19,
# Table 3.
# Page: https://www.gov.uk/government/publications/valuation-of-energy-use-and-greenhouse-gas-emissions-for-appraisal
#
# DESNZ moved to a single consolidated carbon value series in
# November 2023, superseding the historical traded / non-traded
# split. Values are in 2022 prices. The published series covers
# 2010 to 2100.

library(readxl)

url <- "https://assets.publishing.service.gov.uk/media/6567994fcc1ec5000d8eef17/data-tables-1-19.xlsx"

local_file <- tempfile(fileext = ".xlsx")
download.file(url, local_file, mode = "wb", quiet = TRUE)

raw <- read_excel(local_file, sheet = "Table 3", col_names = FALSE,
                  .name_repair = "minimal")

years <- suppressWarnings(as.integer(raw[[1]]))
year_rows <- which(!is.na(years))

carbon_long <- do.call(rbind, lapply(year_rows, function(i) {
  data.frame(
    year = years[i],
    base_year = 2022L,
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
