# Layer 3 - geom_sketch_slope() (v2.0)
# A slope graph: one roughened line per `group` connecting its values across an
# ordered (usually two-level) x, with a sketch point at each vertex. Composes
# the existing line (sketch_path_grob) and dot (sketch_point_grob) grobs, so no
# new geometry. The sketch take on Tufte's slopegraph.

# ---- GeomSketchSlope ---------------------------------------------------------

#' @rdname geom_sketch_slope
#' @export
GeomSketchSlope <- ggplot2::ggproto(
  "GeomSketchSlope", ggplot2::Geom,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    colour    = "grey30",
    linewidth = 0.5,
    linetype  = 1,
    size      = 2.5,
    alpha     = NA
  ),

  draw_key = draw_key_sketch_path,

  parameters = function(self, extra = FALSE) {
    c("roughness", "point_roughness", "bowing", "n_passes", "seed", "na.rm")
  },

  draw_panel = function(data, panel_params, coord,
                         roughness       = 0.6,
                         point_roughness = 0.4,
                         bowing          = 0.4,
                         n_passes        = 2L,
                         seed            = NULL,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    data$group <- data$group %||% 1L
    groups <- split(data, data$group)

    lines <- lapply(seq_along(groups), function(gi) {
      g  <- groups[[gi]]
      g  <- g[order(g$x), , drop = FALSE]
      tp <- coord$transform(g, panel_params)
      if (nrow(tp) < 2L) return(nullGrob())
      sketch_path_grob(
        x = tp$x, y = tp$y,
        roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, gi * 53L),
        gp = outline_gpar(
          colour = g$colour[1], linewidth = g$linewidth[1],
          linetype = g$linetype[1], alpha = g$alpha[1]
        )
      )
    })

    # --- vertex dots (all groups at once) ---
    allp <- coord$transform(data, panel_params)
    dots <- sketch_point_grob(
      x = allp$x, y = allp$y, size = data$size,
      roughness = point_roughness, n_passes = sp$n_passes,
      seed = seed_offset(sp$seed, 7000L),
      gp = gpar(
        col = scales::alpha(data$colour, data$alpha),
        lwd = data$linewidth * ggplot2::.pt, lineend = "round"
      )
    )

    do.call(gList, c(lines, list(dots)))
  }
)

# ---- geom_sketch_slope -------------------------------------------------------

#' Sketchy slope graph
#'
#' Draws a hand-drawn slopegraph: one roughened line per `group` connecting its
#' values across an ordered x (commonly two categories, e.g. before/after), with
#' a sketch point at each vertex. Emphasises rank changes and rates of change
#' between a small number of timepoints (cf. Tufte's slopegraph).
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`
#'   and `y`; map `group` to the series identity (and usually `colour`).
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param roughness Line roughness (0 = straight). Default 0.6.
#' @param point_roughness Roughness of the vertex dots. Default 0.4.
#' @param bowing Non-negative bowing multiplier. Default 0.4.
#' @param n_passes Number of stroke passes. Default 2.
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
#' df <- data.frame(
#'   time  = rep(c("Before", "After"), each = 4),
#'   value = c(20, 35, 28, 42, 34, 51, 22, 47),
#'   who   = rep(c("Alpha", "Bravo", "Charlie", "Delta"), 2)
#' )
#' ggplot(df, aes(time, value, group = who, colour = who)) +
#'   geom_sketch_slope(seed = 1L) +
#'   theme_sketch()
geom_sketch_slope <- function(mapping         = NULL,
                              data            = NULL,
                              stat            = "identity",
                              position        = "identity",
                              ...,
                              roughness       = 0.6,
                              point_roughness = 0.4,
                              bowing          = 0.4,
                              n_passes        = 2L,
                              seed            = NULL,
                              na.rm           = FALSE,
                              show.legend     = NA,
                              inherit.aes     = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchSlope,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      roughness = roughness, point_roughness = point_roughness,
      bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
