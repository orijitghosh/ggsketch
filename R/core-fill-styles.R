# Layer 1 — derived fill styles (P1-T8)
# No grid:: or ggplot2:: (T-ARCH-01).

#' Dispatch fill-style to the appropriate Layer-1 fill function
#'
#' @param px,py Polygon vertices (inch space).
#' @param fill_style Character: one of `"hachure"`, `"cross_hatch"`,
#'   `"zigzag"`, `"zigzag_line"`, `"dots"`, `"dashed"`, `"solid"`.
#' @param hachure_gap Gap between fill lines (inches). Default 0.1.
#' @param hachure_angle Base fill angle (degrees). Default 45.
#' @param fill_weight Thickness weight (passed to caller for gpar). Default 1.
#' @param roughness,bowing Sketch params for fill lines. Defaults 0.5, 0.
#' @param seed Integer seed.
#' @return List of 2-column (x,y) matrices representing fill stroke segments,
#'   OR `NULL` for `"solid"` (solid fill handled by polygon fill colour).
#' @family sketch-core
#' @export
sketch_fill <- function(px, py,
                         fill_style    = "hachure",
                         hachure_gap   = 0.1,
                         hachure_angle = 45,
                         fill_weight   = 1,
                         roughness     = 0.5,
                         bowing        = 0,
                         seed          = NULL) {
  check_fill_style(fill_style)
  seed <- resolve_seed(seed)

  switch(fill_style,
    hachure    = hachure_fill(px, py, hachure_gap, hachure_angle,
                               roughness, bowing, seed),
    cross_hatch = cross_hatch_fill(px, py, hachure_gap, hachure_angle,
                                    roughness, bowing, seed),
    zigzag     = zigzag_fill(px, py, hachure_gap, hachure_angle,
                              roughness, bowing, seed),
    zigzag_line = zigzag_line_fill(px, py, hachure_gap, hachure_angle,
                                    roughness, bowing, seed),
    scribble   = scribble_fill(px, py, hachure_gap, hachure_angle,
                                roughness, bowing, seed),
    dots       = dots_fill(px, py, hachure_gap, hachure_angle,
                            roughness, seed),
    dashed     = dashed_fill(px, py, hachure_gap, hachure_angle,
                              roughness, bowing, seed),
    solid      = NULL
  )
}

# ---- cross_hatch ------------------------------------------------------------

#' Cross-hatch fill: hachure at angle θ and θ+90°
#' @noRd
cross_hatch_fill <- function(px, py, gap, angle, roughness, bowing, seed) {
  a <- hachure_fill(px, py, gap, angle,       roughness, bowing,
                    seed_offset(seed, 0L))
  b <- hachure_fill(px, py, gap, angle + 90,  roughness, bowing,
                    seed_offset(seed, 500L))
  c(a, b)
}

# ---- zigzag -----------------------------------------------------------------

#' Zigzag fill: hachure lines + diagonal connectors between them
#' @noRd
zigzag_fill <- function(px, py, gap, angle, roughness, bowing, seed) {
  lines <- hachure_fill(px, py, gap, angle, roughness, bowing,
                         seed_offset(seed, 0L))
  if (length(lines) < 2L) return(lines)

  connectors <- vector("list", length(lines) - 1L)
  for (i in seq_len(length(lines) - 1L)) {
    seg_i   <- lines[[i]]
    seg_ip1 <- lines[[i + 1L]]
    # Connect end of line i to start of line i+1
    # End = last row of seg_i; Start = first row of seg_ip1
    x0 <- seg_i[nrow(seg_i), "x"]; y0 <- seg_i[nrow(seg_i), "y"]
    x1 <- seg_ip1[1L, "x"];        y1 <- seg_ip1[1L, "y"]
    if (roughness > 0) {
      s <- seed_offset(seed, 1000L + i * 7L)
      connectors[[i]] <- within_seed(s,
        roughen_segment(x0, y0, x1, y1, roughness * 0.5, bowing)
      )
    } else {
      connectors[[i]] <- matrix(c(x0, x1, y0, y1), nrow = 2L, ncol = 2L,
                                 dimnames = list(NULL, c("x", "y")))
    }
  }
  c(lines, connectors)
}

# ---- zigzag_line ------------------------------------------------------------

#' Zigzag-line fill: connectors only (no fill lines), producing a continuous
#' zigzag path
#' @noRd
zigzag_line_fill <- function(px, py, gap, angle, roughness, bowing, seed) {
  lines <- hachure_fill(px, py, gap, angle, 0, 0,
                         seed_offset(seed, 0L))
  if (length(lines) == 0L) return(list())

  # Build one continuous zigzag path from alternating ends of fill lines
  all_pts <- vector("list", length(lines))
  for (i in seq_along(lines)) {
    seg <- lines[[i]]
    if (i %% 2L == 0L) seg <- seg[rev(seq_len(nrow(seg))), , drop = FALSE]
    all_pts[[i]] <- seg
  }
  pts <- do.call(rbind, all_pts)

  if (roughness > 0) {
    within_seed(seed_offset(seed, 2000L),
      roughen_polyline(pts[, "x"], pts[, "y"],
                       roughness, bowing, n_passes = 1L,
                       seed = seed_offset(seed, 2000L))
    )
  } else {
    list(pts)
  }
}

# ---- scribble ---------------------------------------------------------------

#' Scribble fill: one continuous winding stroke that overshoots the boundary,
#' like quickly scribbling to fill a shape by hand.
#' @noRd
scribble_fill <- function(px, py, gap, angle, roughness, bowing, seed) {
  lines <- hachure_fill(px, py, gap, angle, 0, 0, seed_offset(seed, 0L))
  if (length(lines) == 0L) return(list())

  # Liveliness floor: scribbles read as scribbles even when fill roughness is low.
  rough <- max(roughness, 0.6)

  within_seed(seed_offset(seed, 2000L), {
    pts <- vector("list", length(lines))
    for (i in seq_along(lines)) {
      seg <- lines[[i]]
      a   <- seg[1L, ]
      b   <- seg[nrow(seg), ]
      d   <- c(b[["x"]] - a[["x"]], b[["y"]] - a[["y"]])
      len <- sqrt(sum(d^2))
      if (len > 1e-9) {
        u   <- d / len
        os  <- gap * 0.6
        a   <- c(x = a[["x"]] - u[1L] * os * stats::runif(1L, 0.2, 1),
                 y = a[["y"]] - u[2L] * os * stats::runif(1L, 0.2, 1))
        b   <- c(x = b[["x"]] + u[1L] * os * stats::runif(1L, 0.2, 1),
                 y = b[["y"]] + u[2L] * os * stats::runif(1L, 0.2, 1))
      }
      # Alternate direction so the stroke is continuous (boustrophedon).
      pts[[i]] <- if (i %% 2L == 0L) rbind(b, a) else rbind(a, b)
    }
    path <- do.call(rbind, pts)
    if (nrow(path) < 2L) return(list())
    roughen_polyline(path[, "x"], path[, "y"], rough, bowing,
                     n_passes = 1L, seed = seed_offset(seed, 3000L))
  })
}

# ---- dots -------------------------------------------------------------------

#' Dots fill: tiny circles sampled along hachure lines
#' @noRd
dots_fill <- function(px, py, gap, angle, roughness, seed) {
  lines <- hachure_fill(px, py, gap, angle, 0, 0,
                         seed_offset(seed, 0L))
  if (length(lines) == 0L) return(list())

  dot_r  <- gap * 0.15  # dot radius as fraction of gap
  result <- vector("list", length(lines) * 10L)  # pre-allocate generously
  ri     <- 0L

  for (seg in lines) {
    # Sample points along each hachure line at spacing = gap
    x0 <- seg[1L, "x"]; y0 <- seg[1L, "y"]
    x1 <- seg[nrow(seg), "x"]; y1 <- seg[nrow(seg), "y"]
    seg_len <- sqrt((x1 - x0)^2 + (y1 - y0)^2)
    if (seg_len < 1e-9) next
    n_dots <- max(1L, floor(seg_len / gap))
    ts <- seq(0, 1, length.out = n_dots + 1L)

    for (t in ts) {
      cx_dot <- x0 + t * (x1 - x0)
      cy_dot <- y0 + t * (y1 - y0)
      ri <- ri + 1L
      s  <- seed_offset(seed, 3000L + ri * 13L)
      result[[ri]] <- within_seed(s,
        rough_ellipse(cx_dot, cy_dot, dot_r, dot_r,
                      roughness = roughness * 0.5,
                      n_passes = 1L, seed = s)[[1L]]
      )
    }
  }
  result[seq_len(ri)]
}

# ---- dashed -----------------------------------------------------------------

#' Dashed fill: alternating filled / blank sections on each hachure line
#' @noRd
dashed_fill <- function(px, py, gap, angle, roughness, bowing, seed) {
  lines <- hachure_fill(px, py, gap, angle, 0, 0,
                         seed_offset(seed, 0L))
  if (length(lines) == 0L) return(list())

  result <- vector("list", length(lines) * 5L)
  ri     <- 0L
  dash   <- gap * 0.8

  for (seg in lines) {
    x0 <- seg[1L, "x"]; y0 <- seg[1L, "y"]
    x1 <- seg[nrow(seg), "x"]; y1 <- seg[nrow(seg), "y"]
    seg_len <- sqrt((x1 - x0)^2 + (y1 - y0)^2)
    if (seg_len < 1e-9) next

    dx <- (x1 - x0) / seg_len; dy <- (y1 - y0) / seg_len
    t  <- 0
    on <- TRUE
    while (t < seg_len) {
      t2 <- min(t + dash, seg_len)
      if (on) {
        ax <- x0 + t  * dx; ay <- y0 + t  * dy
        bx <- x0 + t2 * dx; by <- y0 + t2 * dy
        ri <- ri + 1L
        s  <- seed_offset(seed, 4000L + ri * 11L)
        result[[ri]] <- within_seed(s,
          roughen_segment(ax, ay, bx, by, roughness * 0.5, bowing)
        )
      }
      t  <- t2
      on <- !on
    }
  }
  result[seq_len(ri)]
}

# ---- curve-fill bridge (P1-T9) ----------------------------------------------

#' Flatten a closed Bézier boundary to a polygon, then fill
#'
#' For area/ribbon/density geoms: converts a curved boundary (list of Bézier
#' control-point sets) into a polygon approximation, then applies `sketch_fill`.
#'
#' @param bezier_list List of 4-element lists, each with `P0`, `P1`, `P2`,
#'   `P3` (each a length-2 c(x,y) vector in inch space). The list describes a
#'   closed path.
#' @param tol Flatness tolerance for flattening. Default 1e-3.
#' @param rdp_eps RDP epsilon. Default 1e-4.
#' @param ... Passed to `sketch_fill`.
#' @return List of fill-line segments (same structure as `sketch_fill`).
#' @family sketch-core
#' @export
curve_fill <- function(bezier_list,
                        tol     = 1e-3,
                        rdp_eps = 1e-4,
                        ...) {
  # Flatten each Bézier segment to a polyline and concatenate
  pts_list <- lapply(bezier_list, function(b) {
    pts <- flatten_bezier(b$P0[1L], b$P0[2L],
                           b$P1[1L], b$P1[2L],
                           b$P2[1L], b$P2[2L],
                           b$P3[1L], b$P3[2L],
                           tol = tol)
    rdp_reduce(pts, rdp_eps)
  })

  # Concatenate (drop duplicate junction points)
  poly <- do.call(rbind, lapply(seq_along(pts_list), function(k) {
    p <- pts_list[[k]]
    if (k > 1L) p[-1L, , drop = FALSE] else p
  }))

  sketch_fill(poly[, "x"], poly[, "y"], ...)
}
