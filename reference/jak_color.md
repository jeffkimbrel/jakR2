# Color defaults

Sets default colors for text, axes, panel border, and geom aesthetics.
Uses `element_geom()` (requires ggplot2 \>= 4.0.0) to set the default
outline color for filled shapes (pch 21-25).

## Usage

``` r
jak_color(
  base_color = "gray30",
  plot_title_color = "gray30",
  axis_title_color = "gray30",
  border_width = 0.5,
  outline_color = base_color
)
```

## Arguments

- base_color:

  Base color for text and borders. Default `"gray30"`.

- plot_title_color:

  Color for plot title. Default `"gray30"`.

- axis_title_color:

  Color for axis titles. Default `"gray30"`.

- border_width:

  Panel border line width. Default `0.5`.

- outline_color:

  Default outline/border color for filled geom shapes (pch 21-25).
  Default `"gray70"`.

## Value

A ggplot2 theme object
