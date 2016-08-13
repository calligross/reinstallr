context('find_used_packages')

test_that('find_used_packages finds the right file', {

  filename <- '/test_find_used_packages.R'
  test_dir <- 'find_used_packages'
  temp_dir <- tempdir()
  testpath <- paste0(temp_dir, test_dir)
  filepath <- paste0(testpath, filename)
  dir.create(paste0(temp_dir, test_dir))

  con <- file(filepath)
  test_source <- 'library(dplyr)
  # library(notused)
  dplyr::filter()
  require(dplyr)'
  writeLines(text = test_source, con = con)
  result_dplyr <- find_used_packages(packages = 'dplyr', path = testpath)
  result_notused <- find_used_packages(packages = 'notused', path = testpath)
  close(con)

  expect_identical(result_dplyr[1, 1], filepath)
  expect_equal(length(result_notused), 0)

})
