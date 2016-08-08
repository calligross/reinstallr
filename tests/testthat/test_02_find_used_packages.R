context('find_used_packages')

test_that('find_used_packages finds the right file', {
  temp_dir <- tempdir()
  filename <- '/test_find_used_packages.R'
  filename <- paste0(temp_dir, filename)
  con <- file(filename)
  test_source <- 'library(dplyr)
  # library(notused)
  dplyr::filter()
  require(dplyr)'
  writeLines(text = test_source, con = con)
  result_dplyr <- find_used_packages(packages = 'dplyr', path = temp_dir)
  result_notused <- find_used_packages(packages = 'notused', path = temp_dir)
  close(con)

  expect_identical(result_dplyr[1, 1], filename)
  expect_equal(length(result_notused), 0)

})
