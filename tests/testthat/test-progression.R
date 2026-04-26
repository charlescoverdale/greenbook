test_that("gb_progression works with all three stages", {
  soc <- gb_appraise(c(100, 0), c(0, 200), ob = 0.50, ob_mitigation = 0)
  obc <- gb_appraise(c(100, 0), c(0, 200), ob = 0.50, ob_mitigation = 0.5)
  fbc <- gb_appraise(c(100, 0), c(0, 200), ob = 0.50, ob_mitigation = 0.9)
  prog <- gb_progression(soc, obc, fbc)
  expect_s3_class(prog, "gb_progression")
  expect_equal(nrow(prog$evolution), 3L)
  expect_equal(prog$evolution$stage, c("SOC", "OBC", "FBC"))
})

test_that("gb_progression NPV improves as OB mitigation increases", {
  soc <- gb_appraise(c(100, 0), c(0, 200), ob = 0.50, ob_mitigation = 0)
  obc <- gb_appraise(c(100, 0), c(0, 200), ob = 0.50, ob_mitigation = 0.5)
  fbc <- gb_appraise(c(100, 0), c(0, 200), ob = 0.50, ob_mitigation = 0.9)
  prog <- gb_progression(soc, obc, fbc)
  expect_true(all(prog$delta_npv > 0))
})

test_that("gb_progression accepts SOC only", {
  soc <- gb_appraise(c(100, 0), c(0, 200))
  prog <- gb_progression(soc)
  expect_equal(nrow(prog$evolution), 1L)
  expect_length(prog$delta_npv, 0L)
})

test_that("gb_progression errors on non-appraisal input", {
  expect_error(gb_progression("nope"))
})

test_that("gb_progression print method does not error", {
  soc <- gb_appraise(c(100, 0), c(0, 200))
  obc <- gb_appraise(c(100, 0), c(0, 200))
  expect_no_error(capture.output(print(gb_progression(soc, obc))))
})
