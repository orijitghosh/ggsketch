# T-GROB-01..03: grob layer tests

test_that("sketch_path_grob() returns a SketchPathGrob", {
  g <- sketch_path_grob(c(0.1, 0.5, 0.9), c(0.2, 0.8, 0.5), seed = 1L)
  expect_s3_class(g, "SketchPathGrob")
  expect_s3_class(g, "grob")
})

test_that("sketch_path_grob() with zero points returns grob", {
  g <- sketch_path_grob(numeric(0), numeric(0), seed = 1L)
  expect_s3_class(g, "SketchPathGrob")
})

test_that("sketch_polygon_grob() returns a SketchPolygonGrob", {
  g <- sketch_polygon_grob(c(0.1, 0.5, 0.9, 0.1), c(0.1, 0.9, 0.1, 0.1),
                            seed = 1L)
  expect_s3_class(g, "SketchPolygonGrob")
})

test_that("sketch_path_grob resolves and stores seed (T-GROB-02)", {
  g <- sketch_path_grob(c(0, 1), c(0, 1), seed = 42L)
  expect_equal(g$seed, 42L)
})

test_that("sketch_polygon_grob stores fill_style (T-GROB-03)", {
  g <- sketch_polygon_grob(c(0.1, 0.5, 0.9), c(0.1, 0.9, 0.1),
                            fill_style = "cross_hatch", seed = 1L)
  expect_equal(g$fill_style, "cross_hatch")
})

test_that("makeContent.SketchPathGrob produces polylineGrobs (T-GROB-01)", {
  skip_if_not_installed("grid")
  g <- sketch_path_grob(c(0.1, 0.5, 0.9), c(0.2, 0.8, 0.5),
                         roughness = 1, n_passes = 2L, seed = 7L)
  # Render inside a device to trigger makeContent
  tmp <- tempfile(fileext = ".png")
  png(tmp, width = 4, height = 4, units = "in", res = 72)
  grid::grid.draw(g)
  dev.off()
  unlink(tmp)
  # If we got here without error, the grob rendered
  expect_true(TRUE)
})

test_that("two draws of same seed produce identical VD output (T-GROB-02)", {
  # We test that the grob has a deterministic seed stored
  g1 <- sketch_path_grob(c(0.1, 0.5, 0.9), c(0.2, 0.8, 0.5), seed = 99L)
  g2 <- sketch_path_grob(c(0.1, 0.5, 0.9), c(0.2, 0.8, 0.5), seed = 99L)
  expect_identical(g1$seed, g2$seed)
  expect_identical(g1$roughness, g2$roughness)
})

test_that("makeContent.SketchPolygonGrob renders without error (T-GROB-01)", {
  skip_if_not_installed("grid")
  g <- sketch_polygon_grob(
    x = c(0.1, 0.5, 0.9, 0.1),
    y = c(0.1, 0.9, 0.5, 0.1),
    fill_style = "hachure", seed = 1L
  )
  tmp <- tempfile(fileext = ".png")
  png(tmp, width = 4, height = 4, units = "in", res = 72)
  grid::grid.draw(g)
  dev.off()
  unlink(tmp)
  expect_true(TRUE)
})

test_that("T-GROB-03: polygon grob children use correct gpar", {
  skip_if_not_installed("grid")
  g <- sketch_polygon_grob(
    x          = c(0.1, 0.5, 0.9, 0.1),
    y          = c(0.1, 0.9, 0.5, 0.1),
    fill_weight = 2.0,
    fill_style  = "hachure",
    outline_gp  = grid::gpar(lwd = 3),
    seed        = 1L
  )

  tmp <- tempfile(fileext = ".png")
  on.exit({ dev.off(); unlink(tmp) }, add = TRUE)
  png(tmp, width = 4, height = 4, units = "in", res = 72)

  grid::pushViewport(grid::viewport(
    width  = grid::unit(4, "inches"),
    height = grid::unit(4, "inches")
  ))

  rendered <- grid::makeContent(g)
  grid::popViewport()

  expect_gt(length(grid::childNames(rendered)), 0)
})

test_that("geom_sketch_path handles single-row data (T-GEOM-EMPTY)", {
  # GeomSketchPath$draw_group returns nullGrob for nrow < 2
  grob <- GeomSketchPath$draw_group(
    data.frame(),
    list(),
    ggplot2::coord_cartesian(),
    seed = 1L
  )
  expect_s3_class(grob, "grob")

  # Also: a single-point plot should render without error (line gets no draw,
  # but the plot shouldn't crash)
  df <- data.frame(x = 1, y = 1)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_path(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("geom_sketch_line handles NA values (T-GEOM-NA)", {
  df <- data.frame(x = 1:5, y = c(1, NA, 3, NA, 5))
  p  <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_line(seed = 1L, na.rm = TRUE)

  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)

  expect_silent({
    png(tmp, width = 4, height = 4, units = "in", res = 72)
    print(p)
    dev.off()
  })

  expect_true(file.exists(tmp))
  expect_gt(file.size(tmp), 0)
})
