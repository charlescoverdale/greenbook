test_that("gb_discount_factor at year 0 is 1", {
  expect_equal(gb_discount_factor(0), 1)
})

test_that("gb_discount_factor at year 1 is 1/1.035", {
  expect_equal(gb_discount_factor(1), 1 / 1.035, tolerance = 1e-9)
})

test_that("gb_discount_factor compounds annually within a band", {
  expect_equal(gb_discount_factor(5), 1 / 1.035^5, tolerance = 1e-9)
  expect_equal(gb_discount_factor(30), 1 / 1.035^30, tolerance = 1e-9)
})

test_that("gb_discount_factor handles the kink at year 31", {
  df_30 <- gb_discount_factor(30)
  df_31 <- gb_discount_factor(31)
  expect_equal(df_31, df_30 / 1.030, tolerance = 1e-9)
})

test_that("gb_discount_factor handles two kink transitions", {
  df_75 <- 1 / (1.035^30 * 1.030^45)
  expect_equal(gb_discount_factor(75), df_75, tolerance = 1e-9)
  df_76 <- df_75 / 1.025
  expect_equal(gb_discount_factor(76), df_76, tolerance = 1e-9)
})

test_that("gb_discount_factor is vectorised", {
  out <- gb_discount_factor(c(0, 1, 5, 30, 31))
  expect_length(out, 5L)
  expect_equal(out[1], 1)
  expect_equal(out[2], 1 / 1.035, tolerance = 1e-9)
})

test_that("gb_discount_factor is monotonically decreasing", {
  out <- gb_discount_factor(0:50)
  expect_true(all(diff(out) < 0))
})

test_that("gb_discount_factor with health schedule is higher than standard", {
  expect_gt(
    gb_discount_factor(30, schedule = "health"),
    gb_discount_factor(30, schedule = "standard")
  )
})

test_that("gb_discount_factor errors on years below base_year", {
  expect_error(gb_discount_factor(-1, base_year = 0))
  expect_error(gb_discount_factor(2, base_year = 5))
})

test_that("gb_discount applies factors element-wise", {
  values <- c(100, 100, 100, 100)
  expected <- values * gb_discount_factor(0:3)
  expect_equal(gb_discount(values), expected)
})

test_that("gb_discount errors on length mismatch", {
  expect_error(gb_discount(c(1, 2, 3), years = c(0, 1)), "equal length")
})

test_that("gb_npv returns a gb_appraisal object", {
  app <- gb_npv(c(-100, 50, 50, 50))
  expect_s3_class(app, "gb_appraisal")
  expect_named(app, c("npv", "cashflow", "years", "pv", "schedule",
                      "base_year", "vintage"))
})

test_that("gb_npv is consistent with manual discounting", {
  cf <- c(-100, 50, 50, 50)
  app <- gb_npv(cf)
  manual <- sum(cf * gb_discount_factor(0:3))
  expect_equal(app$npv, manual, tolerance = 1e-9)
})

test_that("gb_npv stores schedule and vintage", {
  app <- gb_npv(c(-100, 50), schedule = "health", vintage = "2022")
  expect_equal(app$schedule, "health")
  expect_equal(app$vintage, "2022")
})

test_that("gb_npv stores base year when supplied", {
  app <- gb_npv(c(-100, 50), base_year = 2024)
  expect_equal(app$base_year, 2024)
})

test_that("gb_npv known-value: GBP 100 capex, 5 years of GBP 30 benefit", {
  cf <- c(-100, 30, 30, 30, 30, 30)
  app <- gb_npv(cf)
  manual <- -100 + sum(30 / 1.035^(1:5))
  expect_equal(app$npv, manual, tolerance = 1e-9)
})

test_that("gb_eanc is consistent with NPV / annuity factor", {
  app <- gb_npv(c(-100, 30, 30, 30, 30, 30))
  factors <- gb_discount_factor(seq_len(5))
  expect_equal(gb_eanc(app, years = 5), app$npv / sum(factors), tolerance = 1e-9)
})

test_that("gb_eanc accepts numeric NPV scalar", {
  factors <- gb_discount_factor(seq_len(10))
  expect_equal(gb_eanc(50, years = 10), 50 / sum(factors), tolerance = 1e-9)
})

test_that("gb_eanc derives years from gb_appraisal length", {
  app <- gb_npv(c(-100, 30, 30, 30, 30, 30))
  expect_equal(gb_eanc(app), gb_eanc(app, years = 5), tolerance = 1e-12)
})

test_that("gb_eanc errors on bad inputs", {
  expect_error(gb_eanc("abc", years = 5), "numeric scalar or")
  expect_error(gb_eanc(50, years = -1), "must be >= 1")
  expect_error(gb_eanc(50, years = c(1, 2)), "must be scalar")
})

test_that("gb_npv errors on bad input", {
  expect_error(gb_npv("abc"), "must be a numeric")
  expect_error(gb_npv(c(1, NA)), "NA")
})
