# geom_sketch_bracket() - significance brackets (v1.5)

test_that("geom_sketch_bracket() builds and renders", {
  br <- data.frame(xmin = 1, xmax = 2, y = 40, label = "p = 0.01")
  p <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(drv, hwy)) +
    geom_sketch_boxplot(seed = 1L) +
    geom_sketch_bracket(data = br,
      ggplot2::aes(xmin = xmin, xmax = xmax, y = y, label = label),
      family = "", seed = 2L)
  expect_no_error(ggplot2::ggplot_build(p))

  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  png(tmp, width = 5, height = 4, units = "in", res = 72)
  print(p)
  dev.off()
  expect_gt(file.size(tmp), 0)
})

test_that("a bracket with a label draws both the bar and the text", {
  br <- data.frame(xmin = 1, xmax = 2, y = 40, label = "n.s.")
  grob <- GeomSketchBracket$draw_panel(
    data = data.frame(xmin = 1, xmax = 2, y = 0.5, label = "n.s.",
                      colour = "black", linewidth = 0.5, linetype = 1,
                      alpha = NA, size = 3.88),
    panel_params = list(),
    coord = ggplot2::coord_cartesian(),
    family = "", seed = 1L
  )
  # one path (the bar) + one text grob
  expect_true(inherits(grob, "gList"))
  expect_length(grob, 2L)
  expect_true(any(vapply(grob, inherits, logical(1), "text")))
})

test_that("an empty label draws only the bar", {
  grob <- GeomSketchBracket$draw_panel(
    data = data.frame(xmin = 1, xmax = 2, y = 0.5, label = NA,
                      colour = "black", linewidth = 0.5, linetype = 1,
                      alpha = NA, size = 3.88),
    panel_params = list(),
    coord = ggplot2::coord_cartesian(),
    family = "", seed = 1L
  )
  expect_length(grob, 1L)
  expect_false(any(vapply(grob, inherits, logical(1), "text")))
})

test_that("empty data returns a nullGrob", {
  grob <- GeomSketchBracket$draw_panel(
    data = data.frame(), panel_params = list(),
    coord = ggplot2::coord_cartesian()
  )
  expect_true(inherits(grob, "grob"))
})
