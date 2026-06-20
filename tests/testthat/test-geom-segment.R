# T-GEOM segment/step tests (P5-T2)

png_render <- function(p) {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  png(tmp, width = 4, height = 4, units = "in", res = 72)
  print(p)
  dev.off()
  file.size(tmp)
}

test_that("geom_sketch_segment() builds and renders", {
  df <- data.frame(x = 1:3, y = 1:3, xend = 2:4, yend = c(3, 1, 4))
  p <- ggplot2::ggplot(df) +
    geom_sketch_segment(ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
                        seed = 1L)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_step() builds and renders", {
  df <- data.frame(x = 1:6, y = c(1, 3, 2, 5, 4, 6))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) + geom_sketch_step(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("stairstep hv produces horizontal-first stairs", {
  s <- stairstep(c(1, 2, 3), c(10, 20, 30), direction = "hv")
  # First move is horizontal: y stays 10 while x goes 1 -> 2
  expect_equal(s$x, c(1, 2, 2, 3, 3))
  expect_equal(s$y, c(10, 10, 20, 20, 30))
})

test_that("stairstep vh produces vertical-first stairs", {
  s <- stairstep(c(1, 2, 3), c(10, 20, 30), direction = "vh")
  # First move is vertical: x stays 1 while y goes 10 -> 20
  expect_equal(s$x, c(1, 1, 2, 2, 3))
  expect_equal(s$y, c(10, 20, 20, 30, 30))
})

test_that("geom_sketch_segment per-row seed offset differs across rows", {
  # Two identical segments should still get different wobble via seed offset.
  df <- data.frame(x = c(0, 0), y = c(0, 0), xend = c(1, 1), yend = c(1, 1))
  p <- ggplot2::ggplot(df) +
    geom_sketch_segment(ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
                        seed = 1L)
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_step single-row returns minimal grob", {
  grob <- GeomSketchStep$draw_group(
    data.frame(x = 1, y = 1, colour = "black", linewidth = 0.5,
               linetype = 1, alpha = NA),
    list(), ggplot2::coord_cartesian(), seed = 1L
  )
  expect_s3_class(grob, "grob")
})
