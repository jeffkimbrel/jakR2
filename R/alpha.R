#' Alpha-Diversity Measures
#'
#' An extension of the phyloseq `estimate_richness()` function to include Shannon's
#' Evenness and sample depth. It also combines the normal estimate_richness output
#' with the sample data dataframe.
#'
#' Although this new version removes much of the phyloseq code, running them instead
#' in Vegan or calculating manually, it does still require `phyloseq` from bioconductor,
#' which is not automatically installed with `jakR2` installation.
#'
#' @param p A phyloseq object
#' @param id_col The name of the column with sample IDs
#'
#' @export

get_alpha_diversity = function (p, id_col = "SAMPLE") {

  p = phyloseq::filter_taxa(p, function(x) sum(x >= 1) >= (1), TRUE)

  df = otu_table(p) |>
    as.data.frame() |>
    tibble::rownames_to_column("feature_id") |>
    tibble::as_tibble()

  S = get_alpha_S(df, feature_id = "feature_id", id_col = id_col)
  SIMPSON = get_alpha_simpson(df, feature_id = "feature_id", id_col = id_col)
  SHANNON = get_alpha_shannon(df, feature_id = "feature_id", id_col = id_col)

  sample_data = data.frame(sample_data(p))

  if (id_col %in% colnames(data.frame(sample_data(p)))) {

    orig_name = paste(id_col, "orig", sep = "_")

    sample_data = data.frame(sample_data(p)) |>
      dplyr::rename(!!as.name(orig_name) := id_col) |>
      tibble::rownames_to_column(id_col) |>
      tibble::as_tibble()
  } else {
    sample_data = data.frame(sample_data(p)) |>
      tibble::rownames_to_column(id_col) |>
      tibble::as_tibble()
  }

  dplyr::left_join(sample_data, S, by = id_col) |>
    dplyr::left_join(SIMPSON, by = id_col) |>
    dplyr::left_join(SHANNON, by = id_col)

}





#' Calculate richness (S) and sample depth
#'
#' @param df A dataframe with features as rows and samples as columns
#' @param feature_id The name of the column with feature IDs (default is "feature_id")
#' @param id_col The name of the column with sample IDs (default is "SAMPLE")
#'
#' @export

get_alpha_S = function(df, feature_id = "feature_id", id_col = "SAMPLE") {

  sample_sums = df |>
    tidyr::pivot_longer(cols = -{{feature_id}}, names_to = id_col, values_to = "ABUNDANCE") |>
    dplyr::summarize(sample_sum = sum(ABUNDANCE), .by = id_col)

  S = df |>
    tibble::column_to_rownames(feature_id) |>
    t() |>
    vegan::estimateR() |>
    as.data.frame() |>
    t() |>
    as.data.frame() |>
    tibble::rownames_to_column(id_col) |>
    tibble::as_tibble()


  dplyr::left_join(sample_sums, S, by = id_col)
}


#' Calculate Simpson's diversity index and its evenness and inverse
#'
#' @param df A dataframe with features as rows and samples as columns
#' @param feature_id The name of the column with feature IDs (default is "feature_id")
#' @param id_col The name of the column with sample IDs (default is "SAMPLE")
#'
#' @export

get_alpha_simpson = function(df, feature_id = "feature_id", id_col = "SAMPLE") {

  df |>
    tidyr::pivot_longer(cols = -{{feature_id}}, names_to = id_col, values_to = "ABUNDANCE") |>
    dplyr::group_by_at(id_col) |>
    dplyr::mutate(Pi = ABUNDANCE / sum(ABUNDANCE)) |>
    dplyr::left_join(S, by = id_col) |>
    dplyr::mutate(Pi2 = Pi ^ 2) |>
    dplyr::group_by_at(id_col) |>
    dplyr::summarise(SIMPSON_D = sum(Pi2), .groups = 'drop') |>
    dplyr::mutate(SIMPSON_EVENNESS = 1 - SIMPSON_D, SIMPSON_INVERSE = 1 / SIMPSON_D)
}





#' Calculate Shannon's diversity index and its evenness and effective number of species (ENS)
#'
#' @param df A dataframe with features as rows and samples as columns
#' @param feature_id The name of the column with feature IDs (default is "feature_id")
#' @param id_col The name of the column with sample IDs (default is "SAMPLE")
#'
#' @export

get_alpha_shannon = function(df, feature_id = "feature_id", id_col = "SAMPLE") {

  S = get_alpha_S(df, id_col = id_col)

  df |>
    tidyr::pivot_longer(cols = -{{feature_id}}, names_to = id_col, values_to = "ABUNDANCE") |>
    dplyr::group_by_at(id_col) |>
    dplyr::mutate(Pi = ABUNDANCE / sum(ABUNDANCE)) |>
    dplyr::filter(Pi > 0) |>
    dplyr::summarise(SHANNON_H = -sum(Pi*log(Pi)), .groups = 'drop') |>
    dplyr::mutate(SHANNON_ENS = exp(SHANNON_H)) |>
    dplyr::left_join(S, by = id_col) |>
    dplyr::mutate(SHANNON_E = SHANNON_H / log(S.obs)) |>
    dplyr::select(id_col, SHANNON_H, SHANNON_ENS, SHANNON_E)
}
