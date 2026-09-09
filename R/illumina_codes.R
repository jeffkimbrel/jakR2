#' Get Illumina machine and flow cell information from run ID
#'
#' Parses Illumina run IDs to infer machine type and flow cell type based on
#' instrument and flow cell codes. Run IDs can be in dot-separated format
#' (e.g., "VH01105.139.AAFNL3GM5.1"), colon-separated format from FASTQ headers
#' (e.g., "M01056:70:000000000-CMPN2:1"), or just the machine code alone
#' (e.g., "M01056").
#'
#' Machine codes and regular expressions are based on information compiled by
#' Biostars community (https://www.biostars.org/p/198143/).
#'
#' @param run_id Character string with the run ID (full format or machine code only)
#'
#' @return A list with four elements:
#'   \describe{
#'     \item{machine_code}{The instrument serial number / machine code}
#'     \item{machine}{Inferred machine type (e.g., "MiSeq", "NovaSeq", "NextSeq 2000")}
#'     \item{flowcell_code}{The flow cell identifier (NA if not provided)}
#'     \item{flowcell}{Inferred flow cell type (e.g., "MiSeq", "NovaSeq_6000"),
#'       or "Unknown Flowcell Type" if not provided}
#'   }
#'
#' @export
#'
#' @examples
#' # Dot-separated format (from directory names)
#' illumina_codes("VH01105.139.AAFNL3GM5.1")
#'
#' # Colon-separated format (from FASTQ headers)
#' illumina_codes("M01056:70:000000000-CMPN2:1")
#'
#' # Machine code only (no flowcell info)
#' illumina_codes("M01056")
illumina_codes <- function(run_id) {
  # run_id must be a string
  if (!is.character(run_id)) {
    stop("run_id must be a string", call. = FALSE)
  }

  # Handle both dot-separated and colon-separated formats
  # Dot format: machine.run_number.flowcell.lane
  # Colon format: machine:run_number:flowcell:lane
  separator <- ifelse(grepl("\\.", run_id), "\\.", ":")
  parts <- stringr::str_split(run_id, separator)[[1]]

  # Extract machine code (always first part, or the whole string if no separator)
  machine_code <- parts[1]

  # Extract flowcell code (third part, if available)
  flowcell_code <- if (length(parts) >= 3) parts[3] else NA_character_

  # Infer machine type from instrument code
  # Order matters - more specific patterns first
  machine <- dplyr::case_when(
    stringr::str_detect(machine_code, "^HWUSI") ~ "GAIIx",
    stringr::str_detect(machine_code, "^HWI-M") ~ "MiSeq",
    stringr::str_detect(machine_code, "^HWI-D") ~ "HiSeq 2x00",
    stringr::str_detect(machine_code, "^AA") ~ "NextSeq 2000",
    stringr::str_detect(machine_code, "^V") ~ "NextSeq 2000",
    stringr::str_detect(machine_code, "^M") ~ "MiSeq",
    stringr::str_detect(machine_code, "^K") ~ "HiSeq 3/4000",
    stringr::str_detect(machine_code, "^N") ~ "NextSeq 5x0",
    stringr::str_detect(machine_code, "^A") ~ "NovaSeq",
    stringr::str_detect(machine_code, "^H") ~ "NovaSeq",
    .default = "Unknown Illumina Machine"
  )

  # Infer flow cell type from flow cell code (if available)
  # Order matters - more specific patterns first
  # Patterns from https://www.biostars.org/p/198143/
  # ".." means "at least two more characters" (not necessarily at end)
  flowcell <- if (is.na(flowcell_code)) {
    "Unknown Flowcell Type"
  } else {
    dplyr::case_when(
      stringr::str_detect(flowcell_code, "^(BRB|BP[ACGL]|BNT)") ~ "iSeq_100",
      stringr::str_detect(flowcell_code, "000H") ~ "MiniSeq",
      stringr::str_detect(flowcell_code, "HV$") ~ "NextSeq_2000",
      stringr::str_detect(flowcell_code, "M5$") ~ "NextSeq_1000/2000",
      stringr::str_detect(flowcell_code, "^(A[FG]|BG)..") ~ "NextSeq_500/550",
      stringr::str_detect(flowcell_code, "^D[RS]..|^DM.") ~ "NovaSeq_6000",
      stringr::str_detect(flowcell_code, "^BB..") ~ "HiSeq_3000/4000",
      stringr::str_detect(flowcell_code, "^(AL|CC)..") ~ "HiSeq_X",
      stringr::str_detect(flowcell_code, "^([AB]C|AN)..") ~ "HiSeq_2500",
      nchar(flowcell_code) <= 4 & stringr::str_detect(flowcell_code, "^[BCJKDG]") ~ "MiSeq",
      stringr::str_detect(flowcell_code, "^0+") ~ "MiSeq",  # MiSeq flowcells can start with zeros
      .default = "Unknown Flowcell Type"
    )
  }

  return(list(
    machine_code = machine_code,
    machine = machine,
    flowcell_code = flowcell_code,
    flowcell = flowcell
  ))
}
