test_that("gb_economic_case wraps an appraisal", {
  app <- gb_appraise(c(100, 0), c(0, 200))
  ec <- gb_economic_case(app,
                          critical_success_factors = c("VfM", "Achievability"),
                          options_considered = c("Do nothing", "Do max"),
                          recommendation = "Do max")
  expect_s3_class(ec, "gb_economic_case")
  expect_equal(length(ec$critical_success_factors), 2L)
  expect_equal(ec$recommendation, "Do max")
})

test_that("gb_economic_case accepts a gb_comparison", {
  a <- gb_appraise(c(50, 0), c(0, 100))
  b <- gb_appraise(c(100, 0), c(0, 200))
  cmp <- gb_compare(a = a, b = b)
  ec <- gb_economic_case(cmp)
  expect_s3_class(ec, "gb_economic_case")
})

test_that("gb_economic_case errors on bad input", {
  expect_error(gb_economic_case("not an appraisal"))
})

test_that("gb_economic_case prints sections without errors", {
  app <- gb_appraise(c(100, 0), c(0, 200))
  ec <- gb_economic_case(app, recommendation = "Do max")
  expect_no_error(capture.output(print(ec)))
})
