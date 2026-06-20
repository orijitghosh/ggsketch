# T-GEOM-rect: geom_sketch_rect and geom_sketch_tile tests

test_that("geom_sketch_rect() produces a valid layer", {
  df <- data.frame(xmin = c(1, 3), xmax = c(2, 4),
                   ymin = c(1, 2), ymax = c(3, 5))
  p <- ggplot2::ggplot(df, ggplot2::aes(xmin = xmin, xmax = xmax,
                                         ymin = ymin, ymax = ymax)) +
    geom_sketch_rect(seed = 1L)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("geom_sketch_rect renders to PNG (T-GEOM-rect)", {
  df <- data.frame(xmin = c(1, 3), xmax = c(2, 4),
                   ymin = c(1, 2), ymax = c(3, 5))
  p <- ggplot2::ggplot(df, ggplot2::aes(xmin = xmin, xmax = xmax,
                                         ymin = ymin, ymax = ymax)) +
    geom_sketch_rect(roughness = 1, seed = 42L)
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

test_that("geom_sketch_tile() produces a valid layer", {
  df <- data.frame(x = c(1, 2, 3), y = c(1, 2, 3))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_tile(seed = 1L)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("geom_sketch_tile renders to PNG (T-GEOM-rect)", {
  df <- data.frame(x = c(1, 2, 3), y = c(1, 2, 3))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_tile(roughness = 1, seed = 42L)
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

test_that("geom_sketch_tile respects width/height params", {
  df <- data.frame(x = c(1, 2, 3), y = c(1, 2, 3))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_tile(width = 0.5, height = 0.5, seed = 1L)
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

test_that("geom_sketch_rect with empty data returns nullGrob", {
  grob <- GeomSketchRect$draw_panel(
    data.frame(
      xmin      = numeric(0),
      xmax      = numeric(0),
      ymin      = numeric(0),
      ymax      = numeric(0),
      colour    = character(0),
      fill      = character(0),
      linewidth = numeric(0),
      linetype  = integer(0),
      alpha     = numeric(0)
    ),
    coord        = ggplot2::coord_cartesian(),
    panel_params = list()
  )
  expect_s3_class(grob, "grob")
})

test_that("geom_sketch_rect with all fill styles", {
  df <- data.frame(xmin = 1, xmax = 3, ymin = 1, ymax = 4)
  styles <- c("hachure", "cross_hatch", "zigzag", "zigzag_line",
              "dots", "dashed", "solid")
  for (sty in styles) {
    p <- ggplot2::ggplot(df, ggplot2::aes(xmin = xmin, xmax = xmax,
                                           ymin = ymin, ymax = ymax)) +
      geom_sketch_rect(fill_style = sty, seed = 1L)
    tmp <- tempfile(fileext = ".png")
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
    expect_gt(file.size(tmp), 0, label = paste("fill_style:", sty))
    unlink(tmp)
  }
})

test_that("geom_sketch_rect with coord_flip (AC-2)", {
  df <- data.frame(xmin = c(1, 3), xmax = c(2, 4),
                   ymin = c(1, 2), ymax = c(3, 5))
  p <- ggplot2::ggplot(df, ggplot2::aes(xmin = xmin, xmax = xmax,
                                         ymin = ymin, ymax = ymax)) +
    geom_sketch_rect(seed = 1L) +
    ggplot2::coord_flip()
  expect_no_error({
    tmp <- tempfile(fileext = ".png")
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
    unlink(tmp)
  })
})

test_that("geom_sketch_rect with facet_wrap (AC-2)", {
  df <- data.frame(xmin = c(1, 3, 1, 3), xmax = c(2, 4, 2, 4),
                   ymin = c(1, 2, 1, 2), ymax = c(3, 5, 3, 5),
                   g = c("A", "A", "B", "B"))
  p <- ggplot2::ggplot(df, ggplot2::aes(xmin = xmin, xmax = xmax,
                                         ymin = ymin, ymax = ymax)) +
    geom_sketch_rect(seed = 1L) +
    ggplot2::facet_wrap(~g)
  expect_no_error({
    tmp <- tempfile(fileext = ".png")
    png(tmp, width = 6, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
    unlink(tmp)
  })
})

test_that("geom_sketch_tile with facet_grid (AC-2)", {
  df <- data.frame(x = c(1, 2, 3, 1, 2, 3),
                   y = c(1, 2, 3, 1, 2, 3),
                   g = c("A", "A", "A", "B", "B", "B"))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_tile(seed = 1L) +
    ggplot2::facet_grid(. ~ g)
  expect_no_error({
    tmp <- tempfile(fileext = ".png")
    png(tmp, width = 6, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
    unlink(tmp)
  })
})

test_that("geom_sketch_rect + theme_sketch compose", {
  df <- data.frame(xmin = c(1, 3), xmax = c(2, 4),
                   ymin = c(1, 2), ymax = c(3, 5))
  p <- ggplot2::ggplot(df, ggplot2::aes(xmin = xmin, xmax = xmax,
                                         ymin = ymin, ymax = ymax)) +
    geom_sketch_rect(seed = 1L) +
    theme_sketch()
  expect_no_error({
    tmp <- tempfile(fileext = ".png")
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
    unlink(tmp)
  })
})

test_that("geom_sketch_rect with mapped fill (AC-2)", {
  df <- data.frame(xmin = c(1, 3), xmax = c(2, 4),
                   ymin = c(1, 2), ymax = c(3, 5),
                   grp = c("X", "Y"))
  p <- ggplot2::ggplot(df, ggplot2::aes(xmin = xmin, xmax = xmax,
                                         ymin = ymin, ymax = ymax,
                                         fill = grp)) +
    geom_sketch_rect(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})
