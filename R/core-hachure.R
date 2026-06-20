# Layer 1 — hachure scan-line fill via Active Edge Table (P1-T7)
# Handles convex AND concave polygons (AC-5, T-FILL-01).
# No grid:: or ggplot2:: (T-ARCH-01).

# ---- rotation helpers -------------------------------------------------------

#' Rotate 2-D points by angle (radians) around the origin
#' @noRd
rotate_pts <- function(x, y, angle) {
  ca <- cos(angle); sa <- sin(angle)
  list(x = ca * x - sa * y,
       y = sa * x + ca * y)
}

# ---- edge-table construction ------------------------------------------------

#' Build the Global Edge Table from a polygon
#'
#' @param px,py Polygon vertex coordinates (vectors, closed or open).
#' @return Data frame with columns: y_min, y_max, x_at_ymin, inv_slope.
#'   Horizontal edges are excluded.
#' @noRd
build_edge_table <- function(px, py) {
  n <- length(px)
  # Ensure open polygon (last point != first point for edge construction)
  if (px[n] == px[1L] && py[n] == py[1L]) n <- n - 1L

  rows <- vector("list", n)
  kept <- 0L
  for (i in seq_len(n)) {
    j  <- if (i == n) 1L else i + 1L
    x0 <- px[i]; y0 <- py[i]
    x1 <- px[j]; y1 <- py[j]

    dy <- y1 - y0
    if (abs(dy) < 1e-12) next  # skip horizontal edges

    kept <- kept + 1L
    if (y0 < y1) {
      rows[[kept]] <- list(y_min = y0, y_max = y1, x_at_ymin = x0,
                           inv_slope = (x1 - x0) / dy)
    } else {
      rows[[kept]] <- list(y_min = y1, y_max = y0, x_at_ymin = x1,
                           inv_slope = (x0 - x1) / (-dy))
    }
  }

  if (kept == 0L) return(NULL)
  rows <- rows[seq_len(kept)]

  # Sort by y_min then x_at_ymin
  get <- do.call(rbind.data.frame, rows)
  ord <- order(get$y_min, get$x_at_ymin)
  get[ord, , drop = FALSE]
}

# ---- scan-line fill ---------------------------------------------------------

#' Fill a polygon with hachure lines using the AET scan-line algorithm
#'
#' @param px,py Polygon vertex coordinates in inch space. May be open or closed.
#' @param hachure_gap Spacing between fill lines (inches). Default 0.1.
#' @param hachure_angle Fill angle (degrees). Default 45.
#' @param roughness Roughness applied to each fill line. Default 0 (straight).
#' @param bowing Bowing applied to each fill line. Default 0.
#' @param seed Integer seed.
#' @return A list of 2-column (x, y) matrices, one per fill line (roughened
#'   if roughness > 0, otherwise two-point straight segments).
#' @family sketch-core
#' @export
hachure_fill <- function(px, py,
                          hachure_gap   = 0.1,
                          hachure_angle = 45,
                          roughness     = 0,
                          bowing        = 0,
                          seed          = NULL) {
  seed <- resolve_seed(seed)
  th   <- hachure_angle * pi / 180

  # Rotate polygon to make hachure horizontal
  rot <- rotate_pts(px, py, -th)
  rpx <- rot$x; rpy <- rot$y

  # Build edge table
  et <- build_edge_table(rpx, rpy)
  if (is.null(et)) return(list())

  y_global_min <- min(et$y_min)
  y_global_max <- max(et$y_max)
  if (y_global_max - y_global_min < 1e-12) return(list())

  # Snap starting y to a multiple of hachure_gap for cleaner spacing
  y_start <- ceiling(y_global_min / hachure_gap) * hachure_gap

  # Active edge table state: use mutable vectors for speed
  aet_ymax      <- numeric(0)
  aet_x         <- numeric(0)
  aet_inv_slope <- numeric(0)

  get_ptr <- 1L  # next unprocessed row in edge table
  n_get   <- nrow(et)

  segments <- list()
  seg_i    <- 0L

  y <- y_start
  while (y <= y_global_max + hachure_gap * 0.5) {
    # Move GET edges starting at or before y into AET
    while (get_ptr <= n_get && et$y_min[get_ptr] <= y + 1e-9) {
      aet_ymax      <- c(aet_ymax,      et$y_max[get_ptr])
      aet_x         <- c(aet_x,         et$x_at_ymin[get_ptr])
      aet_inv_slope <- c(aet_inv_slope, et$inv_slope[get_ptr])
      get_ptr       <- get_ptr + 1L
    }

    # Remove expired edges
    keep <- aet_ymax > y + 1e-9
    aet_ymax      <- aet_ymax[keep]
    aet_x         <- aet_x[keep]
    aet_inv_slope <- aet_inv_slope[keep]

    if (length(aet_x) >= 2L) {
      # Sort by current x
      ord      <- order(aet_x)
      aet_x    <- aet_x[ord]
      aet_ymax <- aet_ymax[ord]
      aet_inv_slope <- aet_inv_slope[ord]

      # Fill between consecutive x-pairs
      j <- 1L
      while (j + 1L <= length(aet_x)) {
        xl <- aet_x[j]
        xr <- aet_x[j + 1L]
        if (xr > xl + 1e-9) {
          # Rotate fill-line endpoints back by +th
          rback_l <- rotate_pts(xl, y, th)
          rback_r <- rotate_pts(xr, y, th)

          if (roughness > 0) {
            seg_i <- seg_i + 1L
            s     <- seed_offset(seed, seg_i * 7L)
            segments[[seg_i]] <- within_seed(s, {
              roughen_segment(rback_l$x, rback_l$y,
                              rback_r$x, rback_r$y,
                              roughness, bowing)
            })
          } else {
            seg_i <- seg_i + 1L
            segments[[seg_i]] <- matrix(
              c(rback_l$x, rback_r$x, rback_l$y, rback_r$y),
              nrow = 2L, ncol = 2L,
              dimnames = list(NULL, c("x", "y"))
            )
          }
        }
        j <- j + 2L
      }
    }

    # Advance AET x values by inv_slope * hachure_gap
    aet_x <- aet_x + aet_inv_slope * hachure_gap
    y     <- y + hachure_gap
  }

  segments
}

# ---- point-in-polygon (for test containment assertions) ---------------------

#' Test if points lie inside a polygon (ray-casting, for tests)
#' @noRd
point_in_polygon <- function(px_test, py_test, poly_x, poly_y) {
  n <- length(poly_x)
  inside <- logical(length(px_test))
  for (k in seq_along(px_test)) {
    x_t <- px_test[k]; y_t <- py_test[k]
    cnt <- 0L
    for (i in seq_len(n)) {
      j <- if (i == n) 1L else i + 1L
      xi <- poly_x[i]; yi <- poly_y[i]
      xj <- poly_x[j]; yj <- poly_y[j]
      if (((yi > y_t) != (yj > y_t)) &&
          (x_t < (xj - xi) * (y_t - yi) / (yj - yi) + xi)) {
        cnt <- cnt + 1L
      }
    }
    inside[k] <- (cnt %% 2L) == 1L
  }
  inside
}
