# Layer 3 - geom_sketch_histogram() / geom_sketch_freqpoly() (Tier 1)
# Both bin continuous data with stat_bin; histogram draws bars (col grob),
# freqpoly connects the bin counts with a sketch path.

#' Sketchy histogram and frequency polygon
#'
#' `geom_sketch_histogram()` bins a continuous variable and draws hand-drawn bars
#' (the sketch analogue of [ggplot2::geom_histogram()]).
#' `geom_sketch_freqpoly()` draws the same bin counts as a roughened line
#' ([ggplot2::geom_freqpoly()]).
#'
#' @inheritParams geom_sketch_col
#' @param bins Number of bins (passed to [ggplot2::stat_bin()]). Default 30.
#' @param binwidth Bin width; overrides `bins` when supplied.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(faithful, aes(eruptions)) +
#'   geom_sketch_histogram(fill = "#7BAFD4", bins = 20, seed = 1L) +
#'   theme_sketch()
geom_sketch_histogram <- function(mapping       = NULL,
                                   data          = NULL,
                                   stat          = "bin",
                                   position      = "stack",
                                   ...,
                                   bins          = 30,
                                   binwidth      = NULL,
                                   roughness     = 1,
                                   bowing        = 1,
                                   n_passes      = 2L,
                                   seed          = NULL,
                                   fill_style    = "hachure",
                                   hachure_angle = 45,
                                   hachure_gap   = NULL,
                                   fill_weight   = 0.5,
                                   na.rm         = FALSE,
                                   show.legend   = NA,
                                   inherit.aes   = TRUE) {
  params <- list(
    bins = bins, binwidth = binwidth,
    roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed, fill_style = fill_style, hachure_angle = hachure_angle,
    hachure_gap = hachure_gap, fill_weight = fill_weight, na.rm = na.rm, ...
  )
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchCol,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = params
  )
}

#' @rdname geom_sketch_histogram
#' @export
geom_sketch_freqpoly <- function(mapping       = NULL,
                                  data          = NULL,
                                  stat          = "bin",
                                  position      = "identity",
                                  ...,
                                  bins          = 30,
                                  binwidth      = NULL,
                                  roughness     = 1,
                                  bowing        = 1,
                                  n_passes      = 2L,
                                  seed          = NULL,
                                  na.rm         = FALSE,
                                  show.legend   = NA,
                                  inherit.aes   = TRUE) {
  params <- list(
    bins = bins, binwidth = binwidth,
    roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed, na.rm = na.rm, ...
  )
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchPath,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = params
  )
}
