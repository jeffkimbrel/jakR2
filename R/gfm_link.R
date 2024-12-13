#' Decorate a filepath string for gfm markdown in Obsidian
#'
#' @param filepath A string representing a file path
#' @param verify Logical indicating whether to verify the file exists
#'
#' @return A string with the file path as a gfm markdown link
#' @export

filepath2gfm <- function(filepath, verify = F) {
  # note I change the glue open and close to "{{" and "}}" to avoid conflicts with the curly braces in the string

  filepath = path.expand(filepath)

  if (verify) {
    stopifnot("file doesn't appear to exist" = file.exists(filepath))
  }

  b <- basename(filepath)
  glue::glue("`[{{b}}](<file://{{filepath}}>)`{=gfm}",
    .open = "{{",
    .close = "}}"
  )
}
