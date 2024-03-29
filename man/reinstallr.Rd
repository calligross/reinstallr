% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/reinstallr.R
\name{reinstallr}
\alias{reinstallr}
\title{reinstallr}
\usage{
reinstallr(path = NULL, pattern = NULL, ...)
}
\arguments{
\item{path}{Directory which is scanned recursively. Default is the working directory.}

\item{pattern}{Regex to identify R source files. Default is .*\\.(R|r|Rnw|Rhtml|Rpres|Rmd)$}

\item{...}{Parameters passed to install.packages()}
}
\description{
reinstallr
}
\details{
reinstallr() scans all R source files in the path specified by the \code{path} parameter and matching the \code{pattern} regex.
reinstallr looks for \code{library(package)}, \code{require(package)} and \code{package::function}
}
