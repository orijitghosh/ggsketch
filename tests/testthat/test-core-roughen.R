# T-CORE-01, T-CORE-10: point and polyline roughening

# ---- roughen_point ----------------------------------------------------------

test_that("roughen_point returns named c(x,y)", {
  within_seed(1L, {
    pt <- roughen_point(0, 0, 0.5)
    expect_length(pt, 2L)
    expect_named(pt, c("x", "y"))
  })
})

test_that("roughen_point(x, y, 0) == c(x, y) — identity law (T-CORE-10)", {
  pt <- roughen_point(3.14, -2.71, 0)
  expect_equal(pt[["x"]], 3.14)
  expect_equal(pt[["y"]], -2.71)
})

test_that("roughen_point displacement is within roughness radius", {
  within_seed(42L, {
    for (i in 1:50) {
      pt <- roughen_point(1, 1, 0.5)
      d  <- sqrt((pt[["x"]] - 1)^2 + (pt[["y"]] - 1)^2)
      expect_lte(d, 0.5 + 1e-9)
    }
  })
})

# ---- roughen_polyline -------------------------------------------------------

test_that("roughen_polyline returns list of n_passes matrices (T-CORE-01)", {
  result <- roughen_polyline(c(0, 1, 2), c(0, 0, 1),
                              roughness = 1, bowing = 1,
                              n_passes = 2L, seed = 42L)
  expect_type(result, "list")
  expect_length(result, 2L)
  expect_true(is.matrix(result[[1L]]))
  expect_equal(colnames(result[[1L]]), c("x", "y"))
})

test_that("roughness=0 returns original vertices (T-CORE-10)", {
  x <- c(0, 3); y <- c(0, 4)
  result <- roughen_polyline(x, y, roughness = 0, bowing = 1,
                              n_passes = 1L, seed = 1L)
  pts <- result[[1L]]
  # First and last point should be original (within numerical noise)
  expect_equal(unname(pts[1L, "x"]), 0, tolerance = 1e-9)
  expect_equal(unname(pts[1L, "y"]), 0, tolerance = 1e-9)
  expect_equal(unname(pts[nrow(pts), "x"]), 3, tolerance = 1e-9)
  expect_equal(unname(pts[nrow(pts), "y"]), 4, tolerance = 1e-9)
})

test_that("two passes produce different geometry", {
  result <- roughen_polyline(c(0, 5), c(0, 0),
                              roughness = 1, bowing = 1,
                              n_passes = 2L, seed = 42L)
  expect_false(identical(result[[1L]], result[[2L]]))
})

test_that("same seed produces identical geometry (T-CORE-07)", {
  r1 <- roughen_polyline(c(0, 1), c(0, 1), roughness = 0.5, seed = 99L)
  r2 <- roughen_polyline(c(0, 1), c(0, 1), roughness = 0.5, seed = 99L)
  expect_identical(r1, r2)
})

test_that("global .Random.seed unchanged after roughen_polyline (T-CORE-06)", {
  set.seed(7L)
  before <- .Random.seed
  roughen_polyline(c(0, 1, 2, 3), c(0, 1, 0, 1), roughness = 1, seed = 42L)
  expect_identical(.Random.seed, before)
})

test_that("endpoint displacement bounded by roughness (T-CORE-01 fixture 5)", {
  # First and last point of each pass should be within roughness*0.5+eps
  x <- c(0, 10); y <- c(0, 0)
  roughness <- 1
  result <- roughen_polyline(x, y, roughness = roughness, seed = 42L)
  for (pass in result) {
    d_start <- sqrt(unname(pass[1L, "x"])^2 + unname(pass[1L, "y"])^2)
    n <- nrow(pass)
    d_end   <- sqrt((unname(pass[n, "x"]) - 10)^2 + unname(pass[n, "y"])^2)
    max_off <- roughness * 0.5 + 1e-6
    expect_lte(d_start, max_off)
    expect_lte(d_end,   max_off)
  }
})

test_that("geometry snapshot — horizontal unit line (T-CORE-01)", {
  result <- roughen_polyline(c(0, 1), c(0, 0), roughness = 1, bowing = 1,
                              n_passes = 1L, seed = 42L)
  expect_snapshot_geometry(result)
})

test_that("geometry snapshot — diagonal 3-unit line (T-CORE-01)", {
  result <- roughen_polyline(c(0, 3), c(0, 3), roughness = 1, bowing = 1,
                              n_passes = 1L, seed = 42L)
  expect_snapshot_geometry(result)
})
