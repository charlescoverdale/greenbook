test_that("gb_deflator: same year returns 1", {
  expect_equal(gb_deflator(2020, 2020), 1)
  expect_equal(gb_deflator(2024, 2024), 1)
})

test_that("gb_deflator from past to future is > 1", {
  expect_gt(gb_deflator(2020, 2024), 1)
})

test_that("gb_deflator from future to past is < 1", {
  expect_lt(gb_deflator(2024, 2020), 1)
})

test_that("gb_deflator round-trip is identity", {
  f1 <- gb_deflator(2020, 2024)
  f2 <- gb_deflator(2024, 2020)
  expect_equal(f1 * f2, 1, tolerance = 1e-12)
})

test_that("gb_deflator errors on out-of-range years", {
  expect_error(gb_deflator(1800, 2024))
  expect_error(gb_deflator(2024, 2200), "outside bundled deflator")
})

test_that("gb_deflator errors on non-scalar input", {
  expect_error(gb_deflator(c(2020, 2021), 2024), "must be scalar")
  expect_error(gb_deflator(2020, c(2024, 2025)), "must be scalar")
})

test_that("gb_real with scalar year converts uniformly", {
  vals <- c(100, 200, 300)
  out <- gb_real(vals, year = 2020, base_year = 2024)
  factor <- gb_deflator(2020, 2024)
  expect_equal(out, vals * factor, tolerance = 1e-12)
})

test_that("gb_real with vector year applies element-wise", {
  vals <- c(100, 110, 120)
  yrs <- 2020:2022
  out <- gb_real(vals, year = yrs, base_year = 2024)
  expected <- mapply(function(v, y) v * gb_deflator(y, 2024), vals, yrs)
  expect_equal(out, expected, tolerance = 1e-12)
})

test_that("gb_real errors on length mismatch", {
  expect_error(
    gb_real(c(100, 200, 300), year = c(2020, 2021), base_year = 2024),
    "scalar or same length"
  )
})

test_that("gb_rebase equals values times deflator", {
  vals <- c(100, 200, 300)
  out <- gb_rebase(vals, from = 2020, to = 2024)
  expect_equal(out, vals * gb_deflator(2020, 2024), tolerance = 1e-12)
})

test_that("gb_rebase round-trip is identity", {
  vals <- c(100, 200, 300)
  out <- gb_rebase(gb_rebase(vals, from = 2020, to = 2024), from = 2024, to = 2020)
  expect_equal(out, vals, tolerance = 1e-12)
})
