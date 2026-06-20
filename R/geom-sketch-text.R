# Layer 3 — geom_sketch_text() / geom_sketch_label() (Tier 3)
# Roughening glyph outlines is out of scope (ADR-0007): the "sketch" of text is a
# *handwriting font*, not geometry. These geoms therefore reuse ggplot2's text
# drawing but default the font family to the first installed handwriting face
# (the same resolver theme_sketch(base_family = "auto") uses). Cosmetic only:
# if no handwriting font is installed they fall back to the device default.

#' Sketchy text and labels
#'
#' `geom_sketch_text()` and `geom_sketch_label()` add text in a handwriting font,
#' the sketch counterparts of [ggplot2::geom_text()] and [ggplot2::geom_label()].
#' Unlike the other geoms the strokes are not geometrically roughened — the
#' hand-drawn feel comes from the font (see [ggsketch_check_fonts()] for which
#' faces are available). If no handwriting font is installed they render with the
#' device default family.
#'
#' @param mapping Set of aesthetic mappings created by [ggplot2::aes()].
#'   Requires a `label` aesthetic.
#' @param data Data to display.
#' @param stat Statistical transformation (default `"identity"`).
#' @param position Position adjustment (default `"identity"`).
#' @param family Font family. By default the first installed handwriting face is
#'   used; pass an explicit family to override, or `""` for the device default.
#' @param nudge_x,nudge_y Horizontal and vertical adjustment to nudge labels by.
#'   Useful for offsetting text from points. Cannot be used together with an
#'   explicit `position`.
#' @param na.rm If `FALSE` (default), missing values are removed with a warning.
#' @param show.legend Logical. Should this layer be included in the legend?
#' @param inherit.aes If `FALSE`, override the default aesthetics.
#' @param ... Other arguments passed on to [ggplot2::layer()], such as `size`,
#'   `colour`, `angle`, or `hjust`.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(x = c(1, 2, 3), y = c(2, 3, 1),
#'                  lab = c("alpha", "bravo", "charlie"))
#'
#' # `family = ""` uses the device default, so this runs on any device.
#' ggplot(df, aes(x, y, label = lab)) +
#'   geom_sketch_text(size = 6, family = "") +
#'   theme_sketch()
#'
#' # With no `family`, the first installed handwriting font is used. Render with
#' # a font-capable device (ragg, svglite, cairo) to see it — the base pdf() /
#' # postscript() devices cannot use unregistered system fonts.
#' \dontrun{
#' ggplot(df, aes(x, y, label = lab)) +
#'   geom_sketch_text(size = 6) +
#'   theme_sketch()
#' }
geom_sketch_text <- function(mapping     = NULL,
                             data        = NULL,
                             stat        = "identity",
                             position    = "identity",
                             ...,
                             family      = NULL,
                             nudge_x     = 0,
                             nudge_y     = 0,
                             na.rm       = FALSE,
                             show.legend = NA,
                             inherit.aes = TRUE) {
  family <- family %||% resolve_sketch_font()
  position <- sketch_text_position(position, nudge_x, nudge_y)
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = ggplot2::GeomText,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(family = family, na.rm = na.rm, ...)
  )
}

# Mirror ggplot2::geom_text(): turn nudge_x/nudge_y into a position_nudge,
# erroring if the user also supplied an explicit position (same as ggplot2).
sketch_text_position <- function(position, nudge_x, nudge_y) {
  if (nudge_x == 0 && nudge_y == 0) return(position)
  if (!identical(position, "identity")) {
    cli::cli_abort(c(
      "Both {.arg position} and {.arg nudge_x}/{.arg nudge_y} were supplied.",
      "i" = "Only use one approach to alter the position."
    ))
  }
  ggplot2::position_nudge(nudge_x, nudge_y)
}

#' @rdname geom_sketch_text
#' @export
geom_sketch_label <- function(mapping     = NULL,
                              data        = NULL,
                              stat        = "identity",
                              position    = "identity",
                              ...,
                              family      = NULL,
                              nudge_x     = 0,
                              nudge_y     = 0,
                              na.rm       = FALSE,
                              show.legend = NA,
                              inherit.aes = TRUE) {
  family <- family %||% resolve_sketch_font()
  position <- sketch_text_position(position, nudge_x, nudge_y)
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = ggplot2::GeomLabel,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(family = family, na.rm = na.rm, ...)
  )
}
