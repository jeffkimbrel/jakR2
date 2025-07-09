test_that("output looks correct", {
  expect_equal(file2gfm("/Users/kimbrel1/test.md"), "`[test.md](<file:///Users/kimbrel1/test.md>)`{=gfm}")
})

test_that("verify looks OK", {
  expect_no_error(file2gfm(here::here(), verify = T))
  expect_error(file2gfm("~/not_a_file.txt", verify = T), "<file> doesn't appear to exist")
})

test_that("path works ok", {
  expect_no_error(file2gfm("test.txt", path = here::here()))
  expect_error(file2gfm("test.txt", path = "not a path"), "<path> is not a directory or does not exist")
})
