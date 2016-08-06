#' reinstallr
#'
#' @return Installs packages or if not interactive a list of missing packages
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
    if(answer == 'y') {
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

missing_packages <- function(packages) {
  packages <- unique(packages)

  installed <- installed.packages()
  installed <- installed[, 1]

  missing <- packages[!packages %in% installed]

  if (length(missing) > 0) {
    available <- available.packages()
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

show_package_stats <- function(path = NULL, pattern = NULL) {

  found_packages <- scan_for_packages(find_r_files(path = path, pattern = pattern))

  package_stats <- aggregate(file ~ ., data = found_packages, length)
  names(package_stats) <- c('package', 'n')
  package_stats <- package_stats[order(package_stats$n), ]

  if (nrow(package_stats) > 0)
    return(package_stats)
}

find_used_packages <- function(packages, path = NULL, pattern = NULL) {

  found_packages <- scan_for_packages(find_r_files(path = path, pattern = pattern))
  package_location <- found_packages[found_packages$package %in% packages, ]

  if (nrow(package_location) > 0)
    return(package_location)

}
