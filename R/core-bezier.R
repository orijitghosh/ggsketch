# Layer 1 - cubic Bezier sampling, flatness test, RDP, rough_bezier (P1-T5)
# No grid:: or ggplot2:: (T-ARCH-01).

# ---- cubic Bezier sampling --------------------------------------------------

#' Sample points along a cubic Bezier curve
#'
#' @param x0,y0 P0 (start)
#' @param x1,y1 P1 (first control)
#' @param x2,y2 P2 (second control)
#' @param x3,y3 P3 (end)
#' @param n Number of sample points (including endpoints).
#' @return nx2 matrix with columns `x` and `y`.
#' @noRd
sample_cubic_bezier <- function(x0, y0, x1, y1, x2, y2, x3, y3, n = 10L) {
  t  <- seq(0, 1, length.out = n)
  u  <- 1 - t
  bx <- u^3 * x0 + 3 * u^2 * t * x1 + 3 * u * t^2 * x2 + t^3 * x3
  by <- u^3 * y0 + 3 * u^2 * t * y1 + 3 * u * t^2 * y2 + t^3 * y3
  matrix(c(bx, by), ncol = 2L, dimnames = list(NULL, c("x", "y")))
}

# ---- flatness test ----------------------------------------------------------

#' Is a cubic Bezier segment flat within tolerance?
#'
#' Flatness = max perpendicular distance from the interior control points (P1,
#' P2) to the chord P0 -> P3.
#'
#' @return Logical scalar.
#' @noRd
bezier_is_flat <- function(x0, y0, x1, y1, x2, y2, x3, y3, tol) {
  chord_len <- sqrt((x3 - x0)^2 + (y3 - y0)^2)
  if (chord_len < 1e-12) {
    d1 <- sqrt((x1 - x0)^2 + (y1 - y0)^2)
    d2 <- sqrt((x2 - x0)^2 + (y2 - y0)^2)
    return(max(d1, d2) < tol)
  }
  # Cross-product magnitude gives perpendicular distance
  d1 <- abs((x1 - x0) * (y3 - y0) - (y1 - y0) * (x3 - x0)) / chord_len
  d2 <- abs((x2 - x0) * (y3 - y0) - (y2 - y0) * (x3 - x0)) / chord_len
  max(d1, d2) < tol
}

# ---- adaptive subdivision (de Casteljau) ------------------------------------

#' Flatten a cubic Bezier to a polyline via adaptive subdivision
#'
#' Returns a 2-column matrix of points along the curve, guaranteed to
#' approximate the curve within `tol` inches.
#'
#' @param tol Flatness tolerance in inches.
#' @param depth Current recursion depth (internal).
#' @param max_depth Maximum recursion depth (prevents blowup).
#' @noRd
flatten_bezier <- function(x0, y0, x1, y1, x2, y2, x3, y3,
                            tol = 1e-3, depth = 0L, max_depth = 10L) {
  if (depth >= max_depth ||
      bezier_is_flat(x0, y0, x1, y1, x2, y2, x3, y3, tol)) {
    return(matrix(c(x0, x3, y0, y3), nrow = 2L, ncol = 2L,
                  dimnames = list(NULL, c("x", "y"))))
  }

  # de Casteljau split at t = 0.5
  mx01  <- (x0 + x1) / 2;  my01  <- (y0 + y1) / 2
  mx12  <- (x1 + x2) / 2;  my12  <- (y1 + y2) / 2
  mx23  <- (x2 + x3) / 2;  my23  <- (y2 + y3) / 2
  mx012 <- (mx01 + mx12) / 2; my012 <- (my01 + my12) / 2
  mx123 <- (mx12 + mx23) / 2; my123 <- (my12 + my23) / 2
  mxm   <- (mx012 + mx123) / 2; mym <- (my012 + my123) / 2

  left  <- flatten_bezier(x0, y0, mx01, my01, mx012, my012, mxm, mym,
                           tol, depth + 1L, max_depth)
  right <- flatten_bezier(mxm, mym, mx123, my123, mx23, my23, x3, y3,
                           tol, depth + 1L, max_depth)

  # Drop duplicated midpoint
  rbind(left, right[-1L, , drop = FALSE])
}

# ---- Ramer-Douglas-Peucker --------------------------------------------------

#' RDP polyline reduction
#'
#' @param pts 2-column matrix (x, y).
#' @param epsilon Perpendicular distance threshold (inches).
#' @return Reduced 2-column matrix.
#' @noRd
rdp_reduce <- function(pts, epsilon) {
  n <- nrow(pts)
  if (n <= 2L) return(pts)

  # Find point with max perpendicular distance to chord (first -> last)
  x0 <- pts[1L, "x"]; y0 <- pts[1L, "y"]
  x1 <- pts[n,  "x"]; y1 <- pts[n,  "y"]
  chord_len <- sqrt((x1 - x0)^2 + (y1 - y0)^2)

  if (chord_len < 1e-12) {
    dists <- sqrt((pts[, "x"] - x0)^2 + (pts[, "y"] - y0)^2)
  } else {
    dists <- abs((pts[, "x"] - x0) * (y1 - y0) -
                   (pts[, "y"] - y0) * (x1 - x0)) / chord_len
  }

  idx_max <- which.max(dists)
  max_d   <- dists[idx_max]

  if (max_d > epsilon) {
    left  <- rdp_reduce(pts[seq_len(idx_max), , drop = FALSE], epsilon)
    right <- rdp_reduce(pts[idx_max:n, , drop = FALSE], epsilon)
    rbind(left, right[-1L, , drop = FALSE])
  } else {
    pts[c(1L, n), , drop = FALSE]
  }
}

# ---- rough_bezier -----------------------------------------------------------

#' Roughen a cubic Bezier curve
#'
#' Applies roughness to all four control points, then flattens and reduces the
#' curve. Returns `n_passes` roughened polyline paths.
#'
#' @param P0,P1,P2,P3 Control points as length-2 numeric vectors c(x, y) in
#'   inch space.
#' @param roughness Non-negative roughness radius (inches). Default 1.
#' @param bowing Bowing multiplier (currently not applied to Bezier control
#'   points separately; roughness serves the role). Default 1.
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed for reproducibility.
#' @param tol Flatness tolerance. Default `max(roughness * 0.01, 1e-4)`.
#' @param rdp_eps RDP epsilon. Default `max(roughness * 0.005, 1e-5)`.
#' @return List of `n_passes` 2-column (x, y) matrices.
#' @family sketch-core
#' @export
rough_bezier <- function(P0, P1, P2, P3,
                          roughness = 1,
                          bowing    = 1,
                          n_passes  = 2L,
                          seed      = NULL,
                          tol       = NULL,
                          rdp_eps   = NULL) {
  seed    <- resolve_seed(seed)
  tol     <- tol     %||% max(roughness * 0.01, 1e-4)
  rdp_eps <- rdp_eps %||% max(roughness * 0.005, 1e-5)

  lapply(seq_len(n_passes), function(pass) {
    s <- seed_offset(seed, (pass - 1L) * 1000L)
    within_seed(s, {
      rp0 <- roughen_point(P0[1L], P0[2L], roughness)
      rp1 <- roughen_point(P1[1L], P1[2L], roughness)
      rp2 <- roughen_point(P2[1L], P2[2L], roughness)
      rp3 <- roughen_point(P3[1L], P3[2L], roughness)

      pts <- flatten_bezier(rp0[1L], rp0[2L],
                             rp1[1L], rp1[2L],
                             rp2[1L], rp2[2L],
                             rp3[1L], rp3[2L],
                             tol = tol)
      rdp_reduce(pts, rdp_eps)
    })
  })
}
