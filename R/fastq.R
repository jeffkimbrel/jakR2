#' Summarize a fastq_info file
#'
#' @param file Path to output from fastq_info.py
#' @param fill Color to use for the histogram
#'
#' @export

fastq_info_summary <- function(file, fill = "cornflowerblue") {

  if (!file.exists(file)) {
    stop("The file does not exist: ", file)
  }

  df <- readr::read_delim(file, delim = "\t", comment = "#", show_col_types = FALSE) |>
    dplyr::mutate(PAIR = dplyr::case_when(
      PAIR == "F" ~ "Forward",
      PAIR == "R" ~ "Reverse"
    )) |>
    dplyr::arrange(SAMPLE)

  sample_count <- length(unique(df$SAMPLE))

  # do the F and R read counts match?
  pair_count_match <- df |>
    dplyr::select(-FILE, -INDEX, -MD5, -RUN_INFO) |>
    tidyr::pivot_wider(names_from = PAIR, values_from = TOTAL_READS) |>
    dplyr::mutate(MM = dplyr::case_when(
      Forward == Reverse ~ TRUE,
      TRUE ~ FALSE
    ))

  good_pairs <- pair_count_match |>
    dplyr::filter(MM == TRUE)

  if (nrow(good_pairs) == sample_count) {
    message(crayon::green("Read counts match between F and R files for all samples"))
  } else {
    bad_pairs <- pair_count_match |>
      dplyr::filter(MM == "FALSE") |>
      dplyr::pull(SAMPLE)

    message(crayon::yellow("Some samples had read counts that do not match between F and R"))

    for (pair in bad_pairs) {
      message(crayon::yellow(pair))
    }
  }

  # is there one and only one RUN id?
  run_id <- df |>
    dplyr::select(-INDEX, -FILE, -MD5, -TYPE, -PAIR, -TOTAL_READS) |>
    dplyr::mutate(RUN_INFO = gsub("\'", "\"", RUN_INFO)) |>
    dplyr::mutate(json = purrr::map(RUN_INFO, ~ jsonlite::fromJSON(.) |> as.data.frame())) |>
    tidyr::unnest(json) |>
    tidyr::pivot_longer(cols = c(everything(), -SAMPLE, -RUN_INFO), names_to = "RUN_ID", values_to = "READS", values_drop_na = TRUE) |>
    dplyr::group_by(RUN_ID) |>
    dplyr::summarise(TOTAL_READS = sum(READS))

  if (nrow(run_id) > 1) {
    message(crayon::yellow("These fastq files were run on different Illumina Runs"))
  } else {
    message(crayon::green("All reads appear to be from the same Illumina Run"))
  }

  s <- df |>
    dplyr::group_by(SAMPLE) |>
    dplyr::summarise(TOTAL_READS = sum(TOTAL_READS)) |>
    dplyr::pull(TOTAL_READS) |>
    pastecs::stat.desc(norm = F)

  s_for_return <- s |>
    as.data.frame() |>
    tibble::rownames_to_column("METRIC") |>
    dplyr::rename("VALUE" = "s")

  p <- df |>
    dplyr::summarise(TOTAL_READS = sum(TOTAL_READS), .by = SAMPLE) |>
    dplyr::mutate(DIFF_FROM_MEAN = TOTAL_READS - mean(TOTAL_READS)) |>
    ggplot2::ggplot(ggplot2::aes(x = TOTAL_READS)) +
    ggplot2::geom_histogram(bins = ceiling(sample_count / 10), fill = fill) +
    ggplot2::labs(x = "Total Reads (log10)",
                  y = "Count of Samples") +
    ggplot2::scale_x_continuous(labels = function(x) format(x, big.mark = ",", decimal.mark = ".", scientific = FALSE), trans = "log10")


  list(
    "run_id" = run_id,
    "stats" = s_for_return,
    "pairs" = pair_count_match,
    "plot" = p
  )

}




#' Summarize a fastq_filter.py file in amplicon mode
#'
#' @export
#' @param file Output from fastq_filter.py


fastq_filter_summary_amplicon <- function(file) {
  df <- readr::read_delim(file, delim = "\t", comment = "#", show_col_types = F) |>
    dplyr::select(SAMPLE, ORDER_VERIFIED, CF_READS_OUT, CF_READS_REMOVED, CF_BP_OUT, CF_BP_REMOVED) |>
    tidyr::pivot_longer(cols = c(CF_READS_OUT, CF_READS_REMOVED, CF_BP_OUT, CF_BP_REMOVED))

  a <- df |>
    tidyr::separate(name, into = c("FILTER", "TYPE", "STEP")) |>
    ggplot2::ggplot(ggplot2::aes(x = reorder(SAMPLE, -value), y = value, fill = STEP)) +
    ggplot2::geom_point(pch = 21, size = 2) +
    ggplot2::geom_line(ggplot2::aes(group = STEP, color = STEP)) +
    ggplot2::facet_wrap(~TYPE, scales = "free_y", ncol = 1) +
    ggplot2::labs(x = "Sample", y = "Reads") +
    ggplot2::scale_fill_manual(values = c("OUT" = "gray50", "REMOVED" = "orange")) +
    ggplot2::scale_color_manual(values = c("OUT" = "gray50", "REMOVED" = "orange")) +
    ggplot2::theme(panel.grid.major = ggplot2::element_line(color = NA)) +
    ggplot2::scale_y_continuous(labels = function(x) format(x, big.mark = ",", decimal.mark = ".", scientific = FALSE))



  b <- df |>
    tidyr::separate(name, into = c("FILTER", "TYPE", "STEP")) |>
    dplyr::select(-FILTER) |>
    tidyr::pivot_wider(names_from = STEP, values_from = value) |>
    dplyr::mutate(REMOVED = 100 * REMOVED / (OUT + REMOVED)) |>
    ggplot2::ggplot(ggplot2::aes(x = reorder(SAMPLE, -REMOVED), y = REMOVED, fill = REMOVED)) +
    ggplot2::geom_line(ggplot2::aes(group = TYPE), color = "gray50") +
    ggplot2::geom_point(pch = 21, size = 2) +
    ggplot2::facet_wrap(~TYPE, scales = "free_y", ncol = 1) +
    ggplot2::scale_fill_viridis_c() +
    ggplot2::labs(x = "Sample", y = "Reads Removed (%)") +
    ggplot2::theme(panel.grid.major = ggplot2::element_line(color = NA),
                   legend.position = "none")

  df_final <- df |>
    tidyr::pivot_wider(names_from = name, values_from = value)

  list("filtered" = a, "reads_removed" = b, "df" = df_final)
}

#' Summarize a fastq_filter.py file in metagenome mode
#'
#' @export
#' @param file Output from fastq_filter.py

fastq_filter_summary_meta <- function(file) {
  df <- readr::read_tsv(file, comment = "#") |>
    dplyr::select(-ORDER_VERIFIED) |>
    tidyr::pivot_longer(cols = c(everything(), -SAMPLE))

  reads <- df |>
    tidyr::separate(name, into = c("STEP", "TYPE", "RESULT"), sep = "_") |>
    dplyr::arrange(SAMPLE, STEP, TYPE, RESULT) |>
    dplyr::filter(RESULT %in% c("OUT", "REMOVED")) |>
    dplyr::filter(TYPE == "READS") |>
    dplyr::mutate(STEP = forcats::fct_relevel(STEP, c("RT", "CF", "QF"))) |>
    dplyr::mutate(RESULT = forcats::fct_relevel(RESULT, c("REMOVED", "OUT"))) |>
    ggplot2::ggplot(ggplot2::aes(x = STEP, y = value, fill = RESULT)) +
    ggplot2::geom_col() +
    ggplot2::facet_wrap(TYPE ~ SAMPLE, scales = "free_y") +
    jakR::jak_theme() +
    ggplot2::scale_y_log10() +
    ggplot2::scale_fill_manual(values = c("OUT" = "gray30", "REMOVED" = "orange"))

  bp <- df |>
    tidyr::separate(name, into = c("STEP", "TYPE", "RESULT"), sep = "_") |>
    dplyr::arrange(SAMPLE, STEP, TYPE, RESULT) |>
    dplyr::filter(RESULT %in% c("OUT", "REMOVED")) |>
    dplyr::filter(TYPE == "BP") |>
    dplyr::mutate(STEP = forcats::fct_relevel(STEP, c("RT", "CF", "QF"))) |>
    dplyr::mutate(RESULT = forcats::fct_relevel(RESULT, c("REMOVED", "OUT"))) |>
    ggplot2::ggplot(ggplot2::aes(x = STEP, y = value, fill = RESULT)) +
    ggplot2::geom_col() +
    ggplot2::facet_wrap(TYPE ~ SAMPLE, scales = "free_y") +
    jakR::jak_theme() +
    ggplot2::scale_y_log10() +
    ggplot2::scale_fill_manual(values = c("OUT" = "gray30", "REMOVED" = "orange"))


  list("reads" = reads, "bp" = bp, "df" = df)
}
