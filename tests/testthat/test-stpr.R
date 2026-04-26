test_that("gb_stpr returns headline 3.5 percent for first band", {
  expect_equal(gb_stpr(0), 0.035)
  expect_equal(gb_stpr(1), 0.035)
  expect_equal(gb_stpr(15), 0.035)
  expect_equal(gb_stpr(30), 0.035)
})

test_that("gb_stpr steps down at year 31", {
  expect_equal(gb_stpr(31), 0.030)
  expect_equal(gb_stpr(50), 0.030)
  expect_equal(gb_stpr(75), 0.030)
})

test_that("gb_stpr steps down across all bands", {
  expect_equal(gb_stpr(76), 0.025)
  expect_equal(gb_stpr(125), 0.025)
  expect_equal(gb_stpr(126), 0.020)
  expect_equal(gb_stpr(200), 0.020)
  expect_equal(gb_stpr(201), 0.015)
  expect_equal(gb_stpr(300), 0.015)
  expect_equal(gb_stpr(301), 0.010)
  expect_equal(gb_stpr(1000), 0.010)
})

test_that("gb_stpr is vectorised", {
  out <- gb_stpr(c(10, 30, 31, 75, 76))
  expect_equal(out, c(0.035, 0.035, 0.030, 0.030, 0.025))
  expect_length(out, 5L)
})

test_that("gb_stpr supports the health schedule", {
  expect_equal(gb_stpr(0, "health"), 0.015)
  expect_equal(gb_stpr(31, "health"), 0.0129)
  expect_equal(gb_stpr(76, "health"), 0.0107)
})

test_that("gb_stpr supports the catastrophic schedule", {
  expect_equal(gb_stpr(0, "catastrophic"), 0.030)
  expect_equal(gb_stpr(31, "catastrophic"), 0.0257)
  expect_equal(gb_stpr(76, "catastrophic"), 0.0214)
})

test_that("gb_stpr errors on invalid input", {
  expect_error(gb_stpr(-1), "must be >= 0")
  expect_error(gb_stpr(1.5), "integer-valued")
  expect_error(gb_stpr("abc"), "must be a numeric")
  expect_error(gb_stpr(NA_real_), "NA")
  expect_error(gb_stpr(0, schedule = "wrong"))
})

test_that("gb_stpr errors above the last band", {
  expect_error(gb_stpr(1001), "outside the supported")
})
