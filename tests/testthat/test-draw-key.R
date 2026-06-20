# Sketchy legend key tests (P5-T5 / T-GEOM-KEY)

png_render <- function(p) {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  png(tmp, width = 5, height = 4, units = "in", res = 72)
  print(p)
  dev.off()
  file.size(tmp)
}

test_that("draw_key_sketch_path returns a grob", {
  g <- draw_key_sketch_path(
    data.frame(colour = "black", linewidth = 0.5, linetype = 1, alpha = NA),
    list(seed = 1L), c(1, 1)
  )
  expect_s3_class(g, "grob")
})

test_that("draw_key_sketch_point returns a grob", {
  g <- draw_key_sketch_point(
    data.frame(colour = "black", size = 1.5, alpha = NA, stroke = 0.5),
    list(seed = 1L), c(1, 1)
  )
  expect_s3_class(g, "grob")
})

test_that("draw_key_sketch_polygon returns a grob", {
  g <- draw_key_sketch_polygon(
    data.frame(colour = "black", fill = "grey65", linewidth = 0.5,
               linetype = 1, alpha = NA),
    list(seed = 1L, fill_style = "hachure"), c(1, 1)
  )
  expect_s3_class(g, "grob")
})

test_that("geoms dispatch to sketchy key grobs", {
  # ggplot2 4.0 wraps draw_key, so check the produced grob class instead.
  k_line <- GeomSketchLine$draw_key(
    data.frame(colour = "black", linewidth = 0.5, linetype = 1, alpha = NA),
    list(seed = 1L), c(1, 1)
  )
  expect_s3_class(k_line, "SketchPathGrob")

  k_point <- GeomSketchPoint$draw_key(
    data.frame(colour = "black", size = 1.5, alpha = NA, stroke = 0.5),
    list(seed = 1L), c(1, 1)
  )
  expect_s3_class(k_point, "SketchPointGrob")

  k_col <- GeomSketchCol$draw_key(
    data.frame(colour = "black", fill = "grey65", linewidth = 0.5,
               linetype = 1, alpha = NA),
    list(seed = 1L, fill_style = "hachure"), c(1, 1)
  )
  expect_s3_class(k_col, "SketchPolygonGrob")
})

test_that("legend with sketchy keys renders (fill)", {
  p <- ggplot2::ggplot(
    data.frame(x = c("A", "B", "C"), y = c(3, 5, 2), g = c("A", "B", "C")),
    ggplot2::aes(x, y, fill = g)
  ) + geom_sketch_col(seed = 1L)
  expect_gt(png_render(p), 0)
})

test_that("legend with sketchy keys renders (colour, point+line)", {
  p <- ggplot2::ggplot(mtcars,
                       ggplot2::aes(wt, mpg, colour = factor(cyl))) +
    geom_sketch_point(seed = 1L) +
    geom_sketch_line(seed = 2L)
  expect_gt(png_render(p), 0)
})
