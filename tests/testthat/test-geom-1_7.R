# T-1.7: dot plot, mark family (circle/ellipse/rect), ecdf, lollipop,
# and hole-aware filled contour / density bands.

# ---- hole-aware hachure (Layer 1) -------------------------------------------

test_that("hachure_fill_multi delegates identically for a single ring", {
  px <- c(0, 1, 1, 0); py <- c(0, 0, 1, 1)
  a <- hachure_fill(px, py, hachure_gap = 0.25, hachure_angle = 0, seed = 42L)
  b <- hachure_fill_multi(list(list(x = px, y = py)),
                          hachure_gap = 0.25, hachure_angle = 0, seed = 42L)
  expect_identical(a, b)
})

test_that("hachure_fill_multi keeps holes empty", {
  outer <- list(x = c(0, 4, 4, 0), y = c(0, 0, 4, 4))
  hole  <- list(x = c(1, 3, 3, 1), y = c(1, 1, 3, 3))
  segs  <- hachure_fill_multi(list(outer, hole),
                              hachure_gap = 0.5, hachure_angle = 0, seed = 1L)
  expect_gt(length(segs), 0L)
  for (s in segs) {
    mx <- (s[1L, "x"] + s[nrow(s), "x"]) / 2
    my <- (s[1L, "y"] + s[nrow(s), "y"]) / 2
    inside_hole <- point_in_polygon(mx, my, hole$x, hole$y)
    expect_false(isTRUE(inside_hole))
  }
})

test_that("sketch_fill_multi: cross_hatch denser than hachure, solid is NULL", {
  rings <- list(list(x = c(0, 2, 2, 0), y = c(0, 0, 2, 2)))
  h  <- sketch_fill_multi(rings, "hachure",     hachure_gap = 0.3, seed = 1L)
  ch <- sketch_fill_multi(rings, "cross_hatch", hachure_gap = 0.3, seed = 1L)
  expect_gt(length(ch), length(h))
  expect_null(sketch_fill_multi(rings, "solid", seed = 1L))
})

# ---- sketch_band_grob -------------------------------------------------------

test_that("sketch_band_grob solid fill draws an even-odd path", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  rings <- list(list(x = c(0.1, 0.9, 0.9, 0.1), y = c(0.1, 0.1, 0.9, 0.9)),
                list(x = c(0.4, 0.6, 0.6, 0.4), y = c(0.4, 0.4, 0.6, 0.6)))
  g <- sketch_band_grob(rings, fill_col = "grey50", seed = 1L,
                        outline_gp = grid::gpar(col = "black"))
  cls <- vapply(grid::makeContent(g)$children, function(z) class(z)[1], "")
  expect_true(any(grepl("path", cls)))
})

# ---- filled contour / density bands -----------------------------------------

test_that("geom_sketch_contour_filled builds (solid and hachure)", {
  p1 <- ggplot2::ggplot(ggplot2::faithfuld,
                        ggplot2::aes(waiting, eruptions, z = density)) +
    geom_sketch_contour_filled(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p1))

  p2 <- ggplot2::ggplot(ggplot2::faithfuld,
                        ggplot2::aes(waiting, eruptions, z = density)) +
    geom_sketch_contour_filled(fill_style = "hachure", seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p2))
})

test_that("geom_sketch_density_2d_filled builds", {
  skip_if_not_installed("MASS")
  p <- ggplot2::ggplot(faithful, ggplot2::aes(eruptions, waiting)) +
    geom_sketch_density_2d_filled(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_identical(geom_sketch_density2d_filled, geom_sketch_density_2d_filled)
})

# ---- dot plot ---------------------------------------------------------------

test_that("geom_sketch_dotplot bins and stacks", {
  p <- ggplot2::ggplot(faithful, ggplot2::aes(eruptions)) +
    geom_sketch_dotplot(binwidth = 0.2, seed = 1L)
  d <- ggplot2::layer_data(p)
  expect_true(all(c("stackpos", "count") %in% names(d)))
  expect_gt(max(d$stackpos), 1L)            # some bin stacked >1 dot
  expect_equal(max(d$ymax), max(d$count))   # y range = tallest bin
})

test_that("sketch_dotplot_grob makes circular dots that stack upward", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  g <- sketch_dotplot_grob(x = c(0.5, 0.5, 0.5), stackpos = 1:3,
                           dia = 0.1, baseline = 0, seed = 1L,
                           fill_gp = grid::gpar(col = "black"),
                           outline_gp = grid::gpar(col = "black"))
  kids <- grid::makeContent(g)$children
  expect_gt(length(kids), 0L)
})

# ---- mark family ------------------------------------------------------------

test_that("mark circle/ellipse/rect build and expose params", {
  expect_true("expand" %in% GeomSketchMarkCircle$parameters())
  for (g in list(geom_sketch_mark_circle, geom_sketch_mark_ellipse,
                 geom_sketch_mark_rect)) {
    p <- ggplot2::ggplot(iris,
                         ggplot2::aes(Sepal.Length, Sepal.Width, group = Species)) +
      g(seed = 1L)
    expect_no_error(ggplot2::ggplot_build(p))
  }
})

test_that("mark expands the panel to contain the shape", {
  p <- ggplot2::ggplot(iris,
                       ggplot2::aes(Sepal.Length, Sepal.Width, group = Species)) +
    geom_sketch_mark_circle(seed = 1L)
  d <- ggplot2::layer_data(p)
  expect_lt(min(d$xmin), min(iris$Sepal.Length))
  expect_gt(max(d$xmax), max(iris$Sepal.Length))
})

test_that("mark shape with fewer than 2 points draws nothing", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  df <- data.frame(x = 1, y = 1)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) + geom_sketch_mark_circle(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})

# ---- ecdf -------------------------------------------------------------------

test_that("geom_sketch_ecdf builds", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg)) +
    geom_sketch_ecdf(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})

# ---- lollipop ---------------------------------------------------------------

test_that("geom_sketch_lollipop draws stems and heads", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  df <- data.frame(g = c("A", "B", "C"), v = c(3, 5, 2))
  p  <- ggplot2::ggplot(df, ggplot2::aes(g, v)) +
    geom_sketch_lollipop(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_true("baseline" %in% GeomSketchLollipop$parameters())
})

test_that("lollipop value axis includes the baseline", {
  d <- ggplot2::layer_data(
    ggplot2::ggplot(data.frame(g = c("A", "B"), v = c(20, 40)),
                    ggplot2::aes(g, v)) +
      geom_sketch_lollipop(seed = 1L)
  )
  expect_lte(min(d$ymin), 0)
})
