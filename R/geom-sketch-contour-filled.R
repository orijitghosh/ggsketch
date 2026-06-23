# Layer 3 - geom_sketch_contour_filled() / geom_sketch_density_2d_filled()
# Filled contour / 2-D density BANDS (not just lines). Each band is a region
# with holes (an inner higher level cut out of a lower one); they are painted
# with the hole-aware filler (sketch_band_grob -> sketch_fill_multi) so the
# holes stay empty. The sketch analogue of geom_contour_filled() /
# geom_density_2d_filled(). This is the one new geom that needed real Layer-1
# work (the multi-ring hachure promised since 1.3.0).

# ---- GeomSketchContourFilled ------------------------------------------------

#' @rdname geom_sketch_contour_filled
#' @export
GeomSketchContourFilled <- ggplot2::ggproto(
  "GeomSketchContourFilled", ggplot2::Geom,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    fill      = "grey50",
    colour    = NA,
    linewidth = 0.4,
    linetype  = 1,
    alpha     = NA,
    subgroup  = NULL
  ),

  draw_key = draw_key_sketch_polygon,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight", "na.rm")
  },

  draw_group = function(data, panel_params, coord,
                         roughness     = 0.7,
                         bowing        = 0.5,
                         n_passes      = 2L,
                         seed          = NULL,
                         fill_style    = "solid",
                         hachure_angle = 45,
                         hachure_gap   = 0.04,
                         fill_weight   = 0.5,
                         ...) {
    n <- nrow(data)
    if (n < 3L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    # Split the band into its rings: outer pieces and holes. ggplot2's filled
    # contour stat marks holes with `subgroup` and disjoint pieces with `piece`;
    # the even-odd filler handles both, so we only need one ring per closed loop.
    ring_id <- interaction(
      data$piece    %||% rep(1L, n),
      data$subgroup %||% rep(1L, n),
      drop = TRUE, lex.order = TRUE
    )

    rings <- lapply(split(seq_len(n), ring_id), function(idx) {
      pts <- coord$transform(
        data.frame(x = data$x[idx], y = data$y[idx]), panel_params
      )
      list(x = pts$x, y = pts$y)
    })

    first <- data[1L, , drop = FALSE]
    sketch_band_grob(
      rings         = rings,
      roughness     = sp$roughness,
      bowing        = sp$bowing,
      n_passes      = sp$n_passes,
      seed          = sp$seed,
      fill_style    = fill_style,
      hachure_angle = hachure_angle,
      hachure_gap   = hachure_gap,
      fill_weight   = fill_weight,
      fill_col      = scales::alpha(first$fill, first$alpha),
      outline_gp    = gpar(
        col = scales::alpha(first$colour, first$alpha),
        lwd = first$linewidth * ggplot2::.pt,
        lty = first$linetype,
        lineend = "round", linejoin = "round"
      )
    )
  }
)

# ---- geom_sketch_contour_filled ---------------------------------------------

#' Sketchy filled contour and 2-D density bands
#'
#' `geom_sketch_contour_filled()` draws hand-drawn *filled* contour bands of a
#' surface (the sketch analogue of [ggplot2::geom_contour_filled()]); it needs
#' `x`, `y`, and `z`. `geom_sketch_density_2d_filled()` fills the bands of a 2-D
#' kernel density estimate ([ggplot2::geom_density_2d_filled()]); it needs `x`
#' and `y` and uses \pkg{MASS}.
#'
#' Unlike the contour *line* geoms, each band is a region that may contain holes
#' (the next level up, cut out). The fill is painted with a hole-aware
#' scan-line so the holes stay empty, even for `fill_style = "hachure"`.
#'
#' @inheritParams geom_sketch_path
#' @param bins Number of contour bins. Overridden by `binwidth` or `breaks`.
#' @param binwidth Distance between contour bins.
#' @param breaks Explicit numeric contour breaks; overrides `bins`/`binwidth`.
#' @param fill_style Band fill: `"solid"` (default), `"hachure"`, or
#'   `"cross_hatch"`. Other styles degrade to `"hachure"`.
#' @param hachure_angle Fill line angle in degrees. Default 45.
#' @param hachure_gap Fill line gap (npc fraction). Default 0.04.
#' @param fill_weight Stroke weight for fill lines. Default 0.5.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(faithfuld, aes(waiting, eruptions, z = density)) +
#'   geom_sketch_contour_filled(seed = 1L) +
#'   theme_sketch()
geom_sketch_contour_filled <- function(mapping       = NULL,
                                       data          = NULL,
                                       stat          = "contour_filled",
                                       position      = "identity",
                                       ...,
                                       bins          = NULL,
                                       binwidth      = NULL,
                                       breaks        = NULL,
                                       roughness     = 0.7,
                                       bowing        = 0.5,
                                       n_passes      = 2L,
                                       seed          = NULL,
                                       fill_style    = "solid",
                                       hachure_angle = 45,
                                       hachure_gap   = 0.04,
                                       fill_weight   = 0.5,
                                       na.rm         = FALSE,
                                       show.legend   = NA,
                                       inherit.aes   = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat,
    geom = GeomSketchContourFilled,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      bins = bins, binwidth = binwidth, breaks = breaks,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, fill_style = fill_style, hachure_angle = hachure_angle,
      hachure_gap = hachure_gap, fill_weight = fill_weight, na.rm = na.rm, ...
    )
  )
}

#' @rdname geom_sketch_contour_filled
#' @export
geom_sketch_density_2d_filled <- function(mapping       = NULL,
                                          data          = NULL,
                                          stat          = "density_2d_filled",
                                          position      = "identity",
                                          ...,
                                          roughness     = 0.7,
                                          bowing        = 0.5,
                                          n_passes      = 2L,
                                          seed          = NULL,
                                          fill_style    = "solid",
                                          hachure_angle = 45,
                                          hachure_gap   = 0.04,
                                          fill_weight   = 0.5,
                                          na.rm         = FALSE,
                                          show.legend   = NA,
                                          inherit.aes   = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat,
    geom = GeomSketchContourFilled,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, fill_style = fill_style, hachure_angle = hachure_angle,
      hachure_gap = hachure_gap, fill_weight = fill_weight, na.rm = na.rm, ...
    )
  )
}

#' @rdname geom_sketch_contour_filled
#' @export
geom_sketch_density2d_filled <- geom_sketch_density_2d_filled
