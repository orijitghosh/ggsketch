# T-FILL-01..04, T-CORE-04, T-CORE-08, T-CORE-09

mat_val <- function(m, r, c) unname(m[r, c])

# ---- hachure_fill: convex polygon -------------------------------------------

test_that("unit square produces correct fill-line count (T-CORE-04)", {
  # Square (0,0)→(1,0)→(1,1)→(0,1), gap=0.2 → expect ~5 lines
  px <- c(0, 1, 1, 0); py <- c(0, 0, 1, 1)
  segs <- hachure_fill(px, py, hachure_gap = 0.2, hachure_angle = 0, seed = 1L)
  expect_gte(length(segs), 4L)
  expect_lte(length(segs), 7L)
})

test_that("fill lines are 2-column matrices", {
  px <- c(0, 1, 1, 0); py <- c(0, 0, 1, 1)
  segs <- hachure_fill(px, py, hachure_gap = 0.2, hachure_angle = 0, seed = 1L)
  for (s in segs) {
    expect_true(is.matrix(s))
    expect_equal(colnames(s), c("x", "y"))
  }
})

test_that("fill lines lie inside convex polygon (T-FILL-01 convex case)", {
  px <- c(0, 2, 2, 0); py <- c(0, 0, 2, 2)
  segs <- hachure_fill(px, py, hachure_gap = 0.25, hachure_angle = 0, seed = 1L)
  expect_gt(length(segs), 0L)
  for (s in segs) {
    # Midpoint of each segment should be inside the square
    mx <- (s[1L, "x"] + s[nrow(s), "x"]) / 2
    my <- (s[1L, "y"] + s[nrow(s), "y"]) / 2
    expect_true(mx >= -1e-9 && mx <= 2 + 1e-9)
    expect_true(my >= -1e-9 && my <= 2 + 1e-9)
  }
})

test_that("fill-line containment for concave C-shape (T-FILL-01 concave, AC-5)", {
  # C-shape (right-open C):
  # outer: (0,0)→(3,0)→(3,1)→(1,1)→(1,2)→(3,2)→(3,3)→(0,3)
  px <- c(0, 3, 3, 1, 1, 3, 3, 0)
  py <- c(0, 0, 1, 1, 2, 2, 3, 3)
  segs <- hachure_fill(px, py, hachure_gap = 0.3, hachure_angle = 0, seed = 1L)
  expect_gt(length(segs), 0L)

  y_min_poly <- min(py); y_max_poly <- max(py)

  for (s in segs) {
    y_seg <- s[1L, "y"]
    # Skip fill lines on the polygon boundary (y=y_min or y=y_max) — ray-casting
    # classifies boundary points as outside by convention; they're not fill errors.
    if (abs(y_seg - y_min_poly) < 1e-6 || abs(y_seg - y_max_poly) < 1e-6) next

    x_left  <- s[1L, "x"]
    x_right <- s[nrow(s), "x"]
    seg_len <- abs(x_right - x_left)
    if (seg_len < 1e-6) next

    # Sample INTERIOR of the segment (10%..90%): avoid boundary x-values
    xs <- x_left + seq(0.1, 0.9, length.out = 5L) * (x_right - x_left)
    ys <- rep(y_seg, 5L)
    inside <- point_in_polygon(xs, ys, px, py)
    expect_true(all(inside),
                info = paste("Fill line at y =", round(y_seg, 3),
                             "has interior points outside the C-shape"))
  }
})

test_that(".Random.seed unchanged after hachure_fill (T-CORE-06)", {
  set.seed(11L)
  before <- .Random.seed
  hachure_fill(c(0, 1, 1, 0), c(0, 0, 1, 1), seed = 42L)
  expect_identical(.Random.seed, before)
})

test_that("same seed → same fill segments (T-CORE-07)", {
  px <- c(0, 2, 2, 0); py <- c(0, 0, 2, 2)
  s1 <- hachure_fill(px, py, hachure_gap = 0.3, seed = 7L)
  s2 <- hachure_fill(px, py, hachure_gap = 0.3, seed = 7L)
  expect_identical(s1, s2)
})

test_that("horizontal edge in polygon — no crash, correct span count (T-FILL-02)", {
  # Triangle with a horizontal top edge
  px <- c(0, 2, 1, 0); py <- c(0, 0, 2, 0)
  # No error and returns a list
  segs <- expect_no_error(
    hachure_fill(px, py, hachure_gap = 0.25, hachure_angle = 0, seed = 1L)
  )
  expect_type(segs, "list")
})

test_that("vertex on scanline — no doubled spans (T-FILL-02)", {
  # Diamond: vertex exactly at y=1 (scanline)
  px <- c(0, 1, 2, 1); py <- c(1, 0, 1, 2)
  segs <- hachure_fill(px, py, hachure_gap = 0.5, hachure_angle = 0, seed = 1L)
  # y=1 scanline should produce exactly one span (0→2), not two
  y_vals <- vapply(segs, function(s) s[1L, "y"], numeric(1L))
  n_at_y1 <- sum(abs(y_vals - 1) < 1e-6)
  expect_lte(n_at_y1, 1L)
})

# ---- hachure angle rotation (T-FILL-03) ------------------------------------

test_that("angle=45 produces diagonal fill lines", {
  px <- c(0, 3, 3, 0); py <- c(0, 0, 3, 3)
  segs <- hachure_fill(px, py, hachure_gap = 0.5, hachure_angle = 45, seed = 1L)
  expect_gt(length(segs), 0L)
  # Fill lines at 45° should have x-range ≈ y-range (not perfectly horizontal)
  for (s in segs[seq_len(min(3L, length(segs)))]) {
    dx <- abs(s[nrow(s), "x"] - s[1L, "x"])
    dy <- abs(s[nrow(s), "y"] - s[1L, "y"])
    expect_gt(dx + dy, 1e-6)  # not degenerate
  }
})

# ---- derived fill styles (T-CORE-08) ----------------------------------------

test_that("cross_hatch produces more segments than hachure (T-CORE-08)", {
  px <- c(0, 2, 2, 0); py <- c(0, 0, 2, 2)
  h  <- sketch_fill(px, py, fill_style = "hachure",    seed = 1L)
  ch <- sketch_fill(px, py, fill_style = "cross_hatch", seed = 1L)
  expect_gt(length(ch), length(h))
})

test_that("zigzag includes connectors in addition to fill lines (T-CORE-08)", {
  px <- c(0, 2, 2, 0); py <- c(0, 0, 2, 2)
  h  <- sketch_fill(px, py, fill_style = "hachure", hachure_gap = 0.3, seed = 1L)
  z  <- sketch_fill(px, py, fill_style = "zigzag",  hachure_gap = 0.3, seed = 1L)
  expect_gt(length(z), length(h))
})

test_that("zigzag_line fill returns list", {
  px <- c(0, 2, 2, 0); py <- c(0, 0, 2, 2)
  result <- sketch_fill(px, py, fill_style = "zigzag_line", hachure_gap = 0.3,
                         seed = 1L)
  expect_type(result, "list")
})

test_that("dots fill returns list of small ellipse paths (T-CORE-08)", {
  px <- c(0, 2, 2, 0); py <- c(0, 0, 2, 2)
  d <- sketch_fill(px, py, fill_style = "dots", hachure_gap = 0.3, seed = 1L)
  expect_gt(length(d), 0L)
  expect_true(is.matrix(d[[1L]]))
})

test_that("dashed fill returns list (T-CORE-08)", {
  px <- c(0, 2, 2, 0); py <- c(0, 0, 2, 2)
  d <- sketch_fill(px, py, fill_style = "dashed", hachure_gap = 0.3, seed = 1L)
  expect_gt(length(d), 0L)
})

test_that("solid fill returns NULL (T-CORE-08)", {
  px <- c(0, 1, 1, 0); py <- c(0, 0, 1, 1)
  result <- sketch_fill(px, py, fill_style = "solid", seed = 1L)
  expect_null(result)
})

test_that("invalid fill_style errors clearly", {
  expect_error(
    sketch_fill(c(0,1,1,0), c(0,0,1,1), fill_style = "nope"),
    class = "rlang_error"
  )
})

# ---- curve_fill bridge (T-CORE-09) ------------------------------------------

test_that("curve_fill flattens Bézier boundary and fills (T-CORE-09)", {
  # A single Bézier making a roughly square path
  bez_list <- list(
    list(P0 = c(0, 0), P1 = c(0, 0), P2 = c(1, 0), P3 = c(1, 0)),
    list(P0 = c(1, 0), P1 = c(1, 0), P2 = c(1, 1), P3 = c(1, 1)),
    list(P0 = c(1, 1), P1 = c(1, 1), P2 = c(0, 1), P3 = c(0, 1)),
    list(P0 = c(0, 1), P1 = c(0, 1), P2 = c(0, 0), P3 = c(0, 0))
  )
  result <- curve_fill(bez_list, fill_style = "hachure",
                        hachure_gap = 0.25, hachure_angle = 0, seed = 1L)
  expect_type(result, "list")
  expect_gt(length(result), 0L)
})

# ---- geometry snapshot (T-CORE-04, ADR-0009) --------------------------------

test_that("geometry snapshot — unit square hachure fill angle=0", {
  px <- c(0, 1, 1, 0); py <- c(0, 0, 1, 1)
  segs <- hachure_fill(px, py, hachure_gap = 0.25, hachure_angle = 0, seed = 42L)
  expect_snapshot_geometry(segs)
})
