# Extract DADA2 seqtab statistics

Given a seqtab matrix, this function will calculate the counts and
abundances of ASVs and by their sequence lengths. `FREQ` is the number
of ASVs, and `ABUNDANCE` is the total number of reads for each sequence
length.

## Usage

``` r
seqtab_stats(seqtab)
```

## Arguments

- seqtab:

  A DADA2 sequence table

## Details

A seqtab object itself is just a matrix, so the error checking can't
always determine if it is truly a seqtab object, or just another matrix.
So,
