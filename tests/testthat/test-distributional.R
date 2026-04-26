test_that("gb_dist_weight returns 1 at the reference income", {
  income <- c(20000, 50000, 80000)
  w <- gb_dist_weight(income, reference = 50000)
  expect_equal(w[2], 1, tolerance = 1e-12)
})

test_that("gb_dist_weight is > 1 below reference, < 1 above", {
  income <- c(20000, 50000, 80000)
  w <- gb_dist_weight(income, reference = 50000)
  expect_gt(w[1], 1)
  expect_lt(w[3], 1)
})

test_that("gb_dist_weight is monotonically decreasing in income", {
  income <- seq(10000, 100000, length.out = 10)
  w <- gb_dist_weight(income)
  expect_true(all(diff(w) < 0))
})

test_that("gb_dist_weight: higher eta amplifies the weights", {
  income <- c(20000, 80000)
  w_low <- gb_dist_weight(income, eta = 0.8, reference = 50000)
  w_high <- gb_dist_weight(income, eta = 2.0, reference = 50000)
  # ratio of low to high decile widens with eta
  expect_gt(w_high[1] / w_high[2], w_low[1] / w_low[2])
})

test_that("gb_dist_weight default eta is 1.3", {
  w_default <- gb_dist_weight(c(20000, 80000), reference = 50000)
  w_explicit <- gb_dist_weight(c(20000, 80000), eta = 1.3, reference = 50000)
  expect_equal(w_default, w_explicit)
})

test_that("gb_dist_weight uses median of income_data when supplied", {
  income <- c(15000)
  decile_data <- seq(10000, 100000, length.out = 10)
  ref <- stats::median(decile_data)
  w <- gb_dist_weight(income, income_data = decile_data)
  expect_equal(w, (ref / 15000) ^ 1.3, tolerance = 1e-9)
})

test_that("gb_dist_weight uses median of input when no reference", {
  income <- c(20000, 50000, 80000)
  w <- gb_dist_weight(income)
  ref <- stats::median(income)
  expect_equal(w, (ref / income) ^ 1.3, tolerance = 1e-9)
})

test_that("gb_dist_weight errors on non-positive income", {
  expect_error(gb_dist_weight(c(0, 50000)))
  expect_error(gb_dist_weight(c(-100, 50000)))
})

test_that("gb_dist_weight errors on bad reference", {
  expect_error(gb_dist_weight(50000, reference = "wrong"))
  expect_error(gb_dist_weight(50000, reference = -100))
})

test_that("gb_dist_weighted_npv returns gb_appraisal with extras", {
  app <- gb_dist_weighted_npv(rep(30, 5),
                              recipient_income = rep(20000, 5),
                              income_data = seq(10000, 100000, length.out = 10))
  expect_s3_class(app, "gb_appraisal")
  expect_true(!is.null(app$weights))
  expect_true(!is.null(app$eta))
  expect_true(!is.null(app$unweighted_npv))
})

test_that("gb_dist_weighted_npv: low income recipient gets higher weighted NPV", {
  unweighted <- gb_npv(rep(30, 5))
  decile_data <- seq(10000, 100000, length.out = 10)

  low_income <- gb_dist_weighted_npv(rep(30, 5),
                                     recipient_income = rep(15000, 5),
                                     income_data = decile_data)
  high_income <- gb_dist_weighted_npv(rep(30, 5),
                                      recipient_income = rep(80000, 5),
                                      income_data = decile_data)
  expect_gt(low_income$npv, unweighted$npv)
  expect_lt(high_income$npv, unweighted$npv)
})

test_that("gb_dist_weighted_npv errors on length mismatch", {
  expect_error(
    gb_dist_weighted_npv(c(10, 20, 30), recipient_income = c(20000, 30000))
  )
})
