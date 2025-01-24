#' Internal helper function for parsing card.json file
#'
#' This helper function is called in parallel by the `card_parse()` function,
#' and isn't intended to be accessed directly.
#'
#' @param card an inner card.json object

cp_helper <- function(card) {
  card |>
    unlist() |>
    tibble::enframe() |>
    dplyr::filter(stringr::str_detect(name, "ARO_name|ARO_category|ARO_description")) |>
    dplyr::mutate(ARO_name = value[name == "ARO_name"]) |>
    dplyr::mutate(ARO_description = value[name == "ARO_description"]) |>
    dplyr::filter(!name == "ARO_name") |>
    dplyr::filter(!name == "ARO_description") |>
    tidyr::separate(name, into = c("name", "cvterm_id", "C"), sep = "\\.") |>
    tidyr::pivot_wider(names_from = C) |>
    dplyr::select(-name, -cvterm_id)
}

#' Parse CARD database JSON file
#'
#' This function parses the CARD JSON file and returns a dataframe. This
#' dataframe can be used by other functions in the function family.
#'
#' @param card_path Path to the card.json file
#' @param quiet If TRUE, suppress progress bar
#'
#' @export
#' @family "CARD/RGI"
#'
#' @returns A dataframe with card annotations

card_parse <- function(card_path, quiet = F) {

  # card_path must be a file path and the file must exist
  if (!file.exists(card_path)) {
    stop("<card_path> file not found", call. = F)
  }

  # quiet must be true or false
  if (!quiet %in% c(T, F)) {
    stop("<quiet> must be TRUE or FALSE", call. = F)
  }

  card_json <- jsonlite::fromJSON(card_path)

  # the !quiet just converts F to T, and T to F
  card <- purrr::map(card_json, cp_helper, .progress = !quiet) |>
    dplyr::bind_rows(.id = "model_id")

  return(card)
}

#' Get information about an antibiotic
#'
#' @param card output from `card_parse()`
#' @param ab character vector of antibiotic name(s)
#'
#' @export
#' @family "CARD/RGI"

card_ab_info <- function(card, ab) {

  # card must be a dataframe
  if (!is.data.frame(card)) {
    stop("<card> must be a dataframe", call. = F)
  }

  df <- card |>
    dplyr::filter(stringr::str_detect(tolower(category_aro_name), tolower(stringr::str_c(ab, collapse = "|")))) |>
    dplyr::select(antibiotic = category_aro_name, description = category_aro_description, category_aro_class_name) |>
    dplyr::arrange(antibiotic) |>
    unique()

  return(df)
}


#' Get gene information about an antibiotic
#'
#' @param card output from `card_parse()`
#' @param ab character vector of antibiotic name(s)
#' @param return "df" to return a dataframe, "gene" to return a character vector of gene names
#'
#' @export
#' @family "CARD/RGI"


card_ab2gene <- function(card, ab, return = "df") {

  # card must be a dataframe
  if (!is.data.frame(card)) {
    stop("<card> must be a dataframe", call. = F)
  }

  df <- card |>
    dplyr::filter(stringr::str_detect(tolower(category_aro_name), tolower(stringr::str_c(ab, collapse = "|")))) |>
    dplyr::arrange(ARO_name) |>
    dplyr::select(category_aro_name, ARO_name, category_aro_class_name) |>
    unique()

  if (return == "df") {
    return(df)
  } else if (return == "gene") {
    df |>
      dplyr::pull(ARO_name) |>
      unique()
  }
}

#' Get gene information about an antibiotic
#'
#' @param card output from `card_parse()`
#' @param gene character vector of gene name(s)
#'
#' @export
#' @family "CARD/RGI"

card_gene2ab <- function(card, gene) {

  # card must be a dataframe
  if (!is.data.frame(card)) {
    stop("<card> must be a dataframe", call. = F)
  }

  df <- card |>
    dplyr::filter(stringr::str_detect(tolower(ARO_name), tolower(stringr::str_c(gene, collapse = "|")))) |>
    dplyr::filter(category_aro_class_name != "Drug Class") |>
    dplyr::select(ARO_name, category_aro_accession, category_aro_name, category_aro_description, category_aro_class_name) |>
    unique() |>
    dplyr::arrange(category_aro_class_name, category_aro_name)

  return(df)
}



#' Get antibiotic information about a gene
#'
#' @param card output from `card_parse()`
#' @param gene character vector of gene name(s)
#'
#' @export
#' @family "CARD/RGI"

card_gene_info <- function(card, gene) {

  # card must be a dataframe
  if (!is.data.frame(card)) {
    stop("<card> must be a dataframe", call. = F)
  }

  df <- card |>
    dplyr::filter(stringr::str_detect(tolower(ARO_name), tolower(stringr::str_c(gene, collapse = "|")))) |>
    dplyr::select(ARO_name, ARO_description) |>
    unique() |>
    dplyr::arrange(ARO_name)

  return(df)
}
