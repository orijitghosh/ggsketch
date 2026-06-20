# Sketch colour/fill scales (v1.4).

png_render <- function(p) {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  if (requireNamespace("ragg", quietly = TRUE)) {
    ragg::agg_png(tmp, width = 5, height = 4, units = "in", res = 72)
  } else {
    png(tmp, width = 5, height = 4, units = "in", res = 72)
  }
  print(p)
  dev.off()
  file.size(tmp)
}

test_that("sketch_palette() returns the requested colours", {
  expect_length(sketch_palette(3), 3)
  expect_length(sketch_palette(), 8)
  expect_identical(sketch_palette(1), "#7BAFD4")
  expect_warning(sketch_palette(99), "recycled|palette")
})

test_that("discrete scales build and render", {
  p <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(displ, hwy, colour = drv)) +
    geom_sketch_point(seed = 1L) +
    scale_colour_sketch()
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)

  pf <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(class, fill = drv)) +
    geom_sketch_bar() +
    scale_fill_sketch()
  expect_no_error(ggplot2::ggplot_build(pf))
})

test_that("scale_color_sketch is an alias", {
  expect_identical(scale_color_sketch, scale_colour_sketch)
})

test_that("continuous scales build", {
  p <- ggplot2::ggplot(faithful, ggplot2::aes(eruptions, waiting, colour = waiting)) +
    geom_sketch_point(seed = 1L) +
    scale_colour_sketch_c()
  expect_no_error(ggplot2::ggplot_build(p))
})
