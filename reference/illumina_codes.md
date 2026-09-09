# Get Illumina machine and flow cell information from run ID

Parses Illumina run IDs to infer machine type and flow cell type based
on instrument and flow cell codes. Run IDs can be in dot-separated
format (e.g., "VH01105.139.AAFNL3GM5.1") or colon-separated format from
FASTQ headers (e.g., "M01056:70:000000000-CMPN2:1").

## Usage

``` r
illumina_codes(run_id)
```

## Arguments

- run_id:

  Character string with the run ID, either dot-separated or
  colon-separated format

## Value

A list with four elements:

- machine_code:

  The instrument serial number / machine code

- machine:

  Inferred machine type (e.g., "MiSeq", "NovaSeq", "NextSeq 2000")

- flowcell_code:

  The flow cell identifier

- flowcell:

  Inferred flow cell type (e.g., "MiSeq", "NovaSeq_6000")

## Details

Machine codes and regular expressions are based on information compiled
by Biostars community (https://www.biostars.org/p/198143/).

## Examples

``` r
# Dot-separated format (from directory names)
illumina_codes("VH01105.139.AAFNL3GM5.1")
#> $machine_code
#> [1] "VH01105"
#> 
#> $machine
#> [1] "NextSeq 2000"
#> 
#> $flowcell_code
#> [1] "AAFNL3GM5"
#> 
#> $flowcell
#> [1] "NextSeq_1000/2000"
#> 

# Colon-separated format (from FASTQ headers)
illumina_codes("M01056:70:000000000-CMPN2:1")
#> $machine_code
#> [1] "M01056"
#> 
#> $machine
#> [1] "MiSeq"
#> 
#> $flowcell_code
#> [1] "000000000-CMPN2"
#> 
#> $flowcell
#> [1] "MiSeq"
#> 
```
