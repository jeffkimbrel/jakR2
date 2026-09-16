# Merge multiple feature tables with sequence matching

Combines a reference ft object with one or more new ft objects.
Sequences that match the reference retain their original names; novel
sequences are assigned new names with a user-specified prefix.

## Usage

``` r
merge_ft(
  reference_ft,
  new_fts,
  new_prefix,
  sample_collision = c("error", "suffix", "prefix")
)
```

## Arguments

- reference_ft:

  Feature table (ft object) with established feature names

- new_fts:

  Single ft object or list of ft objects to merge into reference

- new_prefix:

  Character string prefix for novel sequences (e.g., "ASV_new\_"). Must
  not create collisions with existing reference names.

- sample_collision:

  Strategy for handling duplicate sample names:

  - "error" (default): Abort if any sample names collide

  - "suffix": Append source identifier to new ft sample names

  - "prefix": Prepend source identifier to new ft sample names

## Value

A merged ft object containing:

- sequences:

  All unique sequences with unified names

- abundance:

  Combined abundance table across all samples

- metadata:

  Merge statistics and provenance

## Details

The reference ft remains unchanged - its feature names and sample names
are preserved exactly. New sequences are numbered starting from 1 with
the user-provided prefix.

Feature naming logic:

- Sequences matching reference: use reference name (e.g., "ASV1")

- Novel sequences: use new_prefix + counter (e.g., "ASV_new_1",
  "ASV_new_2")

The function validates that generated names won't collide with reference
names. If a collision is detected, the merge aborts with an error
suggesting a different prefix.

## Examples

``` r
if (FALSE) { # \dontrun{
# Reference has ASV1-ASV711
# New data has some matching sequences and some novel ones
merged <- merge_ft(
  reference_ft = ref,
  new_fts = list(run1, run2),
  new_prefix = "ASV_2024_"
)

# Result contains:
# - ASV1-ASV711 (original names for matching sequences)
# - ASV_2024_1, ASV_2024_2, ... (novel sequences)
} # }
```
