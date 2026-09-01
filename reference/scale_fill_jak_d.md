# Custom discrete ggplot2 scale fill

Custom discrete ggplot2 scale fill

## Usage

``` r
scale_fill_jak_d(
  p = "bay",
  colors = NULL,
  order = "default",
  na_value = "gray50",
  name = ggplot2::waiver(),
  guide = "legend"
)
```

## Arguments

- p:

  color palette to use from
  [`jakR2::jak_palettes`](https://jeffkimbrel.github.io/jakR2/reference/jak_palettes.md)

- colors:

  An optional vector of rgb or colors to use. Overwrites `p`

- order:

  Order of the palette, "default", "reverse" or "random"

- na_value:

  Color to use for NA values. Default `"gray50"`

- name:

  Legend title. Defaults to the name of the aesthetic (e.g., the
  variable name)

- guide:

  Guide to use for the legend. See
  [`ggplot2::guide_legend()`](https://ggplot2.tidyverse.org/reference/guide_legend.html)
  for details
