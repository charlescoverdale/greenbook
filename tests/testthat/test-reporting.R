test_that("gb_headline returns expected structure", {
  app <- gb_appraise(c(100, 0, 0, 0, 0), c(0, 30, 30, 30, 30))
  h <- gb_headline(app)
  expect_s3_class(h, "gb_headline")
  expect_true(all(c("npv", "bcr", "eanc", "payback_year", "horizon") %in%
                  names(h)))
})

test_that("gb_headline payback year is when cumulative PV turns positive", {
  costs <- c(100, 0, 0, 0, 0)
  benefits <- c(0, 30, 30, 30, 30)
  app <- gb_appraise(costs, benefits)
  h <- gb_headline(app)
  expect_true(h$payback_year >= 1)
})

test_that("gb_headline returns NA payback when never positive", {
  app <- gb_appraise(c(100, 0), c(0, 5))
  h <- gb_headline(app)
  expect_true(is.na(h$payback_year))
})

test_that("gb_cost_per_unit divides PV costs by units", {
  app <- gb_appraise(c(100, 0), c(0, 0))
  cu <- gb_cost_per_unit(app, units_delivered = 10, unit = "QALY")
  expect_equal(cu, 10, tolerance = 1e-9)
})

test_that("gb_cost_per_unit errors on zero or negative units", {
  app <- gb_appraise(c(100, 0), c(0, 0))
  expect_error(gb_cost_per_unit(app, units_delivered = 0))
  expect_error(gb_cost_per_unit(app, units_delivered = -5))
})

test_that("gb_to_latex returns a tabular string", {
  app <- gb_appraise(c(100, 0), c(0, 200))
  tex <- gb_to_latex(app)
  expect_type(tex, "character")
  expect_match(tex, "begin\\{tabular\\}")
  expect_match(tex, "NPV")
})

test_that("gb_to_latex with caption wraps in table environment", {
  app <- gb_appraise(c(100, 0), c(0, 200))
  tex <- gb_to_latex(app, caption = "Test", label = "tab:test")
  expect_match(tex, "\\\\begin\\{table\\}")
  expect_match(tex, "Test")
})

test_that("gb_to_excel writes a workbook when openxlsx is available", {
  skip_if_not_installed("openxlsx")
  app <- gb_appraise(c(100, 0), c(0, 200))
  tmp <- tempfile(fileext = ".xlsx")
  on.exit(unlink(tmp), add = TRUE)
  result <- gb_to_excel(app, tmp)
  expect_true(file.exists(tmp))
  expect_equal(normalizePath(result), normalizePath(tmp))
})

test_that("gb_to_excel errors if file lacks .xlsx extension", {
  skip_if_not_installed("openxlsx")
  app <- gb_appraise(c(100, 0), c(0, 200))
  expect_error(gb_to_excel(app, tempfile(fileext = ".txt")))
})

test_that("gb_to_word writes a docx when officer + flextable available", {
  skip_if_not_installed("officer")
  skip_if_not_installed("flextable")
  app <- gb_appraise(c(100, 0), c(0, 200))
  tmp <- tempfile(fileext = ".docx")
  on.exit(unlink(tmp), add = TRUE)
  result <- gb_to_word(app, tmp)
  expect_true(file.exists(tmp))
})

test_that("gb_headline print method does not error", {
  app <- gb_appraise(c(100, 0), c(0, 200))
  expect_no_error(capture.output(print(gb_headline(app))))
})
