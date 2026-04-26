test_that("gb_risk_register computes expected loss correctly", {
  risks <- data.frame(
    id = c("R1", "R2"),
    description = c("Delay", "Overrun"),
    probability = c(0.3, 0.5),
    impact_gbp = c(100, 200),
    stringsAsFactors = FALSE
  )
  rr <- gb_risk_register(risks)
  expect_s3_class(rr, "gb_risk_register")
  expect_equal(rr$expected_value, 0.3 * 100 + 0.5 * 200)
  expect_equal(rr$total_exposure, 300)
})

test_that("gb_risk_register adds expected_loss column", {
  risks <- data.frame(
    id = "R1", description = "x",
    probability = 0.5, impact_gbp = 100,
    stringsAsFactors = FALSE
  )
  rr <- gb_risk_register(risks)
  expect_equal(rr$risks$expected_loss, 50)
})

test_that("gb_risk_register aggregates by category", {
  risks <- data.frame(
    id = c("R1", "R2", "R3"),
    description = c("a", "b", "c"),
    category = c("cost", "cost", "schedule"),
    probability = c(0.2, 0.3, 0.4),
    impact_gbp = c(100, 200, 50),
    stringsAsFactors = FALSE
  )
  rr <- gb_risk_register(risks)
  expect_false(is.null(rr$by_category))
  expect_equal(nrow(rr$by_category), 2L)
})

test_that("gb_risk_register risk-adjusts an appraisal NPV", {
  risks <- data.frame(
    id = "R1", description = "x",
    probability = 0.5, impact_gbp = 10,
    stringsAsFactors = FALSE
  )
  app <- gb_appraise(c(100, 0), c(0, 200))
  rr <- gb_risk_register(risks, appraisal = app)
  expect_equal(rr$risk_adjusted_npv, app$npv - 5)
})

test_that("gb_risk_register errors on missing columns", {
  bad <- data.frame(id = "R1", description = "x", stringsAsFactors = FALSE)
  expect_error(gb_risk_register(bad))
})

test_that("gb_risk_register errors on probabilities outside [0, 1]", {
  bad <- data.frame(
    id = "R1", description = "x",
    probability = 1.5, impact_gbp = 100,
    stringsAsFactors = FALSE
  )
  expect_error(gb_risk_register(bad))
})

test_that("gb_risk_register print method does not error", {
  risks <- data.frame(
    id = "R1", description = "x",
    probability = 0.5, impact_gbp = 100,
    stringsAsFactors = FALSE
  )
  expect_no_error(capture.output(print(gb_risk_register(risks))))
})
