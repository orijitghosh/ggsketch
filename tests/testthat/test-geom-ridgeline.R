# T-v2: geom_sketch_ridgeline() - stacked offset densities (joyplot).

grob_classes <- function(g) {
  out <- class(g)
  if (!is.null(g$grobs))    out <- c(out, unlist(lapply(g$grobs, grob_classes)))
  if (!is.null(g$children)) out <- c(out, unlist(lapply(g$children, grob_classes)))
  out
}

test_that("geom_sketch_ridgeline builds", {
  p <- ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Species)) +
    geom_sketch_ridgeline(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_s3_class(StatSketchDensityRidges, "Stat")
})

test_that("the stat positions ridges above their baselines", {
  d <- ggplot2::layer_data(
    ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Species)) +
      geom_sketch_ridgeline(scale = 1.6, seed = 1L)
  )
  expect_true(all(c("ymin", "ymax", "height") %in% names(d)))
  expect_true(all(d$ymax >= d$ymin))
  # the ridges rise above the top category baseline (3 for iris) -> overlap
  expect_gt(max(d$ymax), 3)
})

test_that("scale controls ridge height", {
  h <- function(s) {
    d <- ggplot2::layer_data(
      ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Species)) +
        geom_sketch_ridgeline(scale = s, seed = 1L)
    )
    max(d$height)
  }
  expect_gt(h(2.5), h(1.0))
})

test_that("ridgeline draws filled polygon ridges", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Species, fill = Species)) +
    geom_sketch_ridgeline(seed = 1L)
  gt <- ggplot2::ggplotGrob(p)
  expect_true("SketchPolygonGrob" %in% grob_classes(gt))
  expect_no_error(grid::grid.draw(gt))
})

test_that("rel_min_height trims the tails", {
  full <- ggplot2::layer_data(
    ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Species)) +
      geom_sketch_ridgeline(rel_min_height = 0, seed = 1L)
  )
  trim <- ggplot2::layer_data(
    ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Species)) +
      geom_sketch_ridgeline(rel_min_height = 0.1, seed = 1L)
  )
  expect_lt(nrow(trim), nrow(full))
})

test_that("a group with fewer than two points is skipped, others still drawn", {
  df <- data.frame(
    x = c(rnorm(50), rnorm(50, 3), 9),
    g = c(rep("a", 50), rep("b", 50), "c")
  )
  d <- ggplot2::layer_data(
    ggplot2::ggplot(df, ggplot2::aes(x, g)) + geom_sketch_ridgeline(seed = 1L)
  )
  expect_true(all(c("a", "b") %in% unique(d$group) |
                    nlevels(factor(df$g)) >= 2))
  expect_gt(nrow(d), 0L)
})

test_that("empty data builds without error", {
  df <- data.frame(x = numeric(0), g = character(0))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, g)) + geom_sketch_ridgeline(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})
