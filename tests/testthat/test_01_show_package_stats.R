context('show_package_stats')

temp_dir <- tempdir()
filename <- '/test_source_show_package_stats.R'
con <- file(paste0(temp_dir, filename))
test_source <- 'library("dplyr")
# library(notused)
dplyr::filter()
require(dplyr)'
writeLines(text = test_source, con = con)
result <- show_package_stats(path = temp_dir)
close(con)


test_that('show_package_stats finds only used packages', {

  expect_true(any(result$package == 'dplyr'))
  expect_false(any(result$package == 'notused'))
})

test_that('show_package_stats finds the correct number of packages',
  expect_equal(result[result$package == 'dplyr', 'n'], 3)
)
