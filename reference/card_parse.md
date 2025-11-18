# Parse CARD database JSON file

This function parses the CARD JSON file and returns a dataframe. This
dataframe can be used by other functions in the function family.

## Usage

``` r
card_parse(card_path, quiet = F)
```

## Arguments

- card_path:

  Path to the card.json file

- quiet:

  If TRUE, suppress progress bar

## Value

A dataframe with card annotations

## See also

Other "CARD/RGI":
[`card_ab2gene()`](https://jeffkimbrel.github.io/jakR2/reference/card_ab2gene.md),
[`card_ab_info()`](https://jeffkimbrel.github.io/jakR2/reference/card_ab_info.md),
[`card_gene2ab()`](https://jeffkimbrel.github.io/jakR2/reference/card_gene2ab.md),
[`card_gene_info()`](https://jeffkimbrel.github.io/jakR2/reference/card_gene_info.md)
