# scale_fill_jak_d and scale_color_jak_d tests are basically identical

test_that("works right", {
  expect_equal(scale_fill_jak_d()$aesthetics, "fill")
  expect_true(inherits(scale_fill_jak_d(), "ScaleDiscrete"))
  expect_equal(scale_fill_jak_d()$palette(5), toupper(jak_palettes$bay))
  expect_equal(scale_fill_jak_d(order = "reverse")$palette(5), rev(toupper(jak_palettes$bay)))
})

test_that("<p> works right", {
  expect_no_error(scale_fill_jak_d(p = "helpcenter"))
  expect_error(scale_fill_jak_d(p = "not_a_palette"), "'not_a_palette' is not a known palette name")
  expect_error(scale_fill_jak_d(p = 1), "'1' is not a known palette name")
})

test_that("<colors> work right", {
  expect_no_error(scale_fill_jak_d(colors = "black"))
  expect_no_error(scale_fill_jak_d(colors = c("black", "red")))
  expect_error(scale_fill_jak_d(colors = c("black", "not_a_color")), "Invalid <colors> given")
})

test_that("<colors> overwrites <p>", {
  expect_equal(scale_fill_jak_d(p = "bay", colors = "black")$palette(3),
               scale_fill_jak_d(p = "helpcenter", colors = "black")$palette(3))
})

test_that("<order> works right", {
  expect_no_error(scale_fill_jak_d(order = "default"))
  expect_no_error(scale_fill_jak_d(order = "reverse"))
  expect_no_error(scale_fill_jak_d(order = "random"))
  expect_error(scale_fill_jak_d(order = "not_a_valid_order"), "<order> must be 'default', 'reverse' or 'random'")
})
