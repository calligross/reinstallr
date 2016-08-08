context('show_missing_packages')

test_that('missing packages are found', {
  temp_dir <- tempdir()
  filename <- '/test_source_show_missing_packages.R'
  con <- file(paste0(temp_dir, filename))
  test_source <- 'library(dplyr666)
  # library(notused)
  dplyr667::filter()
  require(dplyr668)'
  writeLines(text = test_source, con = con)
  result <- show_missing_packages(path = temp_dir, repos = 'http://cran.rstudio.com/')
  close(con)

  expect_equal(nrow(result), 3)
  expect_true(all(result$on_cran) == FALSE)


})
