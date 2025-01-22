#' Import an orthofinder TSV file
#'
#' This code replaces the `jakR::orthofinder_summary()` function.
#'
#' @param file The path to the Orthogroups/Orthogroups.tsv file in the standard orthofinder output
#' @param type Whether to return the counts or the lists of genes in each orthogroup
#' @param quiet If TRUE, suppress messages
#'
#' @export

read_orthogroups <- function(file,
                             type = "counts",
                             quiet = F) {
  GENE_LIST <- NULL


  # error if file doesnt exist
  if (!file.exists(file)) {
    stop("<file> does not appear to exist", call. = F)
  }

  # type must be either counts or list
  if (!type %in% c("counts", "lists", "count", "list")) {
    stop("<type> must be either 'count' or 'list'", call. = FALSE)
  }


  orthogroups <- readr::read_tsv(file,
    show_col_types = FALSE,
    progress = FALSE
  )

  # error if colnames(orthogroups)[1] != "Orthogroup"
  if (colnames(orthogroups)[1] != "Orthogroup") {
    stop("<file> does not appear to have the correct format. The first column
          should be the Orthogroup IDs, and each additional column should be a
          genome. Each row should be an orthogroup.", call. = F)
  }

  GENE <- GENOME <- Orthogroup <- NULL

  orthogroups <- orthogroups |>
    tidyr::pivot_longer(
      cols = -tidyselect::contains("Orthogroup"),
      names_to = "GENOME",
      values_to = "GENE"
    ) |>
    tidyr::drop_na()

  if (type %in% c("counts", "count")) {
    orthogroups <- orthogroups |>
      dplyr::rowwise() |>
      dplyr::mutate(GENE = length(unlist(strsplit(GENE, ",")))) |>
      tidyr::pivot_wider(
        names_from = GENOME,
        values_from = GENE,
        values_fill = 0
      )
  } else if (type %in% c("lists", "list")) {
    orthogroups <- orthogroups |>
      dplyr::mutate(GENE_LIST = strsplit(GENE, ",")) |>
      dplyr::select(-GENE) |>
      tidyr::pivot_wider(
        names_from = GENOME,
        values_from = GENE_LIST,
        values_fill = list()
      )
  }



  if (quiet == F) {
    message(glue::glue_col("{green {basename(file)} contains {nrow(orthogroups)} orthogroups across {ncol(orthogroups) - 1} genomes}"))
  }

  return(orthogroups)
}


#' Convert an orthogroup list dataframe to a count dataframe
#'
#' This function is used to convert the output of `read_orthogroups()` when the
#' type is set to "list" to a count format. Alternatively, it can run in verify
#' mode where it will return "counts" or "list" based on some basic inference.
#'
#' @param orthogroups The orthogroup dataframe
#' @param verify If TRUE, return "counts" or "list" based on the input
#'
#' @export

orthogroup_list2counts <- function(orthogroups, verify = F) {

  GENE <- GENOME <- L <- NULL

  #
  if (isFALSE(inherits(orthogroups, "data.frame"))) {
    stop("<orthogroups> doesn't seem to be a dataframe", call. = F)
  } else if (colnames(orthogroups)[1] != "Orthogroup") {
    stop("<orthogroups> doesn't seem to be an orthogroup list dataframe", call. = F)
  }

  # decide if it is a "counts" or "list" dataframe
  if (all(sapply(orthogroups[, 2], is.integer))) {
    if (isTRUE(verify)) {
      return("counts")
    } else {
      stop("<orthogroups> doesn't seem to be an orthogroup list dataframe", call. = F)
    }
  } else {
    if (isTRUE(verify)) {
      return("list")
    } else {
      orthogroups |>
        tidyr::pivot_longer(cols = -tidyr::contains("Orthogroup"), names_to = "GENOME", values_to = "GENE") |>
        dplyr::rowwise() |>
        dplyr::mutate(L = length(GENE)) |>
        dplyr::select(-GENE) |>
        tidyr::pivot_wider(names_from = GENOME, values_from = L, values_fill = 0)
    }
  }
}



