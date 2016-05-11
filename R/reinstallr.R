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
    cat('y: Yes! Go ahed!\nn: No, fortget it!\n')
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

  libdir <- normalizePath(.libPaths())

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
    con <- file(i)
    lines <- suppressWarnings(readLines(con))
    libs <- lines[grepl('^(library)|(require)\\(', lines)]
    libs <- gsub('[\'"]', '', libs)
    libs <- gsub('(((library)|(require))\\()([[:alnum:]]*)(.*\\))', '\\5', libs)
    libs <- gsub('\\s', '', libs)

    direct_calls <- lines[grepl('[[:alnum:]]*::[[:alnum:]]*\\(', lines)]
    direct_calls <- gsub('([[:alnum:]]*)::.*', '\\1',  direct_calls)

    libs <- c(libs, direct_calls)

    close(con)
    if (length(libs) > 0)
    {
      result <- rbind(result, data.frame(file = i, package = libs, stringsAsFactors = FALSE))
    }
  }
  return(result)
}

missing_packages <- function(packages) {
  packages <- unique(packages)

  installed <- installed.packages()
  installed <- installed[, 1]

  missing <- packages[!packages %in% installed]

  available <- available.packages()

  on_cran <- missing %in% available

  missing <- data.frame(package = missing, on_cran = on_cran, stringsAsFactors = FALSE)
  return(missing)
}


