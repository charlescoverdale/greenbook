test_that("gb_appraise returns a gb_appraisal with BCR populated", {
  costs <- c(100, 50, 50, 0, 0, 0, 0, 0, 0, 0)
  benefits <- c(0, 0, 0, 30, 30, 30, 30, 30, 30, 30)
  app <- gb_appraise(costs, benefits)
  expect_s3_class(app, "gb_appraisal")
  expect_true(!is.null(app$bcr))
  expect_true(is.finite(app$bcr))
  expect_true(!is.null(app$pv_costs))
  expect_true(!is.null(app$pv_benefits))
})

test_that("gb_appraise NPV equals PV benefits minus PV costs", {
  costs <- c(100, 50, 50, 0, 0)
  benefits <- c(0, 0, 0, 50, 100)
  app <- gb_appraise(costs, benefits)
  expect_equal(app$npv, app$pv_benefits - app$pv_costs, tolerance = 1e-9)
})

test_that("gb_appraise BCR matches PV ratio", {
  costs <- c(100, 50, 50, 0, 0)
  benefits <- c(0, 0, 0, 50, 100)
  app <- gb_appraise(costs, benefits)
  expect_equal(app$bcr, app$pv_benefits / app$pv_costs, tolerance = 1e-9)
})

test_that("gb_appraise applies optimism bias by category", {
  costs <- c(100, 0)
  benefits <- c(0, 200)
  app_no_ob <- gb_appraise(costs, benefits)
  app_ob <- gb_appraise(costs, benefits, ob = "non_standard_buildings")
  expect_lt(app_ob$npv, app_no_ob$npv)
  expect_equal(app_ob$optimism_bias, 0.51)
})

test_that("gb_appraise applies optimism bias as numeric", {
  costs <- c(100, 0)
  benefits <- c(0, 200)
  app <- gb_appraise(costs, benefits, ob = 0.30)
  expect_equal(app$optimism_bias, 0.30)
})

test_that("gb_appraise applies OB mitigation", {
  costs <- c(100, 0)
  benefits <- c(0, 200)
  full_ob <- gb_appraise(costs, benefits, ob = 0.50)
  half_ob <- gb_appraise(costs, benefits, ob = 0.50, ob_mitigation = 0.5)
  expect_lt(full_ob$npv, half_ob$npv)
})

test_that("gb_appraise applies METB to costs", {
  costs <- c(100, 0)
  benefits <- c(0, 200)
  app_no_metb <- gb_appraise(costs, benefits)
  app_metb <- gb_appraise(costs, benefits, metb = TRUE)
  expect_lt(app_metb$npv, app_no_metb$npv)
  expect_true(app_metb$metb_applied)
})

test_that("gb_appraise errors on length mismatch", {
  expect_error(gb_appraise(c(100, 50), c(30, 30, 30)))
})

test_that("gb_appraise errors on invalid ob input", {
  expect_error(gb_appraise(c(100, 0), c(0, 200), ob = list(0.5)))
})

test_that("gb_appraise stores schedule, base year, vintage", {
  app <- gb_appraise(c(100, 0), c(0, 200), schedule = "health",
                     base_year = 2024, vintage = "2026")
  expect_equal(app$schedule, "health")
  expect_equal(app$base_year, 2024)
  expect_equal(app$vintage, "2026")
})

test_that("gb_appraise summary prints BCR and OB", {
  app <- gb_appraise(c(100, 50), c(0, 200), ob = "standard_buildings", metb = TRUE)
  out <- capture.output(summary(app))
  expect_true(any(grepl("BCR", out)))
  expect_true(any(grepl("Optimism bias", out)))
  expect_true(any(grepl("METB", out)))
})
