# T-GEOM-point: geom_sketch_point tests

test_that("geom_sketch_point() produces a valid layer", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("geom_sketch_point renders to PNG (T-GEOM-point)", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(roughness = 0.5, seed = 42L)
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

test_that("geom_sketch_point respects colour aesthetic (T-GEOM-point)", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg, colour = factor(cyl))) +
    geom_sketch_point(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("per-point colours reach the grob (continuous scale, one group)", {
  # Regression: a continuous colour scale puts every point in one group, so the
  # grob receives a vector of per-point colours. It must draw each point in its
  # own colour, not collapse them all to the first one.
  df <- data.frame(x = 1:10, y = 1:10, z = 1:10)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, colour = z)) +
    geom_sketch_point(size = 3, seed = 1L) +
    scale_colour_sketch_c()
  built <- ggplot2::ggplot_build(p)$data[[1]]
  expect_gt(length(unique(built$colour)), 1L)

  pg <- sketch_point_grob(
    x = seq(0.1, 0.9, length.out = nrow(built)),
    y = seq(0.1, 0.9, length.out = nrow(built)),
    size = 3, seed = 1L,
    gp = grid::gpar(col = built$colour)
  )
  resolved <- grid::makeContent(pg)
  cols <- unlist(lapply(resolved$children, function(ch) {
    unlist(lapply(ch$children, function(g) g$gp$col))
  }))
  expect_gt(length(unique(cols)), 1L)
})

test_that("index_gpar picks element i and recycles scalars", {
  gp <- grid::gpar(col = c("a", "b", "c"), lwd = 2, lineend = "round")
  expect_identical(index_gpar(gp, 2L)$col, "b")
  expect_identical(index_gpar(gp, 2L)$lwd, 2)
  expect_identical(index_gpar(gp, 5L)$col, "b")  # (5-1) %% 3 + 1 = 2
})

test_that("geom_sketch_point with empty data returns zeroGrob", {
  grob <- GeomSketchPoint$draw_group(
    data.frame(),
    list(),
    ggplot2::coord_cartesian(),
    seed = 1L
  )
  expect_true(inherits(grob, "grob"))
})

test_that("geom_sketch_point and geom_sketch_line compose together", {
  p <- ggplot2::ggplot(data.frame(x = 1:5, y = c(2,1,4,3,5)),
                        ggplot2::aes(x, y)) +
    geom_sketch_line(seed = 1L) +
    geom_sketch_point(seed = 2L) +
    theme_sketch()
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  unlink(tmp)
})

test_that("facet_grid composition works with geom_sketch_point (AC-2)", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    ggplot2::facet_grid(. ~ am)
  expect_no_error({
    tmp <- tempfile(fileext = ".png")
    png(tmp, width = 6, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
    unlink(tmp)
  })
})
