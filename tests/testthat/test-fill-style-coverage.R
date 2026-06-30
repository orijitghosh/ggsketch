# P3-T3: Fill-style coverage snapshots (AC-1 / T-LOOK-01)
# Tests each fill style on a fixed unit square polygon at Layer 1.

test_that("hachure fill produces non-empty output on a unit square", {
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  result <- sketch_fill(px, py,
    fill_style = "hachure", hachure_gap = 0.1,
    hachure_angle = 45, seed = 1L
  )
  expect_true(is.list(result))
  expect_gt(length(result), 0)
  for (seg in result) {
    expect_true(is.matrix(seg))
    expect_equal(ncol(seg), 2L)
    expect_true(all(c("x", "y") %in% colnames(seg)))
  }
})

test_that("cross_hatch fill produces output with two angle sets", {
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  hach <- sketch_fill(px, py,
    fill_style = "hachure", hachure_gap = 0.1,
    hachure_angle = 45, seed = 1L
  )
  cross <- sketch_fill(px, py,
    fill_style = "cross_hatch", hachure_gap = 0.1,
    hachure_angle = 45, seed = 1L
  )
  expect_gt(length(cross), length(hach))
})

test_that("stipple scatters interior dots, all inside the polygon", {
  px <- c(0, 1, 1, 0); py <- c(0, 0, 1, 1)
  res <- sketch_fill(px, py, fill_style = "stipple", hachure_gap = 0.08,
                     seed = 1L)
  expect_gt(length(res), 20L)
  # each dot is a small closed ring; its centroid lies inside the square
  # (allow a few edge dots whose roughened ring drifts a hair past the border)
  cents <- t(vapply(res, function(m) colMeans(m[, c("x", "y")]), numeric(2L)))
  expect_gt(mean(point_in_polygon(cents[, 1L], cents[, 2L], px, py)), 0.95)
  # denser gap => more dots
  dense <- sketch_fill(px, py, fill_style = "stipple", hachure_gap = 0.04,
                       seed = 1L)
  expect_gt(length(dense), length(res))
})

test_that("pencil_shade lays trimmed strokes plus a cross set", {
  px <- c(0, 1, 1, 0); py <- c(0, 0, 1, 1)
  base <- sketch_fill(px, py, fill_style = "hachure", hachure_gap = 0.1,
                      hachure_angle = 45, seed = 1L)
  pen  <- sketch_fill(px, py, fill_style = "pencil_shade", hachure_gap = 0.1,
                      hachure_angle = 45, seed = 1L)
  expect_true(is.list(pen))
  expect_gt(length(pen), length(base))           # base + cross strokes
  for (seg in pen) expect_true(all(is.finite(seg)))
})

test_that("stipple and pencil_shade work on multi-ring regions", {
  outer <- list(x = c(0, 6, 6, 0), y = c(0, 0, 6, 6))
  hole  <- list(x = c(2, 4, 4, 2), y = c(2, 2, 4, 4))
  st <- sketch_fill_multi(list(outer, hole), fill_style = "stipple",
                          hachure_gap = 0.3, seed = 1L)
  cents <- t(vapply(st, function(m) colMeans(m[, c("x", "y")]), numeric(2L)))
  in_hole <- point_in_polygon(cents[, 1L], cents[, 2L], hole$x, hole$y)
  expect_lt(mean(in_hole), 0.02)                 # dots (centres) avoid the hole
  pen <- sketch_fill_multi(list(outer, hole), fill_style = "pencil_shade",
                           hachure_gap = 0.5, seed = 1L)
  expect_gt(length(pen), 0L)
})

test_that("the new styles are accepted by check_fill_style", {
  expect_silent(check_fill_style("stipple"))
  expect_silent(check_fill_style("pencil_shade"))
})

test_that("zigzag fill produces output with connectors", {
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  result <- sketch_fill(px, py,
    fill_style = "zigzag", hachure_gap = 0.1,
    hachure_angle = 45, seed = 1L
  )
  expect_true(is.list(result))
  expect_gt(length(result), 0)
})

test_that("zigzag_line fill produces a continuous zigzag path", {
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  result <- sketch_fill(px, py,
    fill_style = "zigzag_line", hachure_gap = 0.1,
    hachure_angle = 45, seed = 1L
  )
  expect_true(is.list(result))
  expect_gt(length(result), 0)
})

test_that("scribble fill produces a continuous winding stroke", {
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  result <- sketch_fill(px, py,
    fill_style = "scribble", hachure_gap = 0.1,
    hachure_angle = 45, roughness = 0.6, seed = 1L
  )
  expect_true(is.list(result))
  expect_gt(length(result), 0)
  for (seg in result) {
    expect_true(is.matrix(seg))
    expect_equal(ncol(seg), 2L)
  }
})

test_that("scribble fill is deterministic", {
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  r1 <- sketch_fill(px, py, fill_style = "scribble", seed = 7L)
  r2 <- sketch_fill(px, py, fill_style = "scribble", seed = 7L)
  expect_identical(r1, r2)
})

test_that("dots fill produces small ellipse segments", {
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  result <- sketch_fill(px, py,
    fill_style = "dots", hachure_gap = 0.1,
    hachure_angle = 45, seed = 1L
  )
  expect_true(is.list(result))
  expect_gt(length(result), 0)
  # Each dot is a rough ellipse matrix
  for (seg in result) {
    expect_true(is.matrix(seg))
    expect_equal(ncol(seg), 2L)
  }
})

test_that("dashed fill produces alternating dash segments", {
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  result <- sketch_fill(px, py,
    fill_style = "dashed", hachure_gap = 0.1,
    hachure_angle = 45, seed = 1L
  )
  expect_true(is.list(result))
  expect_gt(length(result), 0)
})

test_that("solid fill returns NULL (handled by polygon fill colour)", {
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  result <- sketch_fill(px, py,
    fill_style = "solid", hachure_gap = 0.1,
    hachure_angle = 45, seed = 1L
  )
  expect_null(result)
})

test_that("invalid fill_style raises an error", {
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  expect_error(
    sketch_fill(px, py, fill_style = "not_a_style", seed = 1L),
    "fill_style"
  )
})

test_that("hachure fill is deterministic (AC-4)", {
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  r1 <- sketch_fill(px, py,
    fill_style = "hachure", hachure_gap = 0.1,
    hachure_angle = 45, seed = 42L
  )
  r2 <- sketch_fill(px, py,
    fill_style = "hachure", hachure_gap = 0.1,
    hachure_angle = 45, seed = 42L
  )
  expect_identical(r1, r2)
})

test_that("different seeds produce different fill output", {
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  r1 <- sketch_fill(px, py,
    fill_style = "hachure", hachure_gap = 0.1,
    hachure_angle = 45, roughness = 1, seed = 1L
  )
  r2 <- sketch_fill(px, py,
    fill_style = "hachure", hachure_gap = 0.1,
    hachure_angle = 45, roughness = 1, seed = 999L
  )
  # At least one segment should differ
  differ <- !identical(r1, r2)
  expect_true(differ)
})

test_that("hachure geometry snapshot (T-CORE-04)", {
  skip_on_cran()
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  result <- sketch_fill(px, py,
    fill_style = "hachure", hachure_gap = 0.1,
    hachure_angle = 45, roughness = 0.5, bowing = 0, seed = 1L
  )
  expect_snapshot_geometry(result)
})

test_that("cross_hatch geometry snapshot (P3-T3)", {
  skip_on_cran()
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  result <- sketch_fill(px, py,
    fill_style = "cross_hatch", hachure_gap = 0.1,
    hachure_angle = 45, roughness = 0.5, bowing = 0, seed = 1L
  )
  expect_snapshot_geometry(result)
})

test_that("zigzag geometry snapshot (P3-T3)", {
  skip_on_cran()
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  result <- sketch_fill(px, py,
    fill_style = "zigzag", hachure_gap = 0.1,
    hachure_angle = 45, roughness = 0.5, bowing = 0, seed = 1L
  )
  expect_snapshot_geometry(result)
})

test_that("zigzag_line geometry snapshot (P3-T3)", {
  skip_on_cran()
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  result <- sketch_fill(px, py,
    fill_style = "zigzag_line", hachure_gap = 0.1,
    hachure_angle = 45, roughness = 0.5, bowing = 0, seed = 1L
  )
  expect_snapshot_geometry(result)
})

test_that("dots geometry snapshot (P3-T3)", {
  skip_on_cran()
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  result <- sketch_fill(px, py,
    fill_style = "dots", hachure_gap = 0.1,
    hachure_angle = 45, roughness = 0.5, seed = 1L
  )
  expect_snapshot_geometry(result)
})

test_that("dashed geometry snapshot (P3-T3)", {
  skip_on_cran()
  px <- c(0, 1, 1, 0)
  py <- c(0, 0, 1, 1)
  result <- sketch_fill(px, py,
    fill_style = "dashed", hachure_gap = 0.1,
    hachure_angle = 45, roughness = 0.5, bowing = 0, seed = 1L
  )
  expect_snapshot_geometry(result)
})

test_that("all fill styles render via sketch_polygon_grob (T-LOOK-01)", {
  skip_if_not_installed("grid")
  styles <- c("hachure", "cross_hatch", "zigzag", "zigzag_line",
               "scribble", "dots", "dashed", "solid")
  for (style in styles) {
    g <- sketch_polygon_grob(
      x = c(0.1, 0.9, 0.9, 0.1),
      y = c(0.1, 0.1, 0.9, 0.9),
      fill_style = style, seed = 1L
    )
    tmp <- tempfile(fileext = ".png")
    png(tmp, width = 4, height = 4, units = "in", res = 72)
    grid::grid.draw(g)
    dev.off()
    expect_gt(file.size(tmp), 0, label = paste("fill_style:", style))
    unlink(tmp)
  }
})
