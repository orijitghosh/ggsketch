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
  # First eight are the anchors, verbatim.
  expect_identical(sketch_palette(8), sketch_palette())
})

test_that("sketch_palette() interpolates beyond eight colours by default", {
  p20 <- sketch_palette(20)
  expect_length(p20, 20)
  expect_silent(sketch_palette(20))            # no recycling warning
  expect_false(any(duplicated(p20)))           # distinct, not recycled
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", p20)))
  # The ramp starts at (near) the primary anchor.
  start_rgb <- grDevices::col2rgb(p20[1])
  expect_lt(max(abs(start_rgb - grDevices::col2rgb("#7BAFD4"))), 4)
})

test_that("sketch_palette(interpolate = FALSE) recycles with a warning", {
  expect_warning(rc <- sketch_palette(12, interpolate = FALSE), "recycled|palette")
  expect_identical(rc[1:8], sketch_palette(8))
  expect_identical(rc[9], rc[1])
})

test_that("discrete scales interpolate for many-level factors", {
  df <- data.frame(x = 1:15, y = 1:15, g = factor(letters[1:15]))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, colour = g)) +
    geom_sketch_point(seed = 1L) +
    scale_colour_sketch()
  b <- ggplot2::ggplot_build(p)
  cols <- unique(b$data[[1]]$colour)
  expect_length(cols, 15)                      # 15 distinct, not 8 recycled
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
