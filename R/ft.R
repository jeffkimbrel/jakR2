#' Make ft object from DADA2 seqtab
#'
#' @param seqtab A DADA2 sequence table (matrix) with ASVs as columns and samples as rows
#' @param clean A string to remove from the sample names in the feature table (default is "_F_filt.fastq.gz")
#' @param name (default: ASV) A string to use as a feature name. Include an underscore (or other separator) if desired
#'
#' @export

seqtab_to_ft <- function(seqtab,
                         clean = "_F_filt.fastq.gz",
                         name = "ASV") {
  feature_table <- phyloseq::otu_table(seqtab, taxa_are_rows = FALSE) |>
    t() |>
    as.data.frame() |>
    tibble::rownames_to_column("SEQUENCE") |>
    tibble::as_tibble() |>
    dplyr::mutate(ASV = paste0(name, seq(dplyr::n()))) |>
    dplyr::select(ASV, tidyselect::everything())

  names(feature_table) <- gsub(clean, "", names(feature_table))

  ft(
    table = feature_table,
    clusters = data.frame(),
    filter = list(),
    merge = list(is_merged = FALSE),
    source = list(
      type = "seqtab",
      created = Sys.time()
    )
  )
}

#' Feature table class
#'
#' This class represents a feature table (ft) object, which contains a table of ASVs and their sequences,
#' along with optional clustering information and filtering parameters.
#'
#' @param table A data frame containing the feature table with ASVs and sequences.
#' @param clusters A data frame containing cluster assignments, populated by [cluster_asv_table()].
#' @param filter A list containing filtering parameters applied to the table, populated by [filter_asv_table()].
#'
#' @usage NULL
#' @export


ft <- S7::new_class("ft",
  properties = list(
    table = S7::class_data.frame,
    clusters = S7::class_data.frame,
    filter = S7::class_list,
    merge = S7::class_list,  # Merge provenance information
    source = S7::class_list  # Source provenance (files, objects, etc.)
  ),
  validator = function(self) {
    if (!all(c("ASV", "SEQUENCE") %in% names(self@table))) {
      stop("Feature table must contain 'ASV' and 'SEQUENCE' columns", call. = F)
    }

    # ASV column must contain only unique values
    if (any(duplicated(self@table$ASV))) {
      stop("ASV column appears to contain duplicates", call. = F)
    }
  }
)

#' @export
get_asv_table <- S7::new_generic("get_asv_table", "x")

#' Return ASV table from ft object
#'
#' @param x An ft object
#'
#' @export
#' @name get_asv_table

S7::method(get_asv_table, ft) <- function(x) {
  S7::prop(x, "table") |>
    dplyr::select(-SEQUENCE)
}

#' @export
get_sequences <- S7::new_generic("get_sequences", "x")

#' Return DNAstring object from ft object
#'
#' @param x An ft object
#'
#' @export
#' @name get_sequences

S7::method(get_sequences, ft) <- function(x) {
  dna <- Biostrings::DNAStringSet(S7::prop(x, "table")$SEQUENCE)
  names(dna) <- S7::prop(x, "table")$ASV
  return(dna)
}

#' @export
filter_asv_table <- S7::new_generic("filter_asv_table", "x")

#' Filter an ft object by minimum count and sample
#'
#' @param x An ft object
#' @param min_count Minimum count for an ASV to be retained (default is 2)
#' @param min_sample Minimum number of samples an ASV must be present in to be retained (default is 2)
#'
#' @export
#' @name filter_asv_table

S7::method(filter_asv_table, ft) <- function(x, min_count = 2, min_sample = 2) {
  # min_count should be a positive integer
  if (!is.numeric(min_count) || min_count < 1 || min_count != round(min_count)) {
    stop("<min_count> must be a positive integer", call. = F)
  }

  # min_sample should be a positive integer
  if (!is.numeric(min_sample) || min_sample < 1 || min_sample != round(min_sample)) {
    stop("<min_sample> must be a positive integer", call. = F)
  }


  original_table <- S7::prop(x, "table")
  original_counts <- original_table |>
    dplyr::select(-ASV, -SEQUENCE) |>
    sum()

  filtered_table <- original_table |>
    tidyr::pivot_longer(cols = -c(ASV, SEQUENCE), names_to = "SAMPLE", values_to = "COUNT") |>
    dplyr::filter(COUNT >= min_count) |>
    dplyr::mutate(n = dplyr::n(), .by = c(SEQUENCE, ASV)) |>
    dplyr::filter(n >= min_sample) |>
    dplyr::select(-n) |>
    tidyr::pivot_wider(names_from = SAMPLE, values_from = COUNT, values_fill = 0) |>
    ft()

  filtered_counts <- S7::prop(filtered_table, "table") |>
    dplyr::select(-ASV, -SEQUENCE) |>
    sum()

  original_features <- nrow(original_table)
  filtered_features <- nrow(filtered_table@table)

  # set filter property with parameters
  filtered_table@filter <- list(
    min_count = min_count,
    min_sample = min_sample,
    original_counts = original_counts,
    filtered_counts = filtered_counts,
    original_features = original_features,
    filtered_features = filtered_features
  )

  cli::cli_text("{.green New table has {formatC(100*filtered_features / original_features, format = 'f', digits = 2)}% of the original features ({filtered_features}/{original_features})}")
  cli::cli_text("{.green New table has {formatC(100*filtered_counts / original_counts, format = 'f', digits = 2)}% of the original abundance ({filtered_counts}/{original_counts})}")

  return(filtered_table)
}


#' @export
cluster_asv_table <- S7::new_generic("cluster_asv_table", "x")

#' Cluster ASV sequences from ft object
#'
#' @param x An ft object
#' @param id Numeric value between 0 and 1 representing the clustering threshold (default is 0.99)
#' @param nproc Number of processors to use for parallel processing (default is 1)
#' @param quiet Logical, whether to suppress verbose output (default is TRUE)
#'
#' @export
#' @name cluster_asv_table

S7::method(cluster_asv_table, ft) <- function(x, id = 0.99, nproc = 1, quiet = TRUE) {
  if (!quiet) {
    verbose <- TRUE
  } else {
    verbose <- FALSE
  }

  # id should be a numeric value between 0 and 1
  if (!is.numeric(id) || id < 0 || id > 1) {
    stop("<id> must be a numeric value between 0 and 1", call. = F)
  }

  # give warning if id is less than 0.9
  if (id < 0.9) {
    cli::cli_warn("<id> of {id} may result in over-clustering, consider using a higher value (e.g., 0.97 or 0.99)")
  }

  # nproc should be a positive integer
  if (!is.numeric(nproc) || nproc < 1 || nproc != round(nproc)) {
    stop("<nproc> must be a positive integer", call. = F)
  }

  table <- S7::prop(x, "table")

  dna <- Biostrings::DNAStringSet(table$SEQUENCE)
  names(dna) <- table$ASV
  aln <- DECIPHER::AlignSeqs(dna,
    processors = nproc,
    verbose = verbose
  )
  d <- DECIPHER::DistanceMatrix(aln,
    processors = nproc,
    verbose = verbose
  )
  clusters <- DECIPHER::Treeline(
    myDistMatrix = d,
    method = "complete",
    cutoff = 1 - id,
    type = "clusters",
    processors = nproc,
    verbose = verbose
  ) |>
    tibble::rownames_to_column("ASV")

  x@clusters <- clusters

  seqs <- table |>
    dplyr::select(ASV, SEQUENCE)

  x@table <- table |>
    dplyr::select(-SEQUENCE) |>
    tidyr::pivot_longer(-ASV) |>
    dplyr::left_join(clusters, by = dplyr::join_by(ASV)) |>
    dplyr::arrange(name) |>
    dplyr::mutate(asv_sum = sum(value), .by = ASV) |>
    dplyr::mutate(cluster_sum = sum(value), .by = c(name, cluster)) |>
    dplyr::select(-value) |>
    dplyr::slice_max(
      n = 1,
      order_by = asv_sum,
      by = c("name", "cluster")
    ) |>
    dplyr::select(-cluster, -asv_sum) |>
    tidyr::pivot_wider(names_from = name, values_from = cluster_sum, values_fill = 0) |>
    dplyr::left_join(seqs, by = dplyr::join_by(ASV)) |>
    dplyr::select(ASV, SEQUENCE, tidyselect::everything())

  return(x)
}



#' Load ft object from FASTA and ASV table files
#'
#' Helper function to create a jakR2::ft object from separate FASTA (sequences)
#' and ASV table (abundance) files on disk.
#'
#' @param fasta_file Path to FASTA file with sequences (headers = ASV names)
#' @param asv_table_file Path to ASV table file (CSV or TSV)
#'   First column = ASV names, remaining columns = sample abundances
#' @param name Name for the ft object
#' @param sep Delimiter for asv_table_file ("," for CSV, "\t" for TSV, "auto" to detect)
#'
#' @return A jakR2::ft object
#' @export

load_ft_from_files <- function(
  fasta_file,
  asv_table_file,
  name = "ft",
  sep = "auto"
) {

  if (!requireNamespace("Biostrings", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg Biostrings} needed to read FASTA")
  }

  if (!requireNamespace("jakR2", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg jakR2} needed to create ft object")
  }

  # Read FASTA
  cli::cli_alert_info("Reading FASTA: {basename(fasta_file)}")
  seqs <- Biostrings::readDNAStringSet(fasta_file)

  # Extract ASV names from FASTA headers
  asv_names <- names(seqs)
  sequences <- as.character(seqs)
  names(sequences) <- asv_names

  cli::cli_alert_success("Loaded {length(sequences)} sequences")

  # Read ASV table
  cli::cli_alert_info("Reading ASV table: {basename(asv_table_file)}")

  if (sep == "auto") {
    # Detect delimiter from file extension or first line
    if (grepl("\\.csv$", asv_table_file, ignore.case = TRUE)) {
      sep <- ","
    } else if (grepl("\\.tsv$|\\.txt$", asv_table_file, ignore.case = TRUE)) {
      sep <- "\t"
    } else {
      # Read first line to detect
      first_line <- readLines(asv_table_file, n = 1)
      if (grepl(",", first_line)) {
        sep <- ","
      } else {
        sep <- "\t"
      }
    }
    cli::cli_alert_info("Detected delimiter: '{sep}'")
  }

  asv_table <- readr::read_delim(asv_table_file, delim = sep, show_col_types = FALSE)

  # First column should be ASV names
  asv_col <- names(asv_table)[1]
  sample_cols <- names(asv_table)[-1]

  cli::cli_alert_success("Loaded {nrow(asv_table)} ASVs × {length(sample_cols)} samples")

  # Check that ASVs match between FASTA and table
  table_asvs <- asv_table[[asv_col]]
  fasta_asvs <- asv_names

  in_both <- intersect(table_asvs, fasta_asvs)
  only_table <- setdiff(table_asvs, fasta_asvs)
  only_fasta <- setdiff(fasta_asvs, table_asvs)

  if (length(only_table) > 0) {
    cli::cli_alert_warning("{length(only_table)} ASV{?s} in table but not in FASTA")
    cli::cli_alert_info("  Examples: {paste(head(only_table, 3), collapse = ', ')}")
  }

  if (length(only_fasta) > 0) {
    cli::cli_alert_warning("{length(only_fasta)} sequence{?s} in FASTA but not in table")
    cli::cli_alert_info("  Examples: {paste(head(only_fasta, 3), collapse = ', ')}")
  }

  if (length(in_both) == 0) {
    cli::cli_abort("No matching ASVs between FASTA and table!")
  }

  # Filter to matching ASVs only
  asv_table_filtered <- asv_table %>%
    dplyr::filter(.data[[asv_col]] %in% in_both)

  sequences_filtered <- sequences[in_both]

  cli::cli_alert_info("Using {length(in_both)} ASVs present in both files")

  # Build ft table: ASV, SEQUENCE, sample1, sample2, ...
  cli::cli_alert_info("Creating ft object")

  # Start with ASV names and sequences
  ft_table <- tibble::tibble(
    ASV = names(sequences_filtered),
    SEQUENCE = as.character(sequences_filtered)
  )

  # Add ASV column to abundance table for joining
  abundance_with_asv <- asv_table_filtered
  colnames(abundance_with_asv)[1] <- "ASV"

  # Join by ASV to maintain order and add abundance columns
  ft_table <- dplyr::left_join(ft_table, abundance_with_asv, by = "ASV")

  # Create ft object
  ft <- jakR2::ft(
    table = ft_table,
    clusters = data.frame(),
    filter = list(),
    merge = list(is_merged = FALSE),
    source = list(
      type = "files",
      fasta_file = normalizePath(fasta_file),
      asv_table_file = normalizePath(asv_table_file),
      created = Sys.time()
    )
  )

  cli::cli_alert_success("ft object created: {name}")

  return(ft)
}
