# Refresh Marginal Excess Tax Burden series.
#
# Source: HM Treasury Green Book successive vintages. The METB is an
# uplift applied to revenue raised through the tax system, capturing the
# welfare cost of distortionary taxation. Reduced from 30 percent to
# 20 percent in the 2018 update. Maintained at 20 percent in 2022 and
# 2026.

metb <- data.frame(
  vintage = c("2003", "2018", "2022", "2026"),
  rate = c(0.30, 0.20, 0.20, 0.20),
  notes = c(
    "Historic Green Book uplift on revenue raised through distortionary taxation",
    "Reduced to 20 percent following review",
    "Maintained at 20 percent in Green Book 2022",
    "Maintained at 20 percent in Green Book 2026"
  ),
  stringsAsFactors = FALSE
)

write.csv(metb, "inst/extdata/metb.csv", row.names = FALSE)
