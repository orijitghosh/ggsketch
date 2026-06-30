# Arrowhead vocabulary: Layer-1 arrowhead() generator + grob wiring.

test_that("sketch_arrowheads lists the styles and check_arrowhead validates", {
  expect_true(all(c("triangle_open", "triangle_filled", "barb", "fishtail",
                    "dot", "bar") %in% sketch_arrowheads()))
  expect_silent(check_arrowhead("barb"))
  expect_error(check_arrowhead("nope"), "must be one of")
})

test_that("each style returns the right kind of primitive", {
  ah <- function(s) arrowhead(0, 0, angle = 0, length = 0.2, style = s)
  expect_length(ah("triangle_open")$strokes, 1L)
  expect_length(ah("triangle_open")$polygons, 0L)

  expect_length(ah("triangle_filled")$polygons, 1L)
  expect_length(ah("barb")$polygons, 1L)
  expect_length(ah("fishtail")$polygons, 1L)

  expect_null(ah("triangle_open")$dots)
  expect_false(is.null(ah("dot")$dots))
  expect_length(ah("bar")$strokes, 1L)
})

test_that("the head points along the given angle (tip leads the wings)", {
  # pointing +x: every base/notch vertex sits at x <= tip x (= 0 here is tip)
  open <- arrowhead(0, 0, angle = 0, length = 0.2, style = "triangle_open")
  s <- open$strokes[[1L]]
  expect_equal(unname(s[2L, "x"]), 0)       # middle vertex is the tip
  expect_true(all(s[c(1L, 3L), "x"] < 0))   # wings swept back in -x
})

test_that("arrowhead() coordinates are finite and well-formed", {
  for (s in sketch_arrowheads()) {
    a <- arrowhead(1, 2, angle = pi / 3, length = 0.15, style = s)
    for (m in c(a$strokes, a$polygons)) {
      expect_true(is.matrix(m))
      expect_true(all(is.finite(m)))
    }
  }
})

# ---- grob integration -------------------------------------------------------

count_heads <- function(grob) {
  kids <- grid::makeContent(grob)$children
  cls  <- vapply(kids, function(z) class(z)[1L], "")
  # a shaft is the first polyline group; heads add polylines/polygons/circles
  sum(grepl("polygon|circle", cls))
}

test_that("sketch_arrow_grob renders a filled head for closed styles", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  grid::pushViewport(grid::viewport(width = grid::unit(4, "in"),
                                    height = grid::unit(4, "in")))
  g <- sketch_arrow_grob(x0 = 0.1, y0 = 0.1, cx = 0.4, cy = 0.6,
                         x1 = 0.8, y1 = 0.8, arrow_head = "barb", seed = 1L,
                         gp = grid::gpar(col = "black"))
  cls <- vapply(grid::makeContent(g)$children, function(z) class(z)[1L], "")
  expect_true(any(grepl("polygon", cls)))   # barb is a filled polygon
  grid::popViewport()
})

test_that("ends = 'both' draws a head at each end", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  grid::pushViewport(grid::viewport(width = grid::unit(4, "in"),
                                    height = grid::unit(4, "in")))
  one <- sketch_arrow_grob(0.1, 0.1, 0.5, 0.5, 0.9, 0.9, arrow_head = "dot",
                           ends = "last", seed = 1L, gp = grid::gpar(col = "black"))
  two <- sketch_arrow_grob(0.1, 0.1, 0.5, 0.5, 0.9, 0.9, arrow_head = "dot",
                           ends = "both", seed = 1L, gp = grid::gpar(col = "black"))
  expect_equal(count_heads(two), count_heads(one) + 1L)   # one extra dot
  grid::popViewport()
})

test_that("arrow_type still maps to a head for back-compat", {
  expect_identical(resolve_arrow_head(NULL, "closed"), "triangle_filled")
  expect_identical(resolve_arrow_head(NULL, "open"), "triangle_open")
  expect_identical(resolve_arrow_head("dot", "closed"), "dot")  # explicit wins
})

test_that("leader_path routes straight / elbow / curved with end tangents", {
  st <- leader_path(0, 0, 1, 1, style = "straight")
  expect_equal(cbind(st$x, st$y), matrix(c(0, 1, 0, 1), ncol = 2L))
  expect_equal(st$angle, atan2(1, 1))

  el <- leader_path(0, 0, 2, 1, style = "elbow")
  expect_length(el$x, 3L)
  expect_equal(el$x, c(0, 2, 2))                  # horizontal then vertical
  expect_equal(el$y, c(0, 0, 1))
  expect_equal(el$angle, atan2(1, 0))             # last segment is vertical

  cu <- leader_path(0, 0, 1, 0, style = "curved", curvature = 0.5)
  expect_gt(length(cu$x), 3L)                     # sampled Bezier
  expect_equal(cu$x[length(cu$x)], 1)             # ends on target
})

test_that("callout leader styles all render", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  for (ld in c("straight", "elbow", "curved")) {
    p <- ggplot2::ggplot() +
      annotate_sketch_callout(x = 0.3, y = 0.8, xend = 0.7, yend = 0.3,
                              label = ld, leader = ld, seed = 1L)
    expect_no_error(print(p))
  }
})

test_that("geom_sketch_arrow accepts head + ends end to end", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot() +
    annotate_sketch_arrow(x = 1, y = 1, xend = 2, yend = 2,
                          arrow_head = "fishtail", ends = "both", seed = 1L)
  expect_no_error(print(p))
})
