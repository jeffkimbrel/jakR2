# A full-service color palette creator

The function creates a vector of RGB values suitable for ggplot or
similar. If using the `p` argument it will use one of the default
palettes in the `jak_palettes` data object, or you can pass it your own
colors using the `colors` argument. What makes this function useful is
that it will extend and interpolate the values of the given palette so
it can return `n` colors. The final parameter is whether you want to
reverse the values or not.

## Usage

``` r
palette_jak(p = "bay", colors = NULL, n = 2, order = "default")
```

## Arguments

- p:

  A named color palette

- colors:

  An optional vector of rgb or colors to use. Overwrites `p`

- n:

  Number of colors to return

- order:

  default, reverse or random order

## Details

Internally, the color palette is "ramped" using
[`colorRampPalette()`](https://rdrr.io/r/grDevices/colorRamp.html).
Further, colors passed via the `colors` argument are first checked
whether they're valid using the
[`all_are_valid_colors()`](https://jeffkimbrel.github.io/jakR2/reference/all_are_valid_colors.md)
function.
