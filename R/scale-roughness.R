# Layer 3 - roughness aesthetic scale (v1.5)
# Default continuous scale for `aes(roughness = )`. It rescales a mapped variable
# to a legible roughness band, exactly as `scale_size()` rescales to a size band,
# so users can map raw variables without thinking in roughness units. ggplot2
# finds it automatically (the `scale_<aes>_continuous` default-scale lookup).

#' Continuous scale for the sketch `roughness` aesthetic
#'
#' [geom_sketch_point()] lets you map a variable to `roughness`
#' (`aes(roughness = z)`). This scale rescales that variable's observed range to a
#' legible band of roughness values, just as `scale_size()` rescales to a size
#' range. It is applied automatically whenever `roughness` is mapped to a
#' continuous variable, so you only call it directly to change `range`. To use
#' values as raw roughness with no rescaling, wrap them in [base::I()]
#' (`aes(roughness = I(z))`).
#'
#' @param ... Other arguments passed to [ggplot2::continuous_scale()].
#' @param range Output roughness range. Default `c(0.01, 0.75)`: `0.01` is
#'   effectively clean and `0.75` is clearly hand-drawn without becoming noise.
#'   Values above roughly `1` start to look scribbled.
#' @param guide Legend guide. Defaults to `"none"` because the legend keys do not
#'   reflect roughness; set to `"legend"` to show one anyway.
#' @return A ggplot2 scale object.
#' @family sketch-theme
#' @export
#' @examples
#' library(ggplot2)
#'
#' # Mapped roughness is rescaled to c(0.01, 0.75) automatically.
#' ggplot(mtcars, aes(wt, mpg, roughness = hp)) +
#'   geom_sketch_point(size = 3, seed = 1L)
#'
#' # Widen the band so the wobble difference is more dramatic.
#' ggplot(mtcars, aes(wt, mpg, roughness = hp)) +
#'   geom_sketch_point(size = 3, seed = 1L) +
#'   scale_roughness_continuous(range = c(0, 1.2))
scale_roughness_continuous <- function(..., range = c(0.01, 0.75),
                                       guide = "none") {
  ggplot2::continuous_scale(
    aesthetics = "roughness",
    palette    = scales::rescale_pal(range),
    guide      = guide,
    ...
  )
}

#' @rdname scale_roughness_continuous
#' @export
scale_roughness <- scale_roughness_continuous
