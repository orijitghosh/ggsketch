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
#' @param n Number of colours to return (max 8). If `NULL`, all are returned.
#' @return A character vector of hex colours.
#' @family sketch-theme
#' @export
#' @examples
#' sketch_palette(4)
sketch_palette <- function(n = NULL) {
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
  if (n > length(cols)) {
    cli::cli_warn(c(
      "The sketch palette has {length(cols)} colours but {n} were requested.",
      "i" = "Colours will be recycled; consider a continuous scale instead."
    ))
    return(rep(cols, length.out = n))
  }
  cols[seq_len(n)]
}

#' @noRd
sketch_pal <- function() {
  function(n) sketch_palette(n)
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
scale_colour_sketch <- function(..., aesthetics = "colour") {
  ggplot2::discrete_scale(aesthetics, palette = sketch_pal(), ...)
}

#' @rdname scale_sketch
#' @export
scale_color_sketch <- scale_colour_sketch

#' @rdname scale_sketch
#' @export
scale_fill_sketch <- function(..., aesthetics = "fill") {
  ggplot2::discrete_scale(aesthetics, palette = sketch_pal(), ...)
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
