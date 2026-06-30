# T-v2: pressure as a mappable aesthetic on the path-like geoms.

# ---- Layer-3 helpers --------------------------------------------------------

test_that("make_pressure_fn interpolates per-vertex values over arc-length", {
  x <- c(0, 1, 2); y <- c(0, 0, 0)
  f <- make_pressure_fn(c(0.2, 1, 2), x, y)
  expect_type(f, "closure")
  # Ends hit the anchor values; midpoint is between them.
  expect_equal(f(0), 0.2)
  expect_equal(f(1), 2)
  mid <- f(0.5)
  expect_true(mid > 0.2 && mid < 2)
  # rule = 2 clamps outside [0, 1]; never negative.
  expect_equal(f(-0.5), 0.2)
  expect_gte(min(f(seq(0, 1, length.out = 20))), 0)
})

test_that("make_pressure_fn tolerates degenerate input", {
  expect_equal(make_pressure_fn(numeric(0), numeric(0), numeric(0))(c(0, 1)),
               c(1, 1))
  expect_equal(make_pressure_fn(0.7, 0, 0)(c(0, 0.5, 1)), rep(0.7, 3))
  # Duplicate vertices (zero-length segment) must not error.
  f <- make_pressure_fn(c(1, 1, 2), c(0, 0, 1), c(0, 0, 0))
  expect_silent(f(seq(0, 1, length.out = 5)))
})

test_that("compose_pressure multiplies profiles, NULL is identity", {
  a <- function(t) rep(2, length(t))
  b <- function(t) t
  expect_identical(compose_pressure(NULL, b), b)
  expect_identical(compose_pressure(a, NULL), a)
  expect_equal(compose_pressure(a, b)(c(0, 0.5, 1)), c(0, 1, 2))
})

# ---- grob dispatch ----------------------------------------------------------

test_that("a pressure mapping forces a stroke ribbon even for medium='pen'", {
  g0 <- sketch_medium_grob(c(0.1, 0.5, 0.9), c(0.2, 0.8, 0.3), medium = "pen",
                           colour = "black", seed = 1L)
  expect_s3_class(g0, "SketchPathGrob")           # no pressure: unchanged

  g1 <- sketch_medium_grob(c(0.1, 0.5, 0.9), c(0.2, 0.8, 0.3), medium = "pen",
                           colour = "black", seed = 1L,
                           pressure_var = c(0.3, 1, 1.6))
  expect_s3_class(g1, "SketchStrokeGrob")          # pressure: ribbon
})

test_that("a length-mismatched / all-NA pressure is ignored", {
  g <- sketch_medium_grob(c(0.1, 0.9), c(0.2, 0.8), medium = "pen",
                          colour = "black", seed = 1L,
                          pressure_var = c(NA_real_, NA_real_))
  expect_s3_class(g, "SketchPathGrob")
})

# ---- geom integration -------------------------------------------------------

test_that("geom_sketch_line / path build and render with aes(pressure=)", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  df <- data.frame(x = 1:40, y = sin(1:40), p = (1:40) / 40)
  p1 <- ggplot2::ggplot(df, ggplot2::aes(x, y, pressure = p)) +
    geom_sketch_line(linewidth = 1, seed = 1L)
  p2 <- ggplot2::ggplot(df, ggplot2::aes(x, y, pressure = p)) +
    geom_sketch_path(medium = "ink", linewidth = 1, seed = 1L)
  expect_no_error(print(p1))
  expect_no_error(print(p2))
})

test_that("scale_pressure_continuous rescales to the width band", {
  sc <- scale_pressure_continuous(range = c(0.5, 2))
  expect_s3_class(sc, "Scale")
  expect_identical(sc$aesthetics, "pressure")
  # The palette maps [0, 1] of the input domain onto the range.
  expect_equal(sc$palette(c(0, 1)), c(0.5, 2))
})
