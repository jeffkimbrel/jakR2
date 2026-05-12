# Calculate Shannon's entropy, ENS, Pielou's evenness, and ENS-based evenness

Shannon's H is an entropy (in nats), not a diversity. `SHANNON_ENS`
converts it to an effective number of species via exp(H) — the q=1 Hill
number, interpretable as the number of equally abundant species that
would produce the same entropy. Two evenness measures are returned:
Pielou's J (widely used, entropy-based) and an ENS-based evenness
consistent with the Hill number framework.

## Usage

``` r
get_alpha_shannon(df, feature_id = "feature_id", id_col = "SAMPLE")
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

- SHANNON_H:

  Shannon entropy H (nats); an index, not a diversity

- SHANNON_ENS:

  Effective number of species (exp(H)); the q=1 Hill number

- SHANNON_PIELOU:

  Pielou's J evenness (H / log(S.obs)); ratio of observed to maximum
  possible entropy

- SHANNON_EVENNESS:

  ENS-based evenness (SHANNON_ENS / S.obs); ranges from 1/S.obs (single
  dominant) to 1 (all species equal)
