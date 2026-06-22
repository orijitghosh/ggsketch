# T-ANNOT: arrows, hull marks, and callouts (v1.7 annotation toolkit)

# ---- arrows -----------------------------------------------------------------

test_that("sketch_arrow_grob renders shaft + head and is reproducible", {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  mk <- function() sketch_arrow_grob(
    x0 = 0.2, y0 = 0.2, cx = 0.4, cy = 0.7, x1 = 0.8, y1 = 0.8,
    seed = 1L, gp = grid::gpar(col = "black"))
  a <- grid::makeContent(mk())$children
  # 2 shaft passes + 2 head passes (open, n_passes = 2)
  expect_length(a, 4L)
  xs <- function(g) lapply(unname(grid::makeContent(g)$children),
                           function(z) as.numeric(z$x))
  expect_identical(xs(mk()), xs(mk()))
})

test_that("closed arrowhead draws a filled polygon", {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  g <- sketch_arrow_grob(0.2, 0.2, 0.5, 0.5, 0.8, 0.8,
                         arrow_type = "closed", seed = 1L,
                         gp = grid::gpar(col = "black"))
  cls <- vapply(grid::makeContent(g)$children, function(z) class(z)[1], "")
  expect_true("polygon" %in% cls)
})

test_that("geom_sketch_arrow and annotate_sketch_arrow build", {
  p1 <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    annotate_sketch_arrow(x = 4.5, y = 30, xend = 5.25, yend = 18,
                          label = "heavy", seed = 2L)
  expect_no_error(ggplot2::ggplot_build(p1))

  adf <- data.frame(x = c(2, 4), y = c(30, 15),
                    xend = c(3, 5), yend = c(22, 20))
  p2 <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_arrow(data = adf,
                      ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
                      inherit.aes = FALSE, seed = 3L)
  expect_no_error(ggplot2::ggplot_build(p2))
})

test_that("annotate_sketch_arrow validates lengths and omits label cleanly", {
  expect_error(
    annotate_sketch_arrow(x = c(1, 2), y = 1, xend = c(1, 2, 3), yend = 1),
    "length"
  )
  # no label -> mapping has no label aesthetic
  lyr <- annotate_sketch_arrow(x = 1, y = 1, xend = 2, yend = 2)
  expect_false("label" %in% names(lyr$mapping))
})

# ---- mark hull --------------------------------------------------------------

test_that("geom_sketch_mark_hull builds and exposes its params", {
  expect_true(all(c("expand", "roughness") %in%
                    GeomSketchMarkHull$parameters()))
  p <- ggplot2::ggplot(iris,
                       ggplot2::aes(Sepal.Length, Sepal.Width, group = Species)) +
    geom_sketch_mark_hull(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("mark hull with fewer than 3 points draws nothing (no error)", {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  df <- data.frame(x = c(1, 2), y = c(1, 2))
  p  <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_mark_hull(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})

# ---- callouts ---------------------------------------------------------------

test_that("sketch_callout_grob sizes its box to the label", {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  short <- sketch_callout_grob(0.5, 0.5, NA, NA, "x",
                               seed = 1L, box_gp = grid::gpar(col = "black"))
  long  <- sketch_callout_grob(0.5, 0.5, NA, NA, "a much longer label",
                               seed = 1L, box_gp = grid::gpar(col = "black"))
  box_x <- function(g) {
    kids <- grid::makeContent(g)$children
    # the box outline is a polyline; take the widest one
    max(vapply(kids, function(z) {
      if (inherits(z, "polyline")) diff(range(as.numeric(z$x))) else 0
    }, numeric(1)))
  }
  expect_gt(box_x(long), box_x(short))
})

test_that("geom_sketch_callout and annotate_sketch_callout build", {
  p1 <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    annotate_sketch_callout(x = 4, y = 32, label = "outlier?",
                            xend = 5.25, yend = 18, seed = 2L)
  expect_no_error(ggplot2::ggplot_build(p1))

  # boxed label with no leader
  p2 <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    annotate_sketch_callout(x = 4, y = 32, label = "note", seed = 3L)
  expect_no_error(ggplot2::ggplot_build(p2))
})
