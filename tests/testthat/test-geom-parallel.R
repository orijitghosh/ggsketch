# geom_sketch_parallel() - parallel-coordinates plots. Layout is pure arithmetic
# (parallel_layout); the constructor returns a list of sketch layers.

ax <- c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")

test_that("parallel_rescale01 maps to [0,1] and handles constants", {
  expect_equal(range(ggsketch:::parallel_rescale01(c(2, 4, 6))), c(0, 1))
  expect_equal(ggsketch:::parallel_rescale01(c(5, 5, 5)), rep(0.5, 3))
})

test_that("parallel_layout returns lines, axes, labels", {
  lay <- ggsketch:::parallel_layout(iris, axes = ax)
  expect_named(lay, c("lines", "axes", "labels", "ranges", "axis_names"))
  # one vertex per observation per axis
  expect_equal(nrow(lay$lines), nrow(iris) * length(ax))
  expect_equal(nrow(lay$axes), length(ax))
  # scaled values within [0,1]
  expect_gte(min(lay$lines$y), 0)
  expect_lte(max(lay$lines$y), 1)
  # one polyline per observation
  expect_equal(length(unique(lay$lines$id)), nrow(iris))
})

test_that("scale = none keeps raw values", {
  lay <- ggsketch:::parallel_layout(iris, axes = ax, scale = "none")
  expect_gt(max(lay$lines$y), 1)   # raw Sepal.Length etc exceed 1
})

test_that("fewer than 2 axes errors", {
  expect_error(ggsketch:::parallel_layout(iris, axes = "Sepal.Length"),
               "at least 2 axes")
})

test_that("missing columns error", {
  expect_error(ggsketch:::parallel_layout(iris, axes = c("Sepal.Length", "Nope")),
               "not found")
})

test_that("geom_sketch_parallel returns layers and builds", {
  layers <- geom_sketch_parallel(iris, axes = ax, colour = "Species", seed = 1L)
  expect_type(layers, "list")
  expect_gte(length(layers), 2L)
  p <- ggplot2::ggplot() + layers + scale_colour_sketch()
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("a constant line colour builds without a colour column", {
  layers <- geom_sketch_parallel(iris, axes = ax, line_colour = "#1F618D",
                                 seed = 2L)
  expect_silent(ggplot2::ggplot_build(ggplot2::ggplot() + layers))
})

test_that("an unknown colour column errors", {
  expect_error(geom_sketch_parallel(iris, axes = ax, colour = "Nope"),
               "not found")
})

test_that("label = FALSE drops the label layer", {
  a <- geom_sketch_parallel(iris, axes = ax, label = TRUE)
  b <- geom_sketch_parallel(iris, axes = ax, label = FALSE)
  expect_equal(length(a) - length(b), 1L)
})
