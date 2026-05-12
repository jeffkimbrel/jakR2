#' JAK color palettes
#'
#' A named list of 23 color palettes used by [get_color_palette()] and related functions.
#'
#' @format A named list of 23 character vectors, each containing hex color codes.
"jak_palettes"


#' Sample abundance matrix for examples and tests
#'
#' A sample feature abundance matrix with 18 features and 20 samples.
#'
#' @format A matrix with 18 rows (features) and 20 columns (samples).
"jak_samp"


#' Sample phylogenetic tree for examples and tests
#'
#' A phylogenetic tree with 20 tips corresponding to the samples in [jak_samp].
#'
#' @format A \code{phylo} object with 20 tips.
"jak_tree"


#' Regular expression for EC numbers
#'
#' A regex pattern that matches Enzyme Commission (EC) numbers
#' of the form \code{1.2.3.4}.
#'
#' @format A length-1 character vector.
"EC_number_regex"


#' Regular expression for gene symbols
#'
#' A regex pattern that matches prokaryotic gene symbols
#' of the form \code{abcA1} (three lowercase letters, uppercase letter(s), optional digits).
#'
#' @format A length-1 character vector.
"gene_symbol_regex"
