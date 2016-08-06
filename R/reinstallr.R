#' reinstallr
#' @param path Directory which is scanned recursively. Default is the working directory.
#' @param pattern Regex to identify R source files. Default is .*\\.(R|r|Rnw|Rhtml|Rpres|Rmd)$
#' @param ... Parameters passed to install.packages()
#' @details
#' reinstallr() scans all R source files in the path specified by the \code{path} parameter and matching the \code{pattern} regex.
#' reinstallr looks for \code{library(package)}, \code{require(package)} and \code{package::function}
#' @importFrom utils install.packages
#' @export
#'
reinstallr <- function(path = NULL, pattern = NULL, ...) {

  # search packages
  found_packages <- scan_for_packages(find_r_files(path = path, pattern = pattern))
  missing_packages <- missing_packages(found_packages$package)

  packages_to_install_from_cran <- missing_packages[missing_packages$on_cran == TRUE, 'package']

  if (length(packages_to_install_from_cran) == 0) {
    return('No missing packages found.')
  }

    message('The following packages were found in your source files and can be installed from CRAN:')
    cat(packages_to_install_from_cran)
    cat('\nDo you want to install them now?\n')
    cat('y: Yes! Go ahead!\nn: No, forget it!\n')
    answer <- readLines(n = 1)

    if (answer == 'y') {
      install.packages(packages_to_install_from_cran, ...)
    } else {
      return(packages_to_install_from_cran)
    }
}

find_r_files <- function(path = NULL, pattern = NULL) {
  if (is.null(path)) {
    path <- getwd()
  }

  if (is.null(pattern)) {
    pattern <- '.*\\.(R|r|Rnw|Rhtml|Rpres|Rmd)$'
  }

  files <- list.files(path = path, pattern = pattern, full.names = TRUE, recursive = TRUE, include.dirs = TRUE)
  files_normalized <- normalizePath(files)

  # Filter libPaths()

  lib_pattern <- gsub('\\\\', '\\\\\\\\', normalizePath(.libPaths()))
  lib_pattern <- paste0('(^', lib_pattern, '.*)')
  lib_pattern <- paste(lib_pattern, collapse = '|')
  files <- files[!grepl(lib_pattern, files_normalized)]

  return(files)
}

scan_for_packages <- function(files) {

  result <- data.frame(file = NULL, package = NULL, stringsAsFactors = FALSE)

  for (i in files) {
    libs <- NULL
    direct_calls <- NULL

    con <- file(i)
    lines <- suppressWarnings(readLines(con))
    libs <- lines[grepl('^(library)|(require)\\(', lines)]
    libs <- gsub('[\'"]', '', libs)
    libs <- gsub('.*?(library|require)\\(([[:alnum:]]+).*', '\\2', libs)
    libs <- gsub('\\s', '', libs)

    direct_calls <- lines[grepl('::[[:alnum:]]+\\(', lines)]
    direct_calls <- unlist(sapply(direct_calls, extract_direct_calls))
    direct_calls <- unname(direct_calls)

    libs <- c(libs, direct_calls)

    close(con)
    if (length(libs) > 0)
    {
      result <- rbind(result, data.frame(file = i, package = libs, stringsAsFactors = FALSE))
    }
  }

  result <- result[!result$package %in% c('base'), ]

  return(result)
}

#' Title
#'
#' @param packages Vector of package names
#' @param ... Parameters passed to available.packages()
#' @return Vector of not installed packages
#' @importFrom utils installed.packages available.packages
missing_packages <- function(packages, ...) {
  packages <- unique(packages)

  installed <- installed.packages()
  installed <- installed[, 1]

  missing <- packages[!packages %in% installed]

  if (length(missing) > 0) {
    available <- available.packages(...)
    on_cran <- missing %in% available
    missing <- data.frame(package = missing, on_cran = on_cran, stringsAsFactors = FALSE)
  }
  return(missing)
}

extract_direct_calls <- function(string) {
  string <- strsplit(string, '\\(')
  string <- unlist(string, use.names = FALSE)
  string <- string[grepl('\\:\\:', string)]
  gsub('.*?([[:alnum:]]+)::.*', '\\1', string)
}

#' Show Used Packages
#'
#' @param path Directory which is scanned recursively. Default is the working directory.
#' @param pattern Regex to identify R source files. Default is .*\\.(R|r|Rnw|Rhtml|Rpres|Rmd)$
#'
#' @return A aggregated data.frame
#' @importFrom stats aggregate
#' @export
#'
#' @examples
#' show_package_stats('../')
show_package_stats <- function(path = NULL, pattern = NULL) {

  found_packages <- scan_for_packages(find_r_files(path = path, pattern = pattern))

  package_stats <- aggregate(file ~ ., data = found_packages, length)
  names(package_stats) <- c('package', 'n')
  package_stats <- package_stats[order(package_stats$n), ]

  if (nrow(package_stats) > 0)
    return(package_stats)
}

#' Find Files Where Specific Packages Are Used
#'
#' @param packages Vector of packages to look for
#' @param path Directory which is scanned recursively. Default is the working directory.
#' @param pattern Regex to identify R source files. Default is .*\\.(R|r|Rnw|Rhtml|Rpres|Rmd)$
#'
#' @return A data.frame with the files which are using the specified packages
#' @export
#'
#' @examples
#' find_used_packages('dplyr', path = '../')
find_used_packages <- function(packages, path = NULL, pattern = NULL) {

  found_packages <- scan_for_packages(find_r_files(path = path, pattern = pattern))
  package_location <- found_packages[found_packages$package %in% packages, ]

  if (nrow(package_location) > 0)
    return(package_location)

}
