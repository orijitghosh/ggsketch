# Rect-family geoms under nonlinear coords (coord_polar) must bend their
# edges: straight-sided quads are densified before the coord transform.

test_that("densify_closed inserts points along every edge", {
  out <- densify_closed(c(0, 1, 1, 0), c(0, 0, 1, 1), n = 8L)
  expect_length(out$x, 4L * 8L)
  expect_length(out$y, 4L * 8L)
  # original corners survive as the first point of each edge
  expect_true(all(c(0, 1) %in% out$x))
  # points along the bottom edge interpolate between x = 0 and 1 at y = 0
  expect_true(any(out$x > 0 & out$x < 1 & out$y == 0))
})

test_that("densify_closed passes degenerate input through", {
  out <- densify_closed(1, 2, n = 8L)
  expect_equal(out, list(x = 1, y = 2))
  out2 <- densify_closed(c(0, 1), c(0, 1), n = 1L)
  expect_equal(out2, list(x = c(0, 1), y = c(0, 1)))
})

test_that("geom_sketch_col renders under coord_polar with curved edges", {
  df <- data.frame(g = letters[1:4], v = c(3, 5, 2, 4))
  p <- ggplot2::ggplot(df, ggplot2::aes(g, v)) +
    geom_sketch_col(seed = 1L) +
    ggplot2::coord_polar()
  expect_no_error(built <- ggplot2::ggplot_gtable(ggplot2::ggplot_build(p)))

  # the panel polygon grobs carry densified (arc-capable) boundaries
  gr <- ggplot2::layer_grob(p, 1)[[1]]
  expect_true(length(gr[[1]]$x) > 8L)
})

test_that("geom_sketch_rect under coord_polar builds cleanly", {
  df <- data.frame(xmin = 1, xmax = 3, ymin = 0, ymax = 2)
  p <- ggplot2::ggplot(df) +
    geom_sketch_rect(
      ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
      seed = 1L
    ) +
    ggplot2::coord_polar()
  expect_no_error(ggplot2::ggplot_gtable(ggplot2::ggplot_build(p)))
})
