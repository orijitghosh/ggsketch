# T-v2: engraving module - tonal cross-hatch by line density.
# Layer 1 (engrave_ladder / engrave_fill / field), Layer 2 (sketch_engrave_grob),
# Layer 3 (geom_sketch_engrave / geom_sketch_shade).

# ---- ladder -----------------------------------------------------------------

test_that("engrave_ladder builds an increasing-density, thresholded ladder", {
  lad <- engrave_ladder(n_levels = 5L, base_gap = 0.1, gap_ratio = 0.6,
                        base_angle = 45, cross_after = 3L)
  expect_length(lad, 5L)
  gaps <- vapply(lad, function(l) l$gap, numeric(1L))
  thr  <- vapply(lad, function(l) l$threshold, numeric(1L))
  expect_true(all(diff(gaps) < 0))     # each layer denser
  expect_true(all(diff(thr) > 0))      # each layer needs darker tone
  # Cross-hatching introduces a different angle at/after cross_after.
  angs <- vapply(lad, function(l) l$angle, numeric(1L))
  expect_true(any(angs != angs[1L]))
})

test_that("engrave_ladder with one level is the base layer", {
  lad <- engrave_ladder(n_levels = 1L, base_gap = 0.1, base_angle = 30)
  expect_length(lad, 1L)
  expect_equal(lad[[1L]]$angle, 30)
})

# ---- field interpolation ----------------------------------------------------

test_that("engrave_field_from_grid bilinearly interpolates and clamps", {
  gx <- c(0, 1); gy <- c(0, 1)
  Z  <- matrix(c(0, 0, 0, 1), 2, 2)   # 1 only at (1,1)
  f  <- engrave_field_from_grid(gx, gy, Z)
  expect_equal(f(0, 0), 0)
  expect_equal(f(1, 1), 1)
  expect_equal(f(0.5, 0.5), 0.25)     # bilinear centre
  expect_equal(f(-5, -5), 0)          # clamped to edge
  expect_equal(f(5, 5), 1)
})

# ---- engrave_fill -----------------------------------------------------------

test_that("engrave_fill density tracks the tone field", {
  ring <- list(list(x = c(0, 4, 4, 0), y = c(0, 0, 4, 4)))
  dark  <- engrave_fill(ring, function(x, y) rep(1, length(x)),
                        base_gap = 0.5, seed = 1L)
  light <- engrave_fill(ring, function(x, y) rep(0.2, length(x)),
                        base_gap = 0.5, seed = 1L)
  blank <- engrave_fill(ring, function(x, y) rep(0, length(x)),
                        base_gap = 0.5, seed = 1L)
  expect_gt(length(dark), length(light))   # darker -> more strokes
  expect_length(blank, 0L)                 # below floor -> nothing
})

test_that("engrave_fill keeps strokes only where tone exceeds threshold", {
  ring <- list(list(x = c(0, 4, 4, 0), y = c(0, 0, 4, 4)))
  # Dark only on the right half (x > 2).
  segs <- engrave_fill(ring, function(x, y) ifelse(x > 2, 1, 0),
                       base_gap = 0.4, roughness = 0, seed = 1L)
  expect_gt(length(segs), 0L)
  mids <- vapply(segs, function(s) (s[1L, "x"] + s[nrow(s), "x"]) / 2, numeric(1L))
  expect_true(all(mids > 1.5))             # nothing strays into the light half
})

# ---- sketch_engrave_grob ----------------------------------------------------

test_that("sketch_engrave_grob draws polylines for a dark field", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  grid::pushViewport(grid::viewport(width = grid::unit(5, "in"),
                                    height = grid::unit(4, "in")))
  field <- function(xn, yn) {
    d <- sqrt((xn - 0.5)^2 + (yn - 0.5)^2); pmin(1, pmax(0, 1 - d / 0.5))
  }
  rings <- list(list(x = c(0.05, 0.95, 0.95, 0.05),
                     y = c(0.05, 0.05, 0.95, 0.95)))
  g   <- sketch_engrave_grob(rings, field, seed = 1L)
  kids <- grid::makeContent(g)$children
  expect_gt(length(kids), 0L)
  cls <- vapply(kids, function(z) class(z)[1L], "")
  expect_true(any(grepl("polyline", cls)))
  grid::popViewport()
})

test_that("sketch_engrave_grob min_gap_in floor drops all-too-fine ladders", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  grid::pushViewport(grid::viewport(width = grid::unit(5, "in"),
                                    height = grid::unit(4, "in")))
  rings <- list(list(x = c(0.05, 0.95, 0.95, 0.05),
                     y = c(0.05, 0.05, 0.95, 0.95)))
  g <- sketch_engrave_grob(rings, function(x, y) rep(1, length(x)),
                           min_gap_in = 100, seed = 1L)   # nothing survives
  kids <- grid::makeContent(g)$children
  expect_true(length(kids) == 1L && inherits(kids[[1L]], "null"))
  grid::popViewport()
})

# ---- geom_sketch_engrave ----------------------------------------------------

test_that("geom_sketch_engrave builds on an x/y/z grid", {
  p <- ggplot2::ggplot(ggplot2::faithfuld,
                       ggplot2::aes(waiting, eruptions, z = density)) +
    geom_sketch_engrave(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_true("reverse" %in% GeomSketchEngrave$parameters())
})

test_that("geom_sketch_engrave renders strokes for a real surface", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(ggplot2::faithfuld,
                       ggplot2::aes(waiting, eruptions, z = density)) +
    geom_sketch_engrave(seed = 1L)
  expect_no_error(print(p))
})

# ---- geom_sketch_shade ------------------------------------------------------

test_that("geom_sketch_shade builds and shades by the tone aesthetic", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  hex <- data.frame(
    x = cos(seq(0, 2 * pi, length.out = 7))[-7L],
    y = sin(seq(0, 2 * pi, length.out = 7))[-7L]
  )
  df <- do.call(rbind, lapply(1:2, function(k) {
    d <- hex; d$x <- d$x + (k - 1L) * 2.3; d$g <- k; d$val <- c(0.3, 0.9)[k]; d
  }))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, group = g)) +
    geom_sketch_shade(ggplot2::aes(tone = val), seed = 2L)
  expect_no_error(print(p))
})
