# Layer 3 - geom_sketch_rug() (Tier 2)
# Marginal rug: short roughened ticks along the panel edges, one per observation.
# `sides` selects which edges (t/r/b/l); ticks are drawn in npc space since we
# already have the panel edges.

# ---- GeomSketchRug ----------------------------------------------------------

#' @rdname geom_sketch_rug
#' @export
GeomSketchRug <- ggplot2::ggproto(
  "GeomSketchRug", ggplot2::Geom,

  optional_aes = c("x", "y"),

  default_aes = ggplot2::aes(colour = "black", linewidth = 0.5, linetype = 1,
                             alpha = NA),

  draw_key = draw_key_sketch_path,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "sides", "length", "na.rm")
  },

  draw_panel = function(data, panel_params, coord,
                         sides     = "bl",
                         length    = 0.03,
                         roughness = 1,
                         bowing    = 1,
                         n_passes  = 2L,
                         seed      = NULL,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp     <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    coords <- coord$transform(data, panel_params)
    L      <- length
    grobs  <- list()

    one_seg <- function(x0, y0, x1, y1, off) {
      sketch_path_grob(
        x = c(x0, x1), y = c(y0, y1),
        roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, off),
        gp = outline_gpar(coords$colour[1L], coords$linewidth[1L],
                          coords$linetype[1L], coords$alpha[1L])
      )
    }

    if (!is.null(coords$x)) {
      xv <- coords$x
      if (grepl("b", sides)) for (i in seq_along(xv))
        grobs[[length(grobs) + 1L]] <- one_seg(xv[i], 0, xv[i], L, i * 11L)
      if (grepl("t", sides)) for (i in seq_along(xv))
        grobs[[length(grobs) + 1L]] <- one_seg(xv[i], 1 - L, xv[i], 1, i * 13L)
    }
    if (!is.null(coords$y)) {
      yv <- coords$y
      if (grepl("l", sides)) for (i in seq_along(yv))
        grobs[[length(grobs) + 1L]] <- one_seg(0, yv[i], L, yv[i], i * 17L)
      if (grepl("r", sides)) for (i in seq_along(yv))
        grobs[[length(grobs) + 1L]] <- one_seg(1 - L, yv[i], 1, yv[i], i * 19L)
    }

    if (length(grobs) == 0L) return(nullGrob())
    do.call(gList, grobs)
  }
)

# ---- geom_sketch_rug --------------------------------------------------------

#' Sketchy marginal rug
#'
#' Draws short hand-drawn ticks along the panel edges, one per observation - the
#' sketch analogue of [ggplot2::geom_rug()]. Maps the `x` and/or `y` aesthetics.
#'
#' @inheritParams geom_sketch_path
#' @param sides Which edges to draw on: any of `"t"`, `"r"`, `"b"`, `"l"`
#'   combined in a string. Default `"bl"` (bottom + left).
#' @param length Tick length as a fraction of the panel (npc). Default `0.03`.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_sketch_point(seed = 1L) +
#'   geom_sketch_rug(seed = 2L) +
#'   theme_sketch()
geom_sketch_rug <- function(mapping     = NULL,
                            data        = NULL,
                            stat        = "identity",
                            position    = "identity",
                            ...,
                            sides       = "bl",
                            length      = 0.03,
                            roughness   = 1,
                            bowing      = 1,
                            n_passes    = 2L,
                            seed        = NULL,
                            na.rm       = FALSE,
                            show.legend = NA,
                            inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchRug,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      sides = sides, length = length,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
