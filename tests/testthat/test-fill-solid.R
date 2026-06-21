# T-FILL-solid: fill_style = "solid" paints the interior (regression)

poly_fills <- function(grob) {
  ch <- grid::makeContent(grob)$children
  out <- vapply(ch, function(k) {
    f <- k$gp$fill
    if (inherits(k, "polygon") && !is.null(f)) as.character(f)[[1]] else NA_character_
  }, character(1))
  out[!is.na(out)]
}

test_that("solid fill paints a polygon with the fill colour", {
  g <- sketch_polygon_grob(
    x = c(0.2, 0.8, 0.8, 0.2), y = c(0.2, 0.2, 0.8, 0.8),
    fill_style = "solid", seed = 1L,
    fill_gp    = grid::gpar(col = "red"),
    outline_gp = grid::gpar(col = "black")
  )
  expect_true("red" %in% poly_fills(g))
})

test_that("solid fill is skipped when fill colour is NA (outline only)", {
  g <- sketch_polygon_grob(
    x = c(0.2, 0.8, 0.8, 0.2), y = c(0.2, 0.2, 0.8, 0.8),
    fill_style = "solid", seed = 1L,
    fill_gp    = grid::gpar(col = NA),
    outline_gp = grid::gpar(col = "black")
  )
  expect_length(poly_fills(g), 0L)
})

test_that("solid fill paints the ellipse interior", {
  g <- sketch_ellipse_grob(
    x = 0.5, y = 0.5, rx = 0.3, ry = 0.3,
    fill_style = "solid", seed = 1L,
    fill_gp    = grid::gpar(col = "blue"),
    outline_gp = grid::gpar(col = "black")
  )
  expect_true("blue" %in% poly_fills(g))
})

test_that("non-solid fill styles emit no filled polygon", {
  g <- sketch_polygon_grob(
    x = c(0.2, 0.8, 0.8, 0.2), y = c(0.2, 0.2, 0.8, 0.8),
    fill_style = "hachure", seed = 1L,
    fill_gp    = grid::gpar(col = "red"),
    outline_gp = grid::gpar(col = "black")
  )
  expect_length(poly_fills(g), 0L)
})

test_that("geom_sketch_col with solid fill renders", {
  p <- ggplot2::ggplot(
    data.frame(g = c("A", "B", "C"), y = c(4, 6, 3)),
    ggplot2::aes(g, y)
  ) +
    geom_sketch_col(fill_style = "solid", fill = "steelblue", seed = 1L)
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  unlink(tmp)
})
