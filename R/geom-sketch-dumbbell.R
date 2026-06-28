# Layer 3 - geom_sketch_dumbbell() (v2.0)
# A dumbbell / connected-dot chart: a roughened connector from `x` to `xend`
# on a shared `y`, capped with a sketch point at each end. Composes the existing
# connector (sketch_path_grob) and dot (sketch_point_grob) grobs, so no new
# geometry. The sketch take on the paired-value chart (cf. ggalt::geom_dumbbell()).

# ---- GeomSketchDumbbell ------------------------------------------------------

#' @rdname geom_sketch_dumbbell
#' @export
GeomSketchDumbbell <- ggplot2::ggproto(
  "GeomSketchDumbbell", ggplot2::Geom,

  required_aes = c("x", "xend", "y"),

  default_aes = ggplot2::aes(
    colour    = "grey50",
    linewidth = 0.5,
    linetype  = 1,
    size      = 2.5,
    alpha     = NA
  ),

  draw_key = draw_key_sketch_point,

  parameters = function(self, extra = FALSE) {
    c("colour_x", "colour_xend", "roughness", "point_roughness",
      "bowing", "n_passes", "seed", "na.rm")
  },

  draw_panel = function(data, panel_params, coord,
                         colour_x        = NULL,
                         colour_xend     = NULL,
                         roughness       = 0.6,
                         point_roughness = 0.4,
                         bowing          = 0.4,
                         n_passes        = 2L,
                         seed            = NULL,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    left  <- coord$transform(data.frame(x = data$x,    y = data$y), panel_params)
    right <- coord$transform(data.frame(x = data$xend, y = data$y), panel_params)

    # --- connectors (one roughened path per row) ---
    conns <- lapply(seq_len(nrow(data)), function(i) {
      sketch_path_grob(
        x = c(left$x[i], right$x[i]), y = c(left$y[i], right$y[i]),
        roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, i * 53L),
        gp = outline_gpar(
          colour = data$colour[i], linewidth = data$linewidth[i],
          linetype = data$linetype[i], alpha = data$alpha[i]
        )
      )
    })

    # --- end dots (left at x, right at xend) ---
    col_x    <- colour_x    %||% data$colour
    col_xend <- colour_xend %||% data$colour

    dot <- function(px, py, col, off) {
      sketch_point_grob(
        x = px, y = py, size = data$size,
        roughness = point_roughness, n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, off),
        gp = gpar(
          col = scales::alpha(col, data$alpha),
          lwd = data$linewidth * ggplot2::.pt, lineend = "round"
        )
      )
    }

    do.call(gList, c(
      conns,
      list(dot(left$x,  left$y,  col_x,    7000L),
           dot(right$x, right$y, col_xend, 9000L))
    ))
  }
)

# ---- geom_sketch_dumbbell ----------------------------------------------------

#' Sketchy dumbbell chart
#'
#' Draws a hand-drawn dumbbell: a roughened connector from `x` to `xend` on a
#' shared `y`, capped with a sketch point at each end. Ideal for showing the
#' change or gap between two paired values per category (cf.
#' `ggalt::geom_dumbbell()`).
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`,
#'   `xend` and `y`.
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param colour_x Colour of the dot at `x`. Default `NULL` (uses `colour`).
#' @param colour_xend Colour of the dot at `xend`. Default `NULL` (uses
#'   `colour`).
#' @param roughness Connector roughness (0 = straight). Default 0.6.
#' @param point_roughness Roughness of the end dots. Default 0.4.
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
#' df <- data.frame(g = c("Alpha", "Bravo", "Charlie", "Delta"),
#'                  before = c(20, 35, 28, 42),
#'                  after  = c(34, 51, 22, 47))
#' ggplot(df, aes(x = before, xend = after, y = g)) +
#'   geom_sketch_dumbbell(colour_x = "#B03A2E", colour_xend = "#1F618D",
#'                        seed = 1L) +
#'   theme_sketch()
geom_sketch_dumbbell <- function(mapping         = NULL,
                                 data            = NULL,
                                 stat            = "identity",
                                 position        = "identity",
                                 ...,
                                 colour_x        = NULL,
                                 colour_xend     = NULL,
                                 roughness       = 0.6,
                                 point_roughness = 0.4,
                                 bowing          = 0.4,
                                 n_passes        = 2L,
                                 seed            = NULL,
                                 na.rm           = FALSE,
                                 show.legend     = NA,
                                 inherit.aes     = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchDumbbell,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      colour_x = colour_x, colour_xend = colour_xend,
      roughness = roughness, point_roughness = point_roughness,
      bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
