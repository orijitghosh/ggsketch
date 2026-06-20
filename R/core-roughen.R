# Layer 1 — point and polyline roughening (P1-T3)
# No grid:: or ggplot2:: symbols (T-ARCH-01, R3).

# ---- helpers ----------------------------------------------------------------

#' Maximum offset for a segment of length L (inches)
#' @noRd
line_offset <- function(len, roughness) {
  min(roughness * 0.05 * sqrt(len), roughness * 0.5)
}

# ---- roughen_point ----------------------------------------------------------

#' Roughen a single point by displacing it randomly within a circle
#'
#' @param x,y Coordinates in inch space.
#' @param roughness Maximum displacement radius (inches).
#' @return Length-2 numeric vector c(x', y').
#' @family sketch-core
#' @noRd
roughen_point <- function(x, y, roughness) {
  x <- as.double(x); y <- as.double(y)  # strip names from matrix subsetting
  if (roughness <= 0) return(c(x = x, y = y))
  angle <- stats::runif(1L, 0, 2 * pi)
  r     <- stats::runif(1L, 0, roughness)
  c(x = x + r * cos(angle), y = y + r * sin(angle))
}

# ---- roughen_segment --------------------------------------------------------

#' Roughen a single line segment into a sampled cubic Bézier path
#'
#' Internal; called within a `within_seed()` context.
#'
#' @param x0,y0 Start point (inches).
#' @param x1,y1 End point (inches).
#' @param roughness,bowing Sketch parameters.
#' @return A 2-column (x, y) matrix of sampled path points.
#' @noRd
roughen_segment <- function(x0, y0, x1, y1, roughness, bowing) {
  dx  <- x1 - x0
  dy  <- y1 - y0
  len <- sqrt(dx^2 + dy^2)

  if (len < 1e-9) {
    return(matrix(c(x0, y0), nrow = 1L, ncol = 2L,
                  dimnames = list(NULL, c("x", "y"))))
  }

  off <- line_offset(len, roughness)

  # Roughen endpoints
  p0 <- roughen_point(x0, y0, off)
  p3 <- roughen_point(x1, y1, off)

  # Unit normal (leftward)
  nx <- -dy / len
  ny <-  dx / len

  # Bowing: shared perpendicular displacement for both control points
  bow <- bowing * off * stats::runif(1L, -1, 1)

  # t-values for intermediate control points (near 50% and 75%)
  t1 <- 0.5  + stats::runif(1L, -0.05, 0.05)
  t2 <- 0.75 + stats::runif(1L, -0.05, 0.05)

  p1x <- x0 + t1 * dx + off * stats::runif(1L, -1, 1) + bow * nx
  p1y <- y0 + t1 * dy + off * stats::runif(1L, -1, 1) + bow * ny
  p2x <- x0 + t2 * dx + off * stats::runif(1L, -1, 1) + bow * nx
  p2y <- y0 + t2 * dy + off * stats::runif(1L, -1, 1) + bow * ny

  # Sample cubic Bézier at N_SEG points
  N_SEG <- max(3L, ceiling(len * 10))
  sample_cubic_bezier(p0[["x"]], p0[["y"]],
                      p1x, p1y,
                      p2x, p2y,
                      p3[["x"]], p3[["y"]],
                      n = N_SEG)
}

# ---- roughen_polyline -------------------------------------------------------

#' Roughen a polyline (multiple connected segments)
#'
#' Converts a multi-vertex polyline into `n_passes` roughened stroke paths.
#' Each path is a matrix with columns `x` and `y` (inch coordinates).
#' Uses a seeded local RNG so the user's `.Random.seed` is never mutated
#' (T-CORE-06).
#'
#' @param x,y Numeric vectors of polyline vertices in inch space. Must have
#'   the same length ≥ 2.
#' @param roughness Non-negative roughness radius (inches at scale). Default 1.
#' @param bowing Non-negative bowing multiplier. Default 1.
#' @param n_passes Positive integer number of stroke passes (default 2).
#' @param seed Integer seed for reproducibility (ADR-0004).
#' @return A list of `n_passes` matrices (columns `x`, `y`), one per pass.
#' @family sketch-core
#' @export
roughen_polyline <- function(x, y,
                              roughness = 1,
                              bowing    = 1,
                              n_passes  = 2L,
                              seed      = NULL) {
  stopifnot(is.numeric(x), is.numeric(y), length(x) == length(y),
            length(x) >= 2L)
  seed <- resolve_seed(seed)

  lapply(seq_len(n_passes), function(pass) {
    s <- seed_offset(seed, (pass - 1L) * 1000L)
    within_seed(s, {
      segs <- vector("list", length(x) - 1L)
      for (i in seq_len(length(x) - 1L)) {
        segs[[i]] <- roughen_segment(x[i], y[i], x[i + 1L], y[i + 1L],
                                     roughness, bowing)
      }
      # Concatenate, dropping duplicate junction points
      do.call(rbind, lapply(seq_along(segs), function(k) {
        seg <- segs[[k]]
        if (k > 1L) seg[-1L, , drop = FALSE] else seg
      }))
    })
  })
}
