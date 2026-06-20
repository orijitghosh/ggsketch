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
#' @inheritParams ggplot2::geom_text
#' @param family Font family. By default the first installed handwriting face is
#'   used; pass an explicit family to override, or `""` for the device default.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(x = c(1, 2, 3), y = c(2, 3, 1),
#'                  lab = c("alpha", "bravo", "charlie"))
#' ggplot(df, aes(x, y, label = lab)) +
#'   geom_sketch_text(size = 6) +
#'   theme_sketch()
geom_sketch_text <- function(mapping     = NULL,
                             data        = NULL,
                             stat        = "identity",
                             position    = "identity",
                             ...,
                             family      = NULL,
                             na.rm       = FALSE,
                             show.legend = NA,
                             inherit.aes = TRUE) {
  family <- family %||% resolve_sketch_font()
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = ggplot2::GeomText,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(family = family, na.rm = na.rm, ...)
  )
}

#' @rdname geom_sketch_text
#' @export
geom_sketch_label <- function(mapping     = NULL,
                              data        = NULL,
                              stat        = "identity",
                              position    = "identity",
                              ...,
                              family      = NULL,
                              na.rm       = FALSE,
                              show.legend = NA,
                              inherit.aes = TRUE) {
  family <- family %||% resolve_sketch_font()
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = ggplot2::GeomLabel,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(family = family, na.rm = na.rm, ...)
  )
}
