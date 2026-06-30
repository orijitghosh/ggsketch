# Layer 3 - sketch colour/fill scales (v1.4)
# A qualitative palette + a continuous gradient built around the package
# primary (Carolina blue #7BAFD4). Chosen to stay reasonably distinguishable
# for common colour-vision deficiencies.
# (ADR-0011 cut the fill-*pattern* scale from v1; this is a colour scale.)

#' The ggsketch qualitative colour palette
#'
#' Eight muted ink-on-paper colours led by the package primary
#' (Carolina blue, `#7BAFD4`), ordered for maximal separation.
#'
#' The first eight colours are returned exactly, so small categorical plots keep
#' their recognisable hues. Ask for **more than eight** and the palette is
#' *interpolated*: a smooth `colorRampPalette()` ramp through all eight anchors
#' yields `n` distinct ink tones, so the discrete sketch scales keep working for
#' large factors and for quasi-continuous use. Set `interpolate = FALSE` to fall
#' back to the old recycling behaviour instead.
#'
#' @param n Number of colours to return. If `NULL`, the eight anchor colours are
#'   returned. Up to eight are taken verbatim; beyond that they are interpolated
#'   (or recycled, if `interpolate = FALSE`).
#' @param interpolate When `n > 8`, interpolate the eight anchors into `n`
#'   colours (the default). `FALSE` recycles the anchors with a warning.
#' @return A character vector of hex colours.
#' @family sketch-theme
#' @export
#' @examples
#' sketch_palette(4)
#' sketch_palette(20)             # interpolated ramp through all eight anchors
sketch_palette <- function(n = NULL, interpolate = TRUE) {
  cols <- c(
    "#7BAFD4", # carolina blue (primary)
    "#C8553D", # terracotta
    "#88B398", # sage
    "#9B6FB0", # plum
    "#E0A458", # ochre
    "#5C6B73", # slate
    "#B05C7A", # dusty rose
    "#4E8C7D"  # teal
  )
  if (is.null(n)) return(cols)
  if (n <= length(cols)) return(cols[seq_len(n)])
  if (interpolate) {
    return(grDevices::colorRampPalette(cols, space = "Lab")(n))
  }
  cli::cli_warn(c(
    "The sketch palette has {length(cols)} colours but {n} were requested.",
    "i" = "Colours will be recycled; pass {.code interpolate = TRUE} or use a continuous scale instead."
  ))
  rep(cols, length.out = n)
}

#' @noRd
sketch_pal <- function(interpolate = TRUE) {
  force(interpolate)
  function(n) sketch_palette(n, interpolate = interpolate)
}

#' @noRd
sketch_gradient <- function() c("#EAF3FA", "#7BAFD4", "#34536B")

# ---- discrete scales --------------------------------------------------------

#' Sketch colour and fill scales
#'
#' Discrete scales (`scale_colour_sketch()`, `scale_fill_sketch()`) use
#' [sketch_palette()]; the continuous variants (`*_sketch_c()`) use a
#' paper-to-ink blue gradient. They pair with [theme_sketch()] and the sketch
#' geoms but work with any ggplot2 layer.
#'
#' @param ... Passed to [ggplot2::discrete_scale()] (discrete) or
#'   [ggplot2::scale_colour_gradientn()] (continuous).
#' @param aesthetics Character vector of aesthetics this scale works with.
#' @param interpolate Discrete scales only. When there are more than eight
#'   levels, interpolate the eight-colour [sketch_palette()] into one colour per
#'   level (the default) instead of recycling.
#' @return A ggplot2 scale object.
#' @family sketch-theme
#' @name scale_sketch
#' @examples
#' library(ggplot2)
#' ggplot(mpg, aes(displ, hwy, colour = drv)) +
#'   geom_sketch_point(seed = 1L) +
#'   scale_colour_sketch() +
#'   theme_sketch()
NULL

#' @rdname scale_sketch
#' @export
scale_colour_sketch <- function(..., aesthetics = "colour", interpolate = TRUE) {
  ggplot2::discrete_scale(aesthetics, palette = sketch_pal(interpolate), ...)
}

#' @rdname scale_sketch
#' @export
scale_color_sketch <- scale_colour_sketch

#' @rdname scale_sketch
#' @export
scale_fill_sketch <- function(..., aesthetics = "fill", interpolate = TRUE) {
  ggplot2::discrete_scale(aesthetics, palette = sketch_pal(interpolate), ...)
}

# ---- continuous scales ------------------------------------------------------

#' @rdname scale_sketch
#' @export
scale_colour_sketch_c <- function(..., aesthetics = "colour") {
  ggplot2::scale_colour_gradientn(..., colours = sketch_gradient(),
                                  aesthetics = aesthetics)
}

#' @rdname scale_sketch
#' @export
scale_color_sketch_c <- scale_colour_sketch_c

#' @rdname scale_sketch
#' @export
scale_fill_sketch_c <- function(..., aesthetics = "fill") {
  ggplot2::scale_fill_gradientn(..., colours = sketch_gradient(),
                                aesthetics = aesthetics)
}
