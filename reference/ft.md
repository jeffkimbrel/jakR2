# Feature table class

This class represents a feature table (ft) object, which contains a
table of ASVs and their sequences, along with optional clustering
information and filtering parameters.

## Arguments

- table:

  A data frame containing the feature table with ASVs and sequences.

- clusters:

  A data frame containing cluster assignments, populated by
  [`cluster_asv_table()`](https://jeffkimbrel.github.io/jakR2/reference/cluster_asv_table.md).

- filter:

  A list containing filtering parameters applied to the table, populated
  by
  [`filter_asv_table()`](https://jeffkimbrel.github.io/jakR2/reference/filter_asv_table.md).
