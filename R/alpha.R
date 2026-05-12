#' Alpha-Diversity Measures
#'
#' An extension of the phyloseq `estimate_richness()` function to include
#' Shannon's Evenness and sample depth. It also combines the normal
#' estimate_richness output with the sample data dataframe.
#'
#' Although this new version removes much of the phyloseq code, running them
#' instead in Vegan or calculating manually, it does still require `phyloseq`
#' from bioconductor, which is not automatically installed with `jakR2`.
#'
#' @param p A phyloseq object
#' @param id_col The name of the column with sample IDs
#'
#' @return A tibble joining sample metadata with columns from [get_alpha_S()],
#'   [get_alpha_simpson()], and [get_alpha_shannon()].
#'
#' @export

get_alpha_diversity <- function(p, id_col = "SAMPLE") {
  p <- phyloseq::filter_taxa(p, function(x) sum(x >= 1) >= (1), TRUE)

  df <- phyloseq::otu_table(p) |>
    as.data.frame() |>
    tibble::rownames_to_column("feature_id") |>
    tibble::as_tibble()

  S <- get_alpha_S(df, feature_id = "feature_id", id_col = id_col)
  SIMPSON <- get_alpha_simpson(df, feature_id = "feature_id", id_col = id_col)
  SHANNON <- get_alpha_shannon(df, feature_id = "feature_id", id_col = id_col)

  sample_data <- data.frame(phyloseq::sample_data(p))

  if (id_col %in% colnames(data.frame(phyloseq::sample_data(p)))) {
    orig_name <- paste(id_col, "orig", sep = "_")

    sample_data <- data.frame(phyloseq::sample_data(p)) |>
      dplyr::rename(!!as.name(orig_name) := id_col) |>
      tibble::rownames_to_column(id_col) |>
      tibble::as_tibble()
  } else {
    sample_data <- data.frame(phyloseq::sample_data(p)) |>
      tibble::rownames_to_column(id_col) |>
      tibble::as_tibble()
  }

  dplyr::left_join(sample_data, S, by = id_col) |>
    dplyr::left_join(SIMPSON, by = id_col) |>
    dplyr::left_join(SHANNON, by = id_col)
}


#' Calculate richness (S) and sample depth
#'
#' Observed richness is counted directly; Chao1 and ACE are extrapolated
#' estimators of true richness based on the frequency of rare species. All
#' three are returned so downstream code can choose the appropriate measure.
#'
#' @param df A dataframe with features as rows and samples as columns
#' @param feature_id The name of the column with feature IDs
#'   (default is "feature_id")
#' @param id_col The name of the column with sample IDs (default is "SAMPLE")
#'
#' @return A tibble with one row per sample and columns:
#'   \describe{
#'     \item{sample_sum}{Total read count (sequencing depth)}
#'     \item{S.obs}{Observed species richness}
#'     \item{S.chao1}{Chao1 richness estimator}
#'     \item{se.chao1}{Standard error of Chao1}
#'     \item{S.ACE}{ACE richness estimator}
#'     \item{se.ACE}{Standard error of ACE}
#'   }
#'
#' @export

get_alpha_S <- function(df, feature_id = "feature_id", id_col = "SAMPLE") {
  sample_sums <- df |>
    tidyr::pivot_longer(
      cols = -{{ feature_id }}, names_to = id_col, values_to = "ABUNDANCE"
    ) |>
    dplyr::summarize(sample_sum = sum(ABUNDANCE), .by = dplyr::all_of(id_col))

  S <- df |>
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


#' Calculate Simpson's diversity, Gini-Simpson index, ENS, and evenness
#'
#' Computes four related measures from Simpson's D (sum of squared relative
#' abundances). Note that `GINI_SIMPSON` (1 - D) is a diversity index, not an
#' evenness measure — it is the probability that two randomly drawn
#' individuals belong to different species. True evenness is derived from the
#' number of species (`SIMPSON_ENS`).
#'
#' @param df A dataframe with features as rows and samples as columns
#' @param feature_id The name of the column with feature IDs
#'   (default is "feature_id")
#' @param id_col The name of the column with sample IDs (default is "SAMPLE")
#'
#' @return A tibble with one row per sample and columns:
#'   \describe{
#'     \item{SIMPSON_D}{Simpson's dominance index (sum of squared proportions);
#'       lower = more diverse}
#'     \item{GINI_SIMPSON}{Gini-Simpson index (1 - D); a diversity index,
#'       not evenness}
#'     \item{SIMPSON_ENS}{Effective number of species (1 / D); the q=2 Hill
#'       number; interpretable as the number of equally abundant dominant
#'       species that would yield the same D}
#'     \item{SIMPSON_ENS_EVENNESS}{ENS-based evenness (SIMPSON_ENS / S.obs);
#'       ranges from 1/S.obs (single dominant) to 1 (all species equal)}
#'   }
#'
#' @section Breaking changes:
#'   \describe{
#'     \item{SIMPSON_EVENNESS}{Previously `1 - SIMPSON_D` (Gini-Simpson index).
#'       Renamed to `GINI_SIMPSON`. The name `SIMPSON_EVENNESS` is no longer
#'       returned — old workflows using it will error rather than silently
#'       return wrong values.}
#'     \item{SIMPSON_INVERSE}{Renamed to `SIMPSON_ENS`. Old workflows using
#'       `SIMPSON_INVERSE` will error.}
#'   }
#'
#' @export

get_alpha_simpson <- function(df, feature_id = "feature_id", id_col = "SAMPLE") {
  S <- get_alpha_S(df, feature_id = feature_id, id_col = id_col)

  df |>
    tidyr::pivot_longer(
      cols = -{{ feature_id }}, names_to = id_col, values_to = "ABUNDANCE"
    ) |>
    dplyr::group_by_at(id_col) |>
    dplyr::mutate(Pi = ABUNDANCE / sum(ABUNDANCE)) |>
    dplyr::mutate(Pi2 = Pi^2) |>
    dplyr::summarise(SIMPSON_D = sum(Pi2), .groups = "drop") |>
    dplyr::mutate(GINI_SIMPSON = 1 - SIMPSON_D, SIMPSON_ENS = 1 / SIMPSON_D) |>
    dplyr::left_join(
      dplyr::select(S, dplyr::all_of(id_col), S.obs),
      by = id_col
    ) |>
    dplyr::mutate(SIMPSON_ENS_EVENNESS = SIMPSON_ENS / S.obs) |>
    dplyr::select(-S.obs)
}


#' Calculate Shannon's entropy, ENS, Pielou's evenness, and ENS-based evenness
#'
#' Shannon's H is an entropy (in nats), not a diversity. `SHANNON_ENS` converts
#' it to an effective number of species via exp(H) — the q=1 Hill number,
#' interpretable as the number of equally abundant species that would produce
#' the same entropy. Two evenness measures are returned: Pielou's J (widely
#' used, entropy-based) and an ENS-based evenness consistent with the Hill
#' number framework.
#'
#' @param df A dataframe with features as rows and samples as columns
#' @param feature_id The name of the column with feature IDs
#'   (default is "feature_id")
#' @param id_col The name of the column with sample IDs (default is "SAMPLE")
#'
#' @return A tibble with one row per sample and columns:
#'   \describe{
#'     \item{SHANNON_H}{Shannon entropy H (nats); an index, not a diversity}
#'     \item{SHANNON_ENS}{Effective number of species (exp(H)); the q=1
#'       Hill number}
#'     \item{SHANNON_PIELOU}{Pielou's J evenness (H / log(S.obs)); ratio of
#'       observed to maximum possible entropy}
#'     \item{SHANNON_EVENNESS}{ENS-based evenness (SHANNON_ENS / S.obs);
#'       ranges from 1/S.obs (single dominant) to 1 (all species equal)}
#'   }
#'
#' @export

get_alpha_shannon <- function(df, feature_id = "feature_id", id_col = "SAMPLE") {
  S <- get_alpha_S(df, feature_id = feature_id, id_col = id_col)

  df |>
    tidyr::pivot_longer(
      cols = -{{ feature_id }}, names_to = id_col, values_to = "ABUNDANCE"
    ) |>
    dplyr::group_by_at(id_col) |>
    dplyr::mutate(Pi = ABUNDANCE / sum(ABUNDANCE)) |>
    dplyr::filter(Pi > 0) |>
    dplyr::summarise(SHANNON_H = -sum(Pi * log(Pi)), .groups = "drop") |>
    dplyr::mutate(SHANNON_ENS = exp(SHANNON_H)) |>
    dplyr::left_join(S, by = id_col) |>
    dplyr::mutate(
      SHANNON_PIELOU = SHANNON_H / log(S.obs),
      SHANNON_EVENNESS = SHANNON_ENS / S.obs
    ) |>
    dplyr::select(
      dplyr::all_of(id_col), SHANNON_H, SHANNON_ENS,
      SHANNON_PIELOU, SHANNON_EVENNESS
    )
}
