# Regression: non-finite (Inf/NaN) vertices must not break the scan-line
# filler or the polygon grob. They can arrive from unbounded stat output
# (e.g. log transforms of zero) or bad user data.

test_that("hachure_fill_multi drops non-finite vertices instead of erroring", {
  ring <- list(x = c(0, 2, Inf, 2, 0), y = c(0, 0, NaN, 2, 2))
  segs <- hachure_fill_multi(list(ring), hachure_gap = 0.3, seed = 1L)
  expect_type(segs, "list")
  expect_gt(length(segs), 0L)
  for (m in segs) expect_true(all(is.finite(m)))
})

test_that("ring left with < 2 finite vertices is skipped", {
  good <- list(x = c(0, 2, 2, 0), y = c(0, 0, 2, 2))
  bad  <- list(x = c(1, Inf, NA_real_), y = c(1, 1, 1))
  segs <- hachure_fill_multi(list(good, bad), hachure_gap = 0.3, seed = 1L)
  ref  <- hachure_fill_multi(list(good), hachure_gap = 0.3, seed = 1L)
  expect_identical(segs, ref)
})

test_that("all-degenerate rings yield an empty fill, not an error", {
  bad <- list(x = c(Inf, NaN, NA_real_), y = c(0, 1, 2))
  expect_identical(
    hachure_fill_multi(list(bad), hachure_gap = 0.3, seed = 1L),
    list()
  )
})

test_that("SketchPolygonGrob renders when a vertex is non-finite", {
  g <- sketch_polygon_grob(
    x = c(0.2, 0.8, NaN, 0.8, 0.2), y = c(0.2, 0.2, 0.5, 0.8, 0.8),
    fill_style = "hachure", seed = 1L,
    fill_gp    = grid::gpar(col = "red"),
    outline_gp = grid::gpar(col = "black")
  )
  kids <- expect_no_error(grid::makeContent(g))$children
  expect_gt(length(kids), 0L)
})

test_that("a group with no finite vertices is skipped, others still drawn", {
  g <- sketch_polygon_grob(
    x  = c(0.2, 0.4, 0.4, 0.2, Inf, NaN, Inf),
    y  = c(0.2, 0.2, 0.4, 0.4, Inf, Inf, NaN),
    id = c(1L, 1L, 1L, 1L, 2L, 2L, 2L),
    fill_style = "hachure", seed = 1L,
    fill_gp    = grid::gpar(col = "red"),
    outline_gp = grid::gpar(col = "black")
  )
  kids <- expect_no_error(grid::makeContent(g))$children
  cls  <- vapply(kids, function(k) class(k)[1L], "")
  expect_true(any(cls != "null"))
})
