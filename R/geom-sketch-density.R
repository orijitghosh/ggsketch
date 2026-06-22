# Layer 3 - geom_sketch_density() (P4-T3)
# A kernel-density curve drawn as a sketchy filled area. Reuses GeomSketchArea
# for drawing; stat_density supplies `y = after_stat(density)`.

#' Sketchy density geom
#'
#' Draws a kernel density estimate as a hand-drawn filled area - the sketch
#' analogue of [ggplot2::geom_density()].  Drawing is delegated to
#' [GeomSketchArea]; the kernel density is computed by [ggplot2::stat_density()].
#'
#' @inheritParams geom_sketch_ribbon
#' @param outline.type Kept for signature parity with [ggplot2::geom_density()];
#'   ignored (the rough outline always traces the full band).
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(faithful, aes(eruptions)) +
#'   geom_sketch_density(fill = "khaki", seed = 1L) +
#'   theme_sketch()
geom_sketch_density <- function(mapping       = NULL,
                                 data          = NULL,
                                 stat          = "density",
                                 position      = "identity",
                                 ...,
                                 roughness     = 1,
                                 bowing        = 1,
                                 n_passes      = 2L,
                                 seed          = NULL,
                                 fill_style    = "hachure",
                                 hachure_angle = 45,
                                 hachure_gap   = NULL,
                                 fill_weight   = 0.5,
                                 outline.type  = "full",
                                 na.rm         = FALSE,
                                 show.legend   = NA,
                                 inherit.aes   = TRUE) {
  ggplot2::layer(
    data        = data,
    mapping     = mapping,
    stat        = stat,
    geom        = GeomSketchArea,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = list(
      roughness     = roughness,
      bowing        = bowing,
      n_passes      = as.integer(n_passes),
      seed          = seed,
      fill_style    = fill_style,
      hachure_angle = hachure_angle,
      hachure_gap   = hachure_gap,
      fill_weight   = fill_weight,
      na.rm         = na.rm,
      ...
    )
  )
}
