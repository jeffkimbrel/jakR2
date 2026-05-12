# Calculate richness (S) and sample depth

Observed richness is counted directly; Chao1 and ACE are extrapolated
estimators of true richness based on the frequency of rare species. All
three are returned so downstream code can choose the appropriate
measure.

## Usage

``` r
get_alpha_S(df, feature_id = "feature_id", id_col = "SAMPLE")
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

- sample_sum:

  Total read count (sequencing depth)

- S.obs:

  Observed species richness

- S.chao1:

  Chao1 richness estimator

- se.chao1:

  Standard error of Chao1

- S.ACE:

  ACE richness estimator

- se.ACE:

  Standard error of ACE
