# geom_sketch_dendrogram() - hierarchical-clustering trees. Layout is pure
# arithmetic over an hclust object; constructor returns sketch layers.

hc <- stats::hclust(stats::dist(mtcars[1:8, c("mpg", "wt", "hp")]))

test_that("dendro_layout returns one elbow group per merge and all leaves", {
  lay <- ggsketch:::dendro_layout(hc)
  expect_named(lay, c("segments", "leaves", "orientation", "hmax"))
  # n leaves -> n-1 merges
  expect_equal(length(unique(lay$segments$seg)), nrow(hc$merge))
  expect_equal(nrow(lay$leaves), length(hc$order))
  # leaves carry the labels in plotting order
  expect_setequal(lay$leaves$label, hc$labels)
})

test_that("up orientation puts merges above the leaf baseline", {
  lay <- ggsketch:::dendro_layout(hc, orientation = "up")
  expect_equal(min(lay$leaves$y), 0)
  expect_gt(max(lay$segments$y), 0)            # heights go up
})

test_that("orientations transform coordinates consistently", {
  up    <- ggsketch:::dendro_layout(hc, orientation = "up")
  right <- ggsketch:::dendro_layout(hc, orientation = "right")
  # right swaps axes: heights now span x, leaves span y
  expect_gt(max(right$segments$x), 0)
  expect_equal(max(up$segments$y), max(right$segments$x))
})

test_that("down flips height sign", {
  lay <- ggsketch:::dendro_layout(hc, orientation = "down")
  expect_lt(min(lay$segments$y), 0)
})

test_that("non-hclust input to dendro_layout errors", {
  expect_error(ggsketch:::dendro_layout(mtcars), "hclust")
})

test_that("geom_sketch_dendrogram builds from a numeric data frame", {
  layers <- geom_sketch_dendrogram(mtcars[1:8, c("mpg", "wt", "hp")], seed = 1L)
  expect_type(layers, "list")
  expect_silent(ggplot2::ggplot_build(
    ggplot2::ggplot() + layers + ggplot2::theme_void()))
})

test_that("geom_sketch_dendrogram builds from a ready hclust object", {
  layers <- geom_sketch_dendrogram(hc, orientation = "right", seed = 2L)
  expect_silent(ggplot2::ggplot_build(ggplot2::ggplot() + layers))
})

test_that("data with no numeric columns errors", {
  df <- data.frame(a = letters[1:3], b = LETTERS[1:3])
  expect_error(geom_sketch_dendrogram(df), "no numeric columns")
})

test_that("non-clusterable input errors", {
  expect_error(geom_sketch_dendrogram(list(1, 2, 3)),
               "hclust|numeric data frame")
})

test_that("label = FALSE drops the label layer", {
  a <- geom_sketch_dendrogram(hc, label = TRUE)
  b <- geom_sketch_dendrogram(hc, label = FALSE)
  expect_equal(length(a) - length(b), 1L)
})
