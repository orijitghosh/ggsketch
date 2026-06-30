# Layer 2 - variable-width stroke grob (v2 keystone)
# Renders a polyline as one or more variable-width FILLED RIBBONS: re-roughens
# the centreline at device resolution (R4), then offsets it with stroke_ribbon()
# and paints each ribbon with the stroke colour. This is the grob the v2 media
# (ink / brush / pencil / calligraphy) draw through; the medium -> width/taper/
# pressure/passes mapping itself lives at Layer 3.

# ---- sketch_stroke_grob -----------------------------------------------------

#' Create a variable-width sketch stroke grob
#'
#' A `grid` grob that draws its path as a tapered / pressure-varying hand-drawn
#' stroke. Unlike [sketch_path_grob()] (constant-`lwd` polylines), the line is
#' built from [stroke_ribbon()] polygons, so it can taper to a point, swell with
#' pressure, or vary like a broad calligraphic nib. Coordinates are npc \[0,1\];
#' roughening and offsetting happen in device inches inside `makeContent()`.
#'
#' @param x,y Numeric vectors of npc \[0,1\] coordinates.
#' @param id Integer vector grouping coordinates into separate strokes (same
#'   semantics as [sketch_path_grob()]). `NULL` treats all points as one stroke.
#' @param width Full stroke width in **inches**. Default `0.03`.
#' @param roughness,bowing,n_passes,seed Sketch parameters for the centreline.
#' @param taper,taper_frac,pressure,nib_angle,jitter_w,cap Passed to
#'   [stroke_ribbon()].
#' @param gp A [grid::gpar()]; its `col` becomes the ribbon fill (the ribbon is
#'   painted, not stroked), `alpha` is honoured.
#' @param name,vp Passed to [grid::gTree()].
#' @return A `SketchStrokeGrob` (a grid grob subclass).
#' @family grob-layer
#' @export
sketch_stroke_grob <- function(x, y,
                               id         = NULL,
                               width      = 0.03,
                               roughness  = 1,
                               bowing     = 1,
                               n_passes   = 2L,
                               seed       = NULL,
                               taper      = "none",
                               taper_frac = 0,
                               pressure   = NULL,
                               nib_angle  = NULL,
                               jitter_w   = 0,
                               cap        = "round",
                               gp         = gpar(),
                               name       = NULL,
                               vp         = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    x = x, y = y, id = id,
    width = width, roughness = roughness, bowing = bowing,
    n_passes = as.integer(n_passes), seed = seed,
    taper = taper, taper_frac = taper_frac, pressure = pressure,
    nib_angle = nib_angle, jitter_w = jitter_w, cap = cap,
    gp = gp, name = name, vp = vp,
    cl = "SketchStrokeGrob"
  )
}

#' @method makeContent SketchStrokeGrob
#' @export
makeContent.SketchStrokeGrob <- function(x) {
  if (length(x$x) == 0L) {
    return(setChildren(x, gList(nullGrob())))
  }

  xi <- if (is.unit(x$x)) as.numeric(convertX(x$x, "inches")) else
    as.numeric(convertX(unit(x$x, "npc"), "inches"))
  yi <- if (is.unit(x$y)) as.numeric(convertY(x$y, "inches")) else
    as.numeric(convertY(unit(x$y, "npc"), "inches"))

  id     <- x$id %||% rep(1L, length(xi))
  groups <- split(seq_along(xi), id)

  # Ink-into-paper grain: when a textured paper is active (theme_sketch(paper =))
  # its tooth roughens the mark, so feather the centreline and the wet edge a
  # little more. A no-op on plain ground (grain 0).
  pg        <- max(0, getOption("ggsketch.wash_grain", 0))
  rough_eff <- x$roughness * (1 + pg * 0.6)
  jit_eff   <- x$jitter_w + pg * 0.12

  children <- vector("list", length(groups) * max(1L, x$n_passes))
  ci <- 0L

  for (g in seq_along(groups)) {
    idx <- groups[[g]]
    gx  <- xi[idx]; gy <- yi[idx]

    gp_g     <- index_gpar(x$gp, g)
    fill_col <- gp_g$col %||% "black"
    rib_gp   <- gpar(fill = fill_col, col = NA, alpha = gp_g$alpha %||% 1)

    # A single point: draw the stroke's round cap as a dot.
    if (length(gx) < 2L) {
      rib <- stroke_ribbon(gx, gy, width = x$width, cap = "round",
                           seed = seed_offset(x$seed, g * 37L))
      if (nrow(rib) > 0L) {
        ci <- ci + 1L
        children[[ci]] <- polygonGrob(unit(rib[, "x"], "inches"),
                                      unit(rib[, "y"], "inches"), gp = rib_gp)
      }
      next
    }

    passes <- roughen_polyline(
      gx, gy,
      roughness = rough_eff, bowing = x$bowing,
      n_passes = x$n_passes, seed = seed_offset(x$seed, g * 37L)
    )

    for (p in seq_along(passes)) {
      pass <- passes[[p]]
      rib  <- stroke_ribbon(
        pass[, "x"], pass[, "y"],
        width = x$width, taper = x$taper, taper_frac = x$taper_frac,
        pressure = x$pressure, nib_angle = x$nib_angle,
        jitter_w = jit_eff, cap = x$cap,
        seed = seed_offset(x$seed, g * 37L + p * 5L)
      )
      if (nrow(rib) == 0L) next
      ci <- ci + 1L
      children[[ci]] <- polygonGrob(unit(rib[, "x"], "inches"),
                                    unit(rib[, "y"], "inches"), gp = rib_gp)
    }
  }

  if (ci == 0L) return(setChildren(x, gList(nullGrob())))
  setChildren(x, do.call(gList, children[seq_len(ci)]))
}

# ---- sketch_spray_grob ------------------------------------------------------

#' Create an airbrush / spray stroke grob
#'
#' A `grid` grob that draws its path as a soft cloud of dots instead of a stroked
#' line: it re-roughens the centreline at device resolution, then scatters dots
#' around it with [spray_scatter()], for the airbrush / spray-can medium (no hard
#' outline). Coordinates are npc \[0,1\]; the scatter happens in device inches
#' inside `makeContent()`.
#'
#' @param x,y Numeric vectors of npc \[0,1\] coordinates.
#' @param id Integer vector grouping coordinates into separate strokes (`NULL`
#'   treats all points as one).
#' @param spread,density,dot_r Passed to [spray_scatter()] (in **inches**).
#' @param roughness,bowing,n_passes,seed Sketch parameters for the centreline.
#' @param gp A [grid::gpar()]; its `col` becomes the dot fill, `alpha` is honoured.
#' @param name,vp Passed to [grid::gTree()].
#' @return A `SketchSprayGrob` (a grid grob subclass).
#' @family grob-layer
#' @export
sketch_spray_grob <- function(x, y,
                              id        = NULL,
                              spread    = 0.05,
                              density   = 150,
                              dot_r     = 0.004,
                              roughness = 1,
                              bowing    = 1,
                              n_passes  = 1L,
                              seed      = NULL,
                              gp        = gpar(),
                              name      = NULL,
                              vp        = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    x = x, y = y, id = id,
    spread = spread, density = density, dot_r = dot_r,
    roughness = roughness, bowing = bowing,
    n_passes = as.integer(n_passes), seed = seed,
    gp = gp, name = name, vp = vp,
    cl = "SketchSprayGrob"
  )
}

#' @method makeContent SketchSprayGrob
#' @export
makeContent.SketchSprayGrob <- function(x) {
  if (length(x$x) == 0L) {
    return(setChildren(x, gList(nullGrob())))
  }

  xi <- if (is.unit(x$x)) as.numeric(convertX(x$x, "inches")) else
    as.numeric(convertX(unit(x$x, "npc"), "inches"))
  yi <- if (is.unit(x$y)) as.numeric(convertY(x$y, "inches")) else
    as.numeric(convertY(unit(x$y, "npc"), "inches"))

  id     <- x$id %||% rep(1L, length(xi))
  groups <- split(seq_along(xi), id)

  children <- vector("list", length(groups))
  ci <- 0L

  for (g in seq_along(groups)) {
    idx <- groups[[g]]
    gx  <- xi[idx]; gy <- yi[idx]

    gp_g     <- index_gpar(x$gp, g)
    fill_col <- gp_g$col %||% "black"
    base_a   <- gp_g$alpha %||% 1

    # Re-roughen the centreline (one pass is enough; the spray hides wobble) so
    # the cloud follows a hand-drawn line, then scatter the dots around it.
    if (length(gx) >= 2L) {
      pass <- roughen_polyline(
        gx, gy, roughness = x$roughness, bowing = x$bowing,
        n_passes = 1L, seed = seed_offset(x$seed, g * 37L)
      )[[1L]]
      sx <- pass[, "x"]; sy <- pass[, "y"]
    } else {
      sx <- gx; sy <- gy
    }

    dots <- spray_scatter(sx, sy, spread = x$spread, density = x$density,
                          dot_r = x$dot_r, seed = seed_offset(x$seed, g * 37L))
    if (nrow(dots) == 0L) next

    ci <- ci + 1L
    children[[ci]] <- circleGrob(
      x = unit(dots[, "x"], "inches"),
      y = unit(dots[, "y"], "inches"),
      r = unit(dots[, "r"], "inches"),
      gp = gpar(fill = fill_col, col = NA, alpha = base_a)
    )
  }

  if (ci == 0L) return(setChildren(x, gList(nullGrob())))
  setChildren(x, do.call(gList, children[seq_len(ci)]))
}
