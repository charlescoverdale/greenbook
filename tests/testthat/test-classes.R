test_that("print.gb_appraisal returns the input invisibly", {
  app <- gb_npv(c(-100, 50, 50, 50))
  capture.output(out <- print(app))
  expect_identical(out, app)
})

test_that("print.gb_appraisal does not error", {
  app <- gb_npv(c(-100, 50, 50, 50), base_year = 2024)
  expect_no_error(capture.output(print(app)))
})

test_that("summary.gb_appraisal returns the input invisibly", {
  app <- gb_npv(c(-100, 50, 50, 50))
  capture.output(out <- summary(app))
  expect_identical(out, app)
})

test_that("summary.gb_appraisal prints provenance", {
  app <- gb_npv(c(-100, 50, 50, 50), base_year = 2024)
  out <- capture.output(summary(app))
  expect_true(any(grepl("NPV", out)))
  expect_true(any(grepl("standard", out)))
  expect_true(any(grepl("Vintage", out)))
})

test_that("format.gb_appraisal returns character", {
  app <- gb_npv(c(-100, 50, 50, 50))
  s <- format(app)
  expect_type(s, "character")
  expect_length(s, 1L)
  expect_match(s, "gb_appraisal")
  expect_match(s, "NPV")
})
