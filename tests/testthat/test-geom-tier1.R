# Tier 1 geoms: histogram, freqpoly, jitter, violin, interval family,
# reference lines. Build + render + edge-case coverage.

png_render <- function(p) {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  png(tmp, width = 5, height = 4, units = "in", res = 72)
  print(p)
  dev.off()
  file.size(tmp)
}

# ---- histogram / freqpoly ---------------------------------------------------

test_that("geom_sketch_histogram() builds and renders", {
  p <- ggplot2::ggplot(faithful, ggplot2::aes(eruptions)) +
    geom_sketch_histogram(bins = 15, seed = 1L)
  expect_s3_class(p, "ggplot")
  expect_no_error(suppressWarnings(ggplot2::ggplot_build(p)))
  expect_gt(suppressWarnings(png_render(p)), 0)
})

test_that("geom_sketch_freqpoly() builds and renders", {
  p <- ggplot2::ggplot(faithful, ggplot2::aes(eruptions)) +
    geom_sketch_freqpoly(bins = 15, seed = 1L)
  expect_gt(suppressWarnings(png_render(p)), 0)
})

# ---- jitter -----------------------------------------------------------------

test_that("geom_sketch_jitter() builds and renders", {
  p <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(class, hwy)) +
    geom_sketch_jitter(width = 0.2, seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_jitter is reproducible with a seed", {
  p <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(class, hwy)) +
    geom_sketch_jitter(seed = 1L)
  b1 <- ggplot2::layer_data(p)
  b2 <- ggplot2::layer_data(p)
  expect_equal(b1$x, b2$x)
})

# ---- violin -----------------------------------------------------------------

test_that("geom_sketch_violin() builds and renders", {
  p <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(class, hwy)) +
    geom_sketch_violin(fill = "#A3D9A5", seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_violin all fill styles render", {
  for (s in c("hachure", "cross_hatch", "solid")) {
    p <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(drv, hwy)) +
      geom_sketch_violin(fill_style = s, seed = 1L)
    expect_gt(png_render(p), 0)
  }
})

# ---- interval family --------------------------------------------------------

ints <- data.frame(x = c("a", "b", "c"), y = c(2, 5, 4),
                   lo = c(1, 4, 2.5), hi = c(3, 6, 5.5))

test_that("geom_sketch_linerange() renders", {
  p <- ggplot2::ggplot(ints, ggplot2::aes(x, y)) +
    geom_sketch_linerange(ggplot2::aes(ymin = lo, ymax = hi), seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_pointrange() renders", {
  p <- ggplot2::ggplot(ints, ggplot2::aes(x, y)) +
    geom_sketch_pointrange(ggplot2::aes(ymin = lo, ymax = hi), seed = 1L)
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_errorbar() renders", {
  p <- ggplot2::ggplot(ints, ggplot2::aes(x, y)) +
    geom_sketch_errorbar(ggplot2::aes(ymin = lo, ymax = hi), seed = 1L)
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_crossbar() renders", {
  p <- ggplot2::ggplot(ints, ggplot2::aes(x, y)) +
    geom_sketch_crossbar(ggplot2::aes(ymin = lo, ymax = hi),
                         fill_style = "hachure", seed = 1L)
  expect_gt(png_render(p), 0)
})

test_that("interval geoms with empty data return minimal grobs", {
  for (G in list(GeomSketchLinerange, GeomSketchErrorbar)) {
    grob <- G$draw_panel(data.frame(), list(),
                         ggplot2::coord_cartesian(), seed = 1L)
    expect_s3_class(grob, "grob")
  }
})

# ---- reference lines --------------------------------------------------------

test_that("geom_sketch_hline() / vline() / abline() render", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    geom_sketch_hline(yintercept = 20, colour = "red", seed = 2L) +
    geom_sketch_vline(xintercept = 3, colour = "blue", seed = 3L) +
    geom_sketch_abline(slope = -5, intercept = 37, seed = 4L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_hline accepts multiple intercepts", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    geom_sketch_hline(yintercept = c(15, 20, 25), seed = 2L)
  expect_equal(nrow(ggplot2::layer_data(p, 2)), 3L)
  expect_gt(png_render(p), 0)
})

test_that("reference-line geoms have correct required_aes", {
  expect_equal(GeomSketchAbline$required_aes, c("slope", "intercept"))
  expect_equal(GeomSketchHline$required_aes, "yintercept")
  expect_equal(GeomSketchVline$required_aes, "xintercept")
})
