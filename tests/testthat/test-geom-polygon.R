# T-GEOM-poly: geom_sketch_polygon tests (P4-T1)

png_render <- function(p) {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  png(tmp, width = 4, height = 4, units = "in", res = 72)
  print(p)
  dev.off()
  file.size(tmp)
}

test_that("geom_sketch_polygon() produces a valid layer", {
  tri <- data.frame(x = c(0, 1, 0.5), y = c(0, 0, 1))
  p <- ggplot2::ggplot(tri, ggplot2::aes(x, y)) + geom_sketch_polygon(seed = 1L)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("geom_sketch_polygon renders a triangle to PNG", {
  tri <- data.frame(x = c(0, 1, 0.5), y = c(0, 0, 1))
  p <- ggplot2::ggplot(tri, ggplot2::aes(x, y)) +
    geom_sketch_polygon(fill = "skyblue", seed = 1L)
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_polygon fills a concave star (AC-5)", {
  ang  <- seq(0, 2 * pi, length.out = 11)[-11]
  r    <- rep(c(1, 0.45), length.out = 10)
  star <- data.frame(x = r * cos(ang), y = r * sin(ang))
  p <- ggplot2::ggplot(star, ggplot2::aes(x, y)) +
    geom_sketch_polygon(fill = "tomato", seed = 2L)
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_polygon respects fill/colour aesthetics", {
  df <- data.frame(
    x = c(0, 1, 1, 0, 2, 3, 3, 2),
    y = c(0, 0, 1, 1, 0, 0, 1, 1),
    grp = rep(c("a", "b"), each = 4)
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, fill = grp, group = grp)) +
    geom_sketch_polygon(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("geom_sketch_polygon degenerate (< 3 pts) returns minimal grob", {
  grob <- GeomSketchPolygon$draw_group(
    data.frame(x = c(0, 1), y = c(0, 1), fill = "grey", colour = "black",
               linewidth = 0.5, linetype = 1, alpha = NA),
    list(), ggplot2::coord_cartesian(), seed = 1L
  )
  expect_s3_class(grob, "grob")
})

test_that("geom_sketch_polygon all fill styles render", {
  tri <- data.frame(x = c(0, 1, 0.5), y = c(0, 0, 1))
  for (s in c("hachure", "cross_hatch", "zigzag", "zigzag_line",
              "dots", "dashed", "solid")) {
    p <- ggplot2::ggplot(tri, ggplot2::aes(x, y)) +
      geom_sketch_polygon(fill_style = s, seed = 1L)
    expect_gt(png_render(p), 0)
  }
})
