% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/alpha.R
\name{get_alpha_simpson}
\alias{get_alpha_simpson}
\title{Calculate Simpson's diversity index and its evenness and inverse}
\usage{
get_alpha_simpson(df, feature_id = "feature_id", id_col = "SAMPLE")
}
\arguments{
\item{df}{A dataframe with features as rows and samples as columns}

\item{feature_id}{The name of the column with feature IDs (default is "feature_id")}

\item{id_col}{The name of the column with sample IDs (default is "SAMPLE")}
}
\description{
Calculate Simpson's diversity index and its evenness and inverse
}
