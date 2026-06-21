# Layer 2 — sketch grobs with makeContent() (P2-T1)
# Roughening happens in inch space inside makeContent() (R4, T-CORE-05).

# Pick element `i` from each component of a gpar, recycling scalars. Aesthetics
# (colour, lwd, alpha, …) arrive as per-row vectors when a single draw call
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
      # Single point — draw a tiny ellipse marker
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
#' @param name,vp Passed to `grid::grob()`.
#' @return A `SketchPolygonGrob` grob subclass.
#' @family grob-layer
#' @export
sketch_polygon_grob <- function(x, y,
                                 id            = NULL,
                                 roughness     = 1,
                                 bowing        = 1,
                                 n_passes      = 2L,
                                 seed          = NULL,
                                 fill_gp       = gpar(),
                                 outline_gp    = gpar(),
                                 fill_style    = "hachure",
                                 hachure_angle = 45,
                                 hachure_gap   = 0.07,
                                 fill_weight   = 0.5,
                                 name          = NULL,
                                 vp            = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    x = x, y = y, id = id,
    roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed,
    fill_gp = fill_gp, outline_gp = outline_gp,
    fill_style = fill_style, hachure_angle = hachure_angle,
    hachure_gap = hachure_gap, fill_weight = fill_weight,
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

    # --- fill ---
    if (!is.null(x$fill_style) && x$fill_style != "solid") {
      fill_segs <- sketch_fill(
        gx, gy,
        fill_style    = x$fill_style,
        hachure_gap   = x$hachure_gap,
        hachure_angle = x$hachure_angle,
        fill_weight   = x$fill_weight,
        roughness     = x$roughness * 0.5,
        bowing        = 0,
        seed          = seed_offset(s_base, 1000L)
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
#' non-square panel — matching ggplot2's coordinate semantics).
#'
#' @param x,y Numeric npc centre coordinates (vectors).
#' @param rx,ry Numeric npc radii (vectors, recycled to `x`).
#' @param roughness,n_passes,seed Sketch parameters.
#' @param fill_style,hachure_angle,hachure_gap,fill_weight Fill parameters; set
#'   `fill_style = NULL` or `"solid"` for outline only.
#' @param fill_gp `gpar()` for the fill lines.
#' @param outline_gp `gpar()` for the rough outline stroke.
#' @param name,vp Passed to `grid::gTree()`.
#' @return A `SketchEllipseGrob` grob subclass.
#' @family grob-layer
#' @export
sketch_ellipse_grob <- function(x, y, rx, ry,
                                 roughness     = 1,
                                 n_passes      = 2L,
                                 seed          = NULL,
                                 fill_style    = NULL,
                                 hachure_angle = 45,
                                 hachure_gap   = 0.07,
                                 fill_weight   = 0.5,
                                 fill_gp       = gpar(),
                                 outline_gp    = gpar(),
                                 name          = NULL,
                                 vp            = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    x = x, y = y, rx = rx, ry = ry,
    roughness = roughness, n_passes = as.integer(n_passes), seed = seed,
    fill_style = fill_style, hachure_angle = hachure_angle,
    hachure_gap = hachure_gap, fill_weight = fill_weight,
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

  n  <- length(cx)
  rx <- rep(rx, length.out = n)
  ry <- rep(ry, length.out = n)

  children <- list()
  do_fill  <- !is.null(x$fill_style) && !identical(x$fill_style, "solid")
  do_solid <- identical(x$fill_style, "solid")

  for (i in seq_len(n)) {
    if (rx[i] <= 0 || ry[i] <= 0) next
    s_base <- seed_offset(x$seed, i * 71L)
    outline_gp_i <- index_gpar(x$outline_gp, i)  # per-shape colour (maps per row)
    fill_gp_i    <- index_gpar(x$fill_gp, i)

    # Roughened outline (also the solid-fill boundary). Computed first; explicit
    # seed offsets keep the RNG stream independent of draw order.
    passes <- rough_ellipse(
      cx = cx[i], cy = cy[i], rx = rx[i], ry = ry[i],
      roughness = x$roughness, n_passes = x$n_passes,
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
        roughness     = x$roughness * 0.4,
        bowing        = 0,
        seed          = seed_offset(s_base, 1000L)
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
