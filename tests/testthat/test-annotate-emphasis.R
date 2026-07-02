# T-ANNOT-emphasis: highlighter swipes + hand-drawn underlines.

test_that("annotate_sketch_highlight builds a highlighter segment layer", {
  l <- annotate_sketch_highlight(x = 1, y = 2, xend = 5, yend = 2)
  expect_s3_class(l, "Layer")
  expect_identical(l$geom_params$medium, "highlighter")
  expect_false(l$inherit.aes)
})

test_that("highlight renders under a pen line", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) +
    annotate_sketch_highlight(x = 2, y = 25, xend = 4, yend = 25, seed = 2L)
  expect_no_error(print(p))
})

test_that("highlight recycles length-1 positions and rejects ragged ones", {
  l <- annotate_sketch_highlight(x = c(1, 2), y = 3, xend = c(4, 5), yend = 3)
  expect_equal(nrow(l$data), 2L)
  expect_error(
    annotate_sketch_highlight(x = c(1, 2, 3), y = 1, xend = c(4, 5), yend = 1),
    "length 1 or"
  )
})

test_that("annotate_sketch_underline defaults to one horizontal stroke", {
  l <- annotate_sketch_underline(x = 1, y = 2, xend = 5)
  expect_s3_class(l, "Layer")
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) + l
  expect_no_error(print(p))
})

test_that("strokes > 1 returns one layer per stroke with distinct seeds", {
  ls <- annotate_sketch_underline(x = 1, y = 2, xend = 5, strokes = 3L,
                                  seed = 9L)
  expect_length(ls, 3L)
  seeds <- vapply(ls, function(l) l$geom_params$seed, numeric(1))
  expect_length(unique(seeds), 3L)
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) + ls
  expect_no_error(print(p))
})
