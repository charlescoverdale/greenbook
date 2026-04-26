test_that("gb_validate passes a clean appraisal", {
  app <- gb_appraise(c(100, 0, 0, 0, 0), c(0, 30, 30, 30, 30),
                     base_year = 2024, vintage = "2022")
  v <- gb_validate(app)
  expect_s3_class(v, "gb_validation")
  expect_true(v$pass)
  expect_length(v$errors, 0L)
})

test_that("gb_validate flags missing base year as warning", {
  app <- gb_appraise(c(100, 0, 0, 0, 0), c(0, 30, 30, 30, 30))
  v <- gb_validate(app)
  warning_checks <- vapply(v$warnings, function(w) w$check, character(1))
  expect_true("base_year" %in% warning_checks)
})

test_that("gb_validate flags negative costs as warning", {
  app <- gb_appraise(c(-10, 0, 0, 0, 0), c(0, 30, 30, 30, 30))
  v <- gb_validate(app)
  warning_checks <- vapply(v$warnings, function(w) w$check, character(1))
  expect_true("cost_sign" %in% warning_checks)
})

test_that("gb_validate flags unrecognised vintage", {
  app <- gb_appraise(c(100, 0), c(0, 200), vintage = "1999")
  v <- gb_validate(app)
  warning_checks <- vapply(v$warnings, function(w) w$check, character(1))
  expect_true("vintage" %in% warning_checks)
})

test_that("gb_validate flags long horizon as info", {
  costs <- c(100, rep(0, 119))
  benefits <- c(0, rep(5, 119))
  app <- gb_appraise(costs, benefits)
  v <- gb_validate(app)
  info_checks <- vapply(v$info, function(i) i$check, character(1))
  expect_true("horizon" %in% info_checks)
})

test_that("gb_validate errors on non-gb_appraisal input", {
  expect_error(gb_validate(list()))
  expect_error(gb_validate(123))
})

test_that("gb_validate print method does not error", {
  app <- gb_appraise(c(100, 0), c(0, 200))
  expect_no_error(capture.output(print(gb_validate(app))))
})
