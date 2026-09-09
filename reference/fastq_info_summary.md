# Summarize a fastq_info file

Parses fastq_info.py output and extracts key statistics including read
counts, pairing validation, run IDs, and Illumina machine/flowcell
information.

## Usage

``` r
fastq_info_summary(file, fill = "cornflowerblue")
```

## Arguments

- file:

  Path to output from fastq_info.py

- fill:

  Color to use for the histogram

## Value

A list with four elements:

- run_id:

  Tibble with RUN_ID, TOTAL_READS, MACHINE_CODE, MACHINE, FLOWCELL_CODE,
  and FLOWCELL columns

- stats:

  Descriptive statistics for read counts across samples

- pairs:

  Tibble showing whether F/R read counts match for each sample

- plot:

  Histogram of read counts per sample
