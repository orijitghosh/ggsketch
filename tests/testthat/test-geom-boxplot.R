# T-GEOM-boxplot tests (P5-T3)

png_render <- function(p) {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  png(tmp, width = 5, height = 4, units = "in", res = 72)
  print(p)
  dev.off()
  file.size(tmp)
}

test_that("geom_sketch_boxplot() builds and renders", {
  p <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(class, hwy)) +
    geom_sketch_boxplot(seed = 1L)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_boxplot setup_data computes box width extents", {
  df <- data.frame(x = c(1, 2), lower = 0, upper = 1, middle = 0.5,
                   ymin = -1, ymax = 2)
  out <- GeomSketchBoxplot$setup_data(df, list(width = 0.5))
  expect_equal(out$xmin, c(0.75, 1.75))
  expect_equal(out$xmax, c(1.25, 2.25))
})

test_that("geom_sketch_boxplot with hachure fill renders", {
  p <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(class, hwy)) +
    geom_sketch_boxplot(fill_style = "hachure", fill = "skyblue", seed = 2L)
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_boxplot outliers = FALSE still renders", {
  p <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(class, hwy)) +
    geom_sketch_boxplot(outliers = FALSE, seed = 1L)
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_boxplot composes with fill scale + flip (AC-2)", {
  p <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(class, hwy, fill = class)) +
    geom_sketch_boxplot(seed = 1L, show.legend = FALSE) +
    ggplot2::coord_flip()
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_boxplot empty data returns minimal grob", {
  grob <- GeomSketchBoxplot$draw_group(
    data.frame(), list(), ggplot2::coord_cartesian(), seed = 1L
  )
  expect_s3_class(grob, "grob")
})
