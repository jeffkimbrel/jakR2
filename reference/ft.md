# Feature table class

This class represents a feature table (ft) object, which contains a
table of ASVs and their sequences, along with optional clustering
information and filtering parameters.

## Usage

``` r
ft(
  table = (function (.data = list(), row.names = NULL) 
 {
     if (is.null(row.names))
    {
         list2DF(.data)
     }
     else {
         out <- list2DF(.data,
    length(row.names))
attr(out, "row.names") <- row.names
         out
     }

    })(),
  clusters = (function (.data = list(), row.names = NULL) 
 {
     if
    (is.null(row.names)) {
         list2DF(.data)
     }
     else {
         out <-
    list2DF(.data, length(row.names))
attr(out, "row.names") <- row.names
      
      out
     }
 })(),
  filter = list()
)
```

## Arguments

- table:

  A data frame containing the feature table with ASVs and sequences.
