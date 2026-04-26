test_that("gb_carbon_value returns published 2020 central traded value", {
  expect_equal(gb_carbon_value(2020), 245)
})

test_that("gb_carbon_value low and high scenarios bracket central", {
  central <- gb_carbon_value(2030, scenario = "central")
  low <- gb_carbon_value(2030, scenario = "low")
  high <- gb_carbon_value(2030, scenario = "high")
  expect_lt(low, central)
  expect_gt(high, central)
})

test_that("gb_carbon_value is monotonically increasing over time", {
  out <- gb_carbon_value(2020:2050)
  expect_true(all(diff(out) >= 0))
})

test_that("gb_carbon_value supports vectorised year input", {
  out <- gb_carbon_value(c(2020, 2030, 2050))
  expect_length(out, 3L)
  expect_equal(out[1], 245)
  expect_equal(out[3], 411)
})

test_that("gb_carbon_value rebases via deflator", {
  v_2020 <- gb_carbon_value(2025, base_year = 2020)
  v_2024 <- gb_carbon_value(2025, base_year = 2024)
  factor <- gb_deflator(2020, 2024)
  expect_equal(v_2024, v_2020 * factor, tolerance = 1e-6)
})

test_that("gb_carbon_value errors outside bundled range", {
  expect_error(gb_carbon_value(2019))
  expect_error(gb_carbon_value(2055))
})

test_that("gb_carbon_value errors on bad scenario or series", {
  expect_error(gb_carbon_value(2030, scenario = "wrong"))
  expect_error(gb_carbon_value(2030, series = "wrong"))
})

test_that("gb_carbon_npv returns gb_appraisal with carbon-specific fields", {
  app <- gb_carbon_npv(rep(100, 7), 2024:2030)
  expect_s3_class(app, "gb_appraisal")
  expect_true(!is.null(app$emissions))
  expect_true(!is.null(app$years_calendar))
  expect_true(!is.null(app$carbon_scenario))
  expect_true(!is.null(app$carbon_series))
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

test_that("gb_carbon_npv non_traded series matches traded under current methodology", {
  app_t <- gb_carbon_npv(rep(100, 5), 2024:2028, series = "traded")
  app_nt <- gb_carbon_npv(rep(100, 5), 2024:2028, series = "non_traded")
  expect_equal(app_t$npv, app_nt$npv, tolerance = 1e-9)
})
