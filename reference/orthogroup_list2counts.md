# Convert an orthogroup list dataframe to a count dataframe

This function is used to convert the output of
[`read_orthogroups()`](https://jeffkimbrel.github.io/jakR2/reference/read_orthogroups.md)
when the type is set to "list" to a count format. Alternatively, it can
run in verify mode where it will return "counts" or "list" based on some
basic inference.

## Usage

``` r
orthogroup_list2counts(orthogroups, verify = F)
```

## Arguments

- orthogroups:

  The orthogroup dataframe

- verify:

  If TRUE, return "counts" or "list" based on the input
