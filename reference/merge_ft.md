# Merge multiple feature tables with priority-based naming

Combines multiple ft objects in priority order. For each unique
sequence, the ASV name from the highest-priority ft is used. Name
collisions (different sequences with the same ASV name) are resolved
using the new_prefix.

## Usage

``` r
merge_ft(fts, new_prefix, sample_collision = c("error", "suffix", "prefix"))
```

## Arguments

- fts:

  List of ft objects in priority order (first = highest priority)

- new_prefix:

  Character string prefix for resolving name collisions (e.g.,
  "collision\_"). Only used when different sequences share the same ASV
  name across fts.

- sample_collision:

  Strategy for handling duplicate sample names:

  - "error" (default): Abort if any sample names collide

  - "suffix": Append source identifier to ft sample names

  - "prefix": Prepend source identifier to ft sample names

## Value

A merged ft object containing:

- sequences:

  All unique sequences with unified names

- abundance:

  Combined abundance table across all samples

- metadata:

  Merge statistics and provenance

## Details

Feature naming logic processes fts in order:

1.  If sequence exists in higher-priority ft: use that ASV name

2.  If sequence is new AND name doesn't collide: keep original ASV name

3.  If sequence is new AND name collides: assign new name with
    new_prefix + counter

This preserves existing nomenclature from higher-priority fts while
resolving conflicts deterministically.

## Examples

``` r
if (FALSE) { # \dontrun{
# Primary ft: ASV1-ASV100
# Secondary ft: ASV50-ASV150 (ASV50-100 are different sequences)
# Tertiary ft: ASV200-ASV250
merged <- merge_ft(
  fts = list(primary, secondary, tertiary),
  new_prefix = "collision_"
)

# Result:
# - ASV1-ASV100 (from primary, unchanged)
# - collision_1 to collision_51 (secondary's ASV50-100 renamed due to collision)
# - ASV101-ASV150 (secondary, no collision, kept)
# - ASV200-ASV250 (tertiary, no collision, kept)
} # }
```
