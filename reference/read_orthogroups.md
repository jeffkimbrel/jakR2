# Import an orthofinder TSV file

This code replaces the `jakR::orthofinder_summary()` function.

## Usage

``` r
read_orthogroups(file, type = "counts", quiet = F)
```

## Arguments

- file:

  The path to the Orthogroups/Orthogroups.tsv file in the standard
  orthofinder output

- type:

  Whether to return the counts or the lists of genes in each orthogroup

- quiet:

  If TRUE, suppress messages
