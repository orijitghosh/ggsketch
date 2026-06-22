# Layer 3 - geom_sketch_qq() / geom_sketch_qq_line() (Tier 2)
# Quantile-quantile plot: points (stat_qq) plus a reference line (stat_qq_line).
# Both reuse existing grobs; the only required aesthetic is `sample`.

#' Sketchy quantile-quantile plot
#'
#' `geom_sketch_qq()` draws Q-Q points (the sketch analogue of
#' [ggplot2::geom_qq()] / [ggplot2::stat_qq()]); `geom_sketch_qq_line()` adds the
#' reference line ([ggplot2::geom_qq_line()]). Map the data to the `sample`
#' aesthetic.
#'
#' @inheritParams geom_sketch_point
#' @param distribution Quantile function for the theoretical distribution.
#'   Default [stats::qnorm].
#' @param dparams List of parameters for `distribution`.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(sample = mpg)) +
#'   geom_sketch_qq(seed = 1L) +
#'   geom_sketch_qq_line(colour = "#C8553D", seed = 2L) +
#'   theme_sketch()
geom_sketch_qq <- function(mapping      = NULL,
                           data         = NULL,
                           stat         = "qq",
                           position     = "identity",
                           ...,
                           distribution = stats::qnorm,
                           dparams      = list(),
                           roughness    = 0.5,
                           bowing       = 1,
                           n_passes     = 2L,
                           seed         = NULL,
                           na.rm        = FALSE,
                           show.legend  = NA,
                           inherit.aes  = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchPoint,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      distribution = distribution, dparams = dparams,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}

#' @rdname geom_sketch_qq
#' @export
geom_sketch_qq_line <- function(mapping      = NULL,
                                data         = NULL,
                                stat         = "qq_line",
                                position     = "identity",
                                ...,
                                distribution = stats::qnorm,
                                dparams      = list(),
                                roughness    = 0.6,
                                bowing       = 0.5,
                                n_passes     = 2L,
                                seed         = NULL,
                                na.rm        = FALSE,
                                show.legend  = NA,
                                inherit.aes  = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchPath,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      distribution = distribution, dparams = dparams,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
