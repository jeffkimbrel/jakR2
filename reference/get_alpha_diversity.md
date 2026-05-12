# Alpha-Diversity Measures

An extension of the phyloseq `estimate_richness()` function to include
Shannon's Evenness and sample depth. It also combines the normal
estimate_richness output with the sample data dataframe.

## Usage

``` r
get_alpha_diversity(p, id_col = "SAMPLE")
```

## Arguments

- p:

  A phyloseq object

- id_col:

  The name of the column with sample IDs

## Value

A tibble joining sample metadata with columns from
[`get_alpha_S()`](https://jeffkimbrel.github.io/jakR2/reference/get_alpha_S.md),
[`get_alpha_simpson()`](https://jeffkimbrel.github.io/jakR2/reference/get_alpha_simpson.md),
and
[`get_alpha_shannon()`](https://jeffkimbrel.github.io/jakR2/reference/get_alpha_shannon.md).

## Details

Although this new version removes much of the phyloseq code, running
them instead in Vegan or calculating manually, it does still require
`phyloseq` from bioconductor, which is not automatically installed with
`jakR2`.
