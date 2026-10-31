test_that("gb_schedule_table returns all bands by default", {
  tbl <- gb_schedule_table()
  expect_s3_class(tbl, "data.frame")
  expect_true(all(c("year_from", "year_to", "standard", "health", "catastrophic") %in% names(tbl)))
  expect_equal(nrow(tbl), 3L)
  expect_equal(tbl$year_to, c(30L, 75L, 125L))
  expect_equal(nrow(gb_schedule_table(vintage = "2003")), 6L)
})

test_that("gb_schedule_table narrows columns when schedule supplied", {
  tbl <- gb_schedule_table("health", vintage = "2003")
  expect_named(tbl, c("year_from", "year_to", "rate"))
  expect_equal(tbl$rate[1], 0.015)
  expect_error(gb_schedule_table("health"), "withdrawn")
})

test_that("gb_schedule_table errors on invalid schedule", {
  expect_error(gb_schedule_table("nonsense"))
})

test_that("gb_data_versions returns vintage metadata", {
  v <- gb_data_versions()
  expect_s3_class(v, "data.frame")
  expect_true(all(c("dataset", "source", "last_updated", "notes") %in% names(v)))
  expect_true("stpr_schedule" %in% v$dataset)
  expect_true("gdp_deflator" %in% v$dataset)
})
