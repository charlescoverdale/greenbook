test_that("gb_metb default is 20 percent", {
  expect_equal(gb_metb(100), 120)
  expect_equal(gb_metb(c(100, 200)), c(120, 240))
})

test_that("gb_metb honours custom rate", {
  expect_equal(gb_metb(100, rate = 0.10), 110)
  expect_equal(gb_metb(100, rate = 0), 100)
})

test_that("gb_metb vintage lookup returns correct rate", {
  expect_equal(gb_metb(100, vintage = "2003"), 130)
  expect_equal(gb_metb(100, vintage = "2018"), 120)
  expect_equal(gb_metb(100, vintage = "2022"), 120)
  expect_equal(gb_metb(100, vintage = "2026"), 120)
})

test_that("gb_metb vintage overrides explicit rate", {
  # vintage takes precedence
  expect_equal(gb_metb(100, rate = 0.50, vintage = "2022"), 120)
})

test_that("gb_metb errors on unknown vintage", {
  expect_error(gb_metb(100, vintage = "1999"))
})

test_that("gb_metb errors on out-of-range rate", {
  expect_error(gb_metb(100, rate = -0.1))
  expect_error(gb_metb(100, rate = 1.5))
})

test_that("gb_metb errors on non-scalar rate", {
  expect_error(gb_metb(100, rate = c(0.1, 0.2)))
})
