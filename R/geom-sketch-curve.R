# Layer 3 - geom_sketch_curve() (Tier 2)
# A curved connector from (x, y) to (xend, yend). We sample a quadratic Bezier
# in transformed (npc) space - so the curvature reads consistently regardless of
# data aspect - and hand the polyline to sketch_path_grob, which re-roughens it
# in device space (honouring R4: roughening happens in device inches).

# ---- GeomSketchCurve --------------------------------------------------------

#' @rdname geom_sketch_curve
#' @export
GeomSketchCurve <- ggplot2::ggproto(
  "GeomSketchCurve", ggplot2::Geom,

  required_aes = c("x", "y", "xend", "yend"),

  default_aes = ggplot2::aes(colour = "black", linewidth = 0.5, linetype = 1,
                             alpha = NA),

  draw_key = draw_key_sketch_path,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "curvature", "na.rm")
  },

  draw_panel = function(data, panel_params, coord,
                         curvature = 0.5,
                         roughness = 1,
                         bowing    = 1,
                         n_passes  = 2L,
                         seed      = NULL,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    t  <- seq(0, 1, length.out = 50L)

    grobs <- lapply(seq_len(nrow(data)), function(i) {
      row <- data[i, , drop = FALSE]
      p   <- coord$transform(
        data.frame(x = c(row$x, row$xend), y = c(row$y, row$yend)),
        panel_params
      )
      x0 <- p$x[1L]; y0 <- p$y[1L]; x1 <- p$x[2L]; y1 <- p$y[2L]
      # Control point: midpoint offset perpendicular to the chord.
      mx <- (x0 + x1) / 2; my <- (y0 + y1) / 2
      dx <- x1 - x0;       dy <- y1 - y0
      cx <- mx - dy * curvature * 0.5
      cy <- my + dx * curvature * 0.5
      # Quadratic Bezier sample.
      bx <- (1 - t)^2 * x0 + 2 * (1 - t) * t * cx + t^2 * x1
      by <- (1 - t)^2 * y0 + 2 * (1 - t) * t * cy + t^2 * y1

      sketch_path_grob(
        x = bx, y = by,
        roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, i * 53L),
        gp = outline_gpar(row$colour, row$linewidth, row$linetype, row$alpha)
      )
    })
    do.call(gList, grobs)
  }
)

# ---- geom_sketch_curve ------------------------------------------------------

#' Sketchy curved connector
#'
#' Draws a hand-drawn curved segment from `(x, y)` to `(xend, yend)` - the sketch
#' analogue of [ggplot2::geom_curve()]. The curve is a quadratic Bezier whose
#' bend is controlled by `curvature`.
#'
#' @inheritParams geom_sketch_segment
#' @param curvature Amount of bend. `0` is a straight line; positive curves to
#'   one side, negative to the other. Default `0.5`.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(x = 1, y = 1, xend = 3, yend = 3)
#' ggplot(df, aes(x, y)) +
#'   geom_sketch_curve(aes(xend = xend, yend = yend), curvature = 0.4,
#'                     seed = 1L) +
#'   theme_sketch()
geom_sketch_curve <- function(mapping     = NULL,
                              data        = NULL,
                              stat        = "identity",
                              position    = "identity",
                              ...,
                              curvature   = 0.5,
                              roughness   = 1,
                              bowing      = 1,
                              n_passes    = 2L,
                              seed        = NULL,
                              na.rm       = FALSE,
                              show.legend = NA,
                              inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchCurve,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      curvature = curvature,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
