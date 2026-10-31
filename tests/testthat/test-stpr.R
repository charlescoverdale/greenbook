test_that("gb_stpr defaults to the October 2026 schedule", {
  expect_equal(gb_stpr(0), 0.030)
  expect_equal(gb_stpr(1), 0.030)
  expect_equal(gb_stpr(30), 0.030)
  expect_equal(gb_stpr(31), 0.025)
  expect_equal(gb_stpr(75), 0.025)
  expect_equal(gb_stpr(76), 0.0225)
  expect_equal(gb_stpr(125), 0.0225)
})

test_that("gb_stpr 2026-10 matches the published discount factors", {
  # Annex A of the October 2026 supplementary guidance on discounting
  expect_equal(round(gb_discount_factor(1), 4), 0.9709)
  expect_equal(round(gb_discount_factor(30), 4), 0.4120)
  expect_equal(round(gb_discount_factor(31), 4), 0.4019)
  expect_equal(round(gb_discount_factor(75), 4), 0.1356)
  expect_equal(round(gb_discount_factor(76), 4), 0.1326)
  expect_equal(round(gb_discount_factor(100), 4), 0.0778)
})

test_that("gb_stpr 2026-10 refuses to discount beyond year 125", {
  expect_error(gb_stpr(126), "125-year horizon")
  expect_error(gb_discount_factor(0:130), "125-year horizon")
})

test_that("gb_stpr 2026-10 has no health or catastrophic schedule", {
  expect_error(gb_stpr(0, "health"), "withdrawn")
  expect_error(gb_stpr(0, "catastrophic"), "withdrawn")
})

test_that("gb_stpr 2003 vintage keeps the earlier schedule", {
  expect_equal(gb_stpr(0, vintage = "2003"), 0.035)
  expect_equal(gb_stpr(30, vintage = "2003"), 0.035)
  expect_equal(gb_stpr(31, vintage = "2003"), 0.030)
  expect_equal(gb_stpr(76, vintage = "2003"), 0.025)
  expect_equal(gb_stpr(126, vintage = "2003"), 0.020)
  expect_equal(gb_stpr(201, vintage = "2003"), 0.015)
  expect_equal(gb_stpr(301, vintage = "2003"), 0.010)
  expect_equal(gb_stpr(1000, vintage = "2003"), 0.010)
  expect_error(gb_stpr(1001, vintage = "2003"), "outside the supported")
})

test_that("gb_stpr 2003 vintage supports health and catastrophic", {
  expect_equal(gb_stpr(c(0, 31, 76), "health", vintage = "2003"),
               c(0.015, 0.0129, 0.0107))
  expect_equal(gb_stpr(c(0, 31, 76), "catastrophic", vintage = "2003"),
               c(0.030, 0.0257, 0.0214))
})

test_that("gb_stpr maps edition labels onto discounting vintages", {
  for (v in c("2018", "2020", "2022", "2026-02")) {
    expect_equal(gb_stpr(0, vintage = v), 0.035)
  }
  expect_equal(gb_stpr(0, vintage = "2026"), 0.030)
  expect_error(gb_stpr(0, vintage = "1999"), "Unknown discounting vintage")
  expect_error(gb_stpr(0, vintage = c("2003", "2026")), "single character")
})

test_that("gb_stpr is vectorised", {
  out <- gb_stpr(c(10, 30, 31, 75, 76))
  expect_equal(out, c(0.030, 0.030, 0.025, 0.025, 0.0225))
  expect_length(out, 5L)
})

test_that("gb_stpr errors on invalid input", {
  expect_error(gb_stpr(-1), "must be >= 0")
  expect_error(gb_stpr(1.5), "integer-valued")
  expect_error(gb_stpr("abc"), "must be a numeric")
  expect_error(gb_stpr(NA_real_), "NA")
  expect_error(gb_stpr(0, schedule = "wrong"))
})
