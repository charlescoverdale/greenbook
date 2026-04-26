test_that("gb_place_based aggregates project NPVs additively when no synergy", {
  a <- gb_appraise(c(50, 0), c(0, 100))
  b <- gb_appraise(c(50, 0), c(0, 80))
  pb <- gb_place_based(a = a, b = b)
  expected <- a$npv + b$npv
  expect_equal(pb$aggregate_npv, expected, tolerance = 1e-9)
})

test_that("gb_place_based applies synergy uplift to benefits", {
  a <- gb_appraise(c(50, 0), c(0, 100))
  b <- gb_appraise(c(50, 0), c(0, 80))
  pb_no <- gb_place_based(a = a, b = b, synergy = 0)
  pb_up <- gb_place_based(a = a, b = b, synergy = 0.1)
  expect_gt(pb_up$aggregate_npv, pb_no$aggregate_npv)
})

test_that("gb_place_based stores place name", {
  a <- gb_appraise(c(50, 0), c(0, 100))
  b <- gb_appraise(c(50, 0), c(0, 80))
  pb <- gb_place_based(a = a, b = b, place = "Manchester")
  expect_equal(pb$place, "Manchester")
})

test_that("gb_place_based errors on out-of-range synergy", {
  a <- gb_appraise(c(50, 0), c(0, 100))
  b <- gb_appraise(c(50, 0), c(0, 80))
  expect_error(gb_place_based(a, b, synergy = 0.6))
  expect_error(gb_place_based(a, b, synergy = -0.6))
})

test_that("gb_place_based per-project table has all rows", {
  a <- gb_appraise(c(50, 0), c(0, 100))
  b <- gb_appraise(c(50, 0), c(0, 80))
  c <- gb_appraise(c(20, 20), c(0, 50))
  pb <- gb_place_based(a = a, b = b, c = c)
  expect_equal(nrow(pb$per_project), 3L)
})

test_that("gb_place_based print method does not error", {
  a <- gb_appraise(c(50, 0), c(0, 100))
  b <- gb_appraise(c(50, 0), c(0, 80))
  expect_no_error(capture.output(print(gb_place_based(a = a, b = b))))
})
