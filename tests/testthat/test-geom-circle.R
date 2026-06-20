# T-GEOM circle/ellipse tests (P5-T1)

png_render <- function(p) {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  png(tmp, width = 4, height = 4, units = "in", res = 72)
  print(p)
  dev.off()
  file.size(tmp)
}

test_that("geom_sketch_circle() builds and renders", {
  df <- data.frame(x = c(1, 3), y = c(1, 2), r = c(0.5, 1))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, r = r)) +
    geom_sketch_circle(fill = "gold", seed = 1L) + ggplot2::coord_equal()
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_circle expands scales to fit radius (setup_data)", {
  df <- data.frame(x = 5, y = 5, r = 3)
  out <- GeomSketchCircle$setup_data(
    data.frame(x = 5, y = 5, r = 3), list()
  )
  expect_equal(out$xmin, 2)
  expect_equal(out$xmax, 8)
  expect_equal(out$ymin, 2)
  expect_equal(out$ymax, 8)
})

test_that("geom_sketch_ellipse() with a/b builds and renders", {
  df <- data.frame(x = 2, y = 2, a = 1.5, b = 0.7)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, a = a, b = b)) +
    geom_sketch_ellipse(fill = "salmon", seed = 2L) + ggplot2::coord_equal()
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_circle outline-only (no fill) renders", {
  df <- data.frame(x = 1, y = 1, r = 1)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, r = r)) +
    geom_sketch_circle(seed = 1L) + ggplot2::coord_equal()
  expect_gt(png_render(p), 0)
})

test_that("sketch_ellipse_grob is a SketchEllipseGrob gTree", {
  g <- sketch_ellipse_grob(0.5, 0.5, 0.2, 0.3, seed = 1L)
  expect_s3_class(g, "SketchEllipseGrob")
  expect_s3_class(g, "gTree")
})

test_that("geom_sketch_circle empty data returns minimal grob", {
  grob <- GeomSketchEllipse$draw_panel(
    data.frame(), list(), ggplot2::coord_cartesian(), seed = 1L
  )
  expect_s3_class(grob, "grob")
})
