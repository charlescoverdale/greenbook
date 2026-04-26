test_that("gb_optimism_bias returns published upper bounds for capex", {
  expect_equal(gb_optimism_bias("standard_buildings"), 0.24)
  expect_equal(gb_optimism_bias("non_standard_buildings"), 0.51)
  expect_equal(gb_optimism_bias("standard_civil_engineering"), 0.44)
  expect_equal(gb_optimism_bias("non_standard_civil_engineering"), 0.66)
  expect_equal(gb_optimism_bias("equipment_development"), 2.00)
  expect_equal(gb_optimism_bias("outsourcing"), 0.41)
})

test_that("gb_optimism_bias returns published upper bounds for duration", {
  expect_equal(gb_optimism_bias("standard_buildings", "duration"), 0.04)
  expect_equal(gb_optimism_bias("non_standard_buildings", "duration"), 0.39)
  expect_equal(gb_optimism_bias("equipment_development", "duration"), 0.54)
})

test_that("gb_optimism_bias errors on unknown category", {
  expect_error(gb_optimism_bias("unknown_category"))
})

test_that("gb_optimism_bias errors on bad dimension", {
  expect_error(gb_optimism_bias("standard_buildings", dimension = "wrong"))
})

test_that("gb_apply_ob applies the upper bound when no mitigation", {
  costs <- c(100, 50)
  out <- gb_apply_ob(costs, ob_pct = 0.51)
  expect_equal(out, c(151, 75.5))
})

test_that("gb_apply_ob applies mitigation correctly", {
  costs <- 100
  out <- gb_apply_ob(costs, ob_pct = 0.50, mitigation = 0.5)
  expect_equal(out, 100 * (1 + 0.50 * 0.5))
  expect_equal(out, 125)
})

test_that("gb_apply_ob mitigation = 1 returns baseline", {
  costs <- c(100, 200)
  out <- gb_apply_ob(costs, ob_pct = 0.5, mitigation = 1)
  expect_equal(out, costs)
})

test_that("gb_apply_ob errors on out-of-range mitigation", {
  expect_error(gb_apply_ob(100, 0.5, mitigation = -0.1))
  expect_error(gb_apply_ob(100, 0.5, mitigation = 1.1))
})

test_that("gb_apply_ob errors on non-scalar ob_pct or mitigation", {
  expect_error(gb_apply_ob(100, c(0.3, 0.5)))
  expect_error(gb_apply_ob(100, 0.3, mitigation = c(0.1, 0.2)))
})

test_that("gb_categories returns all six categories", {
  cats <- gb_categories()
  expect_s3_class(cats, "data.frame")
  expect_equal(nrow(cats), 6L)
  expect_true(all(c("category", "description", "capex_upper", "duration_upper")
                  %in% names(cats)))
})
