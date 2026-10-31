# Refresh STPR schedule.
#
# Two vintages are bundled, one row per band:
#
# "2026-10": HM Treasury, Green Book supplementary guidance: discounting
#   (updated 28 October 2026), paragraph 3.8. 3.00% for years 1 to 30,
#   2.50% for 31 to 75, 2.25% for 76 to 125. Paragraph 3.10 says not to
#   discount beyond year 125, and paragraph 3.2 withdraws differentiated
#   rates, so there is no health or catastrophic-risk schedule.
#
# "2003": the schedule in force from the 2003 Green Book until October
#   2026 (carried unchanged through the 2018, 2022 and February 2026
#   editions). 3.5% declining to 1.0%, with the DHSC health schedule and
#   the catastrophic-risk-excluded schedule.
#
# Year 0 is the base year and is never discounted, so the first band of
# each vintage starts at 0.

stpr_2026 <- data.frame(
  vintage      = "2026-10",
  year_from    = c(0L, 31L, 76L),
  year_to      = c(30L, 75L, 125L),
  standard     = c(0.030, 0.025, 0.0225),
  health       = NA_real_,
  catastrophic = NA_real_
)

stpr_2003 <- data.frame(
  vintage      = "2003",
  year_from    = c(0L, 31L, 76L, 126L, 201L, 301L),
  year_to      = c(30L, 75L, 125L, 200L, 300L, 1000L),
  standard     = c(0.035, 0.030, 0.025, 0.020, 0.015, 0.010),
  health       = c(0.015, 0.0129, 0.0107, 0.0086, 0.0064, 0.0043),
  catastrophic = c(0.030, 0.0257, 0.0214, 0.0171, 0.0129, 0.0086)
)

stpr <- rbind(stpr_2026, stpr_2003)

write.csv(stpr, "inst/extdata/stpr_schedule.csv", row.names = FALSE)
