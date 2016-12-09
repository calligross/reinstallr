context('show_missing_packages')

test_that('missing packages are found', {
  filename <- 'test_source_show_missing_packages.R'
  test_dir <- 'show_missing_packages'
  temp_dir <- tempdir()
  testpath <- file.path(temp_dir, test_dir)
  filepath <- file.path(testpath, filename)
  dir.create(testpath)

  con <- file(filepath)
  test_source <- 'library(dplyr666)
  # library(notused)
  dplyr667::filter()
  require(dplyr668)'
  writeLines(text = test_source, con = con)

  # check if repo is set, otherwise test is going to fail...
  repo <- getOption("repos")
  if (is.null(repo) | repo == '@CRAN@') {
    repo <- 'https://cloud.R-project.org'
  }

  result <- show_missing_packages(path = testpath, repos = repo)
  close(con)

  expect_equal(nrow(result), 3)
  expect_true(all(result$on_cran) == FALSE)

})
