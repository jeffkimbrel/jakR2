#' Merge multiple feature tables with sequence matching
#'
#' Combines a reference ft object with one or more new ft objects. Sequences
#' that match the reference retain their original names; novel sequences are
#' assigned new names with a user-specified prefix.
#'
#' @param reference_ft Feature table (ft object) with established feature names
#' @param new_fts Single ft object or list of ft objects to merge into reference
#' @param new_prefix Character string prefix for novel sequences (e.g., "ASV_new_").
#'   Must not create collisions with existing reference names.
#' @param sample_collision Strategy for handling duplicate sample names:
#'   \itemize{
#'     \item "error" (default): Abort if any sample names collide
#'     \item "suffix": Append source identifier to new ft sample names
#'     \item "prefix": Prepend source identifier to new ft sample names
#'   }
#'
#' @return A merged ft object containing:
#'   \item{sequences}{All unique sequences with unified names}
#'   \item{abundance}{Combined abundance table across all samples}
#'   \item{metadata}{Merge statistics and provenance}
#'
#' @details
#' The reference ft remains unchanged - its feature names and sample names are
#' preserved exactly. New sequences are numbered starting from 1 with the
#' user-provided prefix.
#'
#' Feature naming logic:
#' \itemize{
#'   \item Sequences matching reference: use reference name (e.g., "ASV1")
#'   \item Novel sequences: use new_prefix + counter (e.g., "ASV_new_1", "ASV_new_2")
#' }
#'
#' The function validates that generated names won't collide with reference names.
#' If a collision is detected, the merge aborts with an error suggesting a
#' different prefix.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Reference has ASV1-ASV711
#' # New data has some matching sequences and some novel ones
#' merged <- merge_ft(
#'   reference_ft = ref,
#'   new_fts = list(run1, run2),
#'   new_prefix = "ASV_2024_"
#' )
#'
#' # Result contains:
#' # - ASV1-ASV711 (original names for matching sequences)
#' # - ASV_2024_1, ASV_2024_2, ... (novel sequences)
#' }
merge_ft <- function(
  reference_ft,
  new_fts,
  new_prefix,
  sample_collision = c("error", "suffix", "prefix")
) {

  # Validate inputs
  sample_collision <- match.arg(sample_collision)

  if (!inherits(reference_ft, "jakR2::ft")) {
    cli::cli_abort("reference_ft must be a jakR2::ft object")
  }

  # Coerce single ft to list
  if (inherits(new_fts, "jakR2::ft")) {
    new_fts <- list(new_fts)
  }

  if (!all(sapply(new_fts, function(x) inherits(x, "jakR2::ft")))) {
    cli::cli_abort("All new_fts must be jakR2::ft objects")
  }

  if (missing(new_prefix) || is.null(new_prefix) || new_prefix == "") {
    cli::cli_abort("new_prefix is required and cannot be empty")
  }

  cli::cli_h2("Merging feature tables")

  # Count samples properly (exclude ASV and SEQUENCE columns)
  ref_n_samples <- length(setdiff(colnames(reference_ft@table), c("ASV", "SEQUENCE")))
  ref_n_features <- nrow(reference_ft@table)

  cli::cli_alert_info("Reference: {ref_n_features} features, {ref_n_samples} samples")
  cli::cli_alert_info("Merging {length(new_fts)} new ft object{?s}")

  # Step 1: Check sample name collisions
  cli::cli_alert_info("Checking for sample name collisions")

  # Get sample names (all columns except ASV and SEQUENCE)
  ref_table <- get_asv_table(reference_ft)
  ref_samples <- setdiff(colnames(ref_table), c("ASV", "SEQUENCE"))

  new_samples_list <- lapply(seq_along(new_fts), function(i) {
    table <- get_asv_table(new_fts[[i]])
    samples <- setdiff(colnames(table), c("ASV", "SEQUENCE"))
    list(idx = i, samples = samples)
  })

  all_new_samples <- unlist(lapply(new_samples_list, function(x) x$samples))

  # Check for collisions
  ref_collisions <- intersect(ref_samples, all_new_samples)
  new_internal_collisions <- all_new_samples[duplicated(all_new_samples)]

  if (length(ref_collisions) > 0 || length(new_internal_collisions) > 0) {
    if (sample_collision == "error") {
      msg <- c(
        "Sample name collisions detected:",
        if (length(ref_collisions) > 0) paste0("  Reference vs new: ", paste(head(ref_collisions, 5), collapse = ", ")),
        if (length(new_internal_collisions) > 0) paste0("  Between new fts: ", paste(head(unique(new_internal_collisions), 5), collapse = ", ")),
        "i" = "Use sample_collision = 'suffix' or 'prefix' to resolve automatically"
      )
      cli::cli_abort(msg)
    } else if (sample_collision == "suffix") {
      # Rename sample columns in new_fts with suffix (preserve ASV and SEQUENCE)
      for (i in seq_along(new_fts)) {
        table <- new_fts[[i]]@table
        sample_cols <- setdiff(colnames(table), c("ASV", "SEQUENCE"))
        colnames(table)[colnames(table) %in% sample_cols] <- paste0(sample_cols, "_new", i)
        new_fts[[i]]@table <- table
      }
      cli::cli_alert_warning("Renamed samples in new fts with suffix: _new1, _new2, ...")
    } else if (sample_collision == "prefix") {
      # Rename sample columns in new_fts with prefix (preserve ASV and SEQUENCE)
      for (i in seq_along(new_fts)) {
        table <- new_fts[[i]]@table
        sample_cols <- setdiff(colnames(table), c("ASV", "SEQUENCE"))
        colnames(table)[colnames(table) %in% sample_cols] <- paste0("new", i, "_", sample_cols)
        new_fts[[i]]@table <- table
      }
      cli::cli_alert_warning("Renamed samples in new fts with prefix: new1_, new2_, ...")
    }
  } else {
    cli::cli_alert_success("No sample name collisions detected")
  }

  # Step 2: Build sequence → name mapping from reference
  cli::cli_alert_info("Building sequence mapping from reference")

  ref_seqs <- get_sequences(reference_ft)
  ref_names <- names(ref_seqs)
  seq_to_name <- setNames(ref_names, as.character(ref_seqs))
  existing_names <- ref_names

  # Track statistics
  n_matched <- 0
  n_novel <- 0
  new_counter <- 1

  # Step 3: Process sequences from new fts
  cli::cli_alert_info("Processing sequences from new ft objects")

  for (i in seq_along(new_fts)) {
    ft <- new_fts[[i]]
    new_seqs <- get_sequences(ft)

    cli::cli_alert_info("  Processing ft {i}/{length(new_fts)}: {length(new_seqs)} sequences")

    for (seq in as.character(new_seqs)) {
      if (seq %in% names(seq_to_name)) {
        # Match - use existing name
        n_matched <- n_matched + 1
      } else {
        # Novel - generate new name
        new_name <- paste0(new_prefix, new_counter)

        # Check for collision with reference names
        if (new_name %in% existing_names) {
          # Find examples of colliding names
          collision_examples <- head(ref_names[grepl(paste0("^", gsub("\\.", "\\\\.", new_prefix)), ref_names)], 3)
          cli::cli_abort(c(
            "Name collision detected!",
            "x" = "Generated name '{new_name}' already exists in reference",
            "i" = "Reference contains: {paste(collision_examples, collapse = ', ')}",
            "i" = "Choose a different new_prefix that won't collide"
          ))
        }

        # Safe to add
        seq_to_name[seq] <- new_name
        existing_names <- c(existing_names, new_name)
        new_counter <- new_counter + 1
        n_novel <- n_novel + 1
      }
    }
  }

  cli::cli_alert_success("Sequence mapping complete:")
  cli::cli_alert_info("  {n_matched} sequence{?s} matched reference")
  cli::cli_alert_info("  {n_novel} novel sequence{?s} assigned new names")

  # Step 4: Build unified ft table
  cli::cli_alert_info("Building unified ft table")

  # Start with reference table
  ref_table <- reference_ft@table

  # Process each new ft and rename ASV column to unified names
  all_tables <- list(ref_table)

  for (i in seq_along(new_fts)) {
    ft <- new_fts[[i]]
    ft_table <- ft@table

    # Map old ASV names to unified names based on sequences
    ft_table$ASV <- sapply(ft_table$SEQUENCE, function(seq) seq_to_name[as.character(seq)])

    all_tables[[i + 1]] <- ft_table
  }

  # Combine all tables
  combined_table <- dplyr::bind_rows(all_tables)

  # Fill NAs with 0 (samples not present in some fts)
  sample_cols <- setdiff(colnames(combined_table), c("ASV", "SEQUENCE"))
  combined_table[, sample_cols][is.na(combined_table[, sample_cols])] <- 0

  # Sum abundances for features that appear in multiple fts (same ASV name)
  # Group by ASV and SEQUENCE, sum sample columns
  merged_table <- combined_table %>%
    dplyr::group_by(ASV, SEQUENCE) %>%
    dplyr::summarise(dplyr::across(dplyr::all_of(sample_cols), sum), .groups = "drop")

  # Step 5: Build merge provenance
  cli::cli_alert_info("Building merge provenance")

  # Helper to extract meaningful name from ft source
  get_ft_name <- function(ft) {
    if (!is.null(ft@source$type)) {
      if (ft@source$type == "files" && !is.null(ft@source$fasta_file)) {
        # Use basename of FASTA file without extension
        return(tools::file_path_sans_ext(basename(ft@source$fasta_file)))
      } else if (ft@source$type == "merge") {
        return("merged_ft")
      } else if (ft@source$type == "seqtab") {
        return("seqtab")
      }
    }
    return("unknown")
  }

  # Get sample provenance with meaningful names
  ref_name <- get_ft_name(reference_ft)
  ref_samples <- setdiff(colnames(ref_table), c("ASV", "SEQUENCE"))

  sample_provenance <- list()
  sample_provenance[[ref_name]] <- ref_samples

  ft_names <- c(ref_name)

  for (i in seq_along(new_fts)) {
    ft_name <- get_ft_name(new_fts[[i]])
    # Ensure unique names
    if (ft_name %in% ft_names) {
      ft_name <- paste0(ft_name, "_", i)
    }
    ft_names <- c(ft_names, ft_name)

    ft_samples <- setdiff(colnames(new_fts[[i]]@table), c("ASV", "SEQUENCE"))
    sample_provenance[[ft_name]] <- ft_samples
  }

  # Create merge info
  merge_info <- list(
    is_merged = TRUE,
    n_source_fts = 1 + length(new_fts),
    reference_name = ref_name,
    n_reference_features = length(ref_names),
    n_matched_sequences = n_matched,
    n_novel_sequences = n_novel,
    new_prefix = new_prefix,
    sample_collision_strategy = sample_collision,
    sample_provenance = sample_provenance,
    merge_date = Sys.time()
  )

  # Step 6: Create merged ft object
  cli::cli_alert_info("Creating merged ft object")

  merged_ft <- jakR2::ft(
    table = merged_table,
    clusters = data.frame(),
    filter = list(),
    merge = merge_info,
    source = list(
      type = "merge",
      created = Sys.time()
    )
  )

  cli::cli_alert_success("Merge complete!")

  # Count sample columns (exclude ASV and SEQUENCE)
  n_samples <- length(setdiff(colnames(merged_table), c("ASV", "SEQUENCE")))
  n_features <- nrow(merged_table)

  cli::cli_alert_info("Final ft: {n_features} features ({n_matched} matched, {n_novel} novel), {n_samples} samples")

  return(merged_ft)
}
