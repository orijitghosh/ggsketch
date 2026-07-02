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

  children   <- list()
  wash_grain <- getOption("ggsketch.wash_grain", 0)   # paper-tooth coupling (C3)
  wash_polys <- list()                                # for wet-on-wet bleed (C2)

  for (g in seq_along(groups)) {
    idx  <- groups[[g]]
    gx   <- xi[idx]
    gy   <- yi[idx]
    # Drop non-finite vertices (Inf/NaN from unbounded data or bad transforms)
    # so no downstream fill/stroke comparison hits an NA. A group left with no
    # finite vertices is simply skipped.
    fin  <- is.finite(gx) & is.finite(gy)
    if (!all(fin)) { gx <- gx[fin]; gy <- gy[fin] }
    if (length(gx) == 0L) next
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
    if (identical(x$fill_style, "watercolor")) {
      # Translucent stacked washes instead of stroked fill lines.
      base_col <- index_gpar(x$fill_gp, g)$col
      if (length(base_col) && !is.na(base_col)) {
        wash <- watercolor_wash(
          gx, gy,
          granulation = 0.4,
          grain = wash_grain,
          seed = seed_offset(fill_base, 1000L)
        )
        layer_alpha <- 0.13
        for (poly in wash$washes) {
          children[[length(children) + 1L]] <- polygonGrob(
            x  = unit(poly[, "x"], "inches"),
            y  = unit(poly[, "y"], "inches"),
            gp = gpar(fill = scales::alpha(base_col, layer_alpha), col = NA)
          )
        }
        if (!is.null(wash$granules)) {
          gr <- wash$granules
          children[[length(children) + 1L]] <- circleGrob(
            x  = unit(gr$x, "inches"), y = unit(gr$y, "inches"),
            r  = unit(gr$r, "inches"),
            gp = gpar(fill = scales::alpha(base_col, 0.18), col = NA)
          )
        }
        # Record this region so overlapping washes can bleed into each other.
        wash_polys[[length(wash_polys) + 1L]] <-
          list(x = gx, y = gy, col = base_col, seed = fill_base)
      }
    } else if (!is.null(x$fill_style) && x$fill_style != "solid") {
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

  # --- wet-on-wet bleed (C2): mingle pigment where two washes overlap ---
  if (isTRUE(getOption("ggsketch.wash_bleed", TRUE)) && length(wash_polys) >= 2L) {
    for (i in seq_len(length(wash_polys) - 1L)) {
      for (j in seq(i + 1L, length(wash_polys))) {
        a <- wash_polys[[i]]; b <- wash_polys[[j]]
        bl <- wash_bleed(a$x, a$y, b$x, b$y, a$col, b$col,
                         seed = seed_offset(a$seed, j * 131L))
        if (is.null(bl)) next
        children[[length(children) + 1L]] <- circleGrob(
          x  = unit(bl$x, "inches"), y = unit(bl$y, "inches"),
          r  = unit(bl$r, "inches"),
          gp = gpar(fill = scales::alpha(bl$fill, 0.12), col = NA)
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
#'   `fill_style = NULL` or `"solid"` for outline only. `"watercolor"` paints
#'   translucent stacked washes.
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

  children   <- list()
  wash_grain <- getOption("ggsketch.wash_grain", 0)   # paper-tooth coupling (C3)
  do_water <- identical(x$fill_style, "watercolor")
  do_fill  <- !is.null(x$fill_style) && !identical(x$fill_style, "solid") &&
              !do_water
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
    if (do_water) {
      # Translucent stacked washes on a clean ellipse boundary.
      base_col <- fill_gp_i$col
      if (length(base_col) && !is.na(base_col)) {
        th <- seq(0, 2 * pi, length.out = 64L)
        bx <- cx[i] + rx[i] * cos(th)
        by <- cy[i] + ry[i] * sin(th)
        wash <- watercolor_wash(
          bx, by, granulation = 0.4, grain = wash_grain,
          seed = seed_offset(fill_base, 1000L)
        )
        layer_alpha <- 0.13
        for (poly in wash$washes) {
          children[[length(children) + 1L]] <- polygonGrob(
            x  = unit(poly[, "x"], "inches"), y = unit(poly[, "y"], "inches"),
            gp = gpar(fill = scales::alpha(base_col, layer_alpha), col = NA)
          )
        }
        if (!is.null(wash$granules)) {
          gr <- wash$granules
          children[[length(children) + 1L]] <- circleGrob(
            x  = unit(gr$x, "inches"), y = unit(gr$y, "inches"),
            r  = unit(gr$r, "inches"),
            gp = gpar(fill = scales::alpha(base_col, 0.18), col = NA)
          )
        }
      }
    } else if (do_fill) {
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

# ---- arrowhead grobs (shared by arrow + callout) ----------------------------

# Turn one arrowhead() result into roughened grobs: stroke the open paths, fill
# the closed ones, paint the dot. `col` strokes/fills (a single arrow colour);
# `lwd` sets the stroke weight. Used by both the arrow and callout grobs so every
# head style is available everywhere.
arrowhead_grobs <- function(tipx, tipy, angle, head_len, half_angle, style,
                            roughness, n_passes, seed, gp) {
  ah  <- arrowhead(tipx, tipy, angle, head_len, half_angle = half_angle,
                   style = style)
  out <- list()
  rough <- max(roughness, 0) * 0.6

  for (s in ah$strokes) {
    for (pass in roughen_polyline(s[, "x"], s[, "y"], roughness = rough,
                                  bowing = 0, n_passes = n_passes,
                                  seed = seed_offset(seed, 200L))) {
      out[[length(out) + 1L]] <- polylineGrob(
        x = unit(pass[, "x"], "inches"), y = unit(pass[, "y"], "inches"),
        gp = gp
      )
    }
  }
  for (p in ah$polygons) {
    rp <- roughen_polyline(c(p[, "x"], p[1L, "x"]), c(p[, "y"], p[1L, "y"]),
                           roughness = rough, bowing = 0, n_passes = 1L,
                           seed = seed_offset(seed, 200L))[[1L]]
    out[[length(out) + 1L]] <- polygonGrob(
      x = unit(rp[, "x"], "inches"), y = unit(rp[, "y"], "inches"),
      gp = gpar(fill = gp$col, col = gp$col, lwd = gp$lwd %||% 1)
    )
  }
  if (!is.null(ah$dots)) {
    out[[length(out) + 1L]] <- circleGrob(
      x = unit(ah$dots$x, "inches"), y = unit(ah$dots$y, "inches"),
      r = unit(ah$dots$r, "inches"),
      gp = gpar(fill = gp$col, col = NA)
    )
  }
  out
}

# Resolve the head style: an explicit `arrow_head` wins; otherwise map the
# historical `arrow_type` ("open"/"closed") onto the new vocabulary.
resolve_arrow_head <- function(arrow_head, arrow_type) {
  if (!is.null(arrow_head)) return(arrow_head)
  switch(arrow_type %||% "open",
    closed = "triangle_filled",
    "triangle_open"
  )
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
#'   filled rough triangle. Superseded by `arrow_head`; kept for back-compat.
#' @param arrow_head Head style, one of [sketch_arrowheads()]
#'   (`"triangle_open"`, `"triangle_filled"`, `"barb"`, `"fishtail"`, `"dot"`,
#'   `"bar"`). `NULL` (default) derives it from `arrow_type`.
#' @param ends Which end(s) carry a head: `"last"` (default), `"first"`, or
#'   `"both"`.
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
                              arrow_head   = NULL,
                              ends         = "last",
                              gp           = gpar(),
                              name         = NULL,
                              vp           = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    x0 = x0, y0 = y0, cx = cx, cy = cy, x1 = x1, y1 = y1,
    roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed,
    arrow_length = arrow_length, arrow_angle = arrow_angle,
    arrow_type = arrow_type, arrow_head = arrow_head, ends = ends,
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

  half     <- x$arrow_angle * pi / 180
  style    <- resolve_arrow_head(x$arrow_head, x$arrow_type)
  ends     <- x$ends %||% "last"
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

    shaft_len <- sqrt((x1i[i] - x0i[i])^2 + (y1i[i] - y0i[i])^2)
    head_len  <- x$arrow_length %||% max(0.07, min(0.2, shaft_len * 0.22))

    # --- arrowhead(s): orient to the end tangent (P1 - control) ---
    add_head <- function(tipx, tipy, ang, soff) {
      hg <- arrowhead_grobs(tipx, tipy, ang, head_len, half, style,
                            x$roughness, x$n_passes, seed_offset(s_base, soff),
                            gp_i)
      children <<- c(children, hg)
    }
    if (ends %in% c("last", "both")) {
      tx <- x1i[i] - cxi[i]; ty <- y1i[i] - cyi[i]
      if (abs(tx) < 1e-9 && abs(ty) < 1e-9) {
        tx <- x1i[i] - x0i[i]; ty <- y1i[i] - y0i[i]
      }
      add_head(x1i[i], y1i[i], atan2(ty, tx), 200L)
    }
    if (ends %in% c("first", "both")) {
      tx <- x0i[i] - cxi[i]; ty <- y0i[i] - cyi[i]
      if (abs(tx) < 1e-9 && abs(ty) < 1e-9) {
        tx <- x0i[i] - x1i[i]; ty <- y0i[i] - y1i[i]
      }
      add_head(x0i[i], y0i[i], atan2(ty, tx), 300L)
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
#' @param arrow_head Leader head style (see [sketch_arrowheads()]); `NULL` = the
#'   open V.
#' @param leader Leader routing: `"straight"` (default), `"elbow"` (horizontal
#'   then vertical) or `"curved"` (a bowed Bezier).
#' @param curvature Bow size when `leader = "curved"`. Default 0.3.
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
                                arrow_head    = NULL,
                                leader        = "straight",
                                curvature     = 0.3,
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
    arrow_head = arrow_head, leader = leader, curvature = curvature,
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
      lp <- leader_path(sx, sy, xe, ye, style = x$leader %||% "straight",
                        curvature = x$curvature %||% 0.3)
      shaft <- roughen_polyline(
        lp$x, lp$y,
        roughness = max(x$roughness, 0), bowing = x$bowing,
        n_passes  = x$n_passes, seed = seed_offset(x$seed, 100L)
      )
      for (pass in shaft) {
        children[[length(children) + 1L]] <- polylineGrob(
          x = unit(pass[, "x"], "inches"), y = unit(pass[, "y"], "inches"),
          gp = x$arrow_gp
        )
      }
      spd   <- x$arrow_angle * pi / 180
      hl    <- x$arrow_length %||%
        max(0.07, min(0.18, sqrt((xe - sx)^2 + (ye - sy)^2) * 0.22))
      style <- resolve_arrow_head(x$arrow_head, "open")
      children <- c(children, arrowhead_grobs(
        xe, ye, lp$angle, hl, spd, style, x$roughness, x$n_passes,
        seed_offset(x$seed, 200L), x$arrow_gp
      ))
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
#' @param fill_style `"solid"` (default), `"hachure"`, `"cross_hatch"`, or
#'   `"watercolor"` (hole-aware translucent washes).
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
  do_water <- identical(x$fill_style, "watercolor")
  do_solid <- !do_water && (is.null(x$fill_style) ||
                            identical(x$fill_style, "solid"))
  has_fill <- length(x$fill_col) && !is.na(x$fill_col)

  # --- fill ---
  if (has_fill && do_water) {
    # Hole-aware translucent washes: each layer is every ring, painted as one
    # even-odd path so holes stay empty.
    wash <- watercolor_wash_multi(
      rings_in, granulation = 0.4, grain = getOption("ggsketch.wash_grain", 0),
      seed = seed_offset(x$seed, 1000L)
    )
    layer_alpha <- 0.13
    for (layer in wash$washes) {
      fx <- unlist(lapply(layer, function(m) m[, "x"]))
      fy <- unlist(lapply(layer, function(m) m[, "y"]))
      id <- rep(seq_along(layer), vapply(layer, nrow, integer(1L)))
      children[[length(children) + 1L]] <- pathGrob(
        x = unit(fx, "inches"), y = unit(fy, "inches"), id = id,
        rule = "evenodd",
        gp = gpar(fill = scales::alpha(x$fill_col, layer_alpha), col = NA)
      )
    }
    if (!is.null(wash$granules)) {
      gr <- wash$granules
      children[[length(children) + 1L]] <- circleGrob(
        x  = unit(gr$x, "inches"), y = unit(gr$y, "inches"),
        r  = unit(gr$r, "inches"),
        gp = gpar(fill = scales::alpha(x$fill_col, 0.18), col = NA)
      )
    }
  } else if (has_fill && do_solid) {
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

# ---- sketch_engrave_grob ----------------------------------------------------

#' Create a sketchy engraving grob (tonal cross-hatch by line density)
#'
#' Fills a region with [engrave_fill()]: a ladder of hatch layers whose
#' accumulated density follows a tone field, so the region shades continuously
#' from blank paper (light) to dense cross-hatch (dark) the way an etching does.
#' The hatch geometry is computed in device inches (so angles and wobble are
#' device-consistent); the `field` is supplied in npc \[0,1\] and sampled through
#' an inch-to-npc affine at draw time.
#'
#' @param rings A list of rings, each a list with npc \[0,1\] `x` and `y` vertex
#'   vectors bounding the region to engrave (even-odd holes honoured).
#' @param field A vectorised tone function `function(x, y)` taking npc \[0,1\]
#'   coordinates and returning tone in `[0, 1]` (0 = paper, 1 = darkest).
#' @param ladder A ladder from [engrave_ladder()]; `NULL` builds a default from
#'   the `ladder_*` parameters.
#' @param ladder_levels,ladder_base_gap,ladder_gap_ratio,ladder_base_angle,ladder_cross_after Ladder
#'   controls used when `ladder` is `NULL`. `ladder_base_gap` is an npc-x
#'   fraction (converted to inches at draw time).
#' @param roughness,bowing,seed Sketch parameters for the engraving strokes.
#' @param min_gap_in Hard pitch floor in inches: ladder layers finer than this
#'   are dropped, so the darkest tones cannot explode into a runaway number of
#'   strokes. Default 0.012.
#' @param gp `gpar()` for the engraving strokes (`col`, `lwd`).
#' @param name,vp Passed to `grid::gTree()`.
#' @return A `SketchEngraveGrob` grob subclass.
#' @family grob-layer
#' @export
sketch_engrave_grob <- function(rings, field,
                                ladder            = NULL,
                                ladder_levels     = 5L,
                                ladder_base_gap   = 0.08,
                                ladder_gap_ratio  = 0.62,
                                ladder_base_angle = 45,
                                ladder_cross_after = 3L,
                                roughness         = 0.5,
                                bowing            = 0.3,
                                seed              = NULL,
                                min_gap_in        = 0.012,
                                gp                = gpar(),
                                name              = NULL,
                                vp                = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    rings = rings, field = field, ladder = ladder,
    ladder_levels = as.integer(ladder_levels),
    ladder_base_gap = ladder_base_gap, ladder_gap_ratio = ladder_gap_ratio,
    ladder_base_angle = ladder_base_angle,
    ladder_cross_after = as.integer(ladder_cross_after),
    roughness = roughness, bowing = bowing, seed = seed,
    min_gap_in = min_gap_in, gp = gp,
    name = name, vp = vp,
    cl = "SketchEngraveGrob"
  )
}

#' @method makeContent SketchEngraveGrob
#' @export
makeContent.SketchEngraveGrob <- function(x) {
  rings <- x$rings
  if (length(rings) == 0L || !is.function(x$field)) {
    return(setChildren(x, gList(nullGrob())))
  }

  # Rings npc -> inches.
  rings_in <- lapply(rings, function(r) {
    list(x = as.numeric(convertX(unit(r$x, "npc"), "inches")),
         y = as.numeric(convertY(unit(r$y, "npc"), "inches")))
  })
  rings_in <- rings_in[vapply(rings_in, function(r) length(r$x) >= 3L,
                              logical(1L))]
  if (length(rings_in) == 0L) {
    return(setChildren(x, gList(nullGrob())))
  }

  # Inch -> npc affine (npc-to-inch is affine per axis), so we can evaluate the
  # npc-domain field at inch-space sample points cheaply.
  x0 <- as.numeric(convertX(unit(0, "npc"), "inches"))
  x1 <- as.numeric(convertX(unit(1, "npc"), "inches"))
  y0 <- as.numeric(convertY(unit(0, "npc"), "inches"))
  y1 <- as.numeric(convertY(unit(1, "npc"), "inches"))
  ax <- x1 - x0; ay <- y1 - y0
  if (abs(ax) < 1e-9 || abs(ay) < 1e-9) {
    return(setChildren(x, gList(nullGrob())))
  }
  field_npc  <- x$field
  field_inch <- function(xi, yi) field_npc((xi - x0) / ax, (yi - y0) / ay)

  # Build the ladder in inch units, then apply the pitch floor.
  ladder <- x$ladder %||% engrave_ladder(
    n_levels    = x$ladder_levels,
    base_gap    = x$ladder_base_gap * abs(ax),   # npc-x fraction -> inches
    gap_ratio   = x$ladder_gap_ratio,
    base_angle  = x$ladder_base_angle,
    cross_after = x$ladder_cross_after
  )
  ladder <- Filter(function(l) l$gap >= x$min_gap_in, ladder)
  if (length(ladder) == 0L) {
    return(setChildren(x, gList(nullGrob())))
  }

  segs <- engrave_fill(rings_in, field_inch, ladder = ladder,
                       roughness = x$roughness, bowing = x$bowing,
                       seed = x$seed)
  if (length(segs) == 0L) {
    return(setChildren(x, gList(nullGrob())))
  }

  children <- lapply(segs, function(seg) {
    polylineGrob(x = unit(seg[, "x"], "inches"),
                 y = unit(seg[, "y"], "inches"), gp = x$gp)
  })
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
