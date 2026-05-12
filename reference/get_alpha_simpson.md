# Calculate Simpson's diversity, Gini-Simpson index, ENS, and evenness

Computes four related measures from Simpson's D (sum of squared relative
abundances). Note that `GINI_SIMPSON` (1 - D) is a diversity index, not
an evenness measure — it is the probability that two randomly drawn
individuals belong to different species. True evenness is derived from
the number of species (`SIMPSON_ENS`).

## Usage

``` r
get_alpha_simpson(df, feature_id = "feature_id", id_col = "SAMPLE")
```

## Arguments

- df:

  A dataframe with features as rows and samples as columns

- feature_id:

  The name of the column with feature IDs (default is "feature_id")

- id_col:

  The name of the column with sample IDs (default is "SAMPLE")

## Value

A tibble with one row per sample and columns:

- SIMPSON_D:

  Simpson's dominance index (sum of squared proportions); lower = more
  diverse

- GINI_SIMPSON:

  Gini-Simpson index (1 - D); a diversity index, not evenness

- SIMPSON_ENS:

  Effective number of species (1 / D); the q=2 Hill number;
  interpretable as the number of equally abundant dominant species that
  would yield the same D

- SIMPSON_ENS_EVENNESS:

  ENS-based evenness (SIMPSON_ENS / S.obs); ranges from 1/S.obs (single
  dominant) to 1 (all species equal)

## Breaking changes

- SIMPSON_EVENNESS:

  Previously `1 - SIMPSON_D` (Gini-Simpson index). Renamed to
  `GINI_SIMPSON`. The name `SIMPSON_EVENNESS` is no longer returned —
  old workflows using it will error rather than silently return wrong
  values.

- SIMPSON_INVERSE:

  Renamed to `SIMPSON_ENS`. Old workflows using `SIMPSON_INVERSE` will
  error.
