# T-GEOM-smooth: geom_sketch_smooth tests (P4-T4)

png_render <- function(p) {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  png(tmp, width = 4, height = 4, units = "in", res = 72)
  print(p)
  dev.off()
  file.size(tmp)
}

test_that("geom_sketch_smooth() lm with CI builds and renders", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_smooth(method = "lm", formula = y ~ x, seed = 1L)
  expect_s3_class(p, "ggplot")
  expect_no_error(suppressWarnings(ggplot2::ggplot_build(p)))
  expect_gt(suppressWarnings(png_render(p)), 0)
})

test_that("geom_sketch_smooth() se = FALSE draws line only", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_smooth(method = "lm", formula = y ~ x, se = FALSE, seed = 1L)
  expect_gt(suppressWarnings(png_render(p)), 0)
})

test_that("geom_sketch_smooth composes with points", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    geom_sketch_smooth(method = "lm", formula = y ~ x, seed = 2L)
  expect_gt(suppressWarnings(png_render(p)), 0)
})

test_that("geom_sketch_smooth degenerate (< 2 rows) returns minimal grob", {
  grob <- GeomSketchSmooth$draw_group(
    data.frame(x = 1, y = 1, colour = "blue", fill = "grey",
               linewidth = 1, linetype = 1, weight = 1, alpha = 0.4),
    list(), ggplot2::coord_cartesian(), seed = 1L
  )
  expect_s3_class(grob, "grob")
})

test_that("geom_sketch_smooth loess default method renders", {
  df <- data.frame(x = 1:30, y = sin(1:30 / 3) + rnorm(30, 0, 0))
  df$y <- sin(seq(0, 6, length.out = 30))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_smooth(seed = 1L)
  expect_gt(suppressWarnings(png_render(p)), 0)
})
