# annotate_sketch() tests (P5-T4)

png_render <- function(p) {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  png(tmp, width = 4, height = 4, units = "in", res = 72)
  print(p)
  dev.off()
  file.size(tmp)
}

test_that("annotate_sketch() returns a layer", {
  l <- annotate_sketch("point", x = 1, y = 2, seed = 1L)
  expect_s3_class(l, "LayerInstance")
})

test_that("annotate_sketch() rect renders on a plot", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    annotate_sketch("rect", xmin = 3, xmax = 4, ymin = 15, ymax = 22,
                    fill = NA, colour = "red", seed = 2L)
  expect_gt(png_render(p), 0)
})

test_that("annotate_sketch() segment + circle render", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    annotate_sketch("segment", x = 2, y = 30, xend = 4, yend = 15,
                    colour = "blue", seed = 2L) +
    annotate_sketch("circle", x = 5, y = 16, r = 0.4, seed = 3L)
  expect_gt(png_render(p), 0)
})

test_that("annotate_sketch() recycles length-1 aesthetics", {
  l <- annotate_sketch("point", x = c(1, 2, 3), y = 0, seed = 1L)
  expect_equal(nrow(l$data), 3L)
  expect_equal(l$data$y, c(0, 0, 0))
})

test_that("annotate_sketch() errors on unknown geom", {
  expect_error(annotate_sketch("banana", x = 1, y = 1))
})

test_that("annotate_sketch() errors with no position aesthetics", {
  expect_error(annotate_sketch("point"), "position aesthetic")
})

test_that("annotate_sketch() errors on incompatible lengths", {
  expect_error(
    annotate_sketch("point", x = c(1, 2, 3), y = c(1, 2)),
    "length"
  )
})
