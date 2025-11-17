#' Extract DADA2 seqtab statistics
#'
#' Given a seqtab matrix, this function will calculate the counts and abundances
#' of ASVs and by their sequence lengths. `FREQ` is the number of ASVs, and `ABUNDANCE`
#' is the total number of reads for each sequence length.
#'
#' A seqtab object itself is just a matrix, so the error checking can't always
#' determine if it is truly a seqtab object, or just another matrix. So,
#'
#' @param seqtab A DADA2 sequence table
#'
#' @export

seqtab_stats <- function(seqtab) {
  # seqtab should be a matrix
  if (!is.matrix(seqtab)) {
    stop("seqtab must be a matrix")
  }

  sizes_freq <- as.data.frame(table(nchar(colnames(seqtab)))) |>
    tibble::as_tibble() |>
    dplyr::rename(LENGTH = "Var1", FREQ = "Freq") |>
    dplyr::mutate(LENGTH = as.integer(as.character(LENGTH)))

  # tries to see if it is a seqtab object - if not than colSums(seqtab) will likely fail
  sizes_abund <- tryCatch(
    {
      data.frame("ABUNDANCE" = tapply(
        colSums(seqtab), nchar(colnames(seqtab)),
        sum
      ))
    },
    error = function(e) {
      stop("<seqtab> doesn't appear to be a seqtab object", call. = FALSE)
    }
  )

  sizes_abund <- sizes_abund |>
    tibble::rownames_to_column("LENGTH") |>
    tibble::as_tibble() |>
    dplyr::mutate(LENGTH = as.integer(as.character(LENGTH)))

  sizes_freq |>
    dplyr::left_join(sizes_abund, by = dplyr::join_by(LENGTH))
}



#' Stats of multiple seqtab objects
#'
#' @param ... One or more seqtab objects
#'
#' @returns A tibble with seqtab stats
#' @export

seqtab_stats_bind <- function(...) {

  seqtab_names <- as.character(substitute(list(...)))[-1]
  seqtab_list <- mget(seqtab_names, envir = parent.frame())

  res <- dplyr::bind_rows(
    lapply(
      seqtab_list,
      seqtab_stats
    ),
    .id = "STEP"
  ) |>
    tidyr::pivot_longer(
      cols = c("FREQ", "ABUNDANCE"),
      names_to = "METRIC",
      values_to = "VALUE"
    )

  return(res)
}



#' Plot multiple seqtab objects
#'
#' @param ... One or more seqtab objects
#'
#' @returns A ggplot object
#' @export

seqtab_stats_plot = function(...) {

  # note, the top half of this (before the ggplot call) is identical to seqtab_stats_bind, but I can't use that function here because the mget call doesn't work

  seqtab_names <- as.character(substitute(list(...)))[-1]
  seqtab_list <- mget(seqtab_names, envir = parent.frame())

  dplyr::bind_rows(
    lapply(
      seqtab_list,
      seqtab_stats
    ),
    .id = "STEP"
  ) |>
    tidyr::pivot_longer(
      cols = c("FREQ", "ABUNDANCE"),
      names_to = "METRIC",
      values_to = "VALUE"
    ) |> #
    ggplot2::ggplot(ggplot2::aes(x = LENGTH, y = VALUE, fill = STEP)) +
      ggplot2::geom_col(position = "dodge") +
      ggplot2::scale_fill_manual(values = palette_jak(n = 2, p = "bay")) +
      ggplot2::facet_wrap(~METRIC, scales = "free_y", ncol = 1) +
      ggplot2::scale_y_continuous(labels=function(x) format(x, big.mark = ",", decimal.mark = ".", scientific = FALSE)) +
      ggplot2::labs(x = "ASV Length", y = "ASV Count", title = "ASV frequency and abundance by length")
}
