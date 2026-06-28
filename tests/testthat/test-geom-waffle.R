# T-v2: geom_sketch_waffle() - part-to-whole square grid.

grob_classes <- function(g) {
  out <- class(g)
  if (!is.null(g$grobs))    out <- c(out, unlist(lapply(g$grobs, grob_classes)))
  if (!is.null(g$children)) out <- c(out, unlist(lapply(g$children, grob_classes)))
  out
}

waffle_df <- function() data.frame(
  grp   = c("Rent", "Food", "Travel", "Other"),
  spend = c(45, 25, 20, 10)
)

test_that("geom_sketch_waffle builds", {
  p <- ggplot2::ggplot(waffle_df(), ggplot2::aes(fill = grp, weight = spend)) +
    geom_sketch_waffle(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_s3_class(StatSketchWaffle, "Stat")
})

test_that("cells sum to `cells` and grid has n_rows rows", {
  d <- ggplot2::layer_data(
    ggplot2::ggplot(waffle_df(), ggplot2::aes(fill = grp, weight = spend)) +
      geom_sketch_waffle(n_rows = 10L, cells = 100L, seed = 1L)
  )
  expect_equal(nrow(d), 100L)
  expect_equal(length(unique(d$y)), 10L)
})

test_that("cell counts follow the weights (largest-remainder)", {
  d <- ggplot2::layer_data(
    ggplot2::ggplot(waffle_df(), ggplot2::aes(fill = grp, weight = spend)) +
      geom_sketch_waffle(cells = 100L, seed = 1L)
  )
  # 45/25/20/10 of 100 -> exactly those counts
  tab <- as.integer(table(d$fill))
  expect_setequal(tab, c(45L, 25L, 20L, 10L))
})

test_that("unweighted data counts one cell per row", {
  df <- data.frame(g = rep(c("a", "b"), c(3, 1)))
  d <- ggplot2::layer_data(
    ggplot2::ggplot(df, ggplot2::aes(fill = g)) +
      geom_sketch_waffle(cells = 100L, seed = 1L)
  )
  tab <- as.integer(table(d$fill))
  expect_setequal(tab, c(75L, 25L))   # 3:1
})

test_that("waffle draws sketch rects", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(waffle_df(), ggplot2::aes(fill = grp, weight = spend)) +
    geom_sketch_waffle(seed = 1L)
  gt <- ggplot2::ggplotGrob(p)
  expect_true("SketchPolygonGrob" %in% grob_classes(gt))
  expect_no_error(grid::grid.draw(gt))
})

test_that("empty data builds without error", {
  df <- data.frame(g = character(0))
  p <- ggplot2::ggplot(df, ggplot2::aes(fill = g)) + geom_sketch_waffle(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})
