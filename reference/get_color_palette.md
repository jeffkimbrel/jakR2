# Return table of colors for a palette

On the surface this function doesn't seem useful as it basically
enframes a vector of a color palette. But, with the `full = TRUE`
parameter set, it is used within the `show_color_paeltte()` function to
return a data frame with the color, position, luminance, and text color
for each color in the palette. This is useful for creating a ggplot2
plot of the color palette.

## Usage

``` r
get_color_palette(pal, full = FALSE)
```

## Arguments

- pal:

  A color palette

- full:

  A boolean for whether to return the full data frame or just the color
  and position
