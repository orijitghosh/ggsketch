# T-v2: medium as a mappable aesthetic + scale_medium_discrete().

grob_classes <- function(g) {
  out <- class(g)
  if (!is.null(g$grobs))    out <- c(out, unlist(lapply(g$grobs, grob_classes)))
  if (!is.null(g$children)) out <- c(out, unlist(lapply(g$children, grob_classes)))
  out
}

line_df <- function() data.frame(
  x = rep(1:10, 3),
  y = c(1:10, (1:10) + 4, (1:10) + 8),
  g = rep(c("a", "b", "c"), each = 10)
)

test_that("scale_medium_discrete is a discrete scale on the medium aesthetic", {
  s <- scale_medium_discrete()
  expect_s3_class(s, "Scale")
  expect_identical(s$aesthetics, "medium")
})

test_that("the palette maps levels to media and recycles with a warning", {
  s <- scale_medium_discrete(media = c("ink", "brush"))
  expect_identical(s$palette(2L), c("ink", "brush"))
  expect_warning(out <- s$palette(3L), "recycled")
  expect_identical(out, c("ink", "brush", "ink"))
})

test_that("bad media are rejected", {
  expect_error(scale_medium_discrete(media = c("ink", "quill")), "sketch_media")
})

test_that("mapping medium assigns a medium per group (no warning)", {
  p <- ggplot2::ggplot(line_df(),
                       ggplot2::aes(x, y, group = g, medium = g)) +
    geom_sketch_line(seed = 1L) +
    scale_medium_discrete(media = c("ink", "brush", "pencil"))
  expect_no_warning(d <- ggplot2::layer_data(p))
  expect_true("medium" %in% names(d))
  # one medium per group, drawn from the requested set
  per_group <- tapply(d$medium, d$group, function(z) unique(as.character(z)))
  expect_true(all(lengths(per_group) == 1L))
  expect_setequal(unlist(per_group), c("ink", "brush", "pencil"))
})

test_that("a mapped medium actually changes the rendered grob", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(line_df(),
                       ggplot2::aes(x, y, group = g, medium = g)) +
    geom_sketch_line(linewidth = 1, seed = 1L) +
    scale_medium_discrete(media = c("ink", "brush", "pencil"))
  gt <- ggplot2::ggplotGrob(p)
  cls <- grob_classes(gt)
  # non-pen media render as variable-width ribbons
  expect_true("SketchStrokeGrob" %in% cls)
  expect_no_error(grid::grid.draw(gt))
})

test_that("unmapped medium still honours the layer param (pen unchanged)", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(line_df(), ggplot2::aes(x, y, group = g)) +
    geom_sketch_line(seed = 1L)            # default pen
  cls <- grob_classes(ggplot2::ggplotGrob(p))
  expect_true("SketchPathGrob" %in% cls)   # pen path, not a ribbon
  expect_false("SketchStrokeGrob" %in% cls)
})

test_that("medium maps per segment on geom_sketch_segment", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  df <- data.frame(x = 1:3, y = 1:3, xend = 2:4, yend = c(3, 1, 4),
                   m = c("p", "q", "r"))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, xend = xend, yend = yend,
                                        medium = m)) +
    geom_sketch_segment(linewidth = 1, seed = 1L) +
    scale_medium_discrete(media = c("ink", "brush", "charcoal"))
  expect_no_warning(ggplot2::ggplot_build(p))
  expect_true("SketchStrokeGrob" %in% grob_classes(ggplot2::ggplotGrob(p)))
})

test_that("draw_key_sketch_medium returns a grob for each medium", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  for (m in sketch_media()) {
    g <- draw_key_sketch_medium(
      data.frame(colour = "black", linewidth = 0.5, linetype = 1,
                 alpha = NA, medium = m),
      list(seed = 1L), 1
    )
    expect_true(grid::is.grob(g))
  }
})
