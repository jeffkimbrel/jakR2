# Fake feature table: 3 features, 2 samples
# S1: equal abundances (10,10,10) → maximum diversity
# S2: unequal abundances (1,1,8)  → lower diversity
alpha_df <- tibble::tibble(
  feature_id = c("feat1", "feat2", "feat3"),
  S1 = c(10L, 10L, 10L),
  S2 = c(1L, 1L, 8L)
)


# get_alpha_S ------------------------------------------------------------------

test_that("get_alpha_S returns one row per sample", {
  out <- get_alpha_S(alpha_df)
  expect_equal(nrow(out), 2)
})

test_that("get_alpha_S returns expected columns", {
  out <- get_alpha_S(alpha_df)
  expect_true(all(c("SAMPLE", "sample_sum", "S.obs", "S.chao1", "S.ACE") %in% names(out)))
})

test_that("get_alpha_S sample_sum is correct", {
  out <- get_alpha_S(alpha_df)
  expect_equal(out$sample_sum[out$SAMPLE == "S1"], 30)
  expect_equal(out$sample_sum[out$SAMPLE == "S2"], 10)
})

test_that("get_alpha_S S.obs is correct", {
  out <- get_alpha_S(alpha_df)
  expect_equal(out$S.obs[out$SAMPLE == "S1"], 3)
  expect_equal(out$S.obs[out$SAMPLE == "S2"], 3)
})


# get_alpha_simpson ------------------------------------------------------------

test_that("get_alpha_simpson returns one row per sample", {
  out <- get_alpha_simpson(alpha_df)
  expect_equal(nrow(out), 2)
})

test_that("get_alpha_simpson returns new column names, not old", {
  out <- get_alpha_simpson(alpha_df)
  expect_true(all(c("SIMPSON_D", "GINI_SIMPSON", "SIMPSON_ENS", "SIMPSON_ENS_EVENNESS") %in% names(out)))
  expect_false("SIMPSON_EVENNESS" %in% names(out))
  expect_false("SIMPSON_INVERSE" %in% names(out))
})

test_that("get_alpha_simpson GINI_SIMPSON = 1 - SIMPSON_D", {
  out <- get_alpha_simpson(alpha_df)
  expect_equal(out$GINI_SIMPSON, 1 - out$SIMPSON_D)
})

test_that("get_alpha_simpson SIMPSON_ENS = 1 / SIMPSON_D", {
  out <- get_alpha_simpson(alpha_df)
  expect_equal(out$SIMPSON_ENS, 1 / out$SIMPSON_D)
})

test_that("get_alpha_simpson equal abundances gives maximum evenness", {
  out <- get_alpha_simpson(alpha_df)
  # S1 is perfectly even: D = 3*(1/3)^2 = 1/3, ENS = 3, evenness = 3/3 = 1
  expect_equal(out$SIMPSON_D[out$SAMPLE == "S1"], 1 / 3, tolerance = 1e-6)
  expect_equal(out$SIMPSON_ENS_EVENNESS[out$SAMPLE == "S1"], 1.0, tolerance = 1e-6)
})

test_that("get_alpha_simpson unequal abundances gives correct D", {
  out <- get_alpha_simpson(alpha_df)
  # S2: Pi = (0.1, 0.1, 0.8), D = 0.01 + 0.01 + 0.64 = 0.66
  expect_equal(out$SIMPSON_D[out$SAMPLE == "S2"], 0.66, tolerance = 1e-6)
})


# get_alpha_shannon ------------------------------------------------------------

test_that("get_alpha_shannon returns one row per sample", {
  out <- get_alpha_shannon(alpha_df)
  expect_equal(nrow(out), 2)
})

test_that("get_alpha_shannon returns new column names, not old", {
  out <- get_alpha_shannon(alpha_df)
  expect_true(all(c("SHANNON_H", "SHANNON_ENS", "SHANNON_PIELOU", "SHANNON_EVENNESS") %in% names(out)))
  expect_false("SHANNON_E" %in% names(out))
})

test_that("get_alpha_shannon SHANNON_ENS = exp(SHANNON_H)", {
  out <- get_alpha_shannon(alpha_df)
  expect_equal(out$SHANNON_ENS, exp(out$SHANNON_H), tolerance = 1e-6)
})

test_that("get_alpha_shannon equal abundances gives maximum evenness", {
  out <- get_alpha_shannon(alpha_df)
  # S1: H = log(3), ENS = 3, Pielou = 1, SHANNON_EVENNESS = 1
  expect_equal(out$SHANNON_H[out$SAMPLE == "S1"], log(3), tolerance = 1e-6)
  expect_equal(out$SHANNON_PIELOU[out$SAMPLE == "S1"], 1.0, tolerance = 1e-6)
  expect_equal(out$SHANNON_EVENNESS[out$SAMPLE == "S1"], 1.0, tolerance = 1e-6)
})

test_that("get_alpha_shannon unequal abundances gives correct H", {
  out <- get_alpha_shannon(alpha_df)
  # S2: Pi = (0.1, 0.1, 0.8), H = -(2*0.1*log(0.1) + 0.8*log(0.8))
  expected_H <- -(2 * 0.1 * log(0.1) + 0.8 * log(0.8))
  expect_equal(out$SHANNON_H[out$SAMPLE == "S2"], expected_H, tolerance = 1e-6)
})
