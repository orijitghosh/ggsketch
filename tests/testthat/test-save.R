# T-SAVE: ggsketch_save() picks a font-aware device per format.

save_plot <- function() {
  ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    theme_sketch()
}

test_that("ggsketch_save writes a png and returns the path invisibly", {
  out <- withr::local_tempfile(fileext = ".png")
  res <- withCallingHandlers(
    ggsketch_save(out, save_plot(), width = 3, height = 2),
    message = function(m) invokeRestart("muffleMessage")
  )
  expect_true(file.exists(out))
  expect_identical(res, out)
})

test_that("ggsketch_save writes a pdf through cairo_pdf", {
  out <- withr::local_tempfile(fileext = ".pdf")
  ggsketch_save(out, save_plot(), width = 3, height = 2)
  expect_true(file.exists(out))
  expect_gt(file.size(out), 0)
})

test_that("postscript output warns towards pdf", {
  out <- withr::local_tempfile(fileext = ".eps")
  expect_warning(
    ggsketch_save(out, save_plot(), width = 3, height = 2),
    "PostScript"
  )
  expect_true(file.exists(out))
})

test_that("an explicit device is passed through untouched", {
  out <- withr::local_tempfile(fileext = ".png")
  ggsketch_save(out, save_plot(), width = 3, height = 2,
                device = grDevices::png)
  expect_true(file.exists(out))
})

test_that("svg goes through svglite when available", {
  skip_if_not_installed("svglite")
  out <- withr::local_tempfile(fileext = ".svg")
  ggsketch_save(out, save_plot(), width = 3, height = 2)
  expect_true(file.exists(out))
  expect_match(readLines(out, n = 1L, warn = FALSE), "svg|xml")
})
