# Tier 3 geoms (first batch): contour, density2d, hex, text/label.
# Build + render + edge-case coverage.

png_render <- function(p) {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  png(tmp, width = 5, height = 4, units = "in", res = 72)
  print(p)
  dev.off()
  file.size(tmp)
}

# ---- contour ----------------------------------------------------------------

test_that("geom_sketch_contour() builds and renders", {
  p <- ggplot2::ggplot(ggplot2::faithfuld,
                       ggplot2::aes(waiting, eruptions, z = density)) +
    geom_sketch_contour(seed = 1L)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

# ---- density2d --------------------------------------------------------------

test_that("geom_sketch_density2d() builds and renders", {
  p <- ggplot2::ggplot(faithful, ggplot2::aes(eruptions, waiting)) +
    geom_sketch_density2d(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_density_2d() is an alias", {
  expect_identical(geom_sketch_density_2d, geom_sketch_density2d)
})

# ---- hex --------------------------------------------------------------------

test_that("geom_sketch_hex() renders when hexbin is available", {
  skip_if_not_installed("hexbin")
  p <- ggplot2::ggplot(faithful, ggplot2::aes(eruptions, waiting)) +
    geom_sketch_hex(bins = 10, seed = 1L)
  expect_no_error(suppressWarnings(ggplot2::ggplot_build(p)))
  expect_gt(suppressWarnings(png_render(p)), 0)
})

# ---- text / label -----------------------------------------------------------

test_that("geom_sketch_text() builds and renders", {
  df <- data.frame(x = 1:3, y = c(2, 3, 1), lab = c("a", "b", "c"))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = lab)) +
    geom_sketch_text(size = 6)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_label() builds and renders", {
  df <- data.frame(x = 1:3, y = c(2, 3, 1), lab = c("a", "b", "c"))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = lab)) +
    geom_sketch_label(size = 5)
  expect_gt(png_render(p), 0)
})

# ---- empty-data edge cases --------------------------------------------------

test_that("Tier 3 hex tolerates empty data", {
  empty <- data.frame(x = numeric(0), y = numeric(0), fill = character(0))
  expect_no_error(GeomSketchHex$draw_group(
    empty, list(x.range = c(0, 1), y.range = c(0, 1)),
    ggplot2::coord_cartesian()
  ))
})
