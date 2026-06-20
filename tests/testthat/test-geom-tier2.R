# Tier 2 geoms: count, function, qq/qq_line, quantile, rug, spoke, curve,
# bin2d. Build + render + edge-case coverage.

png_render <- function(p) {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  png(tmp, width = 5, height = 4, units = "in", res = 72)
  print(p)
  dev.off()
  file.size(tmp)
}

# ---- count ------------------------------------------------------------------

test_that("geom_sketch_count() builds and renders", {
  p <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(cty, hwy)) +
    geom_sketch_count(seed = 1L)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

# ---- function ---------------------------------------------------------------

test_that("geom_sketch_function() draws an analytic curve", {
  p <- ggplot2::ggplot(data.frame(x = c(-3, 3)), ggplot2::aes(x)) +
    geom_sketch_function(fun = dnorm, seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

# ---- qq / qq_line -----------------------------------------------------------

test_that("geom_sketch_qq() + qq_line() build and render", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(sample = mpg)) +
    geom_sketch_qq(seed = 1L) +
    geom_sketch_qq_line(seed = 2L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

# ---- quantile ---------------------------------------------------------------

test_that("geom_sketch_quantile() renders when quantreg is available", {
  skip_if_not_installed("quantreg")
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_quantile(seed = 1L)
  expect_gt(suppressWarnings(png_render(p)), 0)
})

# ---- rug --------------------------------------------------------------------

test_that("geom_sketch_rug() builds and renders for all sides", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    geom_sketch_rug(sides = "trbl", seed = 2L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_rug() handles x-only mapping", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(x = wt)) +
    geom_sketch_rug(seed = 1L)
  expect_gt(png_render(p), 0)
})

# ---- spoke ------------------------------------------------------------------

test_that("geom_sketch_spoke() computes xend/yend and renders", {
  df <- expand.grid(x = 1:4, y = 1:4)
  df$angle <- seq(0, 2 * pi, length.out = nrow(df))
  df$radius <- 0.5
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_spoke(ggplot2::aes(angle = angle, radius = radius), seed = 1L)
  built <- ggplot2::ggplot_build(p)
  expect_true(all(c("xend", "yend") %in% names(built$data[[1]])))
  expect_gt(png_render(p), 0)
})

# ---- curve ------------------------------------------------------------------

test_that("geom_sketch_curve() builds and renders", {
  df <- data.frame(x = 1, y = 1, xend = 3, yend = 3)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_curve(ggplot2::aes(xend = xend, yend = yend),
                      curvature = 0.4, seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_curve() is reproducible with a seed", {
  df <- data.frame(x = 1, y = 1, xend = 3, yend = 3)
  mk <- function() {
    p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
      geom_sketch_curve(ggplot2::aes(xend = xend, yend = yend), seed = 7L)
    png_render(p)
  }
  expect_equal(mk(), mk())
})

# ---- bin2d ------------------------------------------------------------------

test_that("geom_sketch_bin2d() builds and renders", {
  p <- ggplot2::ggplot(faithful, ggplot2::aes(eruptions, waiting)) +
    geom_sketch_bin2d(bins = 10, seed = 1L)
  expect_no_error(suppressWarnings(ggplot2::ggplot_build(p)))
  expect_gt(suppressWarnings(png_render(p)), 0)
})

test_that("geom_sketch_bin_2d() is an alias for geom_sketch_bin2d()", {
  expect_identical(geom_sketch_bin_2d, geom_sketch_bin2d)
})

# ---- empty-data edge cases --------------------------------------------------

test_that("Tier 2 geoms tolerate empty data", {
  empty <- data.frame(x = numeric(0), y = numeric(0),
                      xend = numeric(0), yend = numeric(0))
  expect_no_error(GeomSketchCurve$draw_panel(
    empty, list(x.range = c(0, 1), y.range = c(0, 1)),
    ggplot2::coord_cartesian()
  ))
  expect_no_error(GeomSketchRug$draw_panel(
    empty, list(x.range = c(0, 1), y.range = c(0, 1)),
    ggplot2::coord_cartesian()
  ))
})
