# Refresh Value of Preventing a Fatality series.
#
# Source: DfT Transport Analysis Guidance (TAG) data book.
# Page: https://www.gov.uk/government/publications/tag-data-book
#
# The TAG data book publishes the WTP element of the Value of
# Preventing a Fatality (Table A4.1.1) at a fixed price year. We
# bundle the published anchor and uplift other years at 2 percent
# real GDP per head growth, per TAG methodology.

library(readxl)

# Latest TAG data book attachment URL (update on each release).
url <- "https://assets.publishing.service.gov.uk/media/694a908c888ddc41b48a54f9/tag-data-book-v2-03fc-dec-2025.xlsm"

local_file <- tempfile(fileext = ".xlsm")
download.file(url, local_file, mode = "wb", quiet = TRUE)

# Sheet A4.1.1 has the per-casualty values. The fatal row's WTP
# column (col 3) is the published VPF.
raw <- read_excel(local_file, sheet = "A4.1.1", col_names = FALSE,
                  .name_repair = "minimal", n_max = 50)

# Walk the rows looking for the fatal-casualty row (label "Fatal" in col 1
# of the data block). Default behaviour: extract the WTP column for
# the published price year.
fatal_row <- which(raw[[1]] == "Fatal")
anchor_value <- as.numeric(raw[[3]][fatal_row])
anchor_year <- 2023L  # TAG v2.03 price year

# Uplift series 2018-2030 at 2 percent real GDP per head growth
years_vpf <- 2018:2030
vpf <- data.frame(
  year = years_vpf,
  value_gbp = round(anchor_value * 1.02 ^ (years_vpf - anchor_year)),
  base_year = years_vpf,
  source = ifelse(years_vpf == anchor_year,
                  "DfT TAG data book v2.03 (Dec 2025), Table A4.1.1, WTP element",
                  "Uplifted from 2023 anchor at 2 percent real GDP per head growth")
)

write.csv(vpf, "inst/extdata/vpf.csv", row.names = FALSE)
