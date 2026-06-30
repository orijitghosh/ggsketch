# T-v2: airbrush / spray - Layer-1 sampler + Layer-2 grob.

test_that("spray_scatter returns an x/y/r/a dot cloud along the path", {
  x <- seq(0, 2, length.out = 20); y <- rep(0, 20)
  d <- spray_scatter(x, y, spread = 0.05, density = 100, dot_r = 0.01, seed = 1L)
  expect_true(is.matrix(d))
  expect_identical(colnames(d), c("x", "y", "r", "a"))
  expect_gt(nrow(d), 0L)
  # density * arc-length dots (arc-length here is 2).
  expect_equal(nrow(d), 200L)
  # radii non-negative; weights in (0, 1].
  expect_gte(min(d[, "r"]), 0)
  expect_true(all(d[, "a"] > 0 & d[, "a"] <= 1))
  # Dots stay near the line: |y| rarely exceeds a few sigma.
  expect_lt(max(abs(d[, "y"])), 0.05 * 6)
})

test_that("spray_scatter is reproducible by seed and varies without one fixed", {
  x <- seq(0, 1, length.out = 10); y <- seq(0, 1, length.out = 10)
  a <- spray_scatter(x, y, seed = 7L)
  b <- spray_scatter(x, y, seed = 7L)
  expect_identical(a, b)
})

test_that("spray_scatter handles degenerate input", {
  empty <- spray_scatter(numeric(0), numeric(0))
  expect_equal(nrow(empty), 0L)
  expect_identical(colnames(empty), c("x", "y", "r", "a"))
  # A single point becomes a round puff.
  puff <- spray_scatter(0.5, 0.5, spread = 0.05, density = 100, dot_r = 0.01,
                        seed = 1L)
  expect_gt(nrow(puff), 0L)
  # Zero-length path (all duplicate vertices) -> empty, no error.
  expect_equal(nrow(spray_scatter(c(1, 1, 1), c(2, 2, 2))), 0L)
})

test_that("sketch_spray_grob builds and renders", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  g <- sketch_spray_grob(c(0.1, 0.5, 0.9), c(0.2, 0.8, 0.3),
                         gp = grid::gpar(col = "navy", alpha = 0.4), seed = 1L)
  expect_s3_class(g, "SketchSprayGrob")
  expect_no_error(grid::grid.draw(g))
})

test_that("geom_sketch_line renders with medium='spray'", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(ggplot2::economics[1:80, ],
                       ggplot2::aes(date, unemploy)) +
    geom_sketch_line(medium = "spray", linewidth = 1.2, seed = 1L)
  expect_no_error(print(p))
})
