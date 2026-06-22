# Layer 3 - geom_sketch_jitter() (Tier 1)
# geom_sketch_point() with a jitter position adjustment, to spread overplotted
# points (the sketch analogue of geom_jitter()).

#' Sketchy jittered points
#'
#' A convenience wrapper around [geom_sketch_point()] that adds a small amount of
#' random position noise to reduce overplotting - the sketch analogue of
#' [ggplot2::geom_jitter()].
#'
#' @inheritParams geom_sketch_point
#' @param width,height Amount of horizontal/vertical jitter (passed to
#'   [ggplot2::position_jitter()]). `NULL` uses 40% of the data resolution.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mpg, aes(class, hwy)) +
#'   geom_sketch_jitter(width = 0.25, seed = 1L) +
#'   theme_sketch()
geom_sketch_jitter <- function(mapping     = NULL,
                                data        = NULL,
                                stat        = "identity",
                                position    = NULL,
                                ...,
                                width       = NULL,
                                height      = NULL,
                                roughness   = NULL,
                                bowing      = 1,
                                n_passes    = 2L,
                                seed        = NULL,
                                na.rm       = FALSE,
                                show.legend = NA,
                                inherit.aes = TRUE) {
  if (is.null(position)) {
    position <- ggplot2::position_jitter(
      width = width, height = height,
      seed = if (is.null(seed)) NA else seed
    )
  }
  # roughness is a mappable aesthetic (inherited from GeomSketchPoint): only push
  # a constant when supplied, so it never clobbers an aes(roughness = ) mapping.
  params <- list(
    bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed, na.rm = na.rm, ...
  )
  if (!is.null(roughness)) params$roughness <- roughness
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchPoint,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = params
  )
}
