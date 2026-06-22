# Layer 3 - geom_sketch_violin() (Tier 1)
# A violin is the kernel density mirrored about each group's x position. We build
# that closed polygon and hand it to sketch_polygon_grob() for fill + outline.

# ---- GeomSketchViolin -------------------------------------------------------

#' @rdname geom_sketch_violin
#' @export
GeomSketchViolin <- ggplot2::ggproto(
  "GeomSketchViolin", ggplot2::Geom,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    colour    = "grey20",
    fill      = "grey70",
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA,
    weight    = 1
  ),

  draw_key = draw_key_sketch_polygon,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight", "na.rm")
  },

  setup_data = function(data, params) {
    data$width <- data$width %||% params$width %||%
      (ggplot2::resolution(data$x, FALSE) * 0.9)
    transform(data, xmin = x - width / 2, xmax = x + width / 2)
  },

  draw_group = function(data, panel_params, coord,
                         roughness     = 1,
                         bowing        = 1,
                         n_passes      = 2L,
                         seed          = NULL,
                         fill_style    = "hachure",
                         hachure_angle = 45,
                         hachure_gap   = NULL,
                         fill_weight   = 0.5,
                         ...) {
    if (nrow(data) < 3L) return(nullGrob())

    sp   <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    data <- data[order(data$y), , drop = FALSE]

    half <- data$width / 2
    xl   <- data$x - data$violinwidth * half
    xr   <- data$x + data$violinwidth * half

    # Closed polygon: up the left edge, down the right edge.
    poly   <- data.frame(x = c(xl, rev(xr)), y = c(data$y, rev(data$y)))
    coords <- coord$transform(poly, panel_params)

    gap <- hachure_gap %||%
      (0.05 * sqrt(diff(range(coords$x))^2 + diff(range(coords$y))^2))

    first    <- data[1L, , drop = FALSE]
    fill_col <- scales::alpha(first$fill, first$alpha)
    out_col  <- scales::alpha(first$colour, first$alpha)

    sketch_polygon_grob(
      x             = coords$x,
      y             = coords$y,
      roughness     = sp$roughness,
      bowing        = sp$bowing,
      n_passes      = sp$n_passes,
      seed          = sp$seed,
      fill_style    = fill_style,
      hachure_angle = hachure_angle,
      hachure_gap   = max(gap, 1e-3),
      fill_weight   = fill_weight,
      fill_gp       = gpar(col = fill_col, lineend = "round"),
      outline_gp    = gpar(
        col = out_col, lwd = first$linewidth * ggplot2::.pt,
        lty = first$linetype, lineend = "round", linejoin = "round"
      )
    )
  }
)

# ---- geom_sketch_violin -----------------------------------------------------

#' Sketchy violin plot
#'
#' Draws a hand-drawn violin (mirrored kernel density) with a roughened outline
#' and a hachure-style fill - the sketch analogue of [ggplot2::geom_violin()].
#' Uses [ggplot2::stat_ydensity()].
#'
#' @inheritParams geom_sketch_polygon
#' @param trim,scale Passed to [ggplot2::stat_ydensity()]; further density
#'   arguments (e.g. `bw`, `adjust`, `kernel`) pass through `...`.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mpg, aes(class, hwy)) +
#'   geom_sketch_violin(fill = "#A3D9A5", seed = 1L) +
#'   theme_sketch()
geom_sketch_violin <- function(mapping       = NULL,
                                data          = NULL,
                                stat          = "ydensity",
                                position      = "dodge",
                                ...,
                                trim          = TRUE,
                                scale         = "area",
                                roughness     = 1,
                                bowing        = 1,
                                n_passes      = 2L,
                                seed          = NULL,
                                fill_style    = "hachure",
                                hachure_angle = 45,
                                hachure_gap   = NULL,
                                fill_weight   = 0.5,
                                na.rm         = FALSE,
                                show.legend   = NA,
                                inherit.aes   = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchViolin,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      trim = trim, scale = scale,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, fill_style = fill_style, hachure_angle = hachure_angle,
      hachure_gap = hachure_gap, fill_weight = fill_weight, na.rm = na.rm, ...
    )
  )
}
