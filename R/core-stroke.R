# Layer 1 - variable-width strokes (v2 keystone)
# grid `lwd` is constant per polyline, so variable-width / tapered / pressure /
# calligraphic strokes cannot be a polyline. They are rendered as a FILLED
# POLYGON RIBBON: offset an (already-roughened) centreline left and right by a
# per-vertex half-width and close the loop, with round or butt caps. This single
# primitive unlocks the ink / brush / pencil / calligraphy media of v2.
# No grid:: or ggplot2:: (T-ARCH-01). Deterministic except for `jitter_w`, which
# draws from a seeded local RNG stream (T-CORE-06).

# ---- profiles ---------------------------------------------------------------

#' Width-profile presets for [stroke_ribbon()]
#'
#' Returns a vectorised pressure function `f(t)` over the normalised arc-length
#' `t` in `[0, 1]`, giving a width multiplier (>= 0) along the stroke. Pass the
#' result as `pressure` to [stroke_ribbon()].
#'
#' @param kind One of `"flat"` (constant), `"taper_in"` (thin start, thick end),
#'   `"taper_out"` (thick start, thin end), or `"belly"` (a spindle that swells
#'   in the middle and thins at both ends).
#' @return A function of `t` returning a numeric multiplier of the same length.
#' @family sketch-core
#' @export
stroke_profile <- function(kind = c("flat", "taper_in", "taper_out", "belly")) {
  kind <- match.arg(kind)
  switch(kind,
    flat      = function(t) rep(1, length(t)),
    taper_in  = function(t) t,
    taper_out = function(t) 1 - t,
    belly     = function(t) sin(pi * t)
  )
}

# Smoothstep ramp 0 -> 1 (Hermite), used for taper envelopes.
#' @noRd
smoothstep <- function(t) {
  t <- pmin(1, pmax(0, t))
  t * t * (3 - 2 * t)
}

# Taper envelope along normalised arc-length `t`. `frac` is the tip width as a
# fraction of full width (0 = sharp point, 1 = no taper).
#' @noRd
taper_envelope <- function(t, taper, frac) {
  frac <- min(1, max(0, frac))
  e <- switch(taper,
    none  = rep(1, length(t)),
    start = smoothstep(t),
    end   = smoothstep(1 - t),
    both  = smoothstep(pmin(t, 1 - t) * 2)
  )
  frac + (1 - frac) * e
}

# ---- round-cap arc ----------------------------------------------------------

# Semicircle (radius r about (cx, cy)) from p_from to p_to, choosing the sweep
# whose midpoint bulges toward `bulge`. p_from/p_to are diametrically opposite.
#' @noRd
cap_arc <- function(cx, cy, r, p_from, p_to, bulge, n = 8L) {
  if (r < 1e-9) {
    return(matrix(c(p_from[1L], p_to[1L], p_from[2L], p_to[2L]),
                  nrow = 2L, ncol = 2L, dimnames = list(NULL, c("x", "y"))))
  }
  a0 <- atan2(p_from[2L] - cy, p_from[1L] - cx)
  # Two candidate semicircle sweeps: +pi and -pi. Pick the one whose midpoint
  # direction aligns with `bulge` (the direction of travel at the cap).
  mid_pos <- c(cos(a0 + pi / 2), sin(a0 + pi / 2))
  sgn <- if (sum(mid_pos * bulge) >= 0) 1 else -1
  k  <- max(3L, as.integer(n))
  a  <- seq(a0, a0 + sgn * pi, length.out = k)
  matrix(c(cx + r * cos(a), cy + r * sin(a)), ncol = 2L,
         dimnames = list(NULL, c("x", "y")))
}

# ---- stroke_ribbon ----------------------------------------------------------

#' Build a variable-width stroke as a closed polygon ribbon
#'
#' Offsets a centreline left and right by a per-vertex half-width and closes the
#' loop into a single polygon, so a hand-drawn stroke can taper, swell with
#' pressure, or vary like a broad calligraphic nib -- effects `grid` cannot do
#' with a constant-`lwd` polyline. The centreline is used as supplied (roughen it
#' first with [roughen_polyline()] for a sketchy edge); this routine only offsets,
#' so it is deterministic apart from `jitter_w`.
#'
#' @param x,y Numeric vectors of centreline vertices in inch space (same length).
#' @param width Full stroke width in inches: a scalar, or a per-vertex vector.
#' @param taper Where the stroke narrows to a tip: `"none"` (default), `"both"`,
#'   `"start"`, or `"end"`.
#' @param taper_frac Tip width as a fraction of `width` (`0` = sharp point,
#'   `1` = no narrowing). Default `0`.
#' @param pressure Optional vectorised function `f(t)` over normalised
#'   arc-length `t` in `[0, 1]` returning a width multiplier (see
#'   [stroke_profile()]). `NULL` (default) is constant pressure.
#' @param nib_angle Optional broad-nib angle in degrees for a calligraphic
#'   stroke: the half-width is scaled by `|sin(segment_dir - nib_angle)|` (with a
#'   small floor), so the line is thick across the nib and thin along it. `NULL`
#'   (default) disables it.
#' @param nib_floor Minimum nib multiplier in `[0, 1]`, so a calligraphic stroke
#'   never fully vanishes. Default `0.15`.
#' @param jitter_w Width roughening in `[0, 1]`: random per-vertex modulation of
#'   the half-width, for a dry / inky edge. Default `0`.
#' @param cap End-cap style: `"round"` (default) or `"butt"`.
#' @param miter_limit Clamp on the joint miter factor, capping how far an outside
#'   corner extends at a sharp turn. Default `3`.
#' @param seed Integer seed for `jitter_w` (ADR-0004).
#' @return A 2-column `(x, y)` matrix giving the closed ribbon polygon (right side
#'   forward, end cap, left side back, start cap). Fill it with the stroke colour
#'   and no border for a solid variable-width stroke.
#' @family sketch-core
#' @export
stroke_ribbon <- function(x, y,
                          width,
                          taper       = c("none", "both", "start", "end"),
                          taper_frac  = 0,
                          pressure    = NULL,
                          nib_angle   = NULL,
                          nib_floor   = 0.15,
                          jitter_w    = 0,
                          cap         = c("round", "butt"),
                          miter_limit = 3,
                          seed        = NULL) {
  taper <- match.arg(taper)
  cap   <- match.arg(cap)
  x <- as.double(x); y <- as.double(y)
  stopifnot(length(x) == length(y))

  # Drop consecutive duplicate vertices (zero-length segments break normals).
  if (length(x) >= 2L) {
    keep <- c(TRUE, (diff(x)^2 + diff(y)^2) > 1e-18)
    x <- x[keep]; y <- y[keep]
  }
  n <- length(x)

  empty <- matrix(numeric(0), ncol = 2L, dimnames = list(NULL, c("x", "y")))
  if (n == 0L) return(empty)

  hw_full <- as.double(width) / 2
  if (length(hw_full) == 1L) hw_full <- rep(hw_full, n)
  else if (length(hw_full) != n) hw_full <- rep_len(hw_full, n)

  # A lone vertex is a dot (round cap = circle; butt = nothing meaningful).
  if (n == 1L) {
    r <- hw_full[1L]
    if (cap == "butt" || r < 1e-9) return(empty)
    a <- seq(0, 2 * pi, length.out = 17L)
    return(matrix(c(x + r * cos(a), y + r * sin(a)), ncol = 2L,
                  dimnames = list(NULL, c("x", "y"))))
  }

  # Normalised arc-length parameter at each vertex.
  seglen <- sqrt(diff(x)^2 + diff(y)^2)
  s <- c(0, cumsum(seglen))
  total <- s[n]
  t <- if (total > 0) s / total else seq(0, 1, length.out = n)

  # Per-vertex half-width: width profile x taper x pressure x jitter.
  hw <- hw_full * taper_envelope(t, taper, taper_frac)
  if (!is.null(pressure)) hw <- hw * pmax(0, pressure(t))
  if (jitter_w > 0) {
    seed <- resolve_seed(seed)
    jw <- within_seed(seed_offset(seed, 5L),
                      stats::runif(n, 1 - jitter_w, 1 + jitter_w))
    hw <- hw * pmax(0, jw)
  }

  # Leftward unit normals per segment: (-dy, dx) / len.
  nx <- -diff(y) / seglen
  ny <-  diff(x) / seglen

  # Optional calligraphic nib: thin when the stroke runs along the nib angle,
  # thick across it. Applied per segment, averaged onto vertices below.
  seg_scale <- rep(1, n - 1L)
  if (!is.null(nib_angle)) {
    nib <- nib_angle * pi / 180
    seg_dir <- atan2(diff(y), diff(x))
    seg_scale <- pmax(nib_floor, abs(sin(seg_dir - nib)))
  }

  # Bisector normal + clamped miter at each vertex.
  mx <- numeric(n); my <- numeric(n); miter <- rep(1, n); vscale <- rep(1, n)
  mx[1L] <- nx[1L]; my[1L] <- ny[1L]; vscale[1L] <- seg_scale[1L]
  mx[n]  <- nx[n - 1L]; my[n] <- ny[n - 1L]; vscale[n] <- seg_scale[n - 1L]
  if (n > 2L) {
    for (i in 2L:(n - 1L)) {
      ax <- nx[i - 1L]; ay <- ny[i - 1L]
      bx <- nx[i];      by <- ny[i]
      sx <- ax + bx;    sy <- ay + by
      slen <- sqrt(sx^2 + sy^2)
      if (slen < 1e-9) {            # ~180 deg reversal: use incoming normal
        mx[i] <- bx; my[i] <- by; miter[i] <- 1
      } else {
        mxi <- sx / slen; myi <- sy / slen
        cosq <- mxi * bx + myi * by          # = cos(half turn angle)
        miter[i] <- if (cosq > 1e-3) min(miter_limit, 1 / cosq) else miter_limit
        mx[i] <- mxi; my[i] <- myi
      }
      vscale[i] <- (seg_scale[i - 1L] + seg_scale[i]) / 2
    }
  }

  off <- hw * miter * vscale
  Lx <- x + mx * off; Ly <- y + my * off    # left side
  Rx <- x - mx * off; Ry <- y - my * off    # right side

  # Assemble: right side forward, end cap, left side back, start cap.
  right <- cbind(x = Rx, y = Ry)
  left  <- cbind(x = Lx[n:1L], y = Ly[n:1L])

  parts <- list(right)
  if (cap == "round") {
    u_end <- c(x[n] - x[n - 1L], y[n] - y[n - 1L])
    u_end <- u_end / sqrt(sum(u_end^2))
    parts <- c(parts, list(cap_arc(x[n], y[n], off[n],
                                   c(Rx[n], Ry[n]), c(Lx[n], Ly[n]), u_end)))
  }
  parts <- c(parts, list(left))
  if (cap == "round") {
    u_start <- c(x[1L] - x[2L], y[1L] - y[2L])
    u_start <- u_start / sqrt(sum(u_start^2))
    parts <- c(parts, list(cap_arc(x[1L], y[1L], off[1L],
                                   c(Lx[1L], Ly[1L]), c(Rx[1L], Ry[1L]), u_start)))
  }

  ring <- do.call(rbind, parts)
  colnames(ring) <- c("x", "y")
  ring
}

# ---- spray_scatter ----------------------------------------------------------

#' Scatter a cloud of dots along a path (airbrush / spray)
#'
#' Samples points along a centreline and offsets each one perpendicular to the
#' path by a Gaussian random amount, producing a soft-edged spray of dots with no
#' hard outline -- the airbrush / spray-can look. The dot density falls off from
#' the centreline (the Gaussian offset), and dots near the edge are drawn smaller
#' so the cloud feathers out. Pure number-to-number (no `grid`/`ggplot2`);
#' deterministic apart from the seeded RNG (ADR-0004).
#'
#' @param x,y Numeric vectors of centreline vertices (same length, any units --
#'   `spread`, `dot_r` and `density` are interpreted in those units).
#' @param spread Standard deviation of the perpendicular offset (cloud half-width).
#' @param density Mean number of dots per unit of path arc-length.
#' @param dot_r Base dot radius. Edge dots shrink toward `0.4 * dot_r`.
#' @param seed Integer seed for the scatter (ADR-0004).
#' @return A 4-column matrix with columns `x`, `y` (dot centres), `r` (dot radii)
#'   and `a` (a 0-1 weight that fades with distance from the centreline, for the
#'   caller to fold into per-dot alpha if desired). Zero rows for a degenerate
#'   path.
#' @family sketch-core
#' @export
spray_scatter <- function(x, y, spread = 0.04, density = 140, dot_r = 0.004,
                          seed = NULL) {
  x <- as.double(x); y <- as.double(y)
  stopifnot(length(x) == length(y))
  empty <- matrix(numeric(0), ncol = 4L,
                  dimnames = list(NULL, c("x", "y", "r", "a")))
  n <- length(x)
  if (n == 0L) return(empty)
  seed <- resolve_seed(seed)

  # A lone vertex: a round puff centred on the point.
  if (n == 1L) {
    ndots <- max(1L, as.integer(round(density * spread * 6)))
    return(within_seed(seed_offset(seed, 11L), {
      ang <- stats::runif(ndots, 0, 2 * pi)
      rad <- abs(stats::rnorm(ndots, 0, spread))
      a   <- exp(-0.5 * (rad / max(spread, 1e-9))^2)
      rr  <- dot_r * (0.4 + 0.6 * a)
      cbind(x = x + rad * cos(ang), y = y + rad * sin(ang),
            r = pmax(rr, 0), a = a)
    }))
  }

  seg   <- sqrt(diff(x)^2 + diff(y)^2)
  s     <- c(0, cumsum(seg))
  total <- s[n]
  if (total <= 0) return(empty)
  ndots <- max(1L, as.integer(round(density * total)))

  within_seed(seed_offset(seed, 11L), {
    sp <- stats::runif(ndots, 0, total)
    px <- stats::approx(s, x, sp, rule = 2)$y
    py <- stats::approx(s, y, sp, rule = 2)$y
    # Unit tangent via a small central difference in arc-length.
    e  <- total * 1e-3
    x1 <- stats::approx(s, x, pmin(total, sp + e), rule = 2)$y
    x0 <- stats::approx(s, x, pmax(0,     sp - e), rule = 2)$y
    y1 <- stats::approx(s, y, pmin(total, sp + e), rule = 2)$y
    y0 <- stats::approx(s, y, pmax(0,     sp - e), rule = 2)$y
    tx <- x1 - x0; ty <- y1 - y0
    tl <- sqrt(tx^2 + ty^2); tl[tl < 1e-12] <- 1
    ux <- tx / tl; uy <- ty / tl          # unit tangent
    nx <- -uy;     ny <- ux               # unit normal
    off <- stats::rnorm(ndots, 0, spread)
    a   <- exp(-0.5 * (off / max(spread, 1e-9))^2)
    rr  <- dot_r * (0.4 + 0.6 * a) *
      (1 + 0.5 * (stats::runif(ndots) - 0.5) * 2)   # +/-25% size jitter
    cbind(x = px + nx * off, y = py + ny * off, r = pmax(rr, 0), a = a)
  })
}
