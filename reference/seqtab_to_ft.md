# Make ft object from DADA2 seqtab

Make ft object from DADA2 seqtab

## Usage

``` r
seqtab_to_ft(seqtab, clean = "_F_filt.fastq.gz", name = "ASV")
```

## Arguments

- seqtab:

  A DADA2 sequence table (matrix) with ASVs as columns and samples as
  rows

- clean:

  A string to remove from the sample names in the feature table (default
  is "\_F_filt.fastq.gz")

- name:

  (default: ASV) A string to use as a feature name. Include an
  underscore (or other separator) if desired
