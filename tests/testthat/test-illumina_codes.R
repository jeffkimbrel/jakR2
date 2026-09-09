test_that("dot-separated format works correctly", {
  result <- illumina_codes("VH01105.139.AAFNL3GM5.1")

  expect_equal(length(result), 4)
  expect_equal(result$machine, "NextSeq 2000")
  expect_equal(result$machine_code, "VH01105")
  expect_equal(result$flowcell, "NextSeq_1000/2000")
  expect_equal(result$flowcell_code, "AAFNL3GM5")
})

test_that("colon-separated format works correctly", {
  result <- illumina_codes("M01056:70:000000000-CMPN2:1")

  expect_equal(length(result), 4)
  expect_equal(result$machine, "MiSeq")
  expect_equal(result$machine_code, "M01056")
  expect_equal(result$flowcell, "MiSeq")
  expect_equal(result$flowcell_code, "000000000-CMPN2")
})

test_that("various machine types are detected correctly", {
  expect_equal(illumina_codes("M00123.1.ABC.1")$machine, "MiSeq")
  expect_equal(illumina_codes("HWI-M00123.1.ABC.1")$machine, "MiSeq")
  expect_equal(illumina_codes("HWUSI-123.1.ABC.1")$machine, "GAIIx")
  expect_equal(illumina_codes("HWI-D00123.1.ABC.1")$machine, "HiSeq 2x00")
  expect_equal(illumina_codes("K00123.1.ABC.1")$machine, "HiSeq 3/4000")
  expect_equal(illumina_codes("N00123.1.ABC.1")$machine, "NextSeq 5x0")
  expect_equal(illumina_codes("A00123.1.ABC.1")$machine, "NovaSeq")
  expect_equal(illumina_codes("H00123.1.ABC.1")$machine, "NovaSeq")
  expect_equal(illumina_codes("V00123.1.ABC.1")$machine, "NextSeq 2000")
  expect_equal(illumina_codes("AA00123.1.ABC.1")$machine, "NextSeq 2000")
})

test_that("various flowcell types are detected correctly", {
  expect_equal(illumina_codes("M00123.1.BRB123.1")$flowcell, "iSeq_100")
  expect_equal(illumina_codes("M00123.1.000H123.1")$flowcell, "MiniSeq")
  expect_equal(illumina_codes("M00123.1.CABC.1")$flowcell, "MiSeq")
  expect_equal(illumina_codes("N00123.1.AFGH12.1")$flowcell, "NextSeq_500/550")
  expect_equal(illumina_codes("V00123.1.AAFNL3GM5.1")$flowcell, "NextSeq_1000/2000")
  expect_equal(illumina_codes("V00123.1.AAFNL3GHV.1")$flowcell, "NextSeq_2000")
  expect_equal(illumina_codes("HWI-D00123.1.ACXX12.1")$flowcell, "HiSeq_2500")
  expect_equal(illumina_codes("K00123.1.BBXX12.1")$flowcell, "HiSeq_3000/4000")
  expect_equal(illumina_codes("K00123.1.ALXX12.1")$flowcell, "HiSeq_X")
  expect_equal(illumina_codes("A00123.1.DRXX12.1")$flowcell, "NovaSeq_6000")
  expect_equal(illumina_codes("A00123.1.DSXX12.1")$flowcell, "NovaSeq_6000")
})

test_that("unknown format returns unknown", {
  expect_equal(illumina_codes("123.456.78.9")$machine, "Unknown Illumina Machine")
  expect_equal(illumina_codes("123.456.78.9")$flowcell, "Unknown Flowcell Type")
})

test_that("malformed run_id handles gracefully", {
  result <- illumina_codes("short")
  expect_equal(result$machine, "Unknown Illumina Machine")
  expect_equal(result$flowcell, "Unknown Flowcell Type")
  expect_true(is.na(result$flowcell_code))
})

test_that("non-string input errors", {
  expect_error(illumina_codes(123), "run_id must be a string")
  expect_error(illumina_codes(mtcars), "run_id must be a string")
})
