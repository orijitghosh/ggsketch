# T-v2: connector geoms - dumbbell and slope graph.

grob_classes <- function(g) {
  out <- class(g)
  if (!is.null(g$grobs))    out <- c(out, unlist(lapply(g$grobs, grob_classes)))
  if (!is.null(g$children)) out <- c(out, unlist(lapply(g$children, grob_classes)))
  out
}

# ---- dumbbell ---------------------------------------------------------------

test_that("geom_sketch_dumbbell builds and exposes params", {
  df <- data.frame(g = c("A", "B", "C"), before = c(20, 35, 28),
                   after = c(34, 51, 22))
  p <- ggplot2::ggplot(df, ggplot2::aes(x = before, xend = after, y = g)) +
    geom_sketch_dumbbell(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_true(all(c("colour_x", "colour_xend") %in%
                    GeomSketchDumbbell$parameters()))
  expect_setequal(GeomSketchDumbbell$required_aes, c("x", "xend", "y"))
})

test_that("dumbbell draws connectors and dots", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  df <- data.frame(g = c("A", "B"), before = c(20, 35), after = c(34, 51))
  p <- ggplot2::ggplot(df, ggplot2::aes(x = before, xend = after, y = g)) +
    geom_sketch_dumbbell(seed = 1L)
  gt <- ggplot2::ggplotGrob(p)
  cls <- grob_classes(gt)
  expect_true("SketchPathGrob" %in% cls)   # connectors
  expect_true("SketchPointGrob" %in% cls)  # end dots
  expect_no_error(grid::grid.draw(gt))
})

test_that("dumbbell value axis spans both endpoints", {
  df <- data.frame(g = c("A", "B"), before = c(20, 35), after = c(60, 51))
  d <- ggplot2::layer_data(
    ggplot2::ggplot(df, ggplot2::aes(x = before, xend = after, y = g)) +
      geom_sketch_dumbbell(seed = 1L)
  )
  expect_true(all(c("x", "xend") %in% names(d)))
  expect_equal(max(d$xend), 60)
})

test_that("dumbbell with no rows is a nullGrob", {
  df <- data.frame(before = numeric(0), after = numeric(0), g = character(0))
  g <- GeomSketchDumbbell$draw_panel(df, NULL, NULL)
  expect_s3_class(g, "null")
})

# ---- slope ------------------------------------------------------------------

test_that("geom_sketch_slope builds and exposes params", {
  df <- data.frame(
    time  = rep(c("Before", "After"), each = 3),
    value = c(20, 35, 28, 34, 51, 22),
    who   = rep(c("A", "B", "C"), 2)
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(time, value, group = who, colour = who)) +
    geom_sketch_slope(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_true("point_roughness" %in% GeomSketchSlope$parameters())
})

test_that("slope draws one line per group plus vertex dots", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  df <- data.frame(
    time  = rep(c("Before", "After"), each = 2),
    value = c(20, 35, 34, 51),
    who   = rep(c("A", "B"), 2)
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(time, value, group = who)) +
    geom_sketch_slope(seed = 1L)
  gt <- ggplot2::ggplotGrob(p)
  cls <- grob_classes(gt)
  expect_true("SketchPathGrob" %in% cls)
  expect_true("SketchPointGrob" %in% cls)
  expect_no_error(grid::grid.draw(gt))
})

test_that("slope with no rows is a nullGrob", {
  df <- data.frame(x = numeric(0), y = numeric(0), group = integer(0))
  g <- GeomSketchSlope$draw_panel(df, NULL, NULL)
  expect_s3_class(g, "null")
})
