# Layer 3 — geom_sketch_contour() / geom_sketch_density2d() (Tier 3)
# Contour lines (stat_contour) and 2-D kernel-density contours (stat_density_2d)
# are both grouped paths — one roughened polyline per contour piece. Both reuse
# GeomSketchPath, so no new core geometry is needed.

#' Sketchy contour lines
#'
#' `geom_sketch_contour()` draws contour lines of a 3-D surface with a hand-drawn
#' stroke (the sketch analogue of [ggplot2::geom_contour()] /
#' [ggplot2::stat_contour()]); it needs `x`, `y`, and `z` aesthetics. Each
#' contour piece becomes one roughened path.
#'
#' @inheritParams geom_sketch_path
#' @param bins Number of contour bins. Overridden by `binwidth` or `breaks`.
#' @param binwidth Distance between contour bins.
#' @param breaks Explicit numeric contour breaks; overrides `bins`/`binwidth`.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(faithfuld, aes(waiting, eruptions, z = density)) +
#'   geom_sketch_contour(colour = "#2E4053", seed = 1L) +
#'   theme_sketch()
geom_sketch_contour <- function(mapping     = NULL,
                                data        = NULL,
                                stat        = "contour",
                                position    = "identity",
                                ...,
                                bins        = NULL,
                                binwidth    = NULL,
                                breaks      = NULL,
                                roughness   = 0.7,
                                bowing      = 0.5,
                                n_passes    = 2L,
                                seed        = NULL,
                                na.rm       = FALSE,
                                show.legend = NA,
                                inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchPath,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      bins = bins, binwidth = binwidth, breaks = breaks,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}

#' Sketchy 2-D density contours
#'
#' `geom_sketch_density2d()` (alias `geom_sketch_density_2d()`) draws contour
#' lines of a 2-D kernel density estimate with a hand-drawn stroke — the sketch
#' analogue of [ggplot2::geom_density_2d()] / [ggplot2::stat_density_2d()]. Needs
#' `x` and `y` aesthetics. Uses \pkg{MASS} (pulled in by ggplot2).
#'
#' @inheritParams geom_sketch_path
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examplesIf requireNamespace("MASS", quietly = TRUE)
#' library(ggplot2)
#' ggplot(faithful, aes(eruptions, waiting)) +
#'   geom_sketch_point(colour = "grey60", seed = 1L) +
#'   geom_sketch_density2d(colour = "#884EA0", seed = 2L) +
#'   theme_sketch()
geom_sketch_density2d <- function(mapping     = NULL,
                                  data        = NULL,
                                  stat        = "density_2d",
                                  position    = "identity",
                                  ...,
                                  roughness   = 0.7,
                                  bowing      = 0.5,
                                  n_passes    = 2L,
                                  seed        = NULL,
                                  na.rm       = FALSE,
                                  show.legend = NA,
                                  inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchPath,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}

#' @rdname geom_sketch_density2d
#' @export
geom_sketch_density_2d <- geom_sketch_density2d
