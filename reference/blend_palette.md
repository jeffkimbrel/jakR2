# Blend palette with a color

This idea comes (and uses functions) from the `monochromeR` package and
Cara Thompson's talk titled [“Visualise, Optimise,
Parameterise!”](https://www.youtube.com/watch?v=tdaMw6NcNFM&t=2914s).
The idea is that a set of colors in a palette will go together better if
you also blend a common color into all of them.

## Usage

``` r
blend_palette(colors, blend, amount = 3)
```

## Arguments

- colors:

  A vector of colors to blend

- blend:

  A color to blend with the colors

- amount:

  An integer between 0 and 10 to determine the strength of the blend
