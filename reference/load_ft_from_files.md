# Load ft object from FASTA and ASV table files

Helper function to create a jakR2::ft object from separate FASTA
(sequences) and ASV table (abundance) files on disk.

## Usage

``` r
load_ft_from_files(fasta_file, asv_table_file, name = "ft", sep = "auto")
```

## Arguments

- fasta_file:

  Path to FASTA file with sequences (headers = ASV names)

- asv_table_file:

  Path to ASV table file (CSV or TSV) First column = ASV names,
  remaining columns = sample abundances

- name:

  Name for the ft object

- sep:

  Delimiter for asv_table_file ("," for CSV, "\t" for TSV, "auto" to
  detect)

## Value

A jakR2::ft object
