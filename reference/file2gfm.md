# Decorate a file string for gfm markdown in Obsidian

This function takes a file path and returns a string with the file path
as a gfm formatted link that works in Obsidian. If a `path` is not
given, then the function will "expand" the `file` string to be a full
path. This is meant to expand "~/" to a full path, but can cause issues
if you give just a file name but no context as to the path.

## Usage

``` r
file2gfm(file, path = NA, verify = F)
```

## Arguments

- file:

  A string representing a file name or path

- path:

  A string representing a file path

- verify:

  Logical indicating whether to verify the file exists

## Value

A string with the file path as a gfm markdown link
