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
