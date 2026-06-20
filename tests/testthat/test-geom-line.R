# T-GEOM-line: geom_sketch_path and geom_sketch_line tests

test_that("geom_sketch_path() produces a valid layer", {
  p <- ggplot2::ggplot(data.frame(x = 1:5, y = c(2,1,4,3,5)),
                        ggplot2::aes(x, y)) +
    geom_sketch_path(seed = 1L)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("geom_sketch_line() produces a valid layer", {
  p <- ggplot2::ggplot(data.frame(x = 1:5, y = c(2,1,4,3,5)),
                        ggplot2::aes(x, y)) +
    geom_sketch_line(seed = 1L)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("geom_sketch_path renders to PNG without error (T-GEOM-line)", {
  p <- ggplot2::ggplot(data.frame(x = 1:10, y = sin(1:10)),
                        ggplot2::aes(x, y)) +
    geom_sketch_path(roughness = 1, seed = 42L)
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

test_that("geom_sketch_line respects colour aesthetic", {
  p <- ggplot2::ggplot(data.frame(x = 1:5, y = 1:5, g = rep(c("a","b"), c(3,2))),
                        ggplot2::aes(x, y, colour = g)) +
    geom_sketch_line(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("geom_sketch_path with empty data returns zeroGrob", {
  grob <- GeomSketchPath$draw_group(
    data.frame(),
    list(),
    ggplot2::coord_cartesian(),
    seed = 1L
  )
  expect_s3_class(grob, "grob")
})

test_that("facet_wrap composition works with geom_sketch_path (AC-2)", {
  df <- data.frame(x = rep(1:5, 2), y = c(1:5, 5:1),
                   g = rep(c("A", "B"), each = 5))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_path(seed = 1L) +
    ggplot2::facet_wrap(~g)
  expect_no_error({
    tmp <- tempfile(fileext = ".png")
    png(tmp, width = 6, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
    unlink(tmp)
  })
})

test_that("coord_flip works with geom_sketch_path (AC-2)", {
  p <- ggplot2::ggplot(data.frame(x = 1:5, y = 1:5), ggplot2::aes(x, y)) +
    geom_sketch_path(seed = 1L) +
    ggplot2::coord_flip()
  expect_no_error({
    tmp <- tempfile(fileext = ".png")
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
    unlink(tmp)
  })
})

test_that("geom_sketch_path + theme_sketch render together", {
  p <- ggplot2::ggplot(data.frame(x = 1:5, y = 1:5), ggplot2::aes(x, y)) +
    geom_sketch_path(seed = 1L) +
    theme_sketch()
  expect_no_error({
    tmp <- tempfile(fileext = ".png")
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
    unlink(tmp)
  })
})
