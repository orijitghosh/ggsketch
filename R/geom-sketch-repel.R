# Layer 3 - geom_sketch_text_repel() / geom_sketch_label_repel() (v2.0)
# The sketch counterpart of ggrepel: handwriting text (or boxed labels) nudged
# apart so they do not overlap each other or the data points, each tied to its
# anchor by a hand-drawn leader. The placement is done by sketch_repel_grob() at
# draw time (it needs device-space text metrics); the geoms only marshal the
# aesthetics. The leader, and the box for the label variant, are roughened like
# the rest of ggsketch.

# Shared draw_panel for both repel geoms; `boxed` picks text vs boxed label.
sketch_repel_draw <- function(data, panel_params, coord, boxed,
                              roughness, bowing, n_passes, seed,
                              padding, corner_radius, box_padding,
                              point_padding, min_segment, max_iter, family) {
  keep <- !is.na(data$label) & nzchar(as.character(data$label))
  data <- data[keep, , drop = FALSE]
  if (nrow(data) == 0L) return(nullGrob())
  sp  <- resolve_sketch_params(roughness, bowing, n_passes, seed)
  fam <- resolve_label_family(family)
  pos <- coord$transform(data, panel_params)

  col  <- scales::alpha(data$colour, data$alpha)
  fill <- if (!is.null(data$fill)) scales::alpha(data$fill, data$alpha) else NA

  sketch_repel_grob(
    x = pos$x, y = pos$y, label = as.character(data$label), boxed = boxed,
    padding = padding, corner_radius = corner_radius,
    box_padding = box_padding, point_padding = point_padding,
    min_segment = min_segment, max_iter = max_iter,
    roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
    seed = sp$seed,
    text_gp = grid::gpar(col = col, fontfamily = fam,
                         fontsize = data$size * ggplot2::.pt),
    box_gp  = grid::gpar(col = col, fill = fill,
                         lwd = (data$linewidth %||% 0.5) * ggplot2::.pt),
    seg_gp  = grid::gpar(col = col, lwd = (data$linewidth %||% 0.4) * ggplot2::.pt,
                         lineend = "round")
  )
}

repel_params <- function(self, extra = FALSE) {
  c("roughness", "bowing", "n_passes", "seed", "padding", "corner_radius",
    "box_padding", "point_padding", "min_segment", "max_iter", "family", "na.rm")
}

#' @rdname geom_sketch_text_repel
#' @export
GeomSketchTextRepel <- ggplot2::ggproto(
  "GeomSketchTextRepel", ggplot2::Geom,
  required_aes = c("x", "y", "label"),
  default_aes = ggplot2::aes(colour = "black", size = 3.88, alpha = NA,
                             linewidth = 0.4),
  draw_key = draw_key_sketch_path,
  parameters = repel_params,
  draw_panel = function(data, panel_params, coord,
                        roughness = 1, bowing = 0.6, n_passes = 2L, seed = NULL,
                        padding = 0.07, corner_radius = 0.3, box_padding = 0.1,
                        point_padding = 0.05, min_segment = 0.06,
                        max_iter = 2000L, family = NULL, ...) {
    sketch_repel_draw(data, panel_params, coord, boxed = FALSE,
                      roughness, bowing, n_passes, seed, padding, corner_radius,
                      box_padding, point_padding, min_segment, max_iter, family)
  }
)

#' @rdname geom_sketch_text_repel
#' @export
GeomSketchLabelRepel <- ggplot2::ggproto(
  "GeomSketchLabelRepel", ggplot2::Geom,
  required_aes = c("x", "y", "label"),
  default_aes = ggplot2::aes(colour = "black", fill = "white", size = 3.88,
                             alpha = NA, linewidth = 0.4),
  draw_key = draw_key_sketch_path,
  parameters = repel_params,
  draw_panel = function(data, panel_params, coord,
                        roughness = 1, bowing = 0.6, n_passes = 2L, seed = NULL,
                        padding = 0.09, corner_radius = 0.3, box_padding = 0.12,
                        point_padding = 0.05, min_segment = 0.06,
                        max_iter = 2000L, family = NULL, ...) {
    sketch_repel_draw(data, panel_params, coord, boxed = TRUE,
                      roughness, bowing, n_passes, seed, padding, corner_radius,
                      box_padding, point_padding, min_segment, max_iter, family)
  }
)

#' Sketchy repelled text and labels
#'
#' The hand-drawn answer to \pkg{ggrepel}: text (`geom_sketch_text_repel()`) or
#' boxed labels (`geom_sketch_label_repel()`) that are nudged apart so they do
#' not overlap one another or cover the data points, each joined back to its
#' anchor by a roughened leader line when it has moved. Placement is solved at
#' draw time by [repel_layout()] in device space, so it is even on any panel
#' aspect.
#'
#' Unlike most ggsketch geoms the glyphs are not roughened (the sketch of text is
#' a handwriting font, ADR-0007); the leader and the label box are. Like
#' [geom_sketch_text()], `family` defaults to the theme's text family.
#'
#' @param mapping,data,stat,position,show.legend,inherit.aes Standard layer
#'   arguments. Requires `x`, `y` and `label` aesthetics.
#' @param roughness,bowing,n_passes,seed Sketch parameters for the leader / box.
#' @param padding Text clearance inside the box (and around bare text), inches.
#' @param corner_radius Box corner rounding (label variant). Fraction of
#'   half-side; default 0.3.
#' @param box_padding,point_padding Extra clearance kept between boxes and around
#'   the anchor points, in inches.
#' @param min_segment Shortest leader drawn, in inches; below this no leader is
#'   shown (the label is close enough to its anchor).
#' @param max_iter Repel solver iteration cap. Default 2000.
#' @param family Font family for the text. Defaults to the theme's text family.
#' @param na.rm Drop missing values silently? Default `FALSE`.
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- head(mtcars, 12)
#' df$name <- rownames(df)
#' ggplot(df, aes(wt, mpg, label = name)) +
#'   geom_sketch_point(seed = 1L) +
#'   geom_sketch_text_repel(family = "", seed = 1L) +
#'   theme_sketch()
geom_sketch_text_repel <- function(mapping = NULL, data = NULL,
                                   stat = "identity", position = "identity",
                                   ...,
                                   roughness = 1, bowing = 0.6, n_passes = 2L,
                                   seed = NULL, padding = 0.07,
                                   corner_radius = 0.3, box_padding = 0.1,
                                   point_padding = 0.05, min_segment = 0.06,
                                   max_iter = 2000L, family = NULL,
                                   na.rm = FALSE, show.legend = FALSE,
                                   inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchTextRepel,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(roughness = roughness, bowing = bowing,
                  n_passes = as.integer(n_passes), seed = seed,
                  padding = padding, corner_radius = corner_radius,
                  box_padding = box_padding, point_padding = point_padding,
                  min_segment = min_segment, max_iter = as.integer(max_iter),
                  family = family, na.rm = na.rm, ...)
  )
}

#' @rdname geom_sketch_text_repel
#' @export
geom_sketch_label_repel <- function(mapping = NULL, data = NULL,
                                    stat = "identity", position = "identity",
                                    ...,
                                    roughness = 1, bowing = 0.6, n_passes = 2L,
                                    seed = NULL, padding = 0.09,
                                    corner_radius = 0.3, box_padding = 0.12,
                                    point_padding = 0.05, min_segment = 0.06,
                                    max_iter = 2000L, family = NULL,
                                    na.rm = FALSE, show.legend = FALSE,
                                    inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchLabelRepel,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(roughness = roughness, bowing = bowing,
                  n_passes = as.integer(n_passes), seed = seed,
                  padding = padding, corner_radius = corner_radius,
                  box_padding = box_padding, point_padding = point_padding,
                  min_segment = min_segment, max_iter = as.integer(max_iter),
                  family = family, na.rm = na.rm, ...)
  )
}
