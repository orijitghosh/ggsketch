# Layer 1 - arc / wedge / rounded-rect geometry (v1.7 parity knobs)
# Pure geometry: samples elliptical arcs and assembles the clean boundary
# polygons for pie/donut wedges and rounded rectangles. Roughening is done
# downstream by roughen_polyline()/rough_arc(). No grid:: or ggplot2:: (T-ARCH-01).

# ---- arc point sampling -----------------------------------------------------

#' Sample points along an elliptical arc
#'
#' @param cx,cy Centre (any consistent coordinate space).
#' @param rx,ry Semi-axis radii.
#' @param start,end Start/end angle in radians (standard math convention:
#'   counter-clockwise from the positive x-axis). `end` may be less than `start`
#'   to trace clockwise.
#' @param n Number of sample points. `NULL` picks ~3 degrees per step.
#' @return A 2-column (x, y) matrix.
#' @noRd
arc_xy <- function(cx, cy, rx, ry, start, end, n = NULL) {
  if (is.null(n)) n <- max(2L, ceiling(abs(end - start) / (pi / 60)))
  th <- seq(start, end, length.out = n)
  matrix(c(cx + rx * cos(th), cy + ry * sin(th)), ncol = 2L,
         dimnames = list(NULL, c("x", "y")))
}

# ---- annular sector / wedge boundary ----------------------------------------

#' Clean boundary of an annular sector (pie/donut slice) centred at the origin
#'
#' Traces the outer arc `start -> end`, then either the inner arc back
#' (`r0 > 0`, a donut slice) or the apex point (`r0 == 0`, a pie wedge). The
#' result is a closed-able ring suitable for roughening + filling.
#'
#' @param r0,r Inner and outer radius (`r0 = 0` for a solid wedge).
#' @param start,end Angles in radians.
#' @param n Points per arc. `NULL` picks ~3 degrees per step.
#' @return `list(x, y)` of boundary vertices (not explicitly closed).
#' @noRd
arc_sector <- function(r0, r, start, end, n = NULL) {
  if (is.null(n)) n <- max(2L, ceiling(abs(end - start) / (pi / 60)))
  tho <- seq(start, end, length.out = n)
  xo  <- r * cos(tho)
  yo  <- r * sin(tho)
  if (r0 > 0) {
    thi <- seq(end, start, length.out = n)
    list(x = c(xo, r0 * cos(thi)), y = c(yo, r0 * sin(thi)))
  } else {
    list(x = c(xo, 0), y = c(yo, 0))
  }
}

# ---- rounded-rectangle boundary ---------------------------------------------

#' Clean boundary of a rounded rectangle
#'
#' Quarter-arc corners of radius `rx` (horizontal) and `ry` (vertical), traced
#' counter-clockwise from the bottom edge. Radii are clamped to half the
#' respective side so they never cross over.
#'
#' @param xmin,xmax,ymin,ymax Rectangle extent.
#' @param rx,ry Corner radii in the same units as the extent.
#' @param n Points per corner arc. Default 6.
#' @return `list(x, y)` of boundary vertices (not explicitly closed).
#' @noRd
rounded_rect_xy <- function(xmin, xmax, ymin, ymax, rx, ry, n = 6L) {
  rx <- min(rx, (xmax - xmin) / 2)
  ry <- min(ry, (ymax - ymin) / 2)
  if (rx <= 0 || ry <= 0) {
    return(list(x = c(xmin, xmax, xmax, xmin),
                y = c(ymin, ymin, ymax, ymax)))
  }
  corner <- function(ccx, ccy, a0, a1) {
    th <- seq(a0, a1, length.out = n)
    list(x = ccx + rx * cos(th), y = ccy + ry * sin(th))
  }
  br <- corner(xmax - rx, ymin + ry, -pi / 2, 0)        # bottom-right
  tr <- corner(xmax - rx, ymax - ry, 0,       pi / 2)   # top-right
  tl <- corner(xmin + rx, ymax - ry, pi / 2,  pi)       # top-left
  bl <- corner(xmin + rx, ymin + ry, pi,      3 * pi / 2) # bottom-left
  list(x = c(br$x, tr$x, tl$x, bl$x),
       y = c(br$y, tr$y, tl$y, bl$y))
}

#' Boundary vertices for a rectangle, optionally rounded
#'
#' Shared by `geom_sketch_rect()` / `geom_sketch_tile()` / `geom_sketch_col()`.
#' `corner_radius` is a fraction \[0, 1\] of each half-side, so it scales with
#' the rectangle and clamps naturally (1 = fully rounded ends).
#'
#' @return `list(x, y)` of (clean) boundary vertices.
#' @noRd
rect_boundary <- function(xmin, xmax, ymin, ymax, corner_radius = 0) {
  if (is.null(corner_radius) || corner_radius <= 0) {
    return(list(x = c(xmin, xmax, xmax, xmin),
                y = c(ymin, ymin, ymax, ymax)))
  }
  w <- abs(xmax - xmin)
  h <- abs(ymax - ymin)
  rounded_rect_xy(
    min(xmin, xmax), max(xmin, xmax),
    min(ymin, ymax), max(ymin, ymax),
    rx = corner_radius * w / 2, ry = corner_radius * h / 2
  )
}

#' Densify a closed polygon boundary
#'
#' Inserts `n` evenly spaced points along every edge (including the closing
#' edge) so a straight-sided boundary survives a nonlinear coordinate
#' transform: under `coord_polar()` a rectangle's edges must bend into arcs,
#' which only works if there are intermediate vertices to bend.
#'
#' @return `list(x, y)` of the densified boundary vertices.
#' @noRd
densify_closed <- function(x, y, n = 16L) {
  m <- length(x)
  if (m < 2L || n <= 1L) return(list(x = x, y = y))
  xs <- vector("list", m)
  ys <- vector("list", m)
  t  <- seq(0, 1, length.out = n + 1L)[-(n + 1L)]
  for (i in seq_len(m)) {
    j <- if (i == m) 1L else i + 1L
    xs[[i]] <- x[i] + t * (x[j] - x[i])
    ys[[i]] <- y[i] + t * (y[j] - y[i])
  }
  list(x = unlist(xs, use.names = FALSE), y = unlist(ys, use.names = FALSE))
}

# ---- rough_arc --------------------------------------------------------------

#' Roughen an elliptical arc into one or more sketch stroke paths
#'
#' The open-arc sibling of [rough_ellipse()]. Samples the arc by arc length,
#' displaces each point slightly, and returns `n_passes` overlaid strokes for
#' the double-stroke hand-drawn look. Unlike a full ellipse the path is left
#' open (the ends are not joined).
#'
#' @param cx,cy Centre coordinates in inch space.
#' @param rx,ry Semi-axis radii in inches.
#' @param start,end Start/end angle in radians (counter-clockwise from the
#'   positive x-axis; `end` may be less than `start`).
#' @param roughness Non-negative roughness parameter. Default 1.
#' @param n_passes Number of stroke overlays. Default 2.
#' @param seed Integer seed for reproducibility.
#' @return List of `n_passes` 2-column (x, y) matrices of stroke points.
#' @family sketch-core
#' @export
rough_arc <- function(cx, cy, rx, ry, start, end,
                      roughness = 1,
                      n_passes  = 2L,
                      seed      = NULL) {
  seed <- resolve_seed(seed)

  span        <- abs(end - start)
  mean_radius <- sqrt((rx^2 + ry^2) / 2)
  arc_len     <- span * mean_radius
  n <- as.integer(min(max(6L, ceiling(arc_len / 0.1)), 300L))

  lapply(seq_len(n_passes), function(pass) {
    s <- seed_offset(seed, (pass - 1L) * 1000L)
    within_seed(s, {
      # Second pass nudges the sample positions by half a step so the two
      # strokes do not sit exactly on top of each other.
      shift  <- if (pass == 1L) 0 else span / (2 * n)
      angles <- seq(start, end, length.out = n) + shift

      bx <- cx + rx * cos(angles)
      by <- cy + ry * sin(angles)

      pt_rough <- roughness * 0.1
      px <- numeric(n)
      py <- numeric(n)
      for (i in seq_len(n)) {
        rp    <- roughen_point(bx[i], by[i], pt_rough)
        px[i] <- rp[["x"]]
        py[i] <- rp[["y"]]
      }
      matrix(c(px, py), ncol = 2L, dimnames = list(NULL, c("x", "y")))
    })
  })
}
