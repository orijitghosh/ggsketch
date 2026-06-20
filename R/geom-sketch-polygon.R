# Layer 3 — geom_sketch_polygon() (P4-T1)
# Concave-safe hachure fill + rough outline. Exercises the AET scan-line fill
# (P1-T7) on arbitrary polygons via sketch_polygon_grob().

# ---- GeomSketchPolygon ------------------------------------------------------

#' @rdname geom_sketch_polygon
#' @export
GeomSketchPolygon <- ggplot2::ggproto(
  "GeomSketchPolygon", ggplot2::Geom,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    colour    = "black",
    fill      = "grey65",
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA
  ),

  draw_key = draw_key_sketch_polygon,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight", "na.rm")
  },

  draw_group = function(data, panel_params, coord,
                         roughness     = 1,
                         bowing        = 1,
                         n_passes      = 2L,
                         seed          = NULL,
                         fill_style    = "hachure",
                         hachure_angle = 45,
                         hachure_gap   = NULL,
                         fill_weight   = 0.5,
                         ...) {
    n <- nrow(data)
    if (n < 3L) return(nullGrob())

    coords <- coord$transform(data, panel_params)
    sp     <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    # Gap default: 7% of the polygon's npc diagonal extent.
    gap <- hachure_gap %||%
      (0.07 * sqrt(diff(range(coords$x))^2 + diff(range(coords$y))^2))
    gap <- max(gap, 1e-3)

    first <- data[1L, , drop = FALSE]
    fill_col <- scales::alpha(first$fill, first$alpha)
    out_col  <- scales::alpha(first$colour, first$alpha)

    sketch_polygon_grob(
      x             = coords$x,
      y             = coords$y,
      roughness     = sp$roughness,
      bowing        = sp$bowing,
      n_passes      = sp$n_passes,
      seed          = sp$seed,
      fill_style    = fill_style,
      hachure_angle = hachure_angle,
      hachure_gap   = gap,
      fill_weight   = fill_weight,
      fill_gp       = gpar(col = fill_col, lineend = "round"),
      outline_gp    = gpar(
        col = out_col,
        lwd = first$linewidth * ggplot2::.pt,
        lty = first$linetype,
        lineend = "round",
        linejoin = "round"
      )
    )
  }
)

# ---- geom_sketch_polygon ----------------------------------------------------

#' Sketchy polygon geom
#'
#' Draws closed polygons with a hand-drawn roughened outline and a hachure /
#' cross-hatch / zigzag / dots / dashed / solid fill.  Concave polygons are
#' filled correctly via the Active-Edge-Table scan-line algorithm.  Equivalent
#' to [ggplot2::geom_polygon()] with a sketch aesthetic.
#'
#' @param mapping Set of aesthetic mappings created by [ggplot2::aes()].
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param roughness Non-negative roughness (0 = straight). Default 1.
#' @param bowing Non-negative bowing multiplier. Default 1.
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param fill_style One of `"hachure"`, `"cross_hatch"`, `"zigzag"`,
#'   `"zigzag_line"`, `"dots"`, `"dashed"`, or `"solid"`. Default `"hachure"`.
#' @param hachure_angle Fill line angle in degrees. Default 45.
#' @param hachure_gap Fill line gap in npc units (`NULL` = 7% of diagonal).
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
#' tri <- data.frame(x = c(0, 1, 0.5), y = c(0, 0, 1))
#' ggplot(tri, aes(x, y)) +
#'   geom_sketch_polygon(fill = "skyblue", seed = 1L) +
#'   theme_sketch()
geom_sketch_polygon <- function(mapping       = NULL,
                                 data          = NULL,
                                 stat          = "identity",
                                 position      = "identity",
                                 ...,
                                 roughness     = 1,
                                 bowing        = 1,
                                 n_passes      = 2L,
                                 seed          = NULL,
                                 fill_style    = "hachure",
                                 hachure_angle = 45,
                                 hachure_gap   = NULL,
                                 fill_weight   = 0.5,
                                 na.rm         = FALSE,
                                 show.legend   = NA,
                                 inherit.aes   = TRUE) {
  ggplot2::layer(
    data        = data,
    mapping     = mapping,
    stat        = stat,
    geom        = GeomSketchPolygon,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = list(
      roughness     = roughness,
      bowing        = bowing,
      n_passes      = as.integer(n_passes),
      seed          = seed,
      fill_style    = fill_style,
      hachure_angle = hachure_angle,
      hachure_gap   = hachure_gap,
      fill_weight   = fill_weight,
      na.rm         = na.rm,
      ...
    )
  )
}
