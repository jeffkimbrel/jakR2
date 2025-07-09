test_that("returns df", {
  expect_true(inherits(get_package_info(), "data.frame"))
})


test_that("attached boolean", {
  expect_no_error(get_package_info(attached = TRUE))
  expect_no_error(get_package_info(attached = FALSE))
  expect_error(get_package_info(attached = "not_logical"), "<attached> must be TRUE/FALSE")
})
