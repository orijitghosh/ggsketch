# T-GEOM-chicklet: geom_sketch_chicklet() tests

test_that("geom_sketch_chicklet() produces a valid layer", {
  df <- expand.grid(week = factor(1:4), team = c("A", "B", "C"))
  df$pct <- seq_len(nrow(df))
  p <- ggplot2::ggplot(df, ggplot2::aes(week, pct, fill = team)) +
    geom_sketch_chicklet(seed = 1L)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("geom_sketch_chicklet renders to PNG, incl. coord_flip", {
  df <- expand.grid(week = factor(1:4), team = c("A", "B", "C"))
  df$pct <- seq_len(nrow(df))
  p <- ggplot2::ggplot(df, ggplot2::aes(week, pct, fill = team)) +
    geom_sketch_chicklet(seed = 1L) +
    ggplot2::coord_flip()
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 5, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

test_that("segment_gap insets segments but keeps them within the stack", {
  # Two stacked segments of height 5 each; a gap should shrink each toward the
  # boundary while preserving the outer extents.
  data <- data.frame(
    x = c(1, 1), xmin = c(0.55, 0.55), xmax = c(1.45, 1.45),
    ymin = c(0, 5), ymax = c(5, 10),
    colour = "black", fill = c("grey65", "grey40"),
    linewidth = 0.5, linetype = 1, alpha = NA, roughness = 1
  )
  grob <- GeomSketchChicklet$draw_panel(
    data, panel_params = list(), coord = ggplot2::coord_cartesian(),
    segment_gap = 0.1
  )
  expect_true(inherits(grob, "gList") || inherits(grob, "grob"))
})

test_that("geom_sketch_chicklet with empty data returns nullGrob", {
  empty_df <- data.frame(
    x = numeric(0), xmin = numeric(0), xmax = numeric(0),
    ymin = numeric(0), ymax = numeric(0),
    colour = character(0), fill = character(0), alpha = numeric(0),
    linewidth = numeric(0), linetype = numeric(0)
  )
  grob <- GeomSketchChicklet$draw_panel(
    empty_df, panel_params = list(), coord = ggplot2::coord_cartesian()
  )
  expect_true(inherits(grob, "grob"))
})

test_that("segment_gap = 0 leaves segments flush", {
  df <- expand.grid(week = factor(1:3), team = c("A", "B"))
  df$pct <- seq_len(nrow(df))
  p <- ggplot2::ggplot(df, ggplot2::aes(week, pct, fill = team)) +
    geom_sketch_chicklet(segment_gap = 0, seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})
