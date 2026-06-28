# T-v2: watercolour wash fill (watercolor_wash + fill_style = "watercolor").

square <- function(s = 2) list(x = c(0, s, s, 0), y = c(0, 0, s, s))

# ---- watercolor_wash --------------------------------------------------------

test_that("watercolor_wash returns n_layers boundary copies", {
  sq <- square()
  w  <- watercolor_wash(sq$x, sq$y, n_layers = 6L, seed = 1L)
  expect_length(w$washes, 6L)
  expect_true(all(vapply(w$washes, is.matrix, logical(1L))))
  expect_equal(colnames(w$washes[[1L]]), c("x", "y"))
  # Each copy keeps the vertex count of the boundary.
  expect_equal(nrow(w$washes[[1L]]), length(sq$x))
})

test_that("a degenerate polygon yields no wash", {
  w <- watercolor_wash(c(0, 1), c(0, 1), seed = 1L)
  expect_length(w$washes, 0L)
})

test_that("granulation scatters specks inside the polygon, off by default", {
  sq <- square(4)
  none <- watercolor_wash(sq$x, sq$y, seed = 1L)
  expect_null(none$granules)
  some <- watercolor_wash(sq$x, sq$y, granulation = 0.6, seed = 1L)
  expect_true(!is.null(some$granules))
  inside <- point_in_polygon(some$granules$x, some$granules$y, sq$x, sq$y)
  expect_true(all(inside))
})

test_that("watercolor_wash is reproducible and leaves .Random.seed alone", {
  sq <- square()
  set.seed(5L); before <- .Random.seed
  a <- watercolor_wash(sq$x, sq$y, granulation = 0.5, seed = 8L)
  b <- watercolor_wash(sq$x, sq$y, granulation = 0.5, seed = 8L)
  expect_identical(a, b)
  expect_identical(.Random.seed, before)
})

# ---- fill_style registration ------------------------------------------------

test_that("'watercolor' is an accepted fill style", {
  expect_silent(check_fill_style("watercolor"))
})

# ---- grob integration -------------------------------------------------------

test_that("sketch_polygon_grob paints stacked wash polygons for watercolor", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  grid::pushViewport(grid::viewport(width = grid::unit(4, "in"),
                                    height = grid::unit(4, "in")))
  g <- sketch_polygon_grob(
    x = c(0.2, 0.8, 0.8, 0.2), y = c(0.2, 0.2, 0.8, 0.8),
    fill_style = "watercolor",
    fill_gp = grid::gpar(col = "steelblue"),
    outline_gp = grid::gpar(col = "steelblue"),
    seed = 1L
  )
  kids <- grid::makeContent(g)$children
  cls  <- vapply(kids, function(z) class(z)[1L], "")
  expect_true(sum(grepl("polygon", cls)) >= 6L)   # >=6 wash layers + outline
  grid::popViewport()
})

# ---- geom integration -------------------------------------------------------

test_that("polygon-fill geoms render with fill_style = 'watercolor'", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  poly <- data.frame(
    x = c(1, 4, 5, 3, 1), y = c(1, 1, 3, 4, 3), g = 1
  )
  p1 <- ggplot2::ggplot(poly, ggplot2::aes(x, y, group = g)) +
    geom_sketch_polygon(fill = "tomato", fill_style = "watercolor", seed = 1L)
  p2 <- ggplot2::ggplot(ggplot2::economics[1:60, ],
                        ggplot2::aes(date, unemploy)) +
    geom_sketch_area(fill = "steelblue", fill_style = "watercolor", seed = 1L)
  expect_no_error(print(p1))
  expect_no_error(print(p2))
})
