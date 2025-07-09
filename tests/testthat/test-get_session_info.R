test_that("returns df", {
  expect_true(inherits(get_session_info(), "data.frame"))
})
