# Layer 2 - sketch grobs with makeContent() (P2-T1)
# Roughening happens in inch space inside makeContent() (R4, T-CORE-05).

# Pick element `i` from each component of a gpar, recycling scalars. Aesthetics
# (colour, lwd, alpha, ...) arrive as per-row vectors when a single draw call
# covers many shapes (e.g. a continuous colour scale = one group); applying the
# whole vector to each shape's grob would make grid use only the first value, so
# every shape would share one colour. Subsetting per shape fixes that.
#' @noRd
index_gpar <- function(gp, i) {
  parts <- unclass(gp)
  if (length(parts) == 0L) return(gp)
  parts <- lapply(parts, function(v) {
    if (length(v) > 1L) v[[((i - 1L) %% length(v)) + 1L]] else v
  })
  do.call(grid::gpar, parts)
}

# ---- sketch_path_grob -------------------------------------------------------

#' Create a sketchy path grob
#'
#' A `grid` grob that re-roughens its path at actual render resolution in
#' `makeContent()`. Coordinates are in npc \[0,1\]; roughening is performed in
#' device inches.
#'
#' @param x,y Numeric vectors of npc \[0,1\] coordinates.
#' @param id Integer vector grouping coordinates into separate polylines (same
#'   semantics as `grid::polylineGrob`). `NULL` treats all points as one path.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param gp A `grid::gpar()` object controlling line aesthetics.
#' @param name,vp Passed to `grid::grob()`.
#' @return A `SketchPathGrob` (a grid grob subclass).
#' @family grob-layer
#' @export
sketch_path_grob <- function(x, y,
                              id        = NULL,
                              roughness = 1,
                              bowing    = 1,
                              n_passes  = 2L,
                              seed      = NULL,
                              gp        = gpar(),
                              name      = NULL,
                              vp        = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    x = x, y = y, id = id,
    roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed,
    gp = gp, name = name, vp = vp,
    cl = "SketchPathGrob"
  )
}

#' @method makeContent SketchPathGrob
#' @export
makeContent.SketchPathGrob <- function(x) {
  if (length(x$x) == 0L) {
    return(setChildren(x, gList(nullGrob())))
  }

  # Convert to inches (roughening is in inch space, R4). Coordinates may be
  # plain numeric (treated as npc) or grid units (e.g. from theme elements).
  xi <- if (is.unit(x$x)) as.numeric(convertX(x$x, "inches")) else
    as.numeric(convertX(unit(x$x, "npc"), "inches"))
  yi <- if (is.unit(x$y)) as.numeric(convertY(x$y, "inches")) else
    as.numeric(convertY(unit(x$y, "npc"), "inches"))

  # Split into groups
  id <- x$id %||% rep(1L, length(xi))
  groups <- split(seq_along(xi), id)

  children <- vector("list", length(groups) * x$n_passes)
  ci <- 0L

  for (g in seq_along(groups)) {
    idx  <- groups[[g]]
    gx   <- xi[idx]
    gy   <- yi[idx]

    if (length(gx) < 2L) {
      # Single point - draw a tiny ellipse marker
      ci <- ci + 1L
      children[[ci]] <- circleGrob(
        x = unit(gx, "inches"), y = unit(gy, "inches"),
        r = unit(0.005, "npc"),
        gp = x$gp
      )
      next
    }

    passes <- roughen_polyline(
      gx, gy,
      roughness = x$roughness,
      bowing    = x$bowing,
      n_passes  = x$n_passes,
      seed      = seed_offset(x$seed, g * 37L)
    )

    for (pass in passes) {
      ci <- ci + 1L
      children[[ci]] <- polylineGrob(
        x  = unit(pass[, "x"], "inches"),
        y  = unit(pass[, "y"], "inches"),
        gp = x$gp
      )
    }
  }

  setChildren(x, do.call(gList, children[seq_len(ci)]))
}

# ---- sketch_polygon_grob ----------------------------------------------------

#' Create a sketchy polygon grob with optional hachure fill
#'
#' @param x,y Numeric npc \[0,1\] coordinates.
#' @param id Group IDs (same semantics as `grid::polygonGrob`).
#' @param roughness,bowing,n_passes,seed Sketch parameters for the outline.
#' @param fill_gp `gpar()` for fill lines (`col` sets fill-line colour).
#' @param outline_gp `gpar()` for the rough outline stroke.
#' @param fill_style,hachure_angle,hachure_gap,fill_weight Fill parameters.
#' @param fill_roughness Roughness of the fill strokes. `NULL` (default) ties it
#'   to the outline as `roughness * 0.5`; set a number to control the fill
#'   texture independently of the outline.
#' @param fill_seed Seed for the fill strokes. `NULL` (default) derives it from
#'   `seed`; set an integer to vary the fill pattern without moving the outline.
#' @param name,vp Passed to `grid::grob()`.
#' @return A `SketchPolygonGrob` grob subclass.
#' @family grob-layer
#' @export
sketch_polygon_grob <- function(x, y,
                                 id             = NULL,
                                 roughness      = 1,
                                 bowing         = 1,
                                 n_passes       = 2L,
                                 seed           = NULL,
                                 fill_gp        = gpar(),
                                 outline_gp     = gpar(),
                                 fill_style     = "hachure",
                                 hachure_angle  = 45,
                                 hachure_gap    = 0.07,
                                 fill_weight    = 0.5,
                                 fill_roughness = NULL,
                                 fill_seed      = NULL,
                                 name           = NULL,
                                 vp             = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    x = x, y = y, id = id,
    roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed,
    fill_gp = fill_gp, outline_gp = outline_gp,
    fill_style = fill_style, hachure_angle = hachure_angle,
    hachure_gap = hachure_gap, fill_weight = fill_weight,
    fill_roughness = fill_roughness, fill_seed = fill_seed,
    name = name, vp = vp,
    cl = "SketchPolygonGrob"
  )
}

#' @method makeContent SketchPolygonGrob
#' @export
makeContent.SketchPolygonGrob <- function(x) {
  if (length(x$x) == 0L) {
    return(setChildren(x, gList(nullGrob())))
  }

  xi <- as.numeric(convertX(unit(x$x, "npc"), "inches"))
  yi <- as.numeric(convertY(unit(x$y, "npc"), "inches"))

  id     <- x$id %||% rep(1L, length(xi))
  groups <- split(seq_along(xi), id)

  children <- list()

  for (g in seq_along(groups)) {
    idx  <- groups[[g]]
    gx   <- xi[idx]
    gy   <- yi[idx]
    s_base <- seed_offset(x$seed, g * 37L)

    # Roughened, closed outline. Computed first so the "solid" fill can reuse it
    # as the fill boundary (keeping the hand-drawn edge). Explicit seed offsets
    # mean the draw order does not change the RNG stream.
    passes <- NULL
    if (length(gx) >= 2L) {
      cx <- c(gx, gx[1L])
      cy <- c(gy, gy[1L])
      passes <- roughen_polyline(
        cx, cy,
        roughness = x$roughness,
        bowing    = x$bowing,
        n_passes  = x$n_passes,
        seed      = seed_offset(s_base, 2000L)
      )
    }

    # Fill roughness/seed default to a function of the outline's, but can be set
    # independently (NULL keeps the historical coupling).
    fill_rough <- x$fill_roughness %||% (x$roughness * 0.5)
    fill_base  <- if (is.null(x$fill_seed)) s_base
                  else seed_offset(resolve_seed(x$fill_seed), g * 37L)

    # --- fill ---
    if (!is.null(x$fill_style) && x$fill_style != "solid") {
      fill_segs <- sketch_fill(
        gx, gy,
        fill_style    = x$fill_style,
        hachure_gap   = x$hachure_gap,
        hachure_angle = x$hachure_angle,
        fill_weight   = x$fill_weight,
        roughness     = fill_rough,
        bowing        = 0,
        seed          = seed_offset(fill_base, 1000L)
      )

      fill_gp_seg     <- x$fill_gp
      fill_gp_seg$lwd <- x$fill_weight * ggplot2::.pt

      for (seg in fill_segs) {
        children[[length(children) + 1L]] <- polylineGrob(
          x  = unit(seg[, "x"], "inches"),
          y  = unit(seg[, "y"], "inches"),
          gp = fill_gp_seg
        )
      }
    } else if (identical(x$fill_style, "solid") && !is.null(passes)) {
      # Solid fill: paint the roughened boundary with the fill colour. Skipped
      # when there is no fill (col NA) so outline-only stays outline-only.
      solid_col <- index_gpar(x$fill_gp, g)$col
      if (length(solid_col) && !is.na(solid_col)) {
        fp <- passes[[1L]]
        children[[length(children) + 1L]] <- polygonGrob(
          x  = unit(fp[, "x"], "inches"),
          y  = unit(fp[, "y"], "inches"),
          gp = gpar(fill = solid_col, col = NA)
        )
      }
    }

    # --- rough outline (n_passes) ---
    if (!is.null(passes)) {
      for (pass in passes) {
        children[[length(children) + 1L]] <- polylineGrob(
          x  = unit(pass[, "x"], "inches"),
          y  = unit(pass[, "y"], "inches"),
          gp = x$outline_gp
        )
      }
    }
  }

  if (length(children) == 0L) children <- list(nullGrob())
  setChildren(x, do.call(gList, children))
}

# ---- sketch_ellipse_grob ----------------------------------------------------

#' Create a sketchy ellipse / circle grob
#'
#' Draws one or more roughened ellipses whose centres are in npc \[0,1\] and
#' whose radii are npc fractions of the viewport (converted to device inches in
#' `makeContent()`, so a "circle" in data units may appear elliptical on a
#' non-square panel - matching ggplot2's coordinate semantics).
#'
#' @param x,y Numeric npc centre coordinates (vectors).
#' @param rx,ry Numeric npc radii (vectors, recycled to `x`).
#' @param roughness,n_passes,seed Sketch parameters.
#' @param fill_style,hachure_angle,hachure_gap,fill_weight Fill parameters; set
#'   `fill_style = NULL` or `"solid"` for outline only.
#' @param fill_roughness Roughness of the fill strokes. `NULL` (default) ties it
#'   to the outline as `roughness * 0.4`; set a number to control the fill
#'   texture independently of the outline.
#' @param fill_seed Seed for the fill strokes. `NULL` (default) derives it from
#'   `seed`; set an integer to vary the fill pattern without moving the outline.
#' @param fill_gp `gpar()` for the fill lines.
#' @param outline_gp `gpar()` for the rough outline stroke.
#' @param name,vp Passed to `grid::gTree()`.
#' @return A `SketchEllipseGrob` grob subclass.
#' @family grob-layer
#' @export
sketch_ellipse_grob <- function(x, y, rx, ry,
                                 roughness      = 1,
                                 n_passes       = 2L,
                                 seed           = NULL,
                                 fill_style     = NULL,
                                 hachure_angle  = 45,
                                 hachure_gap    = 0.07,
                                 fill_weight    = 0.5,
                                 fill_roughness = NULL,
                                 fill_seed      = NULL,
                                 fill_gp        = gpar(),
                                 outline_gp     = gpar(),
                                 name           = NULL,
                                 vp             = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    x = x, y = y, rx = rx, ry = ry,
    roughness = roughness, n_passes = as.integer(n_passes), seed = seed,
    fill_style = fill_style, hachure_angle = hachure_angle,
    hachure_gap = hachure_gap, fill_weight = fill_weight,
    fill_roughness = fill_roughness, fill_seed = fill_seed,
    fill_gp = fill_gp, outline_gp = outline_gp,
    name = name, vp = vp,
    cl = "SketchEllipseGrob"
  )
}

#' @method makeContent SketchEllipseGrob
#' @export
makeContent.SketchEllipseGrob <- function(x) {
  if (length(x$x) == 0L) {
    return(setChildren(x, gList(nullGrob())))
  }

  cx <- as.numeric(convertX(unit(x$x, "npc"), "inches"))
  cy <- as.numeric(convertY(unit(x$y, "npc"), "inches"))
  rx <- as.numeric(convertWidth(unit(x$rx, "npc"), "inches"))
  ry <- as.numeric(convertHeight(unit(x$ry, "npc"), "inches"))

  n      <- length(cx)
  rx     <- rep(rx, length.out = n)
  ry     <- rep(ry, length.out = n)
  rough_ <- rep(as.numeric(x$roughness), length.out = n)  # per-shape (mappable)

  children <- list()
  do_fill  <- !is.null(x$fill_style) && !identical(x$fill_style, "solid")
  do_solid <- identical(x$fill_style, "solid")

  for (i in seq_len(n)) {
    if (rx[i] <= 0 || ry[i] <= 0) next
    s_base <- seed_offset(x$seed, i * 71L)
    outline_gp_i <- index_gpar(x$outline_gp, i)  # per-shape colour (maps per row)
    fill_gp_i    <- index_gpar(x$fill_gp, i)

    rough_i <- max(rough_[i], 0)

    # Fill roughness/seed default to a function of the outline's, but can be set
    # independently (NULL keeps the historical coupling).
    fill_rough <- if (is.null(x$fill_roughness)) rough_i * 0.4
                  else x$fill_roughness[[((i - 1L) %% length(x$fill_roughness)) + 1L]]
    fill_base  <- if (is.null(x$fill_seed)) s_base
                  else seed_offset(resolve_seed(x$fill_seed), i * 71L)

    # Roughened outline (also the solid-fill boundary). Computed first; explicit
    # seed offsets keep the RNG stream independent of draw order.
    passes <- rough_ellipse(
      cx = cx[i], cy = cy[i], rx = rx[i], ry = ry[i],
      roughness = rough_i, n_passes = x$n_passes,
      seed = seed_offset(s_base, 2000L)
    )

    # --- fill ---
    if (do_fill) {
      # a clean ellipse boundary fed to the scan-line filler
      th   <- seq(0, 2 * pi, length.out = 64L)
      bx   <- cx[i] + rx[i] * cos(th)
      by   <- cy[i] + ry[i] * sin(th)
      segs <- sketch_fill(
        bx, by,
        fill_style    = x$fill_style,
        hachure_gap   = max(x$hachure_gap * 2 * min(rx[i], ry[i]), 1e-3),
        hachure_angle = x$hachure_angle,
        fill_weight   = x$fill_weight,
        roughness     = fill_rough,
        bowing        = 0,
        seed          = seed_offset(fill_base, 1000L)
      )
      fill_gp_seg     <- fill_gp_i
      fill_gp_seg$lwd <- x$fill_weight * ggplot2::.pt
      for (seg in segs) {
        children[[length(children) + 1L]] <- polylineGrob(
          x = unit(seg[, "x"], "inches"), y = unit(seg[, "y"], "inches"),
          gp = fill_gp_seg
        )
      }
    } else if (do_solid) {
      # paint the roughened boundary with the fill colour (skip when fill is NA)
      solid_col <- fill_gp_i$col
      if (length(solid_col) && !is.na(solid_col)) {
        fp <- passes[[1L]]
        children[[length(children) + 1L]] <- polygonGrob(
          x = unit(fp[, "x"], "inches"), y = unit(fp[, "y"], "inches"),
          gp = gpar(fill = solid_col, col = NA)
        )
      }
    }

    # --- roughened outline ---
    for (pass in passes) {
      children[[length(children) + 1L]] <- polylineGrob(
        x = unit(pass[, "x"], "inches"), y = unit(pass[, "y"], "inches"),
        gp = outline_gp_i
      )
    }
  }

  if (length(children) == 0L) children <- list(nullGrob())
  setChildren(x, do.call(gList, children))
}

# ---- sketch_wedge_grob ------------------------------------------------------

#' Create a sketchy pie/donut-wedge grob
#'
#' Draws one or more annular sectors (pie or donut slices) sharing a centre,
#' guaranteed circular regardless of panel shape: radii are taken as a fraction
#' of the smaller panel dimension and the geometry is assembled in device
#' inches inside `makeContent()`, then roughened. Each slice's roughened
#' boundary is also reused as the fill region so the hand-drawn edge is kept.
#'
#' @param x0,y0 Centre in npc \[0,1\] (scalars).
#' @param r,r0 Outer and inner radius as a fraction of the smaller panel
#'   dimension (`r0 = 0` gives a pie, `r0 > 0` a donut).
#' @param start,end Per-slice start/end angles in radians.
#' @param roughness,bowing,n_passes,seed Sketch parameters for the outline.
#' @param fill_style `"solid"` (default) paints each slice in its fill colour;
#'   any other style (`"hachure"`, ...) hatches it instead.
#' @param hachure_angle,hachure_gap,fill_weight Fill parameters (`hachure_gap`
#'   is a fraction of the smaller panel dimension).
#' @param fill_gp `gpar()` for the fill (per-slice `col` recycled).
#' @param outline_gp `gpar()` for the rough outline (per-slice `col` recycled).
#' @param name,vp Passed to `grid::gTree()`.
#' @return A `SketchWedgeGrob` grob subclass.
#' @family grob-layer
#' @export
sketch_wedge_grob <- function(x0, y0, r, r0 = 0,
                              start, end,
                              roughness     = 1,
                              bowing        = 0.4,
                              n_passes      = 2L,
                              seed          = NULL,
                              fill_style    = "solid",
                              hachure_angle = 45,
                              hachure_gap   = 0.07,
                              fill_weight   = 0.5,
                              fill_gp       = gpar(),
                              outline_gp    = gpar(),
                              name          = NULL,
                              vp            = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    x0 = x0, y0 = y0, r = r, r0 = r0, start = start, end = end,
    roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed,
    fill_style = fill_style, hachure_angle = hachure_angle,
    hachure_gap = hachure_gap, fill_weight = fill_weight,
    fill_gp = fill_gp, outline_gp = outline_gp,
    name = name, vp = vp,
    cl = "SketchWedgeGrob"
  )
}

#' @method makeContent SketchWedgeGrob
#' @export
makeContent.SketchWedgeGrob <- function(x) {
  n_slice <- length(x$start)
  if (n_slice == 0L) {
    return(setChildren(x, gList(nullGrob())))
  }

  cxi  <- as.numeric(convertX(unit(x$x0, "npc"), "inches"))
  cyi  <- as.numeric(convertY(unit(x$y0, "npc"), "inches"))
  base <- min(as.numeric(convertWidth(unit(1, "npc"), "inches")),
              as.numeric(convertHeight(unit(1, "npc"), "inches")))
  r_in  <- x$r  * base
  r0_in <- x$r0 * base

  do_solid <- is.null(x$fill_style) || identical(x$fill_style, "solid")
  children <- list()

  for (i in seq_len(n_slice)) {
    if (!is.finite(x$start[i]) || !is.finite(x$end[i]) ||
        x$start[i] == x$end[i]) next

    sect <- arc_sector(r0_in, r_in, x$start[i], x$end[i])
    gx   <- cxi + sect$x
    gy   <- cyi + sect$y

    s_base       <- seed_offset(x$seed, i * 71L)
    outline_gp_i <- index_gpar(x$outline_gp, i)
    fill_gp_i    <- index_gpar(x$fill_gp, i)

    # Roughened, closed boundary (computed first so "solid" can reuse it).
    cxv    <- c(gx, gx[1L])
    cyv    <- c(gy, gy[1L])
    passes <- roughen_polyline(
      cxv, cyv,
      roughness = max(x$roughness, 0), bowing = x$bowing,
      n_passes  = x$n_passes, seed = seed_offset(s_base, 2000L)
    )

    # --- fill ---
    if (do_solid) {
      solid_col <- fill_gp_i$col
      if (length(solid_col) && !is.na(solid_col)) {
        fp <- passes[[1L]]
        children[[length(children) + 1L]] <- polygonGrob(
          x  = unit(fp[, "x"], "inches"),
          y  = unit(fp[, "y"], "inches"),
          gp = gpar(fill = solid_col, col = NA)
        )
      }
    } else {
      segs <- sketch_fill(
        gx, gy,
        fill_style    = x$fill_style,
        hachure_gap   = max(x$hachure_gap * base, 1e-3),
        hachure_angle = x$hachure_angle,
        fill_weight   = x$fill_weight,
        roughness     = max(x$roughness, 0) * 0.5,
        bowing        = 0,
        seed          = seed_offset(s_base, 1000L)
      )
      fgp     <- fill_gp_i
      fgp$lwd <- x$fill_weight * ggplot2::.pt
      for (seg in segs) {
        children[[length(children) + 1L]] <- polylineGrob(
          x = unit(seg[, "x"], "inches"), y = unit(seg[, "y"], "inches"),
          gp = fgp
        )
      }
    }

    # --- roughened outline ---
    for (pass in passes) {
      children[[length(children) + 1L]] <- polylineGrob(
        x = unit(pass[, "x"], "inches"), y = unit(pass[, "y"], "inches"),
        gp = outline_gp_i
      )
    }
  }

  if (length(children) == 0L) children <- list(nullGrob())
  setChildren(x, do.call(gList, children))
}

# ---- sketch_arrow_grob ------------------------------------------------------

#' Create a sketchy arrow grob
#'
#' Draws one or more hand-drawn arrows. The shaft is a quadratic Bezier (so it
#' can curve) and the arrowhead is roughened and oriented to the curve's end
#' tangent, both assembled in device inches so the head stays crisp and
#' correctly angled on any panel shape. The arrowhead size can adapt to the
#' shaft length.
#'
#' @param x0,y0 Shaft start in npc \[0,1\] (vectors, one per arrow).
#' @param cx,cy Quadratic-Bezier control point in npc (vectors). For a straight
#'   arrow pass the chord midpoint.
#' @param x1,y1 Shaft end / arrow tip in npc (vectors).
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param arrow_length Arrowhead length in inches. `NULL` (default) adapts it to
#'   the shaft length.
#' @param arrow_angle Half-angle of the arrowhead in degrees. Default 25.
#' @param arrow_type `"open"` (default) draws a two-stroke V; `"closed"` draws a
#'   filled rough triangle.
#' @param gp A `grid::gpar()` for the strokes (per-arrow `col` recycled).
#' @param name,vp Passed to `grid::gTree()`.
#' @return A `SketchArrowGrob` grob subclass.
#' @family grob-layer
#' @export
sketch_arrow_grob <- function(x0, y0, cx, cy, x1, y1,
                              roughness    = 1,
                              bowing       = 1,
                              n_passes     = 2L,
                              seed         = NULL,
                              arrow_length = NULL,
                              arrow_angle  = 25,
                              arrow_type   = "open",
                              gp           = gpar(),
                              name         = NULL,
                              vp           = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    x0 = x0, y0 = y0, cx = cx, cy = cy, x1 = x1, y1 = y1,
    roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed,
    arrow_length = arrow_length, arrow_angle = arrow_angle,
    arrow_type = arrow_type,
    gp = gp, name = name, vp = vp,
    cl = "SketchArrowGrob"
  )
}

#' @method makeContent SketchArrowGrob
#' @export
makeContent.SketchArrowGrob <- function(x) {
  n_arr <- length(x$x0)
  if (n_arr == 0L) {
    return(setChildren(x, gList(nullGrob())))
  }

  to_in_x <- function(v) as.numeric(convertX(unit(v, "npc"), "inches"))
  to_in_y <- function(v) as.numeric(convertY(unit(v, "npc"), "inches"))
  x0i <- to_in_x(x$x0); y0i <- to_in_y(x$y0)
  cxi <- to_in_x(x$cx); cyi <- to_in_y(x$cy)
  x1i <- to_in_x(x$x1); y1i <- to_in_y(x$y1)

  spread   <- x$arrow_angle * pi / 180
  children <- list()

  for (i in seq_len(n_arr)) {
    s_base <- seed_offset(x$seed, i * 53L)
    gp_i   <- index_gpar(x$gp, i)

    # --- shaft: sample the quadratic Bezier in inches, then roughen ---
    t  <- seq(0, 1, length.out = 40L)
    bx <- (1 - t)^2 * x0i[i] + 2 * (1 - t) * t * cxi[i] + t^2 * x1i[i]
    by <- (1 - t)^2 * y0i[i] + 2 * (1 - t) * t * cyi[i] + t^2 * y1i[i]

    shaft <- roughen_polyline(
      bx, by,
      roughness = max(x$roughness, 0), bowing = x$bowing,
      n_passes  = x$n_passes, seed = seed_offset(s_base, 100L)
    )
    for (pass in shaft) {
      children[[length(children) + 1L]] <- polylineGrob(
        x = unit(pass[, "x"], "inches"), y = unit(pass[, "y"], "inches"),
        gp = gp_i
      )
    }

    # --- arrowhead: orient to the end tangent (P1 - control) ---
    tx <- x1i[i] - cxi[i]
    ty <- y1i[i] - cyi[i]
    if (abs(tx) < 1e-9 && abs(ty) < 1e-9) {
      tx <- x1i[i] - x0i[i]
      ty <- y1i[i] - y0i[i]
    }
    ang <- atan2(ty, tx)

    shaft_len <- sqrt((x1i[i] - x0i[i])^2 + (y1i[i] - y0i[i])^2)
    head_len  <- x$arrow_length %||% max(0.07, min(0.2, shaft_len * 0.22))

    b1x <- x1i[i] - head_len * cos(ang - spread)
    b1y <- y1i[i] - head_len * sin(ang - spread)
    b2x <- x1i[i] - head_len * cos(ang + spread)
    b2y <- y1i[i] - head_len * sin(ang + spread)

    if (identical(x$arrow_type, "closed")) {
      tri <- roughen_polyline(
        c(b1x, x1i[i], b2x, b1x), c(b1y, y1i[i], b2y, b1y),
        roughness = max(x$roughness, 0) * 0.5, bowing = 0,
        n_passes  = 1L, seed = seed_offset(s_base, 200L)
      )[[1L]]
      children[[length(children) + 1L]] <- polygonGrob(
        x = unit(tri[, "x"], "inches"), y = unit(tri[, "y"], "inches"),
        gp = gpar(fill = gp_i$col, col = gp_i$col, lwd = gp_i$lwd %||% 1)
      )
    } else {
      head <- roughen_polyline(
        c(b1x, x1i[i], b2x), c(b1y, y1i[i], b2y),
        roughness = max(x$roughness, 0) * 0.6, bowing = 0,
        n_passes  = x$n_passes, seed = seed_offset(s_base, 200L)
      )
      for (pass in head) {
        children[[length(children) + 1L]] <- polylineGrob(
          x = unit(pass[, "x"], "inches"), y = unit(pass[, "y"], "inches"),
          gp = gp_i
        )
      }
    }
  }

  if (length(children) == 0L) children <- list(nullGrob())
  setChildren(x, do.call(gList, children))
}

# ---- sketch_callout_grob ----------------------------------------------------

#' Create a sketchy callout grob (boxed label + leader arrow)
#'
#' Draws a handwriting label inside a roughened rounded box and a leader arrow
#' from the box to a target point. The box auto-sizes to the label at draw time
#' (device-space text metrics) and the leader leaves from the box edge nearest
#' the target.
#'
#' @param x,y Box centre in npc \[0,1\] (scalars).
#' @param xend,yend Target point in npc the leader points at (scalars). Pass
#'   `NA` for both to draw a boxed label with no leader.
#' @param label Label text.
#' @param padding Box padding around the text, in inches. Default 0.06.
#' @param corner_radius Box corner rounding (fraction of half-side). Default 0.3.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param arrow_length,arrow_angle Leader arrowhead size (see
#'   [sketch_arrow_grob()]).
#' @param text_gp,box_gp,arrow_gp `gpar()`s for the label, the box (outline; its
#'   `fill` paints the box), and the leader.
#' @param name,vp Passed to `grid::gTree()`.
#' @return A `SketchCalloutGrob` grob subclass.
#' @family grob-layer
#' @export
sketch_callout_grob <- function(x, y, xend, yend, label,
                                padding       = 0.06,
                                corner_radius = 0.3,
                                roughness     = 1,
                                bowing        = 0.6,
                                n_passes      = 2L,
                                seed          = NULL,
                                arrow_length  = NULL,
                                arrow_angle   = 25,
                                text_gp       = gpar(),
                                box_gp        = gpar(),
                                arrow_gp      = gpar(),
                                name          = NULL,
                                vp            = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    x = x, y = y, xend = xend, yend = yend, label = label,
    padding = padding, corner_radius = corner_radius,
    roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed, arrow_length = arrow_length, arrow_angle = arrow_angle,
    text_gp = text_gp, box_gp = box_gp, arrow_gp = arrow_gp,
    name = name, vp = vp,
    cl = "SketchCalloutGrob"
  )
}

#' @method makeContent SketchCalloutGrob
#' @export
makeContent.SketchCalloutGrob <- function(x) {
  xi <- as.numeric(convertX(unit(x$x, "npc"), "inches"))
  yi <- as.numeric(convertY(unit(x$y, "npc"), "inches"))

  # Box sized to the label (device-space metrics).
  tg <- grid::textGrob(as.character(x$label), gp = x$text_gp)
  tw <- as.numeric(convertWidth(grid::grobWidth(tg), "inches"))
  th <- as.numeric(convertHeight(grid::grobHeight(tg), "inches"))
  hw <- tw / 2 + x$padding
  hh <- th / 2 + x$padding

  rr <- rounded_rect_xy(xi - hw, xi + hw, yi - hh, yi + hh,
                        rx = x$corner_radius * hw, ry = x$corner_radius * hh)
  passes <- roughen_polyline(
    c(rr$x, rr$x[1L]), c(rr$y, rr$y[1L]),
    roughness = max(x$roughness, 0), bowing = x$bowing,
    n_passes  = x$n_passes, seed = seed_offset(x$seed, 2000L)
  )

  children <- list()

  # --- leader arrow (drawn first, so the box sits on top of its start) ---
  if (length(x$xend) && is.finite(x$xend) && is.finite(x$yend)) {
    xe <- as.numeric(convertX(unit(x$xend, "npc"), "inches"))
    ye <- as.numeric(convertY(unit(x$yend, "npc"), "inches"))
    ang <- atan2(ye - yi, xe - xi)
    # Exit point on the box edge toward the target.
    sc <- min(hw / max(abs(cos(ang)), 1e-6), hh / max(abs(sin(ang)), 1e-6))
    sx <- xi + cos(ang) * sc
    sy <- yi + sin(ang) * sc

    if (sqrt((xe - sx)^2 + (ye - sy)^2) > 1e-3) {
      shaft <- roughen_polyline(
        c(sx, xe), c(sy, ye),
        roughness = max(x$roughness, 0), bowing = x$bowing,
        n_passes  = x$n_passes, seed = seed_offset(x$seed, 100L)
      )
      for (pass in shaft) {
        children[[length(children) + 1L]] <- polylineGrob(
          x = unit(pass[, "x"], "inches"), y = unit(pass[, "y"], "inches"),
          gp = x$arrow_gp
        )
      }
      a2  <- atan2(ye - sy, xe - sx)
      spd <- x$arrow_angle * pi / 180
      hl  <- x$arrow_length %||%
        max(0.07, min(0.18, sqrt((xe - sx)^2 + (ye - sy)^2) * 0.22))
      head <- roughen_polyline(
        c(xe - hl * cos(a2 - spd), xe, xe - hl * cos(a2 + spd)),
        c(ye - hl * sin(a2 - spd), ye, ye - hl * sin(a2 + spd)),
        roughness = max(x$roughness, 0) * 0.6, bowing = 0,
        n_passes  = x$n_passes, seed = seed_offset(x$seed, 200L)
      )
      for (pass in head) {
        children[[length(children) + 1L]] <- polylineGrob(
          x = unit(pass[, "x"], "inches"), y = unit(pass[, "y"], "inches"),
          gp = x$arrow_gp
        )
      }
    }
  }

  # --- box fill ---
  box_fill <- x$box_gp$fill
  if (length(box_fill) && !is.na(box_fill)) {
    fp <- passes[[1L]]
    children[[length(children) + 1L]] <- polygonGrob(
      x = unit(fp[, "x"], "inches"), y = unit(fp[, "y"], "inches"),
      gp = gpar(fill = box_fill, col = NA)
    )
  }

  # --- box outline ---
  out_gp <- x$box_gp
  out_gp$fill <- NA
  for (pass in passes) {
    children[[length(children) + 1L]] <- polylineGrob(
      x = unit(pass[, "x"], "inches"), y = unit(pass[, "y"], "inches"),
      gp = out_gp
    )
  }

  # --- label ---
  children[[length(children) + 1L]] <- grid::textGrob(
    as.character(x$label),
    x = unit(xi, "inches"), y = unit(yi, "inches"),
    gp = x$text_gp
  )

  setChildren(x, do.call(gList, children))
}

# ---- sketch_band_grob -------------------------------------------------------

#' Create a sketchy filled-band grob (hole-aware region)
#'
#' Draws one filled region made of several rings (outer pieces and holes) - the
#' building block for filled contour / 2-D density bands. The whole region is
#' filled with a single hole-aware scan-line (so holes stay empty), and every
#' ring is stroked with a roughened outline. A `"solid"` fill paints the rings
#' with an even-odd rule.
#'
#' @param rings A list of rings, each a list with npc \[0,1\] `x` and `y` vertex
#'   vectors. The even-odd arrangement of outer pieces and holes is honoured.
#' @param roughness,bowing,n_passes,seed Sketch parameters for the outlines.
#' @param fill_style `"solid"` (default), `"hachure"`, or `"cross_hatch"`.
#' @param hachure_angle,hachure_gap,fill_weight Fill parameters (`hachure_gap`
#'   is an npc fraction).
#' @param fill_col Fill colour (`NA` leaves the region empty).
#' @param outline_gp `gpar()` for the roughened ring outlines.
#' @param name,vp Passed to `grid::gTree()`.
#' @return A `SketchBandGrob` grob subclass.
#' @family grob-layer
#' @export
sketch_band_grob <- function(rings,
                             roughness     = 0.7,
                             bowing        = 0.5,
                             n_passes      = 2L,
                             seed          = NULL,
                             fill_style    = "solid",
                             hachure_angle = 45,
                             hachure_gap   = 0.05,
                             fill_weight   = 0.5,
                             fill_col      = NA,
                             outline_gp    = gpar(),
                             name          = NULL,
                             vp            = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    rings = rings,
    roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed,
    fill_style = fill_style, hachure_angle = hachure_angle,
    hachure_gap = hachure_gap, fill_weight = fill_weight,
    fill_col = fill_col, outline_gp = outline_gp,
    name = name, vp = vp,
    cl = "SketchBandGrob"
  )
}

#' @method makeContent SketchBandGrob
#' @export
makeContent.SketchBandGrob <- function(x) {
  rings <- x$rings
  if (length(rings) == 0L) {
    return(setChildren(x, gList(nullGrob())))
  }

  # Convert every ring to inches; drop degenerate rings.
  rings_in <- lapply(rings, function(r) {
    list(x = as.numeric(convertX(unit(r$x, "npc"), "inches")),
         y = as.numeric(convertY(unit(r$y, "npc"), "inches")))
  })
  rings_in <- rings_in[vapply(rings_in, function(r) length(r$x) >= 3L,
                              logical(1L))]
  if (length(rings_in) == 0L) {
    return(setChildren(x, gList(nullGrob())))
  }

  # Roughen each ring once (closed). The first pass doubles as the fill boundary.
  passes_by_ring <- lapply(seq_along(rings_in), function(k) {
    r <- rings_in[[k]]
    roughen_polyline(
      c(r$x, r$x[1L]), c(r$y, r$y[1L]),
      roughness = max(x$roughness, 0), bowing = x$bowing,
      n_passes  = x$n_passes, seed = seed_offset(x$seed, k * 37L + 2000L)
    )
  })

  children <- list()
  do_solid <- is.null(x$fill_style) || identical(x$fill_style, "solid")
  has_fill <- length(x$fill_col) && !is.na(x$fill_col)

  # --- fill ---
  if (has_fill && do_solid) {
    # Even-odd polygon fill across all (roughened) rings keeps holes empty.
    fx <- unlist(lapply(passes_by_ring, function(p) p[[1L]][, "x"]))
    fy <- unlist(lapply(passes_by_ring, function(p) p[[1L]][, "y"]))
    id <- rep(seq_along(passes_by_ring),
              vapply(passes_by_ring, function(p) nrow(p[[1L]]), integer(1L)))
    children[[length(children) + 1L]] <- pathGrob(
      x = unit(fx, "inches"), y = unit(fy, "inches"), id = id,
      rule = "evenodd", gp = gpar(fill = x$fill_col, col = NA)
    )
  } else if (has_fill) {
    segs <- sketch_fill_multi(
      rings_in,
      fill_style    = x$fill_style,
      hachure_gap   = max(x$hachure_gap, 1e-3),
      hachure_angle = x$hachure_angle,
      fill_weight   = x$fill_weight,
      roughness     = max(x$roughness, 0) * 0.5,
      bowing        = 0,
      seed          = seed_offset(x$seed, 1000L)
    )
    fgp     <- gpar(col = x$fill_col, lineend = "round")
    fgp$lwd <- x$fill_weight * ggplot2::.pt
    for (seg in segs) {
      children[[length(children) + 1L]] <- polylineGrob(
        x = unit(seg[, "x"], "inches"), y = unit(seg[, "y"], "inches"),
        gp = fgp
      )
    }
  }

  # --- roughened ring outlines (skipped when col is NA) ---
  if (length(x$outline_gp$col) && !is.na(x$outline_gp$col)) {
    for (passes in passes_by_ring) {
      for (pass in passes) {
        children[[length(children) + 1L]] <- polylineGrob(
          x = unit(pass[, "x"], "inches"), y = unit(pass[, "y"], "inches"),
          gp = x$outline_gp
        )
      }
    }
  }

  if (length(children) == 0L) children <- list(nullGrob())
  setChildren(x, do.call(gList, children))
}

# ---- sketch_dotplot_grob ----------------------------------------------------

#' Create a sketchy dot-plot grob (stacked circular dots)
#'
#' Draws stacked roughened dots for a Wilkinson-style dot plot. The dot diameter
#' is taken from `dia` (an npc-x fraction = the bin width) and converted to
#' device inches at draw time, so every dot is a true circle whatever the panel
#' aspect, and stacks are built upward from `baseline` by that diameter.
#'
#' @param x Npc \[0,1\] x of each dot (its bin centre), one per dot.
#' @param stackpos Integer stack position of each dot within its bin (1 = first).
#' @param dia Dot diameter as an npc-x fraction (scalar; the bin width).
#' @param baseline Npc y the stacks grow from. Default 0.
#' @param stackratio Vertical spacing between stacked dots, as a fraction of the
#'   diameter. Default 1.
#' @param roughness,n_passes,seed Sketch parameters.
#' @param fill_gp `gpar()` for the solid dot fill (per-dot `col` recycled; `NA`
#'   leaves dots unfilled).
#' @param outline_gp `gpar()` for the roughened dot outline (per-dot `col`).
#' @param name,vp Passed to `grid::gTree()`.
#' @return A `SketchDotplotGrob` grob subclass.
#' @family grob-layer
#' @export
sketch_dotplot_grob <- function(x, stackpos,
                                dia,
                                baseline   = 0,
                                stackratio = 1,
                                roughness  = 0.5,
                                n_passes   = 2L,
                                seed       = NULL,
                                fill_gp    = gpar(),
                                outline_gp = gpar(),
                                name       = NULL,
                                vp         = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    x = x, stackpos = stackpos, dia = dia, baseline = baseline,
    stackratio = stackratio, roughness = roughness,
    n_passes = as.integer(n_passes), seed = seed,
    fill_gp = fill_gp, outline_gp = outline_gp,
    name = name, vp = vp,
    cl = "SketchDotplotGrob"
  )
}

#' @method makeContent SketchDotplotGrob
#' @export
makeContent.SketchDotplotGrob <- function(x) {
  if (length(x$x) == 0L) {
    return(setChildren(x, gList(nullGrob())))
  }

  cxi    <- as.numeric(convertX(unit(x$x, "npc"), "inches"))
  dia_in <- as.numeric(convertWidth(unit(x$dia, "npc"), "inches"))
  base_in <- as.numeric(convertY(unit(x$baseline, "npc"), "inches"))
  r       <- dia_in / 2

  children <- list()
  for (i in seq_along(cxi)) {
    if (r <= 0) next
    cy <- base_in + (x$stackpos[i] - 0.5) * dia_in * x$stackratio
    s_i <- seed_offset(x$seed, i * 53L)
    outline_gp_i <- index_gpar(x$outline_gp, i)
    fill_gp_i    <- index_gpar(x$fill_gp, i)

    passes <- rough_ellipse(
      cx = cxi[i], cy = cy, rx = r, ry = r,
      roughness = max(x$roughness, 0), n_passes = x$n_passes,
      seed = seed_offset(s_i, 2000L)
    )

    solid_col <- fill_gp_i$col
    if (length(solid_col) && !is.na(solid_col)) {
      fp <- passes[[1L]]
      children[[length(children) + 1L]] <- polygonGrob(
        x = unit(fp[, "x"], "inches"), y = unit(fp[, "y"], "inches"),
        gp = gpar(fill = solid_col, col = NA)
      )
    }
    for (pass in passes) {
      children[[length(children) + 1L]] <- polylineGrob(
        x = unit(pass[, "x"], "inches"), y = unit(pass[, "y"], "inches"),
        gp = outline_gp_i
      )
    }
  }

  if (length(children) == 0L) children <- list(nullGrob())
  setChildren(x, do.call(gList, children))
}
