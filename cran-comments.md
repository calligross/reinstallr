## Update 2016-08-18

I'm truly sorry, for all the trouble reinstallr is causing you dear maintainers.

The package didn't pass the check with olrdrel, as the available.packages's repos argument was introduced in R 3.3. As a consequence, reinstallr requires now R >= 3.0.0


## Update 2016-08-12

This is a resubmission, the last submission wasn't accepted due to the lack of code testing.

I implemented tests using testthat for:
* show_package_stats()
* find_used_packages()
* show_missing_packages()

## Update 2016-08-7

* Encapsulated the examples in dontrun{} to prevent them from walking through all the parallel .Rchecks directories on CRAN.
* This should also fix the error when checking if no CRAN mirror is configured.



## Test environments
* local OS X install, R 3.3.1
* win-builder (devel and release)
* travis-ci, R 3.3.1 

## R CMD check results

\* checking CRAN incoming feasibility ... NOTE  
Maintainer: 'Calli Gross <calli@calligross.de>'


## Downstream dependencies
There are no downstream dependencies.
