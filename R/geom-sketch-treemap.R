# Layer 3 - geom_sketch_treemap() (v2.0)
# A treemap: nested rectangles whose areas encode a value. StatSketchTreemap
# turns the `area` aesthetic into rectangle bounds via the squarified
# treemap_layout() (Layer 1); GeomSketchTreemap draws them with the roughened
# rect look (reusing GeomSketchRect) and optionally writes a label in each tile.
# No new dependencies (cf. treemapify::geom_treemap()).

# ---- StatSketchTreemap -------------------------------------------------------

#' @rdname geom_sketch_treemap
#' @export
StatSketchTreemap <- ggplot2::ggproto(
  "StatSketchTreemap", ggplot2::Stat,

  required_aes = "area",

  compute_panel = function(data, scales, na.rm = FALSE) {
    if (nrow(data) == 0L) return(data)
    rects <- treemap_layout(data$area)
    data$xmin <- rects$xmin
    data$xmax <- rects$xmax
    data$ymin <- rects$ymin
    data$ymax <- rects$ymax
    data
  }
)

# ---- GeomSketchTreemap -------------------------------------------------------

#' @rdname geom_sketch_treemap
#' @export
GeomSketchTreemap <- ggplot2::ggproto(
  "GeomSketchTreemap", GeomSketchRect,

  required_aes = c("xmin", "xmax", "ymin", "ymax"),

  optional_aes = "label",

  default_aes = utils::modifyList(
    as.list(GeomSketchRect$default_aes),
    list(fill = "grey65")
  ),

  parameters = function(self, extra = FALSE) {
    c(GeomSketchRect$parameters(extra), "label_size", "label_colour")
  },

  draw_panel = function(self, data, panel_params, coord,
                         label_size = 3.2, label_colour = "grey15", ...) {
    if (nrow(data) == 0L) return(nullGrob())

    rect_grob <- ggplot2::ggproto_parent(GeomSketchRect, self)$draw_panel(
      data, panel_params, coord, ...
    )

    have_label <- !is.null(data$label) && !all(is.na(data$label))
    if (!have_label) return(rect_grob)

    centres <- coord$transform(
      data.frame(x = (data$xmin + data$xmax) / 2,
                 y = (data$ymin + data$ymax) / 2),
      panel_params
    )
    keep <- !is.na(data$label)
    labels <- grid::textGrob(
      label = as.character(data$label[keep]),
      x = grid::unit(centres$x[keep], "npc"),
      y = grid::unit(centres$y[keep], "npc"),
      gp = grid::gpar(col = label_colour, fontsize = label_size * ggplot2::.pt)
    )
    grid::gList(rect_grob, labels)
  }
)

# ---- geom_sketch_treemap -----------------------------------------------------

#' Sketchy treemap
#'
#' Draws a hand-drawn treemap: nested rectangles tiling a square, each with area
#' proportional to a value, so the biggest categories take the most space. Map
#' the value to `area` and the category to `fill`; map `label` to write a name in
#' each tile. The rectangles are laid out with a squarified algorithm
#' ([treemap_layout()]) and drawn with the roughened rect look, so they take any
#' `fill_style` (including `"watercolor"`). Add [ggplot2::coord_equal()] for true
#' proportions. No new dependencies (cf. `treemapify::geom_treemap()`).
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires
#'   `area`; usually map `fill` and optionally `label`.
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"sketch_treemap"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param label_size Label text size (as in [ggplot2::geom_text()]). Default 3.2.
#' @param label_colour Label colour. Default `"grey15"`.
#' @param colour Tile outline colour. Default `"grey25"` (set `NA` for none).
#' @param fill_style Tile fill style; see [geom_sketch_rect()]. Default
#'   `"hachure"`.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend?
#' @param inherit.aes Override default aesthetics?
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(grp = c("Alpha", "Bravo", "Charlie", "Delta", "Echo"),
#'                  val = c(40, 25, 15, 12, 8))
#' ggplot(df, aes(area = val, fill = grp, label = grp)) +
#'   geom_sketch_treemap(seed = 1L) +
#'   coord_equal() +
#'   theme_sketch()
geom_sketch_treemap <- function(mapping      = NULL,
                                data         = NULL,
                                stat         = "sketch_treemap",
                                position     = "identity",
                                ...,
                                label_size   = 3.2,
                                label_colour = "grey15",
                                colour       = "grey25",
                                fill_style   = "hachure",
                                roughness    = 1,
                                bowing       = 1,
                                n_passes     = 2L,
                                seed         = NULL,
                                na.rm        = FALSE,
                                show.legend  = NA,
                                inherit.aes  = TRUE) {
  params <- list(
    label_size = label_size, label_colour = label_colour,
    fill_style = fill_style, roughness = roughness, bowing = bowing,
    n_passes = as.integer(n_passes), seed = seed, na.rm = na.rm, ...
  )
  if (!is.null(colour)) params$colour <- colour
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchTreemap,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = params
  )
}
