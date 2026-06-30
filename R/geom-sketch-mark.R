# Layer 3 - geom_sketch_mark_hull() (v1.7 annotation toolkit)
# A roughened convex hull drawn around each group of points - the sketch
# analogue of ggforce::geom_mark_hull(), for circling/grouping clusters. Reuses
# sketch_polygon_grob() so it inherits the fill styles and solid/outline logic.

# ---- GeomSketchMarkHull -----------------------------------------------------

#' @rdname geom_sketch_mark_hull
#' @export
GeomSketchMarkHull <- ggplot2::ggproto(
  "GeomSketchMarkHull", ggplot2::Geom,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    colour    = "black",
    fill      = NA,
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA
  ),

  draw_key = draw_key_sketch_polygon,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "expand",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight", "na.rm")
  },

  draw_group = function(data, panel_params, coord,
                         expand        = 0.05,
                         roughness     = 1,
                         bowing        = 1,
                         n_passes      = 2L,
                         seed          = NULL,
                         fill_style    = "hachure",
                         hachure_angle = 45,
                         hachure_gap   = 0.07,
                         fill_weight   = 0.5,
                         ...) {
    # A hull needs at least a triangle.
    if (nrow(data) < 3L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    hull <- grDevices::chull(data$x, data$y)
    hx   <- data$x[hull]
    hy   <- data$y[hull]

    # Expand the hull outward from its centroid so the mark sits around (not on)
    # the points. `expand` is a fractional inflation.
    ccx <- mean(hx); ccy <- mean(hy)
    hx  <- ccx + (hx - ccx) * (1 + expand)
    hy  <- ccy + (hy - ccy) * (1 + expand)

    pts <- coord$transform(data.frame(x = hx, y = hy), panel_params)

    has_fill   <- !all(is.na(data$fill))
    fill_style <- if (has_fill) fill_style else "solid"

    sketch_polygon_grob(
      x             = pts$x,
      y             = pts$y,
      roughness     = sp$roughness,
      bowing        = sp$bowing,
      n_passes      = sp$n_passes,
      seed          = sp$seed,
      fill_style    = fill_style,
      hachure_angle = hachure_angle,
      hachure_gap   = hachure_gap,
      fill_weight   = fill_weight,
      fill_gp       = gpar(col = scales::alpha(data$fill[1L], data$alpha[1L]),
                           lineend = "round"),
      outline_gp    = gpar(col = scales::alpha(data$colour[1L], data$alpha[1L]),
                           lwd = data$linewidth[1L] * ggplot2::.pt,
                           lty = data$linetype[1L],
                           lineend = "round", linejoin = "round")
    )
  }
)

# ---- geom_sketch_mark_hull --------------------------------------------------

#' Sketchy hull marks around point groups
#'
#' Draws a hand-drawn convex hull around each group of points - the sketch
#' analogue of `ggforce::geom_mark_hull()`, for circling or grouping clusters.
#' Group the points with an aesthetic such as `group`, `colour`, or `fill`; each
#' group gets its own hull. With `fill` mapped the hull is shaded (using
#' `fill_style`); otherwise it is outline-only.
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`
#'   and `y`; map `group`/`colour`/`fill` to separate the clusters.
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param expand Fractional outward inflation of the hull from its centroid, so
#'   the mark sits around the points rather than through them. Default `0.05`.
#' @param roughness Non-negative roughness (0 = clean). Default 1.
#' @param bowing Non-negative bowing multiplier. Default 1.
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param fill_style Fill style when `fill` is mapped: `"hachure"`,
#'   `"cross_hatch"`, `"zigzag"`, `"scribble"`, `"dots"`, `"dashed"`, `"stipple"`, `"pencil_shade"`, or
#'   `"solid"`. Default `"hachure"`.
#' @param hachure_angle Fill line angle in degrees. Default 45.
#' @param hachure_gap Fill line gap (npc fraction). Default 0.07.
#' @param fill_weight Stroke weight for fill lines. Default 0.5.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend?
#' @param inherit.aes Override default aesthetics?
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, colour = Species)) +
#'   geom_sketch_mark_hull(aes(fill = Species), expand = 0.08, seed = 1L) +
#'   geom_sketch_point(seed = 2L) +
#'   theme_sketch()
geom_sketch_mark_hull <- function(mapping       = NULL,
                                  data          = NULL,
                                  stat          = "identity",
                                  position      = "identity",
                                  ...,
                                  expand        = 0.05,
                                  roughness     = 1,
                                  bowing        = 1,
                                  n_passes      = 2L,
                                  seed          = NULL,
                                  fill_style    = "hachure",
                                  hachure_angle = 45,
                                  hachure_gap   = 0.07,
                                  fill_weight   = 0.5,
                                  na.rm         = FALSE,
                                  show.legend   = NA,
                                  inherit.aes   = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchMarkHull,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      expand = expand, roughness = roughness, bowing = bowing,
      n_passes = as.integer(n_passes), seed = seed, fill_style = fill_style,
      hachure_angle = hachure_angle, hachure_gap = hachure_gap,
      fill_weight = fill_weight, na.rm = na.rm, ...
    )
  )
}
