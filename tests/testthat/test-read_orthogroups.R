test_that("import produces correct snapshot", {
  expect_snapshot(read_orthogroups(test_path("fixtures", "Orthogroups.tsv")))
})

test_that("messages work as expected", {
  expect_message(read_orthogroups(test_path("fixtures", "Orthogroups.tsv")),
                 "Orthogroups.tsv contains 11 orthogroups across 5 genomes")
  expect_no_message(read_orthogroups(test_path("fixtures", "Orthogroups.tsv"), quiet = T))
})

test_that("no file found gives error", {
  expect_error(read_orthogroups("not_a_file.tsv"), "<file> does not appear to exist")
})

test_that("incorrect format gives error", {
  expect_error(read_orthogroups(test_path("fixtures", "generic_df.txt")))
})

test_that("type changes output", {
  expect_snapshot(read_orthogroups(test_path("fixtures", "Orthogroups.tsv"), type = "lists"))
})

test_that("incorrect type gives error", {
  expect_error(read_orthogroups(test_path("fixtures", "Orthogroups.tsv"),
                                type = "not_a_type"),
               "<type> must be either 'count' or 'list'")
})
