# T-CORE-02: rough_ellipse

test_that("rough_ellipse returns list of n_passes matrices", {
  result <- rough_ellipse(0, 0, 1, 1, roughness = 0.5, n_passes = 2L, seed = 1L)
  expect_type(result, "list")
  expect_length(result, 2L)
  expect_true(is.matrix(result[[1L]]))
  expect_equal(colnames(result[[1L]]), c("x", "y"))
})

test_that("point count n grows with ellipse size (scale-invariance, T-CORE-02)", {
  # We can't directly test n, but larger ellipses should produce more points
  small <- rough_ellipse(0, 0, 0.5, 0.5, roughness = 0.1, n_passes = 1L, seed = 1L)
  large <- rough_ellipse(0, 0, 5,   5,   roughness = 0.1, n_passes = 1L, seed = 1L)
  expect_gt(nrow(large[[1L]]), nrow(small[[1L]]))
})

test_that("roughness=0 ellipse points lie on the ellipse (T-CORE-10)", {
  cx <- 1; cy <- 2; rx <- 3; ry <- 2
  result <- rough_ellipse(cx, cy, rx, ry,
                           roughness = 0, n_passes = 1L, seed = 1L)
  pts <- result[[1L]]
  # Distance from centre should equal the parametric ellipse distance
  # For an ellipse (x-cx)²/rx² + (y-cy)²/ry² = 1
  # Allow small tolerance from angle jitter
  ellipse_dist <- (pts[, "x"] - cx)^2 / rx^2 + (pts[, "y"] - cy)^2 / ry^2
  # With roughness=0, roughen_point is identity, so points are on ellipse
  expect_true(all(abs(ellipse_dist - 1) < 1e-6),
              info = "All points should lie on the ellipse when roughness=0")
})

test_that("open-loop: first and last point differ (T-CORE-02)", {
  result <- rough_ellipse(0, 0, 2, 1, roughness = 0.5, n_passes = 1L, seed = 1L)
  pts <- result[[1L]]
  first <- pts[1L, ]
  last  <- pts[nrow(pts), ]
  d <- sqrt((first["x"] - last["x"])^2 + (first["y"] - last["y"])^2)
  expect_gt(d, 0, label = "open-loop gap between first and last point")
})

test_that("two passes differ (overlay effect)", {
  result <- rough_ellipse(0, 0, 1, 1, roughness = 0.5, n_passes = 2L, seed = 1L)
  expect_false(identical(result[[1L]], result[[2L]]))
})

test_that(".Random.seed unchanged after rough_ellipse (T-CORE-06)", {
  set.seed(5L)
  before <- .Random.seed
  rough_ellipse(0, 0, 1, 1, roughness = 0.5, n_passes = 2L, seed = 42L)
  expect_identical(.Random.seed, before)
})

test_that("geometry snapshot — unit circle (T-CORE-02)", {
  result <- rough_ellipse(0, 0, 1, 1, roughness = 0.5, n_passes = 1L, seed = 42L)
  expect_snapshot_geometry(result)
})
