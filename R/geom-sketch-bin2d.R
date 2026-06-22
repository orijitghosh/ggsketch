# Layer 3 - geom_sketch_bin2d() (Tier 2)
# Rectangular 2-D bin heatmap: stat_bin_2d produces xmin/xmax/ymin/ymax and a
# count, which we route through GeomSketchRect. Cells default to a hachure fill
# (the package's "solid" style is outline-only), so the sketch look is preserved.

#' Sketchy 2-D bin heatmap
#'
#' Bins data into a rectangular grid and draws each cell as a hand-drawn
#' rectangle shaded by count - the sketch analogue of [ggplot2::geom_bin_2d()] /
#' [ggplot2::stat_bin_2d()]. `geom_sketch_bin2d()` and `geom_sketch_bin_2d()`
#' are aliases.
#'
#' @inheritParams geom_sketch_col
#' @param bins Number of bins in each direction. Default 30.
#' @param binwidth Bin width(s); overrides `bins` when supplied.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(faithful, aes(eruptions, waiting)) +
#'   geom_sketch_bin2d(bins = 12, seed = 1L) +
#'   theme_sketch()
geom_sketch_bin2d <- function(mapping       = NULL,
                              data          = NULL,
                              stat          = "bin2d",
                              position      = "identity",
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
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchTile,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      bins = bins, binwidth = binwidth,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, fill_style = fill_style, hachure_angle = hachure_angle,
      hachure_gap = hachure_gap, fill_weight = fill_weight, na.rm = na.rm, ...
    )
  )
}

#' @rdname geom_sketch_bin2d
#' @export
geom_sketch_bin_2d <- geom_sketch_bin2d
