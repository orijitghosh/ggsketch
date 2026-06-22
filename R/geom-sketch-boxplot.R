# Layer 3 - geom_sketch_boxplot() (P5-T3)
# A composed geom: rough IQR rectangle + median line + whisker segments +
# outlier sketch points. Uses stat_boxplot for the five-number summary.

# ---- GeomSketchBoxplot ------------------------------------------------------

#' @rdname geom_sketch_boxplot
#' @export
GeomSketchBoxplot <- ggplot2::ggproto(
  "GeomSketchBoxplot", ggplot2::Geom,

  required_aes = c("x", "lower", "upper", "middle", "ymin", "ymax"),

  default_aes = ggplot2::aes(
    colour    = "grey20",
    fill      = NA,
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA,
    width     = 0.75,
    shape     = 19,
    size      = 1.5
  ),

  draw_key = ggplot2::draw_key_boxplot,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight",
      "outliers", "na.rm")
  },

  setup_data = function(data, params) {
    data$width <- data$width %||% params$width %||%
      (ggplot2::resolution(data$x, FALSE) * 0.75)
    data$xmin <- data$x - data$width / 2
    data$xmax <- data$x + data$width / 2
    data
  },

  draw_group = function(data, panel_params, coord,
                         roughness     = 0.8,
                         bowing        = 1,
                         n_passes      = 2L,
                         seed          = NULL,
                         fill_style    = "solid",
                         hachure_angle = 45,
                         hachure_gap   = NULL,
                         fill_weight   = 0.5,
                         outliers      = TRUE,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())

    sp    <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    row   <- data[1L, , drop = FALSE]
    col   <- scales::alpha(row$colour, row$alpha)
    grobs <- list()

    tx <- function(xx, yy) {
      coord$transform(data.frame(x = xx, y = yy), panel_params)
    }
    seg_grob <- function(xx, yy, off, lwd_mult = 1, bow_mult = 1) {
      pts <- tx(xx, yy)
      sketch_path_grob(
        x = pts$x, y = pts$y,
        roughness = sp$roughness, bowing = sp$bowing * bow_mult,
        n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, off),
        gp = gpar(col = col, lwd = row$linewidth * lwd_mult * ggplot2::.pt,
                  lty = row$linetype, lineend = "round")
      )
    }

    # --- whiskers (lower: lower->ymin, upper: upper->ymax) ---
    grobs[[length(grobs) + 1L]] <-
      seg_grob(c(row$x, row$x), c(row$lower, row$ymin), 1L)
    grobs[[length(grobs) + 1L]] <-
      seg_grob(c(row$x, row$x), c(row$upper, row$ymax), 2L)

    # --- IQR box (rough rect with optional fill) ---
    bx  <- c(row$xmin, row$xmax, row$xmax, row$xmin)
    by  <- c(row$lower, row$lower, row$upper, row$upper)
    bp  <- tx(bx, by)
    gap <- hachure_gap %||% (abs(bp$x[2L] - bp$x[1L]) * 0.15)
    grobs[[length(grobs) + 1L]] <- sketch_polygon_grob(
      x = bp$x, y = bp$y,
      roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
      seed = seed_offset(sp$seed, 3L),
      fill_style = fill_style, hachure_angle = hachure_angle,
      hachure_gap = max(gap, 1e-3), fill_weight = fill_weight,
      fill_gp = gpar(col = scales::alpha(row$fill, row$alpha), lineend = "round"),
      outline_gp = gpar(col = col, lwd = row$linewidth * ggplot2::.pt,
                        lty = row$linetype, lineend = "round", linejoin = "round")
    )

    # --- median line (thicker; little bowing so it reads as one firm line
    #     rather than a bowed lens at double the linewidth) ---
    grobs[[length(grobs) + 1L]] <-
      seg_grob(c(row$xmin, row$xmax), c(row$middle, row$middle), 4L,
               lwd_mult = 2, bow_mult = 0.2)

    # --- outliers ---
    if (outliers && !is.null(data$outliers) &&
        length(data$outliers[[1L]]) > 0L) {
      oy <- data$outliers[[1L]]
      op <- tx(rep(row$x, length(oy)), oy)
      grobs[[length(grobs) + 1L]] <- sketch_point_grob(
        x = op$x, y = op$y, size = row$size,
        roughness = sp$roughness, n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, 5L),
        gp = gpar(col = col, lwd = 0.5 * ggplot2::.pt, lineend = "round")
      )
    }

    do.call(gList, grobs)
  }
)

# ---- geom_sketch_boxplot ----------------------------------------------------

#' Sketchy boxplot
#'
#' A hand-drawn box-and-whisker plot: a roughened IQR box, a thick median line,
#' rough whiskers, and sketchy outlier points.  Uses [ggplot2::stat_boxplot()]
#' for the five-number summary - the sketch analogue of
#' [ggplot2::geom_boxplot()].
#'
#' @param mapping Set of aesthetic mappings created by [ggplot2::aes()].
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"boxplot"`.
#' @param position Position adjustment. Default `"dodge2"`.
#' @param roughness Non-negative roughness. Default 0.8 (boxes read cleaner).
#' @param bowing Non-negative bowing multiplier. Default 1.
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param fill_style Box fill style. Default `"solid"`. The box is outline-only
#'   until you give it a `fill` (the default `fill` is `NA`); set `fill` for a
#'   solid box, or use e.g. `fill_style = "hachure"` with a `fill` for shaded
#'   boxes.
#' @param hachure_angle,hachure_gap,fill_weight Fill parameters.
#' @param outliers Draw outlier points? Default `TRUE`.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend?
#' @param inherit.aes Override default aesthetics?
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mpg, aes(class, hwy)) +
#'   geom_sketch_boxplot(seed = 1L) +
#'   theme_sketch()
geom_sketch_boxplot <- function(mapping       = NULL,
                                 data          = NULL,
                                 stat          = "boxplot",
                                 position      = "dodge2",
                                 ...,
                                 roughness     = 0.8,
                                 bowing        = 1,
                                 n_passes      = 2L,
                                 seed          = NULL,
                                 fill_style    = "solid",
                                 hachure_angle = 45,
                                 hachure_gap   = NULL,
                                 fill_weight   = 0.5,
                                 outliers      = TRUE,
                                 na.rm         = FALSE,
                                 show.legend   = NA,
                                 inherit.aes   = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchBoxplot,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, fill_style = fill_style, hachure_angle = hachure_angle,
      hachure_gap = hachure_gap, fill_weight = fill_weight,
      outliers = outliers, na.rm = na.rm, ...
    )
  )
}
