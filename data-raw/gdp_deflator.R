# Refresh GDP deflator series.
#
# Source: ONS GDP deflator at market prices (series YBGB) plus OBR
# forecast. Bundled vintage for v0.1.0; future versions can pull live
# values via the `inflateR` package when present (see Suggests).
#
# Run quarterly when ONS publishes the deflator update (March, June,
# September, December).

# Example refresh path (uncomment when inflateR is on CRAN and ready):
# defl <- inflateR::uk_gdp_deflator(base_year = 2022)
# write.csv(defl, "inst/extdata/gdp_deflator.csv", row.names = FALSE)

cat("To refresh: edit inst/extdata/gdp_deflator.csv directly with",
    "the ONS YBGB series, or use inflateR::uk_gdp_deflator() once",
    "this package adds the dependency.\n")
