# T-v2: coord_sketch() - a roughened frame under any theme.

# Recursively collect grob/gtable class names.
grob_classes <- function(g) {
  out <- class(g)
  if (!is.null(g$grobs))    out <- c(out, unlist(lapply(g$grobs, grob_classes)))
  if (!is.null(g$children)) out <- c(out, unlist(lapply(g$children, grob_classes)))
  out
}

test_that("coord_sketch builds a CoordCartesian-derived coord", {
  co <- coord_sketch(seed = 1L)
  expect_s3_class(co, "CoordSketch")
  expect_s3_class(co, "CoordCartesian")
  expect_true(co$sketch$grid)
  expect_true(co$sketch$ticks)
})

test_that("coord_sketch limits behave like coord_cartesian", {
  co <- coord_sketch(xlim = c(0, 5), ylim = c(1, 9))
  expect_equal(co$limits$x, c(0, 5))
  expect_equal(co$limits$y, c(1, 9))
})

test_that("coord_sketch roughens gridlines under a plain theme", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    coord_sketch(seed = 1L) +
    ggplot2::theme_grey()
  gt <- ggplot2::ggplotGrob(p)
  expect_true("SketchPathGrob" %in% grob_classes(gt))
  expect_no_error(grid::grid.draw(gt))
})

test_that("rough_grid = FALSE leaves the gridlines crisp", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    coord_sketch(rough_grid = FALSE, rough_ticks = FALSE, seed = 1L)
  gt <- ggplot2::ggplotGrob(p)
  expect_false("SketchPathGrob" %in% grob_classes(gt))
})

test_that("coord_sketch renders under theme_sketch too", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    coord_sketch(seed = 1L) +
    theme_sketch()
  expect_no_error(print(p))
})
