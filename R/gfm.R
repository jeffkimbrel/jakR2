#' Decorate an Obsidian link for gfm markdown
#'
#' @param link A string representing the link
#' @param text A string representing the text to display
#'
#' @export


obs2gfm = function(link, text = NA) {

  # if link contains "|" give error to reformat and use text argument
  stopifnot("<link> should not contain `|`, try using the <text> argument as well" = !grepl("\\|", link))

  if (is.na(text)) {
    glue::glue("`[[{{link}}]]`{=gfm}",
               .open = "{{",
               .close = "}}"
    )
  } else {
    glue::glue("`[[{{link}}|{{text}}]]`{=gfm}",
               .open = "{{",
               .close = "}}"
    )
  }


}


#' Decorate a file string for gfm markdown in Obsidian
#'
#' This function takes a file path and returns a string with the file path as a
#' gfm formatted link that works in Obsidian. If a `path` is not given, then the
#' function will "expand" the `file` string to be a full path. This is meant to
#' expand "~/" to a full path, but can cause issues if you give just a file name
#' but no context as to the path.
#'
#' @param file A string representing a file name or path
#' @param path A string representing a file path
#' @param verify Logical indicating whether to verify the file exists
#'
#' @return A string with the file path as a gfm markdown link
#' @export

file2gfm <- function(file,
                     path = NA,
                     verify = F) {


  if (!is.na(path)) {
    # verify that path is a directory (not a file) and does exist
    stopifnot("<path> is not a directory or does not exist" = dir.exists(path))

    # if exists, then combine path and file
    file <- file.path(path, file)
  } else {

    # otherwise, expand the file to a complete path
    file = path.expand(file)
  }

  if (verify) {
    stopifnot("<file> doesn't appear to exist" = file.exists(file))
  }

  b <- basename(file)
  glue::glue("`[{{b}}](<file://{{file}}>)`{=gfm}",
    .open = "{{",
    .close = "}}"
  )
}
