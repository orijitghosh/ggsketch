# Layer 3 - geom_sketch_ribbon() / geom_sketch_area() (P4-T2)
# A ribbon is the band between ymin and ymax; an area is a ribbon anchored at 0.
# The band is assembled into one closed polygon (top edge forward, bottom edge
# reversed) and handed to sketch_polygon_grob() for fill + rough outline.

# ---- GeomSketchRibbon -------------------------------------------------------

#' @rdname geom_sketch_ribbon
#' @export
GeomSketchRibbon <- ggplot2::ggproto(
  "GeomSketchRibbon", ggplot2::Geom,

  required_aes = c("x", "ymin", "ymax"),

  default_aes = ggplot2::aes(
    colour    = NA,
    fill      = "grey60",
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
    if (nrow(data) < 2L) return(nullGrob())

    data <- data[order(data$x), , drop = FALSE]

    # Closed polygon: top edge (x, ymax) forward, bottom edge (x, ymin) back.
    poly <- data.frame(
      x = c(data$x, rev(data$x)),
      y = c(data$ymax, rev(data$ymin))
    )
    coords <- coord$transform(poly, panel_params)
    sp     <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    gap <- hachure_gap %||%
      (0.06 * sqrt(diff(range(coords$x))^2 + diff(range(coords$y))^2))
    gap <- max(gap, 1e-3)

    first    <- data[1L, , drop = FALSE]
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

# ---- geom_sketch_ribbon -----------------------------------------------------

#' Sketchy ribbon and area geoms
#'
#' `geom_sketch_ribbon()` draws a hand-drawn band between `ymin` and `ymax`.
#' `geom_sketch_area()` is the special case anchored at zero (`ymin = 0`,
#' `ymax = y`).  Both use a roughened outline and a hachure-style fill, the
#' sketch analogues of [ggplot2::geom_ribbon()] / [ggplot2::geom_area()].
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
#'   `"zigzag_line"`, `"scribble"`, `"dots"`, `"dashed"`, or `"solid"`. Default `"hachure"`.
#' @param hachure_angle Fill line angle in degrees. Default 45.
#' @param hachure_gap Fill line gap in npc units (`NULL` = 6% of diagonal).
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
#' df <- data.frame(x = 1:10, lo = (1:10) - 2, hi = (1:10) + 2)
#' ggplot(df, aes(x)) +
#'   geom_sketch_ribbon(aes(ymin = lo, ymax = hi), fill = "plum", seed = 1L) +
#'   theme_sketch()
geom_sketch_ribbon <- function(mapping       = NULL,
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
    geom        = GeomSketchRibbon,
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

# ---- GeomSketchArea ---------------------------------------------------------

#' @rdname geom_sketch_ribbon
#' @export
GeomSketchArea <- ggplot2::ggproto(
  "GeomSketchArea", GeomSketchRibbon,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    colour    = NA,
    fill      = "grey60",
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA
  ),

  setup_data = function(data, params) {
    data$ymin <- 0
    data$ymax <- data$y
    data[order(data$PANEL, data$group, data$x), , drop = FALSE]
  }
)

#' @rdname geom_sketch_ribbon
#' @export
geom_sketch_area <- function(mapping       = NULL,
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
    geom        = GeomSketchArea,
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
