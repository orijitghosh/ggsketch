# Layer 3 - geom_sketch_spoke() (Tier 2)
# A spoke is a segment defined by an origin (x, y), an angle, and a radius.
# We compute xend/yend in setup_data and reuse GeomSketchSegment to draw.

# ---- GeomSketchSpoke --------------------------------------------------------

#' @rdname geom_sketch_spoke
#' @export
GeomSketchSpoke <- ggplot2::ggproto(
  "GeomSketchSpoke", GeomSketchSegment,

  required_aes = c("x", "y", "angle", "radius"),

  # roughness is a mappable aesthetic (inherited from GeomSketchSegment).
  parameters = function(self, extra = FALSE) {
    c("bowing", "n_passes", "seed", "radius", "angle", "na.rm")
  },

  setup_data = function(data, params) {
    data$radius <- data$radius %||% params$radius
    data$angle  <- data$angle  %||% params$angle
    transform(
      data,
      xend = x + cos(angle) * radius,
      yend = y + sin(angle) * radius
    )
  }
)

# ---- geom_sketch_spoke ------------------------------------------------------

#' Sketchy spoke geom
#'
#' Draws line segments from `(x, y)` at a given `angle` (radians) and `radius` - 
#' the sketch analogue of [ggplot2::geom_spoke()]. Handy for vector / flow
#' fields. Internally reuses [GeomSketchSegment].
#'
#' @inheritParams geom_sketch_segment
#' @param radius,angle Optional fixed `radius` / `angle` (radians) used when not
#'   supplied as aesthetics.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- expand.grid(x = 1:5, y = 1:5)
#' df$angle <- runif(nrow(df), 0, 2 * pi)
#' df$radius <- 0.5
#' ggplot(df, aes(x, y)) +
#'   geom_sketch_spoke(aes(angle = angle, radius = radius), seed = 1L) +
#'   geom_sketch_point(seed = 2L) +
#'   theme_sketch()
geom_sketch_spoke <- function(mapping     = NULL,
                              data        = NULL,
                              stat        = "identity",
                              position    = "identity",
                              ...,
                              radius      = 1,
                              angle       = 0,
                              roughness   = NULL,
                              bowing      = 1,
                              n_passes    = 2L,
                              seed        = NULL,
                              na.rm       = FALSE,
                              show.legend = NA,
                              inherit.aes = TRUE) {
  # roughness is a mappable aesthetic: only push a constant when supplied.
  params <- list(
    radius = radius, angle = angle,
    bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed, na.rm = na.rm, ...
  )
  if (!is.null(roughness)) params$roughness <- roughness
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchSpoke,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = params
  )
}
