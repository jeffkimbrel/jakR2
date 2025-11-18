# Make ft object from DADA2 seqtab

Make ft object from DADA2 seqtab

## Usage

``` r
seqtab_to_ft(seqtab, clean = "_F_filt.fastq.gz")
```

## Arguments

- seqtab:

  A DADA2 sequence table (matrix) with ASVs as columns and samples as
  rows

- clean:

  A string to remove from the sample names in the feature table (default
  is "\_F_filt.fastq.gz")
