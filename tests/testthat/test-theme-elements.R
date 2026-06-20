# Rough theme elements (v1.4): element_sketch_line/rect + theme_sketch(rough_frame).

png_render <- function(p) {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  if (requireNamespace("ragg", quietly = TRUE)) {
    ragg::agg_png(tmp, width = 5, height = 4, units = "in", res = 72)
  } else {
    png(tmp, width = 5, height = 4, units = "in", res = 72)
  }
  print(p)
  dev.off()
  file.size(tmp)
}

test_that("element_sketch_line() is a line element carrying sketch attrs", {
  el <- element_sketch_line(colour = "red", roughness = 0.7, seed = 3L)
  expect_s3_class(el, "element_sketch_line")
  expect_s3_class(el, "element_line")
  expect_identical(attr(el, "sk_roughness"), 0.7)
  expect_identical(attr(el, "sk_seed"), 3L)
})

test_that("element_sketch_rect() is a rect element carrying sketch attrs", {
  el <- element_sketch_rect(colour = "grey40", fill = NA, roughness = 0.6)
  expect_s3_class(el, "element_sketch_rect")
  expect_s3_class(el, "element_rect")
  expect_identical(attr(el, "sk_roughness"), 0.6)
})

test_that("element_grob methods return drawable grobs", {
  lg <- ggplot2::element_grob(
    element_sketch_line(colour = "grey80", seed = 1L),
    x = c(0, 1, 0, 1), y = c(0, 0, 1, 1), id.lengths = c(2, 2)
  )
  expect_s3_class(lg, "gTree")

  rg <- ggplot2::element_grob(
    element_sketch_rect(colour = "grey40", fill = NA, seed = 1L)
  )
  expect_s3_class(rg, "grob")
})

test_that("element_grob.element_sketch_line drops NA (out-of-range) gridlines", {
  # First line group is all-NA, as ggplot2 passes for off-panel gridlines.
  g <- ggplot2::element_grob(
    element_sketch_line(seed = 1L),
    x = c(NA, NA, 0.5, 0.5), y = c(0, 1, 0, 1), id.lengths = c(2, 2)
  )
  expect_s3_class(g, "grob")
  expect_no_error(grid::makeContent(g))  # would choke on NA before the fix
})

test_that("theme_sketch(rough_frame = TRUE) builds and renders", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    theme_sketch(rough_frame = TRUE)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("rough frame is reproducible for a fixed seed", {
  mk <- function() ggplot2::element_grob(
    element_sketch_line(seed = 99L),
    x = c(0, 1), y = c(0.5, 0.5)
  )
  g1 <- grid::makeContent(mk())
  g2 <- grid::makeContent(mk())
  expect_equal(g1$children[[1]]$x, g2$children[[1]]$x)
})
