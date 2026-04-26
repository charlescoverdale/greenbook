# Cross-validation tests pinning the kinked-schedule logic against
# closed-form benchmarks. Useful as level-3/4 invariant tests for
# academic and government-economics scrutiny.

test_that("annuity factor at 3.5 percent for 30 years matches closed form", {
  factors <- gb_discount_factor(seq_len(30))
  annuity <- sum(factors)
  closed_form <- (1 - 1.035^-30) / 0.035
  expect_equal(annuity, closed_form, tolerance = 1e-9)
})

test_that("annuity factor for 5 years matches closed form", {
  factors <- gb_discount_factor(seq_len(5))
  annuity <- sum(factors)
  closed_form <- (1 - 1.035^-5) / 0.035
  expect_equal(annuity, closed_form, tolerance = 1e-9)
})

test_that("100-year flat GBP 1 annuity matches kinked-schedule benchmark", {
  rates <- c(rep(0.035, 30), rep(0.030, 45), rep(0.025, 25))
  factors_manual <- cumprod(1 + rates)
  benchmark <- sum(1 / factors_manual)
  package <- sum(gb_discount_factor(seq_len(100)))
  expect_equal(package, benchmark, tolerance = 1e-9)
})

test_that("health and catastrophic rates are constant ratios of standard within first band", {
  # Within the first band (years 1-30), all variants have constant rates.
  health_ratio <- gb_stpr(15, "health") / gb_stpr(15, "standard")
  catastrophic_ratio <- gb_stpr(15, "catastrophic") / gb_stpr(15, "standard")
  expect_equal(health_ratio, 0.015 / 0.035, tolerance = 1e-9)
  expect_equal(catastrophic_ratio, 0.030 / 0.035, tolerance = 1e-9)
})

test_that("gb_npv worked example: 5-year annuity matches manual calculation", {
  # Standard appraisal pattern: capex GBP 100 in year 0, benefits
  # GBP 30 per year in years 1-5
  net <- c(-100, rep(30, 5))
  app <- gb_npv(net)
  manual <- -100 + sum(30 / 1.035 ^ (1:5))
  expect_equal(app$npv, manual, tolerance = 1e-9)
})

test_that("gb_appraise: 30-year project with OB and METB matches manual", {
  costs <- c(100, rep(0, 29))
  benefits <- c(0, rep(10, 29))
  app <- gb_appraise(costs, benefits, ob = 0.20, ob_mitigation = 0.5,
                     metb = TRUE, metb_rate = 0.20)

  # Manual: cost uplifted by OB then METB:
  # capex_adj = 100 * (1 + 0.20 * 0.5) = 110
  # then * (1 + 0.20) = 132
  expect_equal(app$costs[1], 132, tolerance = 1e-9)

  # PV of benefits: 10 * sum(1.035^-t, t=1..29)
  benefits_pv_manual <- 10 * sum(1.035 ^ -(1:29))
  expect_equal(app$pv_benefits, benefits_pv_manual, tolerance = 1e-9)

  # NPV: PV benefits - PV costs (capex at year 0 has DF = 1)
  expect_equal(app$npv, benefits_pv_manual - 132, tolerance = 1e-9)
})

test_that("WELLBY scaling: persons and years are linear and commute", {
  base <- gb_wellby(1, persons = 1, years = 1)
  expect_equal(gb_wellby(1, 100, 5), 100 * 5 * base, tolerance = 1e-9)
  expect_equal(gb_wellby(1, 5, 100), 5 * 100 * base, tolerance = 1e-9)
})

test_that("gb_carbon_npv equals manually-discounted emissions value", {
  emissions <- rep(100, 5)
  years <- 2024:2028
  app <- gb_carbon_npv(emissions, years, base_year = 2024)

  values <- gb_carbon_value(years, base_year = 2024)
  cashflow <- -emissions * values  # cost convention
  rel_years <- years - 2024
  manual_pv <- sum(cashflow * gb_discount_factor(rel_years))
  expect_equal(app$npv, manual_pv, tolerance = 1e-9)
})

test_that("citation() returns greenbook-aware bibentry", {
  cit <- utils::citation("greenbook")
  expect_s3_class(cit, "citation")
  txt <- format(cit)
  expect_true(any(grepl("greenbook", txt, ignore.case = TRUE)))
  expect_true(any(grepl("Coverdale", txt)))
})
