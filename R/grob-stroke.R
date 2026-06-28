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
      roughness = x$roughness, bowing = x$bowing,
      n_passes = x$n_passes, seed = seed_offset(x$seed, g * 37L)
    )

    for (p in seq_along(passes)) {
      pass <- passes[[p]]
      rib  <- stroke_ribbon(
        pass[, "x"], pass[, "y"],
        width = x$width, taper = x$taper, taper_frac = x$taper_frac,
        pressure = x$pressure, nib_angle = x$nib_angle,
        jitter_w = x$jitter_w, cap = x$cap,
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
