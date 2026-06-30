# Layer 1 - arrowhead geometry (v2.0)
# Ideal (un-roughened) arrowhead paths for a tip at (tipx, tipy) pointing along
# `angle` (radians). One generator, several styles; the grob layer roughens the
# strokes / polygons in device space and paints the dots. Pure geometry - no
# grid:: or ggplot2:: (T-ARCH-01).

#' The available arrowhead styles
#'
#' Valid values for the `head` argument of [geom_sketch_arrow()],
#' [annotate_sketch_arrow()], [geom_sketch_callout()] and the `style` of
#' [arrowhead()].
#'
#' @return A character vector of arrowhead names.
#' @family sketch-core
#' @export
#' @examples
#' sketch_arrowheads()
sketch_arrowheads <- function() {
  c("triangle_open", "triangle_filled", "barb", "fishtail", "dot", "bar")
}

#' Validate an arrowhead style
#' @noRd
check_arrowhead <- function(x, arg = rlang::caller_arg(x),
                            call = rlang::caller_env()) {
  choices <- sketch_arrowheads()
  if (!is.character(x) || length(x) != 1L || !x %in% choices) {
    cli::cli_abort(
      "{.arg {arg}} must be one of {.or {choices}}, not {.val {x}}.",
      call = call
    )
  }
  invisible(x)
}

#' Build the ideal paths for one arrowhead
#'
#' Returns the un-roughened geometry of an arrowhead whose tip is at
#' `(tipx, tipy)` and which points along `angle`. The grob layer roughens and
#' paints it, so this stays pure geometry and reproduces on every device. Styles:
#' `"triangle_open"` (a two-stroke V), `"triangle_filled"` (a solid triangle),
#' `"barb"` (swept-back harpoon barbs), `"fishtail"` (a forked swallowtail),
#' `"dot"` (a blob at the tip) and `"bar"` (a perpendicular tick).
#'
#' @param tipx,tipy Tip position (inch space).
#' @param angle Direction the arrow points, in radians (the end tangent).
#' @param length Head length in inches.
#' @param half_angle Half-angle of the wings, in radians. Default ~25 degrees.
#' @param style One of [sketch_arrowheads()].
#' @return A list with `strokes` (a list of 2-column `(x, y)` polylines to
#'   stroke), `polygons` (a list of `(x, y)` rings to fill) and `dots`
#'   (`list(x, y, r)` or `NULL`).
#' @family sketch-core
#' @export
#' @examples
#' arrowhead(1, 1, angle = 0, length = 0.2, style = "barb")
arrowhead <- function(tipx, tipy, angle, length,
                      half_angle = 25 * pi / 180,
                      style      = "triangle_open") {
  check_arrowhead(style)
  ax <- cos(angle); ay <- sin(angle)                 # unit axis (points forward)
  b1x <- tipx - length * cos(angle - half_angle)
  b1y <- tipy - length * sin(angle - half_angle)
  b2x <- tipx - length * cos(angle + half_angle)
  b2y <- tipy - length * sin(angle + half_angle)
  mk  <- function(xs, ys) matrix(c(xs, ys), ncol = 2L,
                                 dimnames = list(NULL, c("x", "y")))
  out <- list(strokes = list(), polygons = list(), dots = NULL)

  switch(style,
    triangle_open = {
      out$strokes <- list(mk(c(b1x, tipx, b2x), c(b1y, tipy, b2y)))
    },
    triangle_filled = {
      out$polygons <- list(mk(c(b1x, tipx, b2x, b1x), c(b1y, tipy, b2y, b1y)))
    },
    barb = {                                          # notch behind the wings
      nx <- tipx - length * 1.25 * ax; ny <- tipy - length * 1.25 * ay
      out$polygons <- list(mk(c(tipx, b1x, nx, b2x, tipx),
                              c(tipy, b1y, ny, b2y, tipy)))
    },
    fishtail = {                                      # notch in front: forked
      nx <- tipx - length * 0.35 * ax; ny <- tipy - length * 0.35 * ay
      out$polygons <- list(mk(c(tipx, b1x, nx, b2x, tipx),
                              c(tipy, b1y, ny, b2y, tipy)))
    },
    dot = {
      out$dots <- list(x = tipx, y = tipy, r = length * 0.45)
    },
    bar = {                                           # perpendicular tick
      px <- -ay; py <- ax
      half <- length * 0.7
      out$strokes <- list(mk(c(tipx - half * px, tipx + half * px),
                             c(tipy - half * py, tipy + half * py)))
    }
  )
  out
}
