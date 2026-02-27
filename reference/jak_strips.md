# Strip text styling

Sets facet strip text appearance using
[`ggtext::element_textbox()`](https://wilkelab.org/ggtext/reference/element_textbox.html).

## Usage

``` r
jak_strips(
  strip_size = 10,
  strip_color = "transparent",
  strip_line = 0,
  base_color = "gray30"
)
```

## Arguments

- strip_size:

  Font size for strip text. Default `10`.

- strip_color:

  Background fill color for strip text boxes. Default `"transparent"`.

- strip_line:

  Border line width for strip text boxes. Default `0`.

- base_color:

  Text color for strips. Default `"gray30"`.

## Value

A ggplot2 theme object
