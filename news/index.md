# Changelog

## jakR2 0.4

- Reworked alpha-diversity functions with corrected naming and Hill
  number framework
  - `SIMPSON_EVENNESS` renamed to `GINI_SIMPSON` (1 - D);
    `SIMPSON_INVERSE` renamed to `SIMPSON_ENS` (1/D)
  - New `SIMPSON_ENS_EVENNESS` column (ENS / S.obs)
  - `SHANNON_E` renamed to `SHANNON_PIELOU`; new `SHANNON_EVENNESS`
    column (ENS / S.obs)
- Added roxygen documentation for all package data objects
- Added `@param` entries for `clusters` and `filter` in the `ft` class
- Added testthat coverage for all alpha-diversity functions
- Added embed argument to
  [`obs2gfm()`](https://jeffkimbrel.github.io/jakR2/reference/obs2gfm.md)
  function
- Created `sysdata.rda` to store data accessible with `::`
- Added na values to color themes
- Illumina codes
- [`merge_ft()`](https://jeffkimbrel.github.io/jakR2/reference/merge_ft.md)
  and
  [`load_ft_from_files()`](https://jeffkimbrel.github.io/jakR2/reference/load_ft_from_files.md)
- New `n` argument to
  [`show_all_color_palettes()`](https://jeffkimbrel.github.io/jakR2/reference/show_all_color_palettes.md)
  to make it easier to select a palette based on the ramped values

## jakR2 0.3

- A new `S7` object called `ft` to hold feature tables
- methods for filtering based on min count and sample
- methods for OTU clustering
- some reusable regular expressions
- some new functions to work with multiple seqtab objects
  (`seqtab_stats_bind` and `seqtab_stats_plot`)
- better feature naming options for `ft` objects
- new
  [`obs_callout()`](https://jeffkimbrel.github.io/jakR2/reference/obs_callout.md)
  function
- split
  [`jak_theme()`](https://jeffkimbrel.github.io/jakR2/reference/jak_theme.md)
  into 6 smaller functions, with
  [`jak_theme()`](https://jeffkimbrel.github.io/jakR2/reference/jak_theme.md)
  now being a wrapper around them

## jakR2 0.2

- Helpful functions to create and work with palettes and colors
  - new `order` parameter for default, reverse and random palette order
  - [`blend_palette()`](https://jeffkimbrel.github.io/jakR2/reference/blend_palette.md)
    to use monochromeR::generate_palette() blending
- Some
  [`jak_theme()`](https://jeffkimbrel.github.io/jakR2/reference/jak_theme.md)
  tweaks
- Alpha-diversity metrics
- Session and package info utilities
