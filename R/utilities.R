#' Session info utility
#'
#' @export

get_session_info <- function() {
  df_sess <- sessioninfo::platform_info() |>
    unlist() |>
    as.data.frame() |>
    tibble::rownames_to_column()

  colnames(df_sess) <- c("name", "value")

  df_sess <- rbind(df_sess, c("machine", Sys.info()["nodename"]))

  df_sess |>
    dplyr::filter(name %in% c("machine", "version", "os", "system", "rstudio", "tz", "pandoc", "date", "ctype", "quarto"))
}




#' Package info utility
#'
#' @param attached Logical, whether to return only attached packages (default is TRUE)
#'
#' @export

get_package_info <- function(attached = TRUE) {

  # attached must be true/false
  if (!is.logical(attached) || length(attached) != 1) {
    stop("The 'attached' argument must be a single logical value (TRUE or FALSE).", call. = F)
  }

  df <- sessioninfo::package_info() |>
    tibble::as_tibble()

  if (isTRUE(attached)) {
    df <- df |>
      dplyr::filter(attached == TRUE)
  }

  df |>
    dplyr::select(Package = package, Version = loadedversion, Date = date)
}
