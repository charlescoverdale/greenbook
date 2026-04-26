test_that("gb_wellby central value matches HMT 2019 figure", {
  out <- gb_wellby(1, persons = 1, years = 1)
  expect_equal(out, 13000)
})

test_that("gb_wellby low and high scenarios match HMT range", {
  expect_equal(gb_wellby(1, persons = 1, years = 1, scenario = "low"), 10000)
  expect_equal(gb_wellby(1, persons = 1, years = 1, scenario = "high"), 16000)
})

test_that("gb_wellby scales linearly", {
  expect_equal(gb_wellby(0.5, 200, 3), 0.5 * 200 * 3 * 13000)
})

test_that("gb_wellby uplifts to other base years via deflator", {
  v_2019 <- gb_wellby(1, 1, 1, base_year = 2019)
  v_2024 <- gb_wellby(1, 1, 1, base_year = 2024)
  factor <- gb_deflator(2019, 2024)
  expect_equal(v_2024, v_2019 * factor, tolerance = 1e-6)
})

test_that("gb_wellby errors on bad scenario", {
  expect_error(gb_wellby(1, 1, scenario = "wrong"))
})

test_that("gb_vpf default returns 2024 value", {
  expect_equal(gb_vpf(), 2153000)
})

test_that("gb_vpf year lookup matches bundled series", {
  expect_equal(gb_vpf(2018), 1958303)
  expect_equal(gb_vpf(2024), 2153000)
})

test_that("gb_vpf errors outside bundled range", {
  expect_error(gb_vpf(2010))
  expect_error(gb_vpf(2050))
})

test_that("gb_vpf errors on non-scalar year", {
  expect_error(gb_vpf(c(2020, 2024)))
})

test_that("gb_qaly default is DHSC GBP 70k per QALY", {
  expect_equal(gb_qaly(1), 70000)
})

test_that("gb_qaly NICE thresholds match published values", {
  expect_equal(gb_qaly(1, scenario = "nice_lower"), 20000)
  expect_equal(gb_qaly(1, scenario = "nice_upper"), 30000)
})

test_that("gb_qaly scales linearly", {
  expect_equal(gb_qaly(2.5), 2.5 * 70000)
  expect_equal(gb_qaly(c(1, 2, 3)), c(70000, 140000, 210000))
})

test_that("gb_qaly rebases via deflator", {
  v_2024 <- gb_qaly(1, base_year = 2024)
  v_2020 <- gb_qaly(1, base_year = 2020)
  factor <- gb_deflator(2024, 2020)
  expect_equal(v_2020, v_2024 * factor, tolerance = 1e-6)
})

test_that("gb_qaly errors on bad scenario", {
  expect_error(gb_qaly(1, scenario = "wrong"))
})
