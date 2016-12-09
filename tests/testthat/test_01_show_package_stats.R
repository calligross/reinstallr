context('show_package_stats')

filename <- 'test_source_show_package_stats.R'
test_dir <- 'show_package_stats'
temp_dir <- tempdir()
testpath <- file.path(temp_dir, test_dir)
filepath <- file.path(testpath, filename)
dir.create(testpath)

con <- file(filepath)
test_source <- 'library("dplyr")
# library(notused)
ggplot2::filter()
require(reshape2)'
writeLines(text = test_source, con = con)
result <- show_package_stats(path = testpath)
close(con)


test_that('show_package_stats finds only used packages', {

  expect_true(any(result$package == 'dplyr'))
  expect_false(any(result$package == 'notused'))
})

test_that('show_package_stats finds the correct number of packages',
  expect_equal(length(result[result$package %in% c('dplyr', 'ggplot2', 'reshape2'), 'n']), 3)
)
