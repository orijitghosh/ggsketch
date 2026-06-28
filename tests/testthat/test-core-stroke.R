# T-v2 keystone: variable-width strokes (stroke_ribbon / stroke_profile).

# Shoelace area of a closed ring.
ring_area <- function(r) {
  x <- r[, "x"]; y <- r[, "y"]; n <- nrow(r)
  j <- c(2:n, 1L)
  abs(sum(x * y[j] - x[j] * y)) / 2
}

# ---- stroke_profile ---------------------------------------------------------

test_that("stroke_profile presets return the documented multipliers", {
  expect_equal(stroke_profile("flat")(c(0, 0.5, 1)), c(1, 1, 1))
  expect_equal(stroke_profile("taper_in")(c(0, 0.5, 1)), c(0, 0.5, 1))
  expect_equal(stroke_profile("taper_out")(c(0, 0.5, 1)), c(1, 0.5, 0))
  belly <- stroke_profile("belly")
  expect_equal(belly(0.5), 1)
  expect_equal(belly(c(0, 1)), c(0, 0), tolerance = 1e-12)
})

# ---- taper_envelope ---------------------------------------------------------

test_that("taper_envelope narrows to taper_frac at the tip(s)", {
  t <- seq(0, 1, length.out = 5L)
  expect_equal(taper_envelope(t, "none", 0), rep(1, 5L))
  both <- taper_envelope(t, "both", 0)
  expect_equal(both[c(1L, 5L)], c(0, 0))      # both ends sharp
  expect_equal(both[3L], 1)                    # full in the middle
  st <- taper_envelope(t, "start", 0.25)
  expect_equal(st[1L], 0.25)                   # tip fraction honoured
  expect_equal(st[5L], 1)
})

# ---- stroke_ribbon: basic geometry ------------------------------------------

test_that("constant-width straight ribbon has the requested width (butt cap)", {
  r <- stroke_ribbon(c(0, 4), c(0, 0), width = 0.2, cap = "butt")
  expect_true(is.matrix(r))
  expect_equal(colnames(r), c("x", "y"))
  # Centreline along y = 0 -> ribbon spans +/- width/2.
  expect_equal(max(r[, "y"]), 0.1, tolerance = 1e-9)
  expect_equal(min(r[, "y"]), -0.1, tolerance = 1e-9)
  # Butt-cap rectangle area ~ length * width.
  expect_equal(ring_area(r), 4 * 0.2, tolerance = 1e-6)
})

test_that("round caps add area and vertices beyond the butt rectangle", {
  butt  <- stroke_ribbon(c(0, 4), c(0, 0), width = 0.2, cap = "butt")
  round <- stroke_ribbon(c(0, 4), c(0, 0), width = 0.2, cap = "round")
  expect_gt(nrow(round), nrow(butt))
  expect_gt(ring_area(round), ring_area(butt))   # two half-disc caps added
})

test_that("taper reduces ribbon area and sharpens the tips", {
  # Interior vertex so the full-width belly is actually sampled.
  flat  <- stroke_ribbon(c(0, 2, 4), c(0, 0, 0), width = 0.3,
                         taper = "none", cap = "butt")
  taper <- stroke_ribbon(c(0, 2, 4), c(0, 0, 0), width = 0.3,
                         taper = "both", taper_frac = 0, cap = "butt")
  expect_lt(ring_area(taper), ring_area(flat))
  # Max half-width is still ~ width/2 at the belly (the interior vertex).
  expect_equal(max(abs(taper[, "y"])), 0.15, tolerance = 1e-6)
})

test_that("pressure profile scales the half-width along the stroke", {
  flat  <- stroke_ribbon(c(0, 4), c(0, 0), width = 0.3, cap = "butt")
  belly <- stroke_ribbon(c(0, 4), c(0, 0), width = 0.3,
                         pressure = stroke_profile("belly"), cap = "butt")
  expect_lt(ring_area(belly), ring_area(flat))   # thins toward both ends
})

# ---- calligraphic nib -------------------------------------------------------

test_that("nib_angle makes across-the-nib strokes wider than along-the-nib", {
  along  <- stroke_ribbon(c(0, 4), c(0, 0), width = 0.4,
                          nib_angle = 0,  cap = "butt")   # |sin(0)| -> floor
  across <- stroke_ribbon(c(0, 4), c(0, 0), width = 0.4,
                          nib_angle = 90, cap = "butt")   # |sin(-90)| = 1
  expect_lt(max(abs(along[, "y"])), max(abs(across[, "y"])))
  expect_equal(max(abs(across[, "y"])), 0.2, tolerance = 1e-6)
})

# ---- degenerate input -------------------------------------------------------

test_that("a single vertex becomes a round dot, butt cap is empty", {
  dot <- stroke_ribbon(1, 1, width = 0.2, cap = "round")
  expect_gt(nrow(dot), 3L)
  # All points ~ radius 0.1 from the centre.
  d <- sqrt((dot[, "x"] - 1)^2 + (dot[, "y"] - 1)^2)
  expect_equal(unique(round(d, 6)), 0.1)
  expect_equal(nrow(stroke_ribbon(1, 1, width = 0.2, cap = "butt")), 0L)
})

test_that("duplicate consecutive vertices are collapsed", {
  r <- stroke_ribbon(c(0, 0, 4), c(0, 0, 0), width = 0.2, cap = "butt")
  expect_equal(ring_area(r), 4 * 0.2, tolerance = 1e-6)   # behaves like 2-pt line
})

test_that("empty input returns an empty (x, y) matrix", {
  e <- stroke_ribbon(numeric(0), numeric(0), width = 0.2)
  expect_equal(nrow(e), 0L)
  expect_equal(colnames(e), c("x", "y"))
})

# ---- reproducibility --------------------------------------------------------

test_that("jitter_w is reproducible and never touches .Random.seed", {
  set.seed(7L); before <- .Random.seed
  a <- stroke_ribbon(c(0, 4), c(0, 0), width = 0.3, jitter_w = 0.4, seed = 99L)
  b <- stroke_ribbon(c(0, 4), c(0, 0), width = 0.3, jitter_w = 0.4, seed = 99L)
  expect_identical(a, b)
  expect_identical(.Random.seed, before)
  # Jitter actually perturbs the geometry.
  c0 <- stroke_ribbon(c(0, 4), c(0, 0), width = 0.3, jitter_w = 0, seed = 99L)
  expect_false(isTRUE(all.equal(a, c0)))
})

# ---- sketch_stroke_grob (Layer 2) -------------------------------------------

test_that("sketch_stroke_grob draws a filled ribbon polygon per pass", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  grid::pushViewport(grid::viewport(width = grid::unit(4, "in"),
                                    height = grid::unit(3, "in")))
  g <- sketch_stroke_grob(x = c(0.1, 0.5, 0.9), y = c(0.2, 0.8, 0.3),
                          width = 0.05, n_passes = 2L, seed = 1L)
  kids <- grid::makeContent(g)$children
  expect_length(kids, 2L)                       # one ribbon per pass
  cls <- vapply(kids, function(z) class(z)[1L], "")
  expect_true(all(grepl("polygon", cls)))
  grid::popViewport()
})

test_that("sketch_stroke_grob renders a tapered ink stroke without error", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  g <- sketch_stroke_grob(x = c(0.1, 0.4, 0.7, 0.9), y = c(0.5, 0.7, 0.4, 0.6),
                          width = 0.06, taper = "both", n_passes = 1L,
                          gp = grid::gpar(col = "navy"), seed = 2L)
  expect_no_error(grid::grid.draw(g))
})

test_that("sketch_stroke_grob with no points draws a null grob", {
  g <- sketch_stroke_grob(x = numeric(0), y = numeric(0))
  kids <- grid::makeContent(g)$children
  expect_true(length(kids) == 1L && inherits(kids[[1L]], "null"))
})
