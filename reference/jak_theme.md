# Complete JAK theme

A complete ggplot2 theme that combines
[`jak_transparent()`](https://jeffkimbrel.github.io/jakR2/reference/jak_transparent.md),
[`jak_color()`](https://jeffkimbrel.github.io/jakR2/reference/jak_color.md),
[`jak_text()`](https://jeffkimbrel.github.io/jakR2/reference/jak_text.md),
[`jak_grid()`](https://jeffkimbrel.github.io/jakR2/reference/jak_grid.md),
[`jak_legend()`](https://jeffkimbrel.github.io/jakR2/reference/jak_legend.md),
and
[`jak_strips()`](https://jeffkimbrel.github.io/jakR2/reference/jak_strips.md)
into a single convenience wrapper. Built on top of
[`ggplot2::theme_bw()`](https://ggplot2.tidyverse.org/reference/ggtheme.html).

## Usage

``` r
jak_theme(
  base_size = 10,
  plot_title_size = 12,
  axis_title_size = 11,
  base_color = "gray30",
  plot_title_color = "gray30",
  axis_title_color = "gray30",
  grid_color = "transparent",
  border_width = 0.5,
  outline_color = base_color,
  strip_size = 10,
  strip_color = "transparent",
  strip_line = 0,
  legend_size = 10,
  legend_position = "bottom",
  base_family = ""
)
```

## Arguments

- base_size:

  Base font size. Default `10`.

- plot_title_size:

  Plot title font size. Default `12`.

- axis_title_size:

  Axis title font size. Default `11`.

- base_color:

  Base color for text and borders. Default `"gray30"`.

- plot_title_color:

  Color for plot title. Default `"gray30"`.

- axis_title_color:

  Color for axis titles. Default `"gray30"`.

- grid_color:

  Color for major grid lines. Default `"transparent"` (no grid).

- border_width:

  Panel border line width. Default `0.5`.

- outline_color:

  Default outline/border color for filled geom shapes (pch 21-25).
  Default `"gray70"`.

- strip_size:

  Font size for strip text. Default `10`.

- strip_color:

  Background fill color for strip text boxes. Default `"transparent"`.

- strip_line:

  Border line width for strip text boxes. Default `0`.

- legend_size:

  Font size for legend text and title. Default `10`.

- legend_position:

  Legend position. One of `"bottom"`, `"top"`, `"left"`, `"right"`, or
  `"none"`. Default `"bottom"`.

- base_family:

  Base font family. Default `""` (system default).

## Value

A ggplot2 theme object
