test_that("gb_carbon_value matches DESNZ October 2026 Table 3 published values", {
  # DESNZ data tables 1 to 18 (October 2026), central path, 2025 GBP/tCO2e
  expect_equal(gb_carbon_value(2020), 289.47)
  expect_equal(gb_carbon_value(2024), 307.51)
  expect_equal(gb_carbon_value(2030), 336.70)
  expect_equal(gb_carbon_value(2050), 454.51)
})

test_that("rebasing the 2025-price values to 2022 recovers the November 2023 path", {
  # The October 2026 tables restate the November 2023 real path in 2025
  # prices; rebasing through gb_deflator() reproduces the old 2022 values.
  expect_equal(gb_carbon_value(2020, base_year = 2022), 253.19, tolerance = 1e-3)
  expect_equal(gb_carbon_value(2025, base_year = 2022), 273.06, tolerance = 1e-3)
  expect_equal(gb_carbon_value(2050, base_year = 2022), 397.54, tolerance = 1e-3)
})

test_that("gb_carbon_value low and high scenarios match Table 3", {
  expect_equal(gb_carbon_value(2020, "low"), 144.74)
  expect_equal(gb_carbon_value(2020, "high"), 434.21)
  expect_equal(gb_carbon_value(2050, "low"), 227.25)
  expect_equal(gb_carbon_value(2050, "high"), 681.76)
})

test_that("gb_carbon_value low < central < high at every year", {
  for (y in c(2020, 2030, 2040, 2050)) {
    expect_lt(gb_carbon_value(y, "low"), gb_carbon_value(y, "central"))
    expect_gt(gb_carbon_value(y, "high"), gb_carbon_value(y, "central"))
  }
})

test_that("gb_carbon_value is monotonically increasing over time", {
  out <- gb_carbon_value(2020:2050)
  expect_true(all(diff(out) > 0))
})

test_that("gb_carbon_value supports vectorised year input", {
  out <- gb_carbon_value(c(2020, 2030, 2050))
  expect_length(out, 3L)
  expect_equal(out[1], 289.47)
  expect_equal(out[3], 454.51)
})

test_that("gb_carbon_value rebases via deflator", {
  v_2022 <- gb_carbon_value(2025, base_year = 2022)
  v_2024 <- gb_carbon_value(2025, base_year = 2024)
  factor <- gb_deflator(2022, 2024)
  expect_equal(v_2024, v_2022 * factor, tolerance = 1e-6)
})

test_that("gb_carbon_value errors outside bundled range", {
  expect_error(gb_carbon_value(2019))
  expect_error(gb_carbon_value(2055))
})

test_that("gb_carbon_value errors on bad scenario", {
  expect_error(gb_carbon_value(2030, scenario = "wrong"))
})

test_that("gb_carbon_npv returns gb_appraisal with carbon-specific fields", {
  app <- gb_carbon_npv(rep(100, 7), 2024:2030)
  expect_s3_class(app, "gb_appraisal")
  expect_true(!is.null(app$emissions))
  expect_true(!is.null(app$years_calendar))
  expect_true(!is.null(app$carbon_scenario))
})

test_that("gb_carbon_npv treats positive emissions as cost by default", {
  app_cost <- gb_carbon_npv(rep(100, 5), 2024:2028)
  expect_lt(app_cost$npv, 0)
})

test_that("gb_carbon_npv with sign='benefit' inverts the cashflow", {
  app_cost <- gb_carbon_npv(rep(100, 5), 2024:2028, sign = "cost")
  app_benefit <- gb_carbon_npv(rep(100, 5), 2024:2028, sign = "benefit")
  expect_equal(app_cost$npv, -app_benefit$npv, tolerance = 1e-9)
})

test_that("gb_carbon_npv errors on length mismatch", {
  expect_error(gb_carbon_npv(c(100, 200), 2024:2026))
})
