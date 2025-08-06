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







