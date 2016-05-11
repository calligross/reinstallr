reinstallr
==============

`reinstallr` is a tool to identify missing packages, e.g. after upgrading R, by scanning through your R files. If the missing package is available on CRAN and you confirmed the install, `install.packages` is called.

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

reinstallr(path = NULL, pattern = NULL)

```

Per default reinstallr searches the working directory for R, Rmd, Rnw, Rhtml and Rpres files. If you have all your R projects under one directory, you should specify this as path.

```r
reinstallr(path = '../', pattern = NULL)

```
