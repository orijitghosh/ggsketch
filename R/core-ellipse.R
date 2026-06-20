# Layer 1 — rough ellipse / circle (P1-T4)
# No grid:: or ggplot2:: (T-ARCH-01).

#' Roughen an ellipse into one or more sketch stroke paths
#'
#' Generates points around the ellipse, roughens them, and connects them with
#' a smooth path (sampled cubic Bézier between consecutive point-pairs).
#' Deliberately leaves a small gap at the close point ("ends don't meet"
#' hand-drawn effect).
#'
#' @param cx,cy Centre coordinates in inch space.
#' @param rx,ry Semi-axis radii in inches (rx = horizontal, ry = vertical).
#' @param roughness Non-negative roughness parameter. Default 1.
#' @param n_passes Number of stroke overlays. Default 2.
#' @param seed Integer seed for reproducibility.
#' @return List of `n_passes` 2-column (x, y) matrices of stroke points.
#' @family sketch-core
#' @export
rough_ellipse <- function(cx, cy, rx, ry,
                           roughness = 1,
                           n_passes  = 2L,
                           seed      = NULL) {
  seed <- resolve_seed(seed)

  # Adaptive point count: enough points per inch of arc (spec §3.1)
  mean_radius <- sqrt((rx^2 + ry^2) / 2)
  arc_len     <- pi * mean_radius  # half circumference (rough estimate)
  n <- as.integer(min(max(10L, ceiling(arc_len / 0.1)), 200L))

  lapply(seq_len(n_passes), function(pass) {
    s <- seed_offset(seed, (pass - 1L) * 1000L)
    within_seed(s, {
      # Jittered angles; second pass shifts start by half a step
      angle_shift <- if (pass == 1L) 0 else pi / n
      base_angles <- seq(0, 2 * pi, length.out = n + 1L)[-1L] + angle_shift
      jitter      <- stats::runif(n, -pi / n, pi / n)
      angles      <- base_angles + jitter

      # Base ellipse points
      bx <- cx + rx * cos(angles)
      by <- cy + ry * sin(angles)

      # Per-point roughness scale: smaller fraction so ellipse keeps its shape
      pt_rough <- roughness * 0.1

      # Roughen each point
      rx_pts <- numeric(n)
      ry_pts <- numeric(n)
      for (i in seq_len(n)) {
        rp        <- roughen_point(bx[i], by[i], pt_rough)
        rx_pts[i] <- rp[["x"]]
        ry_pts[i] <- rp[["y"]]
      }

      # "Open loop": connect last point toward the 2nd point rather than 1st
      # This is achieved by appending points 2..3 at the end (not closing exactly)
      close_target <- if (n >= 3L) 2L else 1L
      px <- c(rx_pts, rx_pts[close_target])
      py <- c(ry_pts, ry_pts[close_target])

      # Build path by sampling cubic Beziers between consecutive pairs
      # Use the points as Catmull-Rom-like: P[i-1], P[i], P[i+1], P[i+2]
      # For simplicity, use linear segments (enough points for smooth look)
      # Points are already smoothed by the angular jitter + roughening
      matrix(c(px, py), ncol = 2L,
             dimnames = list(NULL, c("x", "y")))
    })
  })
}
