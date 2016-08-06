reinstallr
==============
[![Build Status](https://travis-ci.org/calligross/reinstallr.svg?branch=master)](https://travis-ci.org/calligross/reinstallr)
[![CRAN](http://www.r-pkg.org/badges/version/reinstallr)](http://cran.rstudio.com/package=reinstallr) [![Downloads](http://cranlogs.r-pkg.org/badges/grand-total/reinstallr?color=brightgreen)](http://www.r-pkg.org/pkg/reinstallr)

`reinstallr` is a tool to identify missing packages, e.g. after upgrading R, by scanning through your R files. If the missing packages are available on CRAN and you confirmed the install, `install.packages` is called. As a bonus, it provides some information about the packages you are using.

`reinstallr` is a little helper I wrote for myself and I'm glad if it's useful for anyone else. **Pull requests to improve the package are very welcomed!**

`reinstallr` searches for 

* `library()`, 
* `require()` and 
* `package::function` calls. 

Installation
------------
```r
if (!requireNamespace("devtools", quietly = TRUE))
  install.packages("devtools")

devtools::install_github("calligross/reinstallr")
```

Usage
------------

```r
reinstallr(path = NULL, pattern = NULL, ...)
```

Per default reinstallr searches the working directory for R, Rmd, Rnw, Rhtml and Rpres files. After a reinstall the following might be enough to install all packages (from CRAN):

```r
# All my R projects are located in ~/Documents/R/
reinstallr(path = '~/Documents/R/')

```

`show_missing_packages()` searches for missing packages and gives the information if the package is available on CRAN:

```r
show_missing_packages(path = '~/Documents/R/')
#           package on_cran
# 1        lineprof   FALSE
# 2            BuBa   FALSE
# 3 metricsgraphics    TRUE
```


If you would like to find out, which packages you use, `show_package_stats()` is your friend:

```r
show_package_stats(path = '~/Documents/R/')
# [...]
# 43        testthat  3
# 44       htmltools  4
# 45       lubridate  4
# 46        reshape2  4
# 47         twitteR  4
# 48            data  5
# 49      rstudioapi  5
# 50          scales  5
# 51        jsonlite  7
# 52           dplyr 10
# 53           knitr 11
# 54     htmlwidgets 12
# 55         ggplot2 17
# 56   rhandsontable 17
# 57  microbenchmark 18
# 58           shiny 34
```

`find_used_packages()` gives you the information, in which files a package is used:

```r
find_used_packages(packages = c('dplyr', 'ggplot2'), path = '~/Documents/R/')
```

