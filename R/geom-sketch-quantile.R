# Layer 3 - geom_sketch_quantile() (Tier 2)
# Quantile regression lines drawn as sketch paths (stat_quantile). Requires the
# optional 'quantreg' package (Suggests), following ADR-0005's posture: a clear
# cli message if missing, never a hard dependency.

#' Sketchy quantile regression lines
#'
#' Fits and draws quantile regression lines with a hand-drawn stroke - the
#' sketch analogue of [ggplot2::geom_quantile()] / [ggplot2::stat_quantile()].
#' Requires the optional \pkg{quantreg} package.
#'
#' @inheritParams geom_sketch_path
#' @param quantiles Numeric vector of quantiles to fit. Default
#'   `c(0.25, 0.5, 0.75)`.
#' @param formula Model formula passed to [quantreg::rq()]. Default
#'   `y ~ x`.
#' @param method Fitting method passed to [ggplot2::stat_quantile()].
#'   Default `"rq"`.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' if (requireNamespace("quantreg", quietly = TRUE)) {
#'   ggplot(mtcars, aes(wt, mpg)) +
#'     geom_sketch_point(seed = 1L) +
#'     geom_sketch_quantile(seed = 2L) +
#'     theme_sketch()
#' }
geom_sketch_quantile <- function(mapping     = NULL,
                                 data        = NULL,
                                 stat        = "quantile",
                                 position    = "identity",
                                 ...,
                                 quantiles   = c(0.25, 0.5, 0.75),
                                 formula     = NULL,
                                 method      = "rq",
                                 roughness   = 0.7,
                                 bowing      = 0.5,
                                 n_passes    = 2L,
                                 seed        = NULL,
                                 na.rm       = FALSE,
                                 show.legend = NA,
                                 inherit.aes = TRUE) {
  if (!requireNamespace("quantreg", quietly = TRUE)) {
    cli::cli_abort(c(
      "{.pkg quantreg} is required for {.fn geom_sketch_quantile}.",
      "i" = 'Install it with {.run install.packages("quantreg")}.'
    ))
  }
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchPath,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      quantiles = quantiles, formula = formula, method = method,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
