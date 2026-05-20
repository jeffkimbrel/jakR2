# jakR2 0.4

* Reworked alpha-diversity functions with corrected naming and Hill number framework
    * `SIMPSON_EVENNESS` renamed to `GINI_SIMPSON` (1 - D); `SIMPSON_INVERSE` renamed to `SIMPSON_ENS` (1/D)
    * New `SIMPSON_ENS_EVENNESS` column (ENS / S.obs)
    * `SHANNON_E` renamed to `SHANNON_PIELOU`; new `SHANNON_EVENNESS` column (ENS / S.obs)
* Added roxygen documentation for all package data objects
* Added `@param` entries for `clusters` and `filter` in the `ft` class
* Added testthat coverage for all alpha-diversity functions
* Added embed argument to `obs2gfm()` function

# jakR2 0.3

* A new `S7` object called `ft` to hold feature tables
* methods for filtering based on min count and sample
* methods for OTU clustering
* some reusable regular expressions
* some new functions to work with multiple seqtab objects (`seqtab_stats_bind` and `seqtab_stats_plot`)
* better feature naming options for `ft` objects
* new `obs_callout()` function
* split `jak_theme()` into 6 smaller functions, with `jak_theme()` now being a wrapper around them

# jakR2 0.2

* Helpful functions to create and work with palettes and colors
	* new `order` parameter for default, reverse and random palette order
	* `blend_palette()` to use monochromeR::generate_palette() blending 
* Some `jak_theme()` tweaks
* Alpha-diversity metrics
* Session and package info utilities
