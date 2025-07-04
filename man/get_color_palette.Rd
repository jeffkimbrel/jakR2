% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/palettes.R
\name{get_color_palette}
\alias{get_color_palette}
\title{Return table of colors for a palette}
\usage{
get_color_palette(pal, full = FALSE)
}
\arguments{
\item{pal}{A color palette}

\item{full}{A boolean for whether to return the full data frame or just the color and position}
}
\description{
On the surface this function doesn't seem useful as it basically enframes a vector
of a color palette. But, with the \code{full = TRUE} parameter set, it is used within
the \code{show_color_paeltte()} function to return a data frame with the color, position,
luminance, and text color for each color in the palette. This is useful for creating
a ggplot2 plot of the color palette.
}
