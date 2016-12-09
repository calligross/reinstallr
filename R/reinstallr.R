#' reinstallr
#' @param path Directory which is scanned recursively. Default is the working directory.
#' @param pattern Regex to identify R source files. Default is .*\\.(R|r|Rnw|Rhtml|Rpres|Rmd)$
#' @param ... Parameters passed to install.packages()
#' @details
#' reinstallr() scans all R source files in the path specified by the \code{path} parameter and matching the \code{pattern} regex.
#' reinstallr looks for \code{library(package)}, \code{require(package)} and \code{package::function}
#' @importFrom utils install.packages menu
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
    cat(paste0(c(packages_to_install_from_cran, '\n\n')))
    answer <- menu(
      choices = c(
      'Yes!',
      'No, forget it!'
      ),
      title = 'Do you want to run install.packages()?'
    )

    if (answer == 1) {
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
  files <- files[!grepl('win-library\\/[0-9]\\.[0-9]', files)]

  return(files)
}

scan_for_packages <- function(files) {

  result <- data.frame(file = NULL, package = NULL, stringsAsFactors = FALSE)

  for (i in files) {
    libs <- NULL
    direct_calls <- NULL

    con <- file(i)
    lines <- suppressWarnings(readLines(con))
    lines <- gsub('#.*', '', lines)
    libs <- lines[grepl('((library)|(require))\\(', lines)]
    libs <- gsub('[\'"]', '', libs)
    libs <- gsub('.*?(library|require)\\(([[:alnum:]]+).*', '\\2', libs)
    libs <- gsub('\\s', '', libs)

    direct_calls <- lines[grepl('(:){2,3}[[:alnum:]]+\\(', lines)]
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
#' \dontrun{
#' show_package_stats('../')
#' }
show_package_stats <- function(path = NULL, pattern = NULL) {

  found_packages <- scan_for_packages(find_r_files(path = path, pattern = pattern))
  found_packages <- unique(found_packages[, c('file', 'package')])
  if (nrow(found_packages) > 0) {
    package_stats <- aggregate(file ~ ., data = found_packages, length)
    names(package_stats) <- c('package', 'n')
    package_stats <- package_stats[order(package_stats$n), ]
    row.names(package_stats) <- NULL

    return(package_stats)
  }

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
#' \dontrun{
#' find_used_packages('dplyr', path = '../')
#' }
find_used_packages <- function(packages, path = NULL, pattern = NULL) {

  found_packages <- scan_for_packages(find_r_files(path = path, pattern = pattern))
  package_location <- found_packages[found_packages$package %in% packages, ]

  if (nrow(package_location) > 0)
    return(package_location)

}

#' Show used but not installed packages
#'
#' @param path Directory which is scanned recursively. Default is the working directory.
#' @param pattern Regex to identify R source files. Default is .*\\.(R|r|Rnw|Rhtml|Rpres|Rmd)$
#' @param ... Parameters passed to available.packages()
#'
#' @return A data.frame with missing packages
#' @details \code{show_missing_packages()} searches missing packages and checks if they are available on CRAN
#' @export
#'
#' @examples
#' \dontrun{
#' show_missing_packages('../')
#' }
show_missing_packages <- function(path = NULL, pattern = NULL, ...) {
  found_packages <- scan_for_packages(find_r_files(path = path, pattern = pattern))
  missing_packages <- missing_packages(found_packages$package, ...)
  return(missing_packages)
}
