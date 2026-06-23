# Layer 3 - geom_sketch_ecdf() (v1.7)
# Empirical cumulative distribution function: stat_ecdf produces a sorted step
# series, drawn as one roughened stairstep per group. Reuses GeomSketchStep, so
# no new geometry. Sketch analogue of ggplot2::geom_step(stat = "ecdf").

#' Sketchy empirical cumulative distribution
#'
#' `geom_sketch_ecdf()` draws the empirical CDF of a continuous variable as a
#' hand-drawn stairstep - the sketch analogue of [ggplot2::stat_ecdf()] /
#' `geom_step(stat = "ecdf")`. Needs an `x` aesthetic; each group gets its own
#' curve.
#'
#' @inheritParams geom_sketch_segment
#' @param n If `NULL` (default), the ECDF jumps at each observed value;
#'   otherwise the curve is evaluated at `n` evenly spaced points (passed to
#'   [ggplot2::stat_ecdf()]).
#' @param pad If `TRUE`, add `-Inf`/`Inf` plateaus at the ends. Default `FALSE`
#'   (the roughened line spans the data range only, avoiding infinite
#'   coordinates).
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(mpg)) +
#'   geom_sketch_ecdf(colour = "#2E86C1", seed = 1L) +
#'   theme_sketch()
geom_sketch_ecdf <- function(mapping     = NULL,
                              data        = NULL,
                              stat        = "ecdf",
                              position    = "identity",
                              ...,
                              n           = NULL,
                              pad         = FALSE,
                              roughness   = 0.8,
                              bowing      = 0.5,
                              n_passes    = 2L,
                              seed        = NULL,
                              na.rm       = FALSE,
                              show.legend = NA,
                              inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchStep,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      n = n, pad = pad,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
