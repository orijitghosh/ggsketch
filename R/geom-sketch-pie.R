# Layer 3 - geom_sketch_pie() / geom_sketch_donut() (v1.7)
# A hand-drawn pie or donut chart. StatSketchPie turns an `amount` per slice
# into start/end angles (clockwise from 12 o'clock); GeomSketchPie draws the
# slices via sketch_wedge_grob(), which keeps them circular on any panel shape.

# ---- StatSketchPie ----------------------------------------------------------

#' @rdname geom_sketch_pie
#' @format NULL
#' @usage NULL
#' @export
StatSketchPie <- ggplot2::ggproto(
  "StatSketchPie", ggplot2::Stat,

  required_aes = "amount",

  compute_panel = function(data, scales, ...) {
    data <- data[order(data$group), , drop = FALSE]
    amt  <- pmax(as.numeric(data$amount), 0)
    total <- sum(amt)
    if (!is.finite(total) || total <= 0) total <- 1

    frac  <- amt / total
    cum   <- cumsum(frac)
    upper <- c(0, cum[-length(cum)])

    # Clockwise from the top (12 o'clock = pi/2 in math angles).
    data$start <- pi / 2 - 2 * pi * upper
    data$end   <- pi / 2 - 2 * pi * cum
    # Nominal centre so the panel trains to a usable range.
    data$x <- 0.5
    data$y <- 0.5
    data
  }
)

# ---- GeomSketchPie ----------------------------------------------------------

#' @rdname geom_sketch_pie
#' @export
GeomSketchPie <- ggplot2::ggproto(
  "GeomSketchPie", ggplot2::Geom,

  required_aes = c("start", "end"),

  default_aes = ggplot2::aes(
    fill      = "grey65",
    colour    = "black",
    linewidth = 0.5,
    alpha     = NA
  ),

  draw_key = draw_key_sketch_polygon,

  parameters = function(self, extra = FALSE) {
    c("x0", "y0", "r", "r0", "roughness", "bowing", "n_passes", "seed",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight", "na.rm")
  },

  # Span the panel [0, 1] so the pie (drawn in npc) sits in a sensible frame.
  setup_data = function(data, params) {
    data$xmin <- 0; data$xmax <- 1
    data$ymin <- 0; data$ymax <- 1
    data
  },

  draw_panel = function(data, panel_params, coord,
                         x0 = 0.5, y0 = 0.5, r = 0.45, r0 = 0,
                         roughness = 1, bowing = 0.4, n_passes = 2L, seed = NULL,
                         fill_style = "solid", hachure_angle = 45,
                         hachure_gap = 0.07, fill_weight = 0.5, ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    sketch_wedge_grob(
      x0 = x0, y0 = y0, r = r, r0 = r0,
      start = data$start, end = data$end,
      roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
      seed = sp$seed,
      fill_style = fill_style, hachure_angle = hachure_angle,
      hachure_gap = hachure_gap, fill_weight = fill_weight,
      fill_gp = gpar(col = scales::alpha(data$fill, data$alpha),
                     lineend = "round"),
      outline_gp = gpar(col = scales::alpha(data$colour, data$alpha),
                        lwd = data$linewidth * ggplot2::.pt,
                        lineend = "round", linejoin = "round")
    )
  }
)

# ---- constructors -----------------------------------------------------------

#' Sketchy pie and donut charts
#'
#' `geom_sketch_pie()` draws a hand-drawn pie chart: one slice per row, sized by
#' the `amount` aesthetic and coloured by `fill`. `geom_sketch_donut()` is the
#' same with a hole in the middle. Slices are kept circular regardless of the
#' panel's shape, so they look right without `coord_fixed()`. The chart is drawn
#' in the centre of the panel; pair it with [theme_sketch()] or
#' [ggplot2::theme_void()] to hide the (unused) axes.
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires
#'   `amount`; map `fill` to colour the slices.
#' @param data Data with one row per slice.
#' @param stat The statistic; defaults to `StatSketchPie`, which converts
#'   `amount` into slice angles.
#' @param position Position adjustment. Default `"identity"`.
#' @param x0,y0 Pie centre in npc \[0,1\]. Default `0.5` (panel centre).
#' @param r Outer radius as a fraction of the smaller panel dimension. Default
#'   `0.45`.
#' @param r0 Inner radius (hole) as a fraction of the smaller panel dimension.
#'   `0` (default) is a full pie; `geom_sketch_donut()` defaults it to `0.5`.
#' @param roughness Non-negative roughness of the slice edges (0 = clean).
#'   Default 1.
#' @param bowing Non-negative bowing multiplier. Default 0.4 (kept low so the
#'   radial edges stay straight-ish).
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param fill_style `"solid"` (default) paints each slice in its `fill` colour
#'   with a rough edge; any other style (`"hachure"`, `"cross_hatch"`,
#'   `"zigzag"`, `"scribble"`, `"dots"`, `"dashed"`) hatches it instead.
#' @param hachure_angle Fill line angle in degrees. Default 45.
#' @param hachure_gap Fill line gap as a fraction of the smaller panel
#'   dimension. Default 0.07.
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
#' df <- data.frame(
#'   group  = c("Sketch", "Polish", "Coffee", "Doubt"),
#'   amount = c(40, 25, 20, 15)
#' )
#' ggplot(df, aes(amount = amount, fill = group)) +
#'   geom_sketch_pie(seed = 1L) +
#'   scale_fill_sketch() +
#'   coord_fixed() +
#'   theme_void()
#'
#' # A donut:
#' ggplot(df, aes(amount = amount, fill = group)) +
#'   geom_sketch_donut(seed = 2L) +
#'   theme_void()
geom_sketch_pie <- function(mapping       = NULL,
                            data          = NULL,
                            stat          = StatSketchPie,
                            position      = "identity",
                            ...,
                            x0            = 0.5,
                            y0            = 0.5,
                            r             = 0.45,
                            r0            = 0,
                            roughness     = 1,
                            bowing        = 0.4,
                            n_passes      = 2L,
                            seed          = NULL,
                            fill_style    = "solid",
                            hachure_angle = 45,
                            hachure_gap   = 0.07,
                            fill_weight   = 0.5,
                            na.rm         = FALSE,
                            show.legend   = NA,
                            inherit.aes   = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchPie,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      x0 = x0, y0 = y0, r = r, r0 = r0,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, fill_style = fill_style, hachure_angle = hachure_angle,
      hachure_gap = hachure_gap, fill_weight = fill_weight, na.rm = na.rm, ...
    )
  )
}

#' @rdname geom_sketch_pie
#' @export
geom_sketch_donut <- function(..., r0 = 0.5) {
  geom_sketch_pie(..., r0 = r0)
}
