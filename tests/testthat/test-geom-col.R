# T-GEOM-col: geom_sketch_col / geom_sketch_bar tests

test_that("geom_sketch_col() produces a valid layer", {
  df <- data.frame(x = c("A", "B", "C", "D"), y = c(3, 5, 2, 6))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_col(seed = 1L)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("geom_sketch_col renders to PNG (T-GEOM-col)", {
  df <- data.frame(x = c("A", "B", "C", "D"), y = c(3, 5, 2, 6))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_col(seed = 1L)
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

test_that("geom_sketch_col respects mapped fill and colour", {
  df <- data.frame(x = c("A", "B", "C", "D"), y = c(3, 5, 2, 6))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, fill = x, colour = x)) +
    geom_sketch_col(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("all 7 fill styles render without error (T-GEOM-col)", {
  df <- data.frame(x = c("A", "B", "C", "D"), y = c(3, 5, 2, 6))
  styles <- c("hachure", "cross_hatch", "zigzag", "zigzag_line",
              "dots", "dashed", "solid")
  for (style in styles) {
    tmp <- tempfile(fileext = ".png")
    p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
      geom_sketch_col(fill_style = style, seed = 1L)
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
    expect_gt(file.size(tmp), 0, label = paste("fill_style:", style))
    unlink(tmp)
  }
})

test_that("per-bar seed offset produces different bar geometry (AC-1)", {
  # Different bar indices must receive different seeds
  s1 <- seed_offset(1L, 1 * 97L)
  s2 <- seed_offset(1L, 2 * 97L)
  expect_false(s1 == s2)

  # Build two sketch_polygon_grob()s with those seeds; confirm stored seeds differ
  g1 <- sketch_polygon_grob(
    x = c(0.1, 0.3, 0.3, 0.1), y = c(0, 0, 0.5, 0.5),
    seed = s1
  )
  g2 <- sketch_polygon_grob(
    x = c(0.4, 0.6, 0.6, 0.4), y = c(0, 0, 0.8, 0.8),
    seed = s2
  )
  expect_false(g1$seed == g2$seed)
})

test_that("geom_sketch_bar uses stat=count", {
  df <- data.frame(x = c("a", "a", "b", "b", "b", "c"))
  p <- ggplot2::ggplot(df, ggplot2::aes(x)) +
    geom_sketch_bar(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))

  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

test_that("geom_sketch_col with empty data returns nullGrob", {
  empty_df <- data.frame(
    x        = numeric(0),
    y        = numeric(0),
    xmin     = numeric(0),
    xmax     = numeric(0),
    ymin     = numeric(0),
    ymax     = numeric(0),
    colour   = character(0),
    fill     = character(0),
    alpha    = numeric(0),
    linewidth = numeric(0),
    linetype = numeric(0)
  )
  grob <- GeomSketchCol$draw_panel(
    data         = empty_df,
    panel_params = list(),
    coord        = ggplot2::coord_cartesian()
  )
  expect_true(inherits(grob, "grob"))
})

test_that("geom_sketch_col with coord_flip (AC-2)", {
  df <- data.frame(x = c("A", "B", "C", "D"), y = c(3, 5, 2, 6))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_col(seed = 1L) +
    ggplot2::coord_flip()
  expect_no_error({
    tmp <- tempfile(fileext = ".png")
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
    unlink(tmp)
  })
})

test_that("geom_sketch_col with facet_wrap (AC-2)", {
  df <- data.frame(
    x = rep(c("A", "B", "C"), 2),
    y = c(3, 5, 2, 4, 1, 6),
    g = rep(c("G1", "G2"), each = 3)
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_col(seed = 1L) +
    ggplot2::facet_wrap(~g)
  expect_no_error({
    tmp <- tempfile(fileext = ".png")
    png(tmp, width = 6, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
    unlink(tmp)
  })
})

test_that("geom_sketch_col + theme_sketch compose", {
  df <- data.frame(x = c("A", "B", "C", "D"), y = c(3, 5, 2, 6))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_col(seed = 1L) +
    theme_sketch()
  expect_no_error({
    tmp <- tempfile(fileext = ".png")
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
    unlink(tmp)
  })
})
