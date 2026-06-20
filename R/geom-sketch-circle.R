# Layer 3 — geom_sketch_circle() / geom_sketch_ellipse() (P5-T1)
# Annotation-style rough circles/ellipses sized in data units via
# sketch_ellipse_grob() (radius converted to device inches in makeContent).

# ---- GeomSketchEllipse ------------------------------------------------------

#' @rdname geom_sketch_circle
#' @export
GeomSketchEllipse <- ggplot2::ggproto(
  "GeomSketchEllipse", ggplot2::Geom,

  required_aes = c("x", "y", "a", "b"),

  default_aes = ggplot2::aes(
    colour    = "black",
    fill      = NA,
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA
  ),

  draw_key = draw_key_sketch_polygon,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight", "na.rm")
  },

  # Expose the bounding box so position scales expand to fit whole ellipses.
  setup_data = function(data, params) {
    data$xmin <- data$x - data$a
    data$xmax <- data$x + data$a
    data$ymin <- data$y - data$b
    data$ymax <- data$y + data$b
    data
  },

  draw_panel = function(data, panel_params, coord,
                         roughness     = 1,
                         bowing        = 1,
                         n_passes      = 2L,
                         seed          = NULL,
                         fill_style    = "hachure",
                         hachure_angle = 45,
                         hachure_gap   = 0.07,
                         fill_weight   = 0.5,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())

    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    # Transform centre and centre+radius to npc; radius = difference in npc.
    centre <- coord$transform(
      data.frame(x = data$x, y = data$y), panel_params
    )
    edge_x <- coord$transform(
      data.frame(x = data$x + data$a, y = data$y), panel_params
    )
    edge_y <- coord$transform(
      data.frame(x = data$x, y = data$y + data$b), panel_params
    )
    rx <- abs(edge_x$x - centre$x)
    ry <- abs(edge_y$y - centre$y)

    has_fill   <- !all(is.na(data$fill))
    fill_style <- if (has_fill) fill_style else "solid"

    sketch_ellipse_grob(
      x             = centre$x,
      y             = centre$y,
      rx            = rx,
      ry            = ry,
      roughness     = sp$roughness,
      n_passes      = sp$n_passes,
      seed          = sp$seed,
      fill_style    = fill_style,
      hachure_angle = hachure_angle,
      hachure_gap   = hachure_gap,
      fill_weight   = fill_weight,
      fill_gp       = gpar(
        col = scales::alpha(data$fill, data$alpha), lineend = "round"
      ),
      outline_gp    = gpar(
        col = scales::alpha(data$colour, data$alpha),
        lwd = data$linewidth[1L] * ggplot2::.pt,
        lty = data$linetype[1L],
        lineend = "round", linejoin = "round"
      )
    )
  }
)

# ---- GeomSketchCircle -------------------------------------------------------

#' @rdname geom_sketch_circle
#' @export
GeomSketchCircle <- ggplot2::ggproto(
  "GeomSketchCircle", GeomSketchEllipse,

  required_aes = c("x", "y", "r"),

  setup_data = function(data, params) {
    data$a <- data$r
    data$b <- data$r
    data$xmin <- data$x - data$r
    data$xmax <- data$x + data$r
    data$ymin <- data$y - data$r
    data$ymax <- data$y + data$r
    data
  }
)

# ---- constructors -----------------------------------------------------------

#' Sketchy circle and ellipse geoms
#'
#' `geom_sketch_circle()` draws roughened circles of radius `r` (data units);
#' `geom_sketch_ellipse()` draws ellipses with semi-axes `a` (x) and `b` (y).
#' Radii are in data units, so on a non-square panel a circle appears
#' elliptical — use [ggplot2::coord_equal()] for true circles.  These are
#' annotation-style geoms (cf. `ggforce::geom_circle()`).
#'
#' @param mapping Set of aesthetic mappings created by [ggplot2::aes()].
#'   `geom_sketch_circle()` needs `x`, `y`, `r`; `geom_sketch_ellipse()` needs
#'   `x`, `y`, `a`, `b`.
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param roughness Non-negative roughness (0 = clean). Default 1.
#' @param bowing Non-negative bowing multiplier. Default 1.
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param fill_style Fill style when `fill` is mapped: `"hachure"`,
#'   `"cross_hatch"`, `"zigzag"`, `"dots"`, `"dashed"`. Default `"hachure"`.
#' @param hachure_angle Fill line angle in degrees. Default 45.
#' @param hachure_gap Fill line gap (npc fraction, scaled by radius). Default 0.07.
#' @param fill_weight Stroke weight for fill lines. Default 0.5.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend?
#' @param inherit.aes Override default aesthetics?
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(x = c(1, 3), y = c(1, 2), r = c(0.5, 1))
#' ggplot(df, aes(x, y, r = r)) +
#'   geom_sketch_circle(fill = "gold", seed = 1L) +
#'   coord_equal() + theme_sketch()
geom_sketch_circle <- function(mapping       = NULL,
                                data          = NULL,
                                stat          = "identity",
                                position      = "identity",
                                ...,
                                roughness     = 1,
                                bowing        = 1,
                                n_passes      = 2L,
                                seed          = NULL,
                                fill_style    = "hachure",
                                hachure_angle = 45,
                                hachure_gap   = 0.07,
                                fill_weight   = 0.5,
                                na.rm         = FALSE,
                                show.legend   = NA,
                                inherit.aes   = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchCircle,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, fill_style = fill_style, hachure_angle = hachure_angle,
      hachure_gap = hachure_gap, fill_weight = fill_weight, na.rm = na.rm, ...
    )
  )
}

#' @rdname geom_sketch_circle
#' @export
geom_sketch_ellipse <- function(mapping       = NULL,
                                 data          = NULL,
                                 stat          = "identity",
                                 position      = "identity",
                                 ...,
                                 roughness     = 1,
                                 bowing        = 1,
                                 n_passes      = 2L,
                                 seed          = NULL,
                                 fill_style    = "hachure",
                                 hachure_angle = 45,
                                 hachure_gap   = 0.07,
                                 fill_weight   = 0.5,
                                 na.rm         = FALSE,
                                 show.legend   = NA,
                                 inherit.aes   = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchEllipse,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, fill_style = fill_style, hachure_angle = hachure_angle,
      hachure_gap = hachure_gap, fill_weight = fill_weight, na.rm = na.rm, ...
    )
  )
}
