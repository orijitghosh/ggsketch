# Layer 3 - geom_sketch_function() (Tier 2)
# Sketch a function curve over the x range using stat_function, drawn as a
# roughened path. Great for teaching / annotating analytic curves.

#' Sketchy function curve
#'
#' Draws the curve of a function `y = fun(x)` with a hand-drawn stroke - the
#' sketch analogue of [ggplot2::geom_function()], built on
#' [ggplot2::stat_function()].
#'
#' @inheritParams geom_sketch_path
#' @param fun Function to evaluate, or its name as a string.
#' @param xlim Optional numeric range over which to evaluate `fun`; defaults to
#'   the panel x range.
#' @param n Number of points to sample along the curve. Default 101.
#' @param args List of extra arguments passed to `fun`.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(data.frame(x = c(-3, 3)), aes(x)) +
#'   geom_sketch_function(fun = dnorm, colour = "#7BAFD4", seed = 1L) +
#'   theme_sketch()
geom_sketch_function <- function(mapping     = NULL,
                                 data        = NULL,
                                 stat        = "function",
                                 position    = "identity",
                                 ...,
                                 fun         = NULL,
                                 xlim        = NULL,
                                 n           = 101,
                                 args        = list(),
                                 roughness   = 1,
                                 bowing      = 1,
                                 n_passes    = 2L,
                                 seed        = NULL,
                                 na.rm       = FALSE,
                                 show.legend = NA,
                                 inherit.aes = FALSE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchPath,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      fun = fun, xlim = xlim, n = n, args = args,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
