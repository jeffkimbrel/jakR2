#' Merge multiple feature tables with priority-based naming
#'
#' Combines multiple ft objects in priority order. For each unique sequence,
#' the ASV name from the highest-priority ft is used. Name collisions (different
#' sequences with the same ASV name) are resolved using the new_prefix.
#'
#' @param fts List of ft objects in priority order (first = highest priority)
#' @param new_prefix Character string prefix for resolving name collisions
#'   (e.g., "collision_"). Only used when different sequences share the same
#'   ASV name across fts.
#' @param sample_collision Strategy for handling duplicate sample names:
#'   \itemize{
#'     \item "error" (default): Abort if any sample names collide
#'     \item "suffix": Append source identifier to ft sample names
#'     \item "prefix": Prepend source identifier to ft sample names
#'   }
#'
#' @return A merged ft object containing:
#'   \item{sequences}{All unique sequences with unified names}
#'   \item{abundance}{Combined abundance table across all samples}
#'   \item{metadata}{Merge statistics and provenance}
#'
#' @details
#' Feature naming logic processes fts in order:
#' \enumerate{
#'   \item If sequence exists in higher-priority ft: use that ASV name
#'   \item If sequence is new AND name doesn't collide: keep original ASV name
#'   \item If sequence is new AND name collides: assign new name with new_prefix + counter
#' }
#'
#' This preserves existing nomenclature from higher-priority fts while resolving
#' conflicts deterministically.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Primary ft: ASV1-ASV100
#' # Secondary ft: ASV50-ASV150 (ASV50-100 are different sequences)
#' # Tertiary ft: ASV200-ASV250
#' merged <- merge_ft(
#'   fts = list(primary, secondary, tertiary),
#'   new_prefix = "collision_"
#' )
#'
#' # Result:
#' # - ASV1-ASV100 (from primary, unchanged)
#' # - collision_1 to collision_51 (secondary's ASV50-100 renamed due to collision)
#' # - ASV101-ASV150 (secondary, no collision, kept)
#' # - ASV200-ASV250 (tertiary, no collision, kept)
#' }
merge_ft <- function(
  fts,
  new_prefix,
  sample_collision = c("error", "suffix", "prefix")
) {

  # Validate inputs
  sample_collision <- match.arg(sample_collision)

  if (!is.list(fts) || length(fts) < 2) {
    cli::cli_abort("fts must be a list of at least 2 ft objects")
  }

  if (!all(sapply(fts, function(x) inherits(x, "jakR2::ft")))) {
    cli::cli_abort("All fts must be jakR2::ft objects")
  }

  if (missing(new_prefix) || is.null(new_prefix) || new_prefix == "") {
    cli::cli_abort("new_prefix is required and cannot be empty")
  }

  cli::cli_h2("Merging feature tables")
  cli::cli_alert_info("Processing {length(fts)} ft objects in priority order")

  # Step 1: Check sample name collisions
  cli::cli_alert_info("Checking for sample name collisions")

  # Get sample names from all fts
  all_samples <- character(0)
  for (i in seq_along(fts)) {
    samples <- setdiff(colnames(fts[[i]]@table), c("ASV", "SEQUENCE"))
    all_samples <- c(all_samples, samples)
  }

  duplicated_samples <- all_samples[duplicated(all_samples)]

  if (length(duplicated_samples) > 0) {
    if (sample_collision == "error") {
      msg <- c(
        "Sample name collisions detected:",
        paste0("  ", paste(head(unique(duplicated_samples), 5), collapse = ", ")),
        "i" = "Use sample_collision = 'suffix' or 'prefix' to resolve automatically"
      )
      cli::cli_abort(msg)
    } else if (sample_collision == "suffix") {
      # Rename sample columns with suffix (preserve priority 1, rename others)
      for (i in 2:length(fts)) {
        table <- fts[[i]]@table
        sample_cols <- setdiff(colnames(table), c("ASV", "SEQUENCE"))
        colnames(table)[colnames(table) %in% sample_cols] <- paste0(sample_cols, "_ft", i)
        fts[[i]]@table <- table
      }
      cli::cli_alert_warning("Renamed samples in lower-priority fts with suffix: _ft2, _ft3, ...")
    } else if (sample_collision == "prefix") {
      # Rename sample columns with prefix (preserve priority 1, rename others)
      for (i in 2:length(fts)) {
        table <- fts[[i]]@table
        sample_cols <- setdiff(colnames(table), c("ASV", "SEQUENCE"))
        colnames(table)[colnames(table) %in% sample_cols] <- paste0("ft", i, "_", sample_cols)
        fts[[i]]@table <- table
      }
      cli::cli_alert_warning("Renamed samples in lower-priority fts with prefix: ft2_, ft3_, ...")
    }
  } else {
    cli::cli_alert_success("No sample name collisions detected")
  }

  # Step 2: Build sequence → name mapping in priority order
  cli::cli_alert_info("Building sequence mapping in priority order")

  seq_to_name <- list()  # sequence → ASV name
  existing_names <- character(0)  # all ASV names seen
  new_counter <- 1

  # Track statistics per ft
  n_matched <- integer(length(fts))  # sequences matched to higher priority
  n_kept <- integer(length(fts))     # new sequences kept original name
  n_renamed <- integer(length(fts))  # new sequences renamed due to collision

  # Process each ft in priority order
  for (i in seq_along(fts)) {
    ft_table <- fts[[i]]@table

    cli::cli_alert_info("  Processing ft {i}/{length(fts)}: {nrow(ft_table)} ASVs")

    for (j in seq_len(nrow(ft_table))) {
      seq <- as.character(ft_table$SEQUENCE[j])
      original_name <- ft_table$ASV[j]

      if (seq %in% names(seq_to_name)) {
        # Sequence already seen in higher-priority ft - use that name
        n_matched[i] <- n_matched[i] + 1
      } else {
        # New sequence - check if name collides
        if (original_name %in% existing_names) {
          # Name collision - assign new name with prefix
          new_name <- paste0(new_prefix, new_counter)

          # Ensure no collision (shouldn't happen if prefix is unique)
          while (new_name %in% existing_names) {
            new_counter <- new_counter + 1
            new_name <- paste0(new_prefix, new_counter)
          }

          seq_to_name[[seq]] <- new_name
          existing_names <- c(existing_names, new_name)
          new_counter <- new_counter + 1
          n_renamed[i] <- n_renamed[i] + 1
        } else {
          # No collision - keep original name
          seq_to_name[[seq]] <- original_name
          existing_names <- c(existing_names, original_name)
          n_kept[i] <- n_kept[i] + 1
        }
      }
    }
  }

  cli::cli_alert_success("Sequence mapping complete:")
  for (i in seq_along(fts)) {
    if (i == 1) {
      cli::cli_alert_info("  ft {i}: {n_kept[i]} ASVs (highest priority)")
    } else {
      cli::cli_alert_info("  ft {i}: {n_matched[i]} matched, {n_kept[i]} kept, {n_renamed[i]} renamed")
    }
  }

  # Step 3: Build unified ft table
  cli::cli_alert_info("Building unified ft table")

  # Process each ft and rename ASV column to unified names
  all_tables <- list()

  for (i in seq_along(fts)) {
    ft_table <- fts[[i]]@table

    # Map original ASV names to unified names based on sequences
    ft_table$ASV <- sapply(ft_table$SEQUENCE, function(seq) seq_to_name[[as.character(seq)]])

    all_tables[[i]] <- ft_table
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

  # Step 4: Build merge provenance
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
  sample_provenance <- list()
  ft_names <- character(0)

  for (i in seq_along(fts)) {
    ft_name <- get_ft_name(fts[[i]])

    # Ensure unique names
    if (ft_name %in% ft_names) {
      ft_name <- paste0(ft_name, "_", i)
    }
    ft_names <- c(ft_names, ft_name)

    ft_samples <- setdiff(colnames(fts[[i]]@table), c("ASV", "SEQUENCE"))
    sample_provenance[[ft_name]] <- ft_samples
  }

  # Create merge info
  merge_info <- list(
    is_merged = TRUE,
    n_source_fts = length(fts),
    priority_order = ft_names,
    n_features_per_ft = sapply(fts, function(ft) nrow(ft@table)),
    n_matched_per_ft = n_matched,
    n_kept_per_ft = n_kept,
    n_renamed_per_ft = n_renamed,
    new_prefix = new_prefix,
    sample_collision_strategy = sample_collision,
    sample_provenance = sample_provenance,
    merge_date = Sys.time()
  )

  # Step 5: Create merged ft object
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

  # Count final features and samples
  n_samples <- length(sample_cols)
  n_features <- nrow(merged_table)
  n_total_matched <- sum(n_matched)
  n_total_kept <- sum(n_kept)
  n_total_renamed <- sum(n_renamed)

  cli::cli_alert_info("Final ft: {n_features} features ({n_total_matched} matched, {n_total_kept} kept, {n_total_renamed} renamed), {n_samples} samples")

  return(merged_ft)
}
