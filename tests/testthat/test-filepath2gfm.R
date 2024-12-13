test_that("output looks correct", {
  expect_equal(filepath2gfm("~/test.md"), "`[test.md](<file:///Users/kimbrel1/test.md>)`{=gfm}")
})

test_that("verify looks OK", {
  expect_no_error(filepath2gfm(here::here(), verify = T))
  expect_error(filepath2gfm("~/not_a_file.txt", verify = T), "file doesn't appear to exist")
})

