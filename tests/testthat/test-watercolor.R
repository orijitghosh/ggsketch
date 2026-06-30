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

# ---- grain (C3: ink-into-paper) ---------------------------------------------

test_that("grain = 0 is a no-op that leaves the RNG stream untouched", {
  sq <- square()
  expect_identical(
    watercolor_wash(sq$x, sq$y, grain = 0, seed = 1L),
    watercolor_wash(sq$x, sq$y, seed = 1L)
  )
})

test_that("grain > 0 perturbs the wash edges but keeps the vertex count", {
  sq <- square()
  flat <- watercolor_wash(sq$x, sq$y, grain = 0, seed = 1L)
  toot <- watercolor_wash(sq$x, sq$y, grain = 1, seed = 1L)
  expect_false(identical(flat$washes[[1L]], toot$washes[[1L]]))
  expect_equal(nrow(toot$washes[[1L]]), length(sq$x))
})

test_that("watercolor_wash_multi honours grain and stays seed-safe", {
  rings <- list(list(x = c(0, 4, 4, 0), y = c(0, 0, 4, 4)))
  set.seed(3L); before <- .Random.seed
  flat <- watercolor_wash_multi(rings, grain = 0, seed = 9L)
  toot <- watercolor_wash_multi(rings, grain = 1, seed = 9L)
  expect_false(identical(flat$washes[[1L]][[1L]], toot$washes[[1L]][[1L]]))
  expect_identical(.Random.seed, before)
})

test_that("paper_grain rises from smooth to toothy grounds", {
  expect_identical(paper_grain("none"), 0)
  expect_lt(paper_grain("notebook"), paper_grain("kraft"))
  expect_true(all(vapply(sketch_papers(), function(k)
    paper_grain(k) >= 0 && paper_grain(k) <= 1, logical(1L))))
  expect_error(paper_grain("nope"))
})

# ---- wash_bleed (C2: wet-on-wet) --------------------------------------------

test_that("wash_bleed mixes colour where two washes overlap", {
  a <- square(2)
  b <- list(x = c(1, 3, 3, 1), y = c(1, 1, 3, 3))   # overlaps a in [1,2]^2
  bl <- wash_bleed(a$x, a$y, b$x, b$y, "red", "blue", seed = 1L)
  expect_false(is.null(bl))
  expect_true(length(bl$x) > 0L)
  # every speck lies inside both polygons
  expect_true(all(point_in_polygon(bl$x, bl$y, a$x, a$y)))
  expect_true(all(point_in_polygon(bl$x, bl$y, b$x, b$y)))
  # red + blue mid-mix is a purple
  expect_identical(bl$fill, "#7F007F")
})

test_that("wash_bleed returns NULL for disjoint or degenerate regions", {
  a <- square(1)
  far <- list(x = c(5, 6, 6, 5), y = c(5, 5, 6, 6))
  expect_null(wash_bleed(a$x, a$y, far$x, far$y, "red", "blue", seed = 1L))
  expect_null(wash_bleed(c(0, 1), c(0, 1), a$x, a$y, "red", "blue", seed = 1L))
})

test_that("wash_bleed is reproducible and leaves .Random.seed alone", {
  a <- square(2); b <- list(x = c(1, 3, 3, 1), y = c(1, 1, 3, 3))
  set.seed(7L); before <- .Random.seed
  x1 <- wash_bleed(a$x, a$y, b$x, b$y, "red", "blue", seed = 4L)
  x2 <- wash_bleed(a$x, a$y, b$x, b$y, "red", "blue", seed = 4L)
  expect_identical(x1, x2)
  expect_identical(.Random.seed, before)
})

test_that("overlapping watercolor groups emit a bleed layer", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  withr::local_options(ggsketch.wash_bleed = TRUE)
  grid::pushViewport(grid::viewport(width = grid::unit(4, "in"),
                                    height = grid::unit(4, "in")))
  g <- sketch_polygon_grob(
    x  = c(0.2, 0.6, 0.6, 0.2,  0.4, 0.8, 0.8, 0.4),
    y  = c(0.2, 0.2, 0.6, 0.6,  0.4, 0.4, 0.8, 0.8),
    id = rep(1:2, each = 4L),
    fill_style = "watercolor",
    fill_gp = grid::gpar(col = c("red", "blue")),
    outline_gp = grid::gpar(col = c("red", "blue")), seed = 1L
  )
  cls <- vapply(grid::makeContent(g)$children, function(z) class(z)[1L], "")
  expect_true(any(grepl("circle", cls)))   # bleed specks are circleGrobs
  grid::popViewport()
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

# ---- watercolor_wash_multi (hole-aware) -------------------------------------

test_that("watercolor_wash_multi returns n_layers, each a list of rings", {
  outer <- list(x = c(0, 4, 4, 0), y = c(0, 0, 4, 4))
  hole  <- list(x = c(1, 3, 3, 1), y = c(1, 1, 3, 3))
  w <- watercolor_wash_multi(list(outer, hole), n_layers = 5L, seed = 1L)
  expect_length(w$washes, 5L)
  # each layer carries one matrix per input ring
  expect_true(all(vapply(w$washes, length, integer(1L)) == 2L))
  expect_equal(colnames(w$washes[[1L]][[1L]]), c("x", "y"))
})

test_that("multi granulation specks avoid holes (even-odd membership)", {
  outer <- list(x = c(0, 6, 6, 0), y = c(0, 0, 6, 6))
  hole  <- list(x = c(2, 4, 4, 2), y = c(2, 2, 4, 4))
  w <- watercolor_wash_multi(list(outer, hole), granulation = 0.8, seed = 2L)
  expect_false(is.null(w$granules))
  in_hole <- point_in_polygon(w$granules$x, w$granules$y, hole$x, hole$y)
  expect_false(any(in_hole))
})

test_that("watercolor_wash_multi is reproducible and seed-safe", {
  rings <- list(list(x = c(0, 4, 4, 0), y = c(0, 0, 4, 4)))
  set.seed(3L); before <- .Random.seed
  a <- watercolor_wash_multi(rings, granulation = 0.5, seed = 9L)
  b <- watercolor_wash_multi(rings, granulation = 0.5, seed = 9L)
  expect_identical(a, b)
  expect_identical(.Random.seed, before)
})

test_that("degenerate / empty ring set yields no wash", {
  expect_length(watercolor_wash_multi(list(), seed = 1L)$washes, 0L)
  thin <- list(list(x = c(0, 1), y = c(0, 1)))
  expect_length(watercolor_wash_multi(thin, seed = 1L)$washes, 0L)
})

# ---- ellipse + band grob integration ----------------------------------------

test_that("sketch_ellipse_grob paints washes for watercolor", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  grid::pushViewport(grid::viewport(width = grid::unit(4, "in"),
                                    height = grid::unit(4, "in")))
  g <- sketch_ellipse_grob(
    x = 0.5, y = 0.5, rx = 0.3, ry = 0.3,
    fill_style = "watercolor",
    fill_gp = grid::gpar(col = "darkorange"),
    outline_gp = grid::gpar(col = "darkorange"), seed = 1L
  )
  cls <- vapply(grid::makeContent(g)$children, function(z) class(z)[1L], "")
  expect_true(sum(grepl("polygon", cls)) >= 6L)
  grid::popViewport()
})

test_that("sketch_band_grob paints hole-aware washes for watercolor", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  grid::pushViewport(grid::viewport(width = grid::unit(4, "in"),
                                    height = grid::unit(4, "in")))
  rings <- list(list(x = c(0.1, 0.9, 0.9, 0.1), y = c(0.1, 0.1, 0.9, 0.9)),
                list(x = c(0.4, 0.6, 0.6, 0.4), y = c(0.4, 0.4, 0.6, 0.6)))
  g <- sketch_band_grob(rings, fill_col = "seagreen", fill_style = "watercolor",
                        outline_gp = grid::gpar(col = "seagreen"), seed = 1L)
  cls <- vapply(grid::makeContent(g)$children, function(z) class(z)[1L], "")
  expect_true(sum(grepl("pathgrob|path", cls)) >= 6L)  # one even-odd path/layer
  grid::popViewport()
})

test_that("ellipse-backed geom renders with watercolor fill", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  df <- data.frame(x = 1, y = 1, r = 0.4)
  p <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, r = r)) +
    geom_sketch_circle(fill = "tomato", fill_style = "watercolor", seed = 1L)
  expect_no_error(print(p))
})

test_that("band-backed geom (contour_filled) renders with watercolor fill", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(ggplot2::faithfuld,
                       ggplot2::aes(waiting, eruptions, z = density)) +
    geom_sketch_contour_filled(fill_style = "watercolor", seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})
