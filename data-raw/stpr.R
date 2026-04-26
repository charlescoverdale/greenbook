# Refresh STPR schedule.
#
# Source: HM Treasury Green Book 2022 / 2026, supplementary guidance on
# discounting. Update only when a new Green Book vintage publishes a
# revised STPR schedule (next: 2026 review).

stpr <- data.frame(
  year_from = c(0L, 31L, 76L, 126L, 201L, 301L),
  year_to   = c(30L, 75L, 125L, 200L, 300L, 1000L),
  standard  = c(0.035, 0.030, 0.025, 0.020, 0.015, 0.010),
  health    = c(0.015, 0.0129, 0.0107, 0.0086, 0.0064, 0.0043),
  catastrophic = c(0.030, 0.0257, 0.0214, 0.0171, 0.0129, 0.0086)
)

write.csv(stpr, "inst/extdata/stpr_schedule.csv", row.names = FALSE)
