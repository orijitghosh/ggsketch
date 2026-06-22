# Layer 3 - geom_sketch_count() (Tier 2)
# Sketch points sized by the number of overplotted observations (stat_sum).

#' Sketchy count geom
#'
#' Like [ggplot2::geom_count()]: draws a sketch point at each `(x, y)` location
#' sized by the number of observations there, via [ggplot2::stat_sum()]. Pair
#' with [ggplot2::scale_size_area()] for honest area scaling.
#'
#' @inheritParams geom_sketch_point
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mpg, aes(cty, hwy)) +
#'   geom_sketch_count(colour = "#7BAFD4", seed = 1L) +
#'   theme_sketch()
geom_sketch_count <- function(mapping     = NULL,
                              data        = NULL,
                              stat        = "sum",
                              position    = "identity",
                              ...,
                              roughness   = 0.5,
                              bowing      = 1,
                              n_passes    = 2L,
                              seed        = NULL,
                              na.rm       = FALSE,
                              show.legend = NA,
                              inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchPoint,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
