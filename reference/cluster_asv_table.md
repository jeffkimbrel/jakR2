# Cluster ASV sequences from ft object

Cluster ASV sequences from ft object

## Usage

``` r
## S7 method for class <jakR2::ft>
cluster_asv_table(x, id = 0.99, nproc = 1, quiet = TRUE)
```

## Arguments

- x:

  An ft object

- id:

  Numeric value between 0 and 1 representing the clustering threshold
  (default is 0.99)

- nproc:

  Number of processors to use for parallel processing (default is 1)

- quiet:

  Logical, whether to suppress verbose output (default is TRUE)
