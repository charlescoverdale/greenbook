test_that("gb_compare returns gb_comparison with correct structure", {
  a <- gb_appraise(c(50, 0), c(0, 80))
  b <- gb_appraise(c(100, 0), c(0, 150))
  cmp <- gb_compare(a = a, b = b)
  expect_s3_class(cmp, "gb_comparison")
  expect_equal(nrow(cmp$summary_table), 2L)
  expect_true(all(c("option", "npv", "bcr", "rank_npv", "rank_bcr") %in%
                  names(cmp$summary_table)))
})

test_that("gb_compare ranks correctly by NPV", {
  a <- gb_appraise(c(50, 0), c(0, 80))   # NPV = -50 + 80/1.035 ≈ 27.3
  b <- gb_appraise(c(100, 0), c(0, 200)) # NPV = -100 + 200/1.035 ≈ 93.2
  cmp <- gb_compare(small = a, large = b)
  expect_equal(cmp$preferred_npv, "large")
})

test_that("gb_compare auto-labels unnamed options", {
  a <- gb_appraise(c(50, 0), c(0, 80))
  b <- gb_appraise(c(100, 0), c(0, 200))
  cmp <- gb_compare(a, b)
  expect_equal(cmp$summary_table$option, c("option_1", "option_2"))
})

test_that("gb_compare errors with fewer than 2 inputs", {
  a <- gb_appraise(c(50, 0), c(0, 80))
  expect_error(gb_compare(a))
})

test_that("gb_compare errors on non-appraisal input", {
  a <- gb_appraise(c(50, 0), c(0, 80))
  expect_error(gb_compare(a, "not an appraisal"))
})

test_that("gb_compare BCR ranking works when BCR available", {
  a <- gb_appraise(c(50, 0), c(0, 100))
  b <- gb_appraise(c(50, 0), c(0, 200))
  cmp <- gb_compare(low = a, high = b)
  expect_equal(cmp$preferred_bcr, "high")
})

test_that("gb_compare print method does not error", {
  a <- gb_appraise(c(50, 0), c(0, 80))
  b <- gb_appraise(c(100, 0), c(0, 200))
  cmp <- gb_compare(a = a, b = b)
  expect_no_error(capture.output(print(cmp)))
})
