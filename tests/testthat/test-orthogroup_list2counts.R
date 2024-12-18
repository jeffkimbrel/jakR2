o_list = read_orthogroups(test_path("fixtures", "Orthogroups.tsv"), type = "list", quiet = T)
o_counts = read_orthogroups(test_path("fixtures", "Orthogroups.tsv"), type = "counts", quiet = T)

test_that("converts list to counts correctly", {
  expect_equal(orthogroup_list2counts(o_list), o_counts)
})

test_that("wrong (inferred) file type gives error", {
  expect_error(orthogroup_list2counts(orthogroups = "random_text"), "<orthogroups> doesn't seem to be a dataframe")
  expect_error(orthogroup_list2counts(orthogroups = mtcars), "<orthogroups> doesn't seem to be an orthogroup list dataframe")
})

test_that("error if data is already counts", {
  expect_error(orthogroup_list2counts(o_counts), "<orthogroups> doesn't seem to be an orthogroup list dataframe")
})

test_that("verify gives correct output", {
  expect_equal(orthogroup_list2counts(o_counts, verify = TRUE), "counts")
  expect_equal(orthogroup_list2counts(o_list, verify = TRUE), "list")
})
