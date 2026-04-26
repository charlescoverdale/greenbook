test_that("gb_sensitivity_ob returns a table for each mitigation", {
  costs <- c(100, 0, 0, 0, 0)
  benefits <- c(0, 30, 30, 30, 30)
  s <- gb_sensitivity_ob(costs, benefits, ob = "non_standard_buildings")
  expect_s3_class(s, "gb_sensitivity_ob")
  expect_equal(nrow(s$table), 5L)
})

test_that("gb_sensitivity_ob NPV monotonically increases with mitigation", {
  costs <- c(100, 0, 0, 0, 0)
  benefits <- c(0, 30, 30, 30, 30)
  s <- gb_sensitivity_ob(costs, benefits, ob = 0.50)
  expect_true(all(diff(s$npv) > 0))
})

test_that("gb_sensitivity_ob accepts custom mitigation grid", {
  s <- gb_sensitivity_ob(c(100, 0), c(0, 200),
                         ob = 0.50, mitigations = c(0, 0.5, 1.0))
  expect_equal(nrow(s$table), 3L)
})

test_that("gb_sensitivity_ob errors on out-of-range mitigation", {
  expect_error(gb_sensitivity_ob(c(100, 0), c(0, 200), ob = 0.5,
                                 mitigations = c(0, 1.5)))
})

test_that("gb_sensitivity_ob print method does not error", {
  s <- gb_sensitivity_ob(c(100, 0), c(0, 200), ob = 0.5)
  expect_no_error(capture.output(print(s)))
})
