# Layer 3 - geom_sketch_engrave() / geom_sketch_shade() (v2 engraving module)
# Tonal shading by hatch-line DENSITY, the way an etcher or banknote engraver
# builds a gradient: light areas stay near-blank, dark areas accumulate dense
# cross-hatch. This is the thing the fill-pattern packages cannot do -- they
# tile a motif; ggsketch COMPUTES tone from geometry (engrave_fill, Layer 1).
#
#   * geom_sketch_engrave() shades a z surface (x, y, z grid) by tone, the
#     hand-drawn cousin of an etched relief / banknote vignette.
#   * geom_sketch_shade() shades each polygon region with a uniform density set
#     by a `tone` aesthetic, so a mapped value reads as darkness.

# Build a vectorised bilinear tone field over a regular npc grid. `gx`, `gy` are
# the sorted unique npc coordinates; `Z` is a length(gx) x length(gy) matrix of
# tone in [0, 1]. Returns function(xn, yn) clamped to the grid edges.
#' @noRd
engrave_field_from_grid <- function(gx, gy, Z) {
  nx <- length(gx); ny <- length(gy)
  function(xn, yn) {
    if (nx < 2L || ny < 2L) return(rep(mean(Z), length(xn)))
    ix <- findInterval(xn, gx, all.inside = TRUE)
    iy <- findInterval(yn, gy, all.inside = TRUE)
    tx <- (xn - gx[ix]) / (gx[ix + 1L] - gx[ix])
    ty <- (yn - gy[iy]) / (gy[iy + 1L] - gy[iy])
    tx <- pmin(1, pmax(0, tx)); ty <- pmin(1, pmax(0, ty))
    z00 <- Z[cbind(ix,      iy)];      z10 <- Z[cbind(ix + 1L, iy)]
    z01 <- Z[cbind(ix,      iy + 1L)]; z11 <- Z[cbind(ix + 1L, iy + 1L)]
    val <- z00 * (1 - tx) * (1 - ty) + z10 * tx * (1 - ty) +
           z01 * (1 - tx) * ty       + z11 * tx * ty
    pmin(1, pmax(0, val))
  }
}

# ---- GeomSketchEngrave -------------------------------------------------------

#' @rdname geom_sketch_engrave
#' @export
GeomSketchEngrave <- ggplot2::ggproto(
  "GeomSketchEngrave", ggplot2::Geom,

  required_aes = c("x", "y", "z"),

  default_aes = ggplot2::aes(
    colour    = "grey15",
    linewidth = 0.35,
    alpha     = NA
  ),

  draw_key = draw_key_sketch_path,

  parameters = function(self, extra = FALSE) {
    c("levels", "base_gap", "gap_ratio", "base_angle", "cross_after",
      "reverse", "roughness", "bowing", "min_gap_in", "seed", "na.rm")
  },

  draw_panel = function(data, panel_params, coord,
                         levels      = 5L,
                         base_gap    = 0.08,
                         gap_ratio   = 0.62,
                         base_angle  = 45,
                         cross_after = 3L,
                         reverse     = FALSE,
                         roughness   = 0.5,
                         bowing      = 0.3,
                         min_gap_in  = 0.012,
                         seed        = NULL,
                         ...) {
    if (nrow(data) < 4L) return(nullGrob())
    seed <- resolve_seed(seed)

    tp <- coord$transform(data, panel_params)
    gx <- sort(unique(tp$x)); gy <- sort(unique(tp$y))
    if (length(gx) < 2L || length(gy) < 2L) return(nullGrob())

    # Tone in [0, 1] from z (high z = dark by default).
    tone <- scales::rescale(data$z, to = c(0, 1), from = range(data$z))
    if (reverse) tone <- 1 - tone

    # Lay the tone onto the npc grid: Z[i, j] = tone at (gx[i], gy[j]).
    Z  <- matrix(NA_real_, length(gx), length(gy))
    ix <- match(tp$x, gx); iy <- match(tp$y, gy)
    Z[cbind(ix, iy)] <- tone
    # Fill any gaps (irregular grids) with the column/overall mean so lookups
    # never hit NA.
    if (anyNA(Z)) Z[is.na(Z)] <- mean(Z, na.rm = TRUE)

    field <- engrave_field_from_grid(gx, gy, Z)

    # Engrave the data's bounding rectangle (npc).
    rx <- range(gx); ry <- range(gy)
    rings <- list(list(x = c(rx[1L], rx[2L], rx[2L], rx[1L]),
                       y = c(ry[1L], ry[1L], ry[2L], ry[2L])))

    first <- data[1L, , drop = FALSE]
    sketch_engrave_grob(
      rings = rings, field = field,
      ladder_levels = as.integer(levels),
      ladder_base_gap = base_gap, ladder_gap_ratio = gap_ratio,
      ladder_base_angle = base_angle, ladder_cross_after = as.integer(cross_after),
      roughness = roughness, bowing = bowing, seed = seed,
      min_gap_in = min_gap_in,
      gp = gpar(col = scales::alpha(first$colour, first$alpha),
                lwd = first$linewidth * ggplot2::.pt, lineend = "round")
    )
  }
)

# ---- GeomSketchShade ---------------------------------------------------------

#' @rdname geom_sketch_engrave
#' @export
GeomSketchShade <- ggplot2::ggproto(
  "GeomSketchShade", ggplot2::Geom,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    tone      = 0.6,
    colour    = "grey15",
    linewidth = 0.35,
    alpha     = NA
  ),

  draw_key = draw_key_sketch_path,

  parameters = function(self, extra = FALSE) {
    c("levels", "base_gap", "gap_ratio", "base_angle", "cross_after",
      "roughness", "bowing", "min_gap_in", "seed", "na.rm")
  },

  draw_group = function(data, panel_params, coord,
                         levels      = 5L,
                         base_gap    = 0.08,
                         gap_ratio   = 0.62,
                         base_angle  = 45,
                         cross_after = 3L,
                         roughness   = 0.5,
                         bowing      = 0.3,
                         min_gap_in  = 0.012,
                         seed        = NULL,
                         ...) {
    if (nrow(data) < 3L) return(nullGrob())
    seed <- resolve_seed(seed)

    pts <- coord$transform(data, panel_params)
    rings <- list(list(x = pts$x, y = pts$y))

    # Constant tone across the region (the `tone` aesthetic, clamped to [0,1]).
    tone  <- pmin(1, pmax(0, data$tone[1L]))
    field <- function(xn, yn) rep(tone, length(xn))

    first <- data[1L, , drop = FALSE]
    sketch_engrave_grob(
      rings = rings, field = field,
      ladder_levels = as.integer(levels),
      ladder_base_gap = base_gap, ladder_gap_ratio = gap_ratio,
      ladder_base_angle = base_angle, ladder_cross_after = as.integer(cross_after),
      roughness = roughness, bowing = bowing, seed = seed,
      min_gap_in = min_gap_in,
      gp = gpar(col = scales::alpha(first$colour, first$alpha),
                lwd = first$linewidth * ggplot2::.pt, lineend = "round")
    )
  }
)

# ---- constructors -----------------------------------------------------------

#' Sketchy engraving: tonal shading by hatch-line density
#'
#' `geom_sketch_engrave()` shades a surface the way an etcher or banknote
#' engraver does: continuous tone is built from the *density* of hand-drawn hatch
#' lines, with cross-hatching deepening the shadows. It takes a regular grid of
#' `x`, `y`, and `z` (like [ggplot2::geom_raster()]); `z` is mapped to tone (high
#' = dark by default). Unlike the fill-pattern packages, the tone is *computed*
#' from geometry (a [engrave_fill()] ladder), not tiled from a motif.
#'
#' `geom_sketch_shade()` shades each polygon region with a *uniform* density set
#' by a `tone` aesthetic in `[0, 1]`, so a mapped value reads directly as
#' darkness -- a hand-drawn alternative to a solid fill scale.
#'
#' The hatch ladder is a stack of layers of increasing density and rotating
#' angle (`levels`, `base_gap`, `gap_ratio`, `base_angle`, `cross_after`); each
#' layer is drawn only where the tone reaches its threshold, so light areas keep
#' the sparse base layer and shadows accumulate every layer. `min_gap_in` is a
#' pitch floor (inches) that keeps the darkest tones from exploding into a
#' runaway number of strokes.
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()].
#'   `geom_sketch_engrave()` needs `x`, `y`, `z`; `geom_sketch_shade()` needs
#'   `x`, `y` and uses the `tone` aesthetic (default 0.6).
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param levels Number of hatch layers in the ladder. Default 5.
#' @param base_gap Pitch of the sparsest layer (npc-x fraction). Default 0.08.
#' @param gap_ratio Multiplicative pitch shrink per layer (smaller = densens
#'   faster). Default 0.62.
#' @param base_angle Angle of the first hatch layer (degrees). Default 45.
#' @param cross_after Layer index at which cross-hatching begins. Default 3.
#' @param reverse (`geom_sketch_engrave()` only) Invert the tone mapping so low
#'   `z` is dark. Default `FALSE`.
#' @param roughness Non-negative stroke roughness. Default 0.5.
#' @param bowing Non-negative bowing multiplier. Default 0.3.
#' @param min_gap_in Pitch floor in inches; finer ladder layers are dropped.
#'   Default 0.012.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend?
#' @param inherit.aes Override default aesthetics?
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(faithfuld, aes(waiting, eruptions, z = density)) +
#'   geom_sketch_engrave(seed = 1L) +
#'   theme_sketch()
geom_sketch_engrave <- function(mapping     = NULL,
                                data        = NULL,
                                stat        = "identity",
                                position    = "identity",
                                ...,
                                levels      = 5L,
                                base_gap    = 0.08,
                                gap_ratio   = 0.62,
                                base_angle  = 45,
                                cross_after = 3L,
                                reverse     = FALSE,
                                roughness   = 0.5,
                                bowing      = 0.3,
                                min_gap_in  = 0.012,
                                seed        = NULL,
                                na.rm       = FALSE,
                                show.legend = NA,
                                inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchEngrave,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      levels = as.integer(levels), base_gap = base_gap, gap_ratio = gap_ratio,
      base_angle = base_angle, cross_after = as.integer(cross_after),
      reverse = reverse, roughness = roughness, bowing = bowing,
      min_gap_in = min_gap_in, seed = seed, na.rm = na.rm, ...
    )
  )
}

#' @rdname geom_sketch_engrave
#' @export
geom_sketch_shade <- function(mapping     = NULL,
                              data        = NULL,
                              stat        = "identity",
                              position    = "identity",
                              ...,
                              levels      = 5L,
                              base_gap    = 0.08,
                              gap_ratio   = 0.62,
                              base_angle  = 45,
                              cross_after = 3L,
                              roughness   = 0.5,
                              bowing      = 0.3,
                              min_gap_in  = 0.012,
                              seed        = NULL,
                              na.rm       = FALSE,
                              show.legend = NA,
                              inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchShade,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      levels = as.integer(levels), base_gap = base_gap, gap_ratio = gap_ratio,
      base_angle = base_angle, cross_after = as.integer(cross_after),
      roughness = roughness, bowing = bowing,
      min_gap_in = min_gap_in, seed = seed, na.rm = na.rm, ...
    )
  )
}
