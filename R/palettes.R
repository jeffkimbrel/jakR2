#' A full-service color palette creator
#'
#' These palettes can be used all over.
#'
#' @param n Number of colors to return
#' @param colors An optional vector of rgb or colors to use. Overwrites `p`
#' @param p A named color palette
#' @param reverse A boolean for whether the palette should be reversed or not
#'
#' @export

palette_jak = function(p = "bay",
                       colors = NULL,
                       n = 2,
                       reverse = FALSE) {

  if (is.null(colors)) {
    cols = colorRampPalette(unname(unlist(jak_palettes[p])))(n)
  } else {
    if (all(all_are_valid_colors(colors))) {
      cols = colorRampPalette(colors)(n)
    } else {
      stop("ERROR: one of the colors isn't valid")
    }
  }

  if (isTRUE(reverse)) {
    return(rev(cols))
  } else {
    return(cols)
  }
}


#' Check if a string contains valid color strings
#'
#' It appears I copied this function from https://stackoverflow.com/questions/13289009/check-if-character-string-is-a-valid-color-representation
#'
#' @param x A vector of colors in rgb or text string
#'
#' @export

all_are_valid_colors <- function(x) {
  sapply(x, function(X) {
    tryCatch(is.matrix(col2rgb(X)),
             error = function(e) FALSE)
  })
}
