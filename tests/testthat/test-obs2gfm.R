test_that("link looks right", {
  expect_equal(obs2gfm("obsidian note"), "`[[obsidian note]]`{=gfm}")
})

test_that("hash tags don't cause problems", {
  expect_equal(obs2gfm("obsidian note#heading"), "`[[obsidian note#heading]]`{=gfm}")
})

test_that("titling works", {
  expect_equal(obs2gfm("obsidian note#heading", text = "new text"), "`[[obsidian note#heading|new text]]`{=gfm}")
})

test_that("pipe in link fails", {
  expect_error(obs2gfm("obsidian note|new text"),
               "<link> should not contain `|`, try using the <text> argument as well")
})
