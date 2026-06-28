# T-v2: geom_sketch_beeswarm() - deterministic data-space dot swarm.

test_that("geom_sketch_beeswarm builds", {
  p <- ggplot2::ggplot(iris, ggplot2::aes(Species, Sepal.Length)) +
    geom_sketch_beeswarm(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("the swarm offsets x within a category", {
  d <- ggplot2::layer_data(
    ggplot2::ggplot(iris, ggplot2::aes(Species, Sepal.Length)) +
      geom_sketch_beeswarm(seed = 1L)
  )
  # group 1 (setosa) sits at integer x = 1; the swarm must spread some points
  # off that centre.
  x1 <- d$x[d$group == 1L]
  expect_gt(stats::sd(x1), 0)
  expect_true(any(abs(x1 - 1) > 1e-6))
})

test_that("swarm offsets stay within the category band", {
  d <- ggplot2::layer_data(
    ggplot2::ggplot(iris, ggplot2::aes(Species, Sepal.Length)) +
      geom_sketch_beeswarm(seed = 1L)
  )
  centres <- as.numeric(d$group)
  expect_true(all(abs(d$x - centres) <= 0.5 + 1e-9))
})

test_that("width widens the swarm", {
  base <- ggplot2::layer_data(
    ggplot2::ggplot(iris, ggplot2::aes(Species, Sepal.Length)) +
      geom_sketch_beeswarm(seed = 1L)
  )
  wide <- ggplot2::layer_data(
    ggplot2::ggplot(iris, ggplot2::aes(Species, Sepal.Length)) +
      geom_sketch_beeswarm(width = 0.08, seed = 1L)
  )
  spread <- function(z) diff(range(z$x[z$group == 1L]))
  expect_gt(spread(wide), spread(base))
})

test_that("the swarm is deterministic", {
  f <- function() ggplot2::layer_data(
    ggplot2::ggplot(iris, ggplot2::aes(Species, Sepal.Length)) +
      geom_sketch_beeswarm(seed = 1L)
  )$x
  expect_identical(f(), f())
})

test_that("stat is a Stat and renders", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  expect_s3_class(StatSketchBeeswarm, "Stat")
  p <- ggplot2::ggplot(iris, ggplot2::aes(Species, Sepal.Length)) +
    geom_sketch_beeswarm(seed = 1L)
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})

test_that("empty data builds without error", {
  df <- data.frame(g = character(0), y = numeric(0))
  p <- ggplot2::ggplot(df, ggplot2::aes(g, y)) + geom_sketch_beeswarm(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})
