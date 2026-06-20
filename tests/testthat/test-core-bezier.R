# T-CORE-03: Bézier sampling, flatness, RDP, rough_bezier

# Helper to get a plain numeric from a matrix cell (strips name attribute)
mat_val <- function(m, r, c) unname(m[r, c])

test_that("sample_cubic_bezier returns n×2 matrix", {
  pts <- sample_cubic_bezier(0, 0, 1, 3, 2, 3, 3, 0, n = 10L)
  expect_true(is.matrix(pts))
  expect_equal(dim(pts), c(10L, 2L))
  expect_equal(colnames(pts), c("x", "y"))
})

test_that("Bézier endpoints match P0 and P3", {
  pts <- sample_cubic_bezier(1, 2, 3, 4, 5, 6, 7, 8, n = 5L)
  expect_equal(mat_val(pts, 1L, "x"), 1)
  expect_equal(mat_val(pts, 1L, "y"), 2)
  expect_equal(mat_val(pts, 5L, "x"), 7)
  expect_equal(mat_val(pts, 5L, "y"), 8)
})

test_that("Bézier of a straight line returns collinear points", {
  pts <- sample_cubic_bezier(0, 0, 1, 1, 2, 2, 3, 3, n = 7L)
  expect_true(all(abs(pts[, "y"] - pts[, "x"]) < 1e-10))
})

test_that("bezier_is_flat detects straight Bézier", {
  flat <- bezier_is_flat(0, 0, 1, 0, 2, 0, 3, 0, tol = 1e-3)
  expect_true(flat)
})

test_that("bezier_is_flat detects curved Bézier", {
  curved <- bezier_is_flat(0, 0, 0, 2, 3, 2, 3, 0, tol = 1e-3)
  expect_false(curved)
})

test_that("flatten_bezier straight line returns 2 points", {
  pts <- flatten_bezier(0, 0, 1, 0, 2, 0, 3, 0, tol = 1e-3)
  expect_equal(nrow(pts), 2L)
  expect_equal(mat_val(pts, 1L, "x"), 0)
  expect_equal(mat_val(pts, 2L, "x"), 3)
})

test_that("flatten_bezier curved has more points than straight", {
  flat   <- flatten_bezier(0, 0, 1, 0, 2, 0, 3, 0, tol = 1e-3)
  curved <- flatten_bezier(0, 0, 0, 2, 3, 2, 3, 0, tol = 1e-3)
  expect_gt(nrow(curved), nrow(flat))
})

test_that("flatten_bezier endpoints match P0 and P3", {
  pts <- flatten_bezier(1, 2, 3, 5, 7, 2, 9, 3, tol = 1e-3)
  expect_equal(mat_val(pts, 1L, "x"), 1, tolerance = 1e-9)
  expect_equal(mat_val(pts, 1L, "y"), 2, tolerance = 1e-9)
  expect_equal(mat_val(pts, nrow(pts), "x"), 9, tolerance = 1e-9)
  expect_equal(mat_val(pts, nrow(pts), "y"), 3, tolerance = 1e-9)
})

test_that("rdp_reduce collinear points returns just endpoints", {
  pts <- matrix(c(0, 1, 2, 3, 4,
                  0, 0.0, 0, 0.0, 0), ncol = 2,
                dimnames = list(NULL, c("x", "y")))
  reduced <- rdp_reduce(pts, epsilon = 1e-6)
  expect_equal(nrow(reduced), 2L)
})

test_that("rdp_reduce keeps significant inflection point", {
  # V-shape: (0,0), (2,4), (4,0) — midpoint far from chord
  pts <- matrix(c(0, 2, 4, 0, 4, 0), ncol = 2,
                dimnames = list(NULL, c("x", "y")))
  reduced <- rdp_reduce(pts, epsilon = 0.1)
  expect_equal(nrow(reduced), 3L)
})

test_that("rough_bezier returns list of n_passes matrices", {
  P0 <- c(0, 0); P1 <- c(1, 2); P2 <- c(2, 2); P3 <- c(3, 0)
  result <- rough_bezier(P0, P1, P2, P3, roughness = 0.5, n_passes = 2L,
                          seed = 42L)
  expect_type(result, "list")
  expect_length(result, 2L)
  expect_true(is.matrix(result[[1L]]))
})

test_that("rough_bezier roughness=0 endpoints near P0/P3 (T-CORE-10)", {
  P0 <- c(0, 0); P3 <- c(3, 0)
  result <- rough_bezier(P0, c(1, 1), c(2, 1), P3,
                          roughness = 0, n_passes = 1L, seed = 1L)
  pts <- result[[1L]]
  expect_equal(mat_val(pts, 1L, "x"), 0, tolerance = 1e-9)
  expect_equal(mat_val(pts, nrow(pts), "x"), 3, tolerance = 1e-9)
})

test_that(".Random.seed unchanged after rough_bezier (T-CORE-06)", {
  set.seed(3L)
  before <- .Random.seed
  rough_bezier(c(0, 0), c(1, 1), c(2, 1), c(3, 0), roughness = 0.5, seed = 7L)
  expect_identical(.Random.seed, before)
})

test_that("output point count responds to tolerance (T-CORE-03 monotonic)", {
  P0 <- c(0, 0); P1 <- c(0, 3); P2 <- c(3, 3); P3 <- c(3, 0)
  fine   <- rough_bezier(P0, P1, P2, P3, roughness = 0,
                          n_passes = 1L, seed = 1L, tol = 1e-5, rdp_eps = 1e-6)
  coarse <- rough_bezier(P0, P1, P2, P3, roughness = 0,
                          n_passes = 1L, seed = 1L, tol = 1e-1, rdp_eps = 1e-1)
  expect_gte(nrow(fine[[1L]]), nrow(coarse[[1L]]))
})
