#' Null sketch geom (infrastructure smoke-test only)
#'
#' A do-nothing geom used to verify the package skeleton builds and checks
#' clean on both ggplot2 versions. Not exported.
#'
#' @keywords internal
GeomSketchNull <- ggplot2::ggproto(
  "GeomSketchNull", ggplot2::Geom,
  required_aes = character(0),
  default_aes = ggplot2::aes(),
  draw_panel = function(data, panel_params, coord) {
    grid::nullGrob()
  },
  draw_key = ggplot2::draw_key_blank
)

#' @rdname GeomSketchNull
#' @keywords internal
geom_sketch_null <- function(mapping = NULL, data = NULL,
                              stat = "identity", position = "identity",
                              ..., na.rm = FALSE, show.legend = NA,
                              inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping,
    stat = stat, geom = GeomSketchNull,
    position = position,
    show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}
