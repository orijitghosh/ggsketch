# T-v2: geom_sketch_streamgraph() - stacked area with a floating baseline.

grob_classes <- function(g) {
  out <- class(g)
  if (!is.null(g$grobs))    out <- c(out, unlist(lapply(g$grobs, grob_classes)))
  if (!is.null(g$children)) out <- c(out, unlist(lapply(g$children, grob_classes)))
  out
}

stream_df <- function() {
  df <- expand.grid(t = 1:8, grp = c("a", "b", "c"))
  df$v <- abs(sin(df$t / 2 + match(df$grp, letters)) + 1.2) * 4
  df
}

test_that("geom_sketch_streamgraph builds", {
  p <- ggplot2::ggplot(stream_df(), ggplot2::aes(t, v, fill = grp)) +
    geom_sketch_streamgraph(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_s3_class(StatSketchStream, "Stat")
})

test_that("the stat produces stacked, gap-free bands", {
  d <- ggplot2::layer_data(
    ggplot2::ggplot(stream_df(), ggplot2::aes(t, v, fill = grp)) +
      geom_sketch_streamgraph(seed = 1L)
  )
  expect_true(all(c("ymin", "ymax") %in% names(d)))
  # within an x, ordering bands by group, each top meets the next bottom
  for (xv in unique(d$x)) {
    s <- d[d$x == xv, ]
    s <- s[order(s$group), ]
    expect_equal(s$ymax[-nrow(s)], s$ymin[-1], tolerance = 1e-8)
  }
})

test_that("silhouette is centred; zero rests on 0", {
  sil <- ggplot2::layer_data(
    ggplot2::ggplot(stream_df(), ggplot2::aes(t, v, fill = grp)) +
      geom_sketch_streamgraph(offset = "silhouette", seed = 1L)
  )
  for (xv in unique(sil$x)) {
    s <- sil[sil$x == xv, ]
    expect_equal(min(s$ymin), -max(s$ymax), tolerance = 1e-8)
  }
  zero <- ggplot2::layer_data(
    ggplot2::ggplot(stream_df(), ggplot2::aes(t, v, fill = grp)) +
      geom_sketch_streamgraph(offset = "zero", seed = 1L)
  )
  expect_equal(min(zero$ymin), 0, tolerance = 1e-8)
})

test_that("wiggle offset builds", {
  p <- ggplot2::ggplot(stream_df(), ggplot2::aes(t, v, fill = grp)) +
    geom_sketch_streamgraph(offset = "wiggle", seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("streamgraph draws filled bands", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(stream_df(), ggplot2::aes(t, v, fill = grp)) +
    geom_sketch_streamgraph(seed = 1L)
  gt <- ggplot2::ggplotGrob(p)
  expect_true("SketchPolygonGrob" %in% grob_classes(gt))
  expect_no_error(grid::grid.draw(gt))
})

test_that("empty data builds without error", {
  df <- data.frame(t = numeric(0), v = numeric(0), grp = character(0))
  p <- ggplot2::ggplot(df, ggplot2::aes(t, v, fill = grp)) +
    geom_sketch_streamgraph(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})
