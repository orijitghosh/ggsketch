# Layer 3 - pressure aesthetic scale (v2)
# Default continuous scale for `aes(pressure = )` on the path-like sketch geoms.
# It rescales a mapped variable to a stroke-width-multiplier band, exactly as
# `scale_size()` rescales to a size band, so a raw variable can drive how hard
# the "pen" presses along a line without thinking in width units. ggplot2 finds
# it automatically (the `scale_<aes>_continuous` default-scale lookup).

#' Continuous scale for the sketch `pressure` aesthetic
#'
#' [geom_sketch_line()] and [geom_sketch_path()] let you map a variable to
#' `pressure` (`aes(pressure = z)`) so the stroke swells and thins **along** the
#' line, like a real pen pressed harder in places. This scale rescales that
#' variable's observed range to a band of width multipliers, just as
#' `scale_size()` rescales to a size range. It is applied automatically whenever
#' `pressure` is mapped to a continuous variable, so you only call it directly to
#' change `range`. To use values as raw width multipliers with no rescaling, wrap
#' them in [base::I()] (`aes(pressure = I(z))`).
#'
#' Mapping `pressure` renders the line through the variable-width
#' [stroke_ribbon()] engine even under the default `medium = "pen"`, and combines
#' with a non-`pen` `medium` (the medium's own width profile is multiplied by the
#' mapped pressure).
#'
#' @param ... Other arguments passed to [ggplot2::continuous_scale()].
#' @param range Output width-multiplier range. Default `c(0.2, 1.6)`: the lightest
#'   pressure draws the stroke at `0.2x` its base width, the heaviest at `1.6x`.
#' @param guide Legend guide. Defaults to `"none"` because the legend keys do not
#'   reflect pressure; set to `"legend"` to show one anyway.
#' @return A ggplot2 scale object.
#' @family sketch-theme
#' @export
#' @examples
#' library(ggplot2)
#'
#' # A line whose width tracks a variable, rescaled to c(0.2, 1.6) automatically.
#' ggplot(economics[1:120, ], aes(date, unemploy, pressure = unemploy)) +
#'   geom_sketch_line(linewidth = 1, seed = 1L)
#'
#' # Widen the band for a more dramatic swell.
#' ggplot(economics[1:120, ], aes(date, unemploy, pressure = unemploy)) +
#'   geom_sketch_line(linewidth = 1, seed = 1L) +
#'   scale_pressure_continuous(range = c(0.05, 2.5))
scale_pressure_continuous <- function(..., range = c(0.2, 1.6),
                                      guide = "none") {
  ggplot2::continuous_scale(
    aesthetics = "pressure",
    palette    = scales::rescale_pal(range),
    guide      = guide,
    ...
  )
}

#' @rdname scale_pressure_continuous
#' @export
scale_pressure <- scale_pressure_continuous
