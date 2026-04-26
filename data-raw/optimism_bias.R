# Refresh optimism bias upper bounds.
#
# Source: HM Treasury Supplementary Green Book Guidance: Optimism Bias.
# Underlying study: Mott MacDonald (2002) Review of Large Public Procurement
# in the UK. Values published in Annex A1 of the supplementary guidance.
# Unchanged since 2003. Update only if HM Treasury publishes a refreshed
# OB schedule.

ob <- data.frame(
  category = c(
    "standard_buildings",
    "non_standard_buildings",
    "standard_civil_engineering",
    "non_standard_civil_engineering",
    "equipment_development",
    "outsourcing"
  ),
  description = c(
    "Schools hospitals offices: standard accommodation",
    "Major prestige projects and complex programmes",
    "Roads drainage sewers and similar",
    "Innovative civil works (light rail tunnels major estuarine)",
    "Bespoke or innovative equipment and development",
    "IT and similar service outsourcing"
  ),
  capex_upper = c(0.24, 0.51, 0.44, 0.66, 2.00, 0.41),
  duration_upper = c(0.04, 0.39, 0.20, 0.25, 0.54, 0.15),
  stringsAsFactors = FALSE
)

write.csv(ob, "inst/extdata/optimism_bias.csv", row.names = FALSE)
