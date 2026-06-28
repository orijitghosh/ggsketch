# T-v2: treemap layout (Layer 1) + geom_sketch_treemap().

grob_classes <- function(g) {
  out <- class(g)
  if (!is.null(g$grobs))    out <- c(out, unlist(lapply(g$grobs, grob_classes)))
  if (!is.null(g$children)) out <- c(out, unlist(lapply(g$children, grob_classes)))
  out
}

tm_df <- function() data.frame(
  grp = c("Alpha", "Bravo", "Charlie", "Delta", "Echo"),
  val = c(40, 25, 15, 12, 8)
)

# ---- treemap_layout (Layer 1) ----------------------------------------------

test_that("treemap_layout tiles the unit square with proportional areas", {
  v <- c(6, 3, 2, 1)
  r <- treemap_layout(v)
  expect_equal(nrow(r), length(v))
  areas <- (r$xmax - r$xmin) * (r$ymax - r$ymin)
  # areas proportional to values, total == 1
  expect_equal(sum(areas), 1, tolerance = 1e-8)
  expect_equal(areas / sum(areas), v / sum(v), tolerance = 1e-8)
})

test_that("rectangles stay inside the bounding box and don't overlap much", {
  r <- treemap_layout(c(5, 4, 3, 2, 1), x = 0, y = 0, width = 2, height = 1)
  expect_true(all(r$xmin >= -1e-9 & r$xmax <= 2 + 1e-9))
  expect_true(all(r$ymin >= -1e-9 & r$ymax <= 1 + 1e-9))
  expect_equal(sum((r$xmax - r$xmin) * (r$ymax - r$ymin)), 2, tolerance = 1e-8)
})

test_that("zero / negative values give zero-area tiles", {
  r <- treemap_layout(c(3, 0, -1, 2))
  a <- (r$xmax - r$xmin) * (r$ymax - r$ymin)
  expect_equal(a[2], 0)
  expect_equal(a[3], 0)
  expect_gt(a[1], 0)
})

test_that("empty and all-zero inputs are handled", {
  expect_equal(nrow(treemap_layout(numeric(0))), 0L)
  r <- treemap_layout(c(0, 0))
  expect_true(all((r$xmax - r$xmin) * (r$ymax - r$ymin) == 0))
})

# ---- geom_sketch_treemap ----------------------------------------------------

test_that("geom_sketch_treemap builds and computes rect bounds", {
  d <- ggplot2::layer_data(
    ggplot2::ggplot(tm_df(), ggplot2::aes(area = val, fill = grp)) +
      geom_sketch_treemap(seed = 1L)
  )
  expect_true(all(c("xmin", "xmax", "ymin", "ymax") %in% names(d)))
  expect_equal(nrow(d), 5L)
})

test_that("treemap draws rects, and labels when mapped", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(tm_df(),
                       ggplot2::aes(area = val, fill = grp, label = grp)) +
    geom_sketch_treemap(seed = 1L)
  gt <- ggplot2::ggplotGrob(p)
  cls <- grob_classes(gt)
  expect_true("SketchPolygonGrob" %in% cls)
  expect_true(any(grepl("text", cls)))
  expect_no_error(grid::grid.draw(gt))
})

test_that("no labels without a label mapping", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(tm_df(), ggplot2::aes(area = val, fill = grp)) +
    geom_sketch_treemap(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("empty data builds without error", {
  df <- data.frame(val = numeric(0), grp = character(0))
  p <- ggplot2::ggplot(df, ggplot2::aes(area = val, fill = grp)) +
    geom_sketch_treemap(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})
