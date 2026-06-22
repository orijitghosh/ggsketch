# Layer 3 - geom_sketch_hex() (Tier 3)
# Hexagonal binning: stat_binhex produces one row per hexagon (x, y centre,
# width, height, count). We build each hexagon as a 6-vertex polygon and route
# it through sketch_polygon_grob. Requires the optional 'hexbin' package (also
# required by stat_binhex itself).

# ---- GeomSketchHex ----------------------------------------------------------

#' @rdname geom_sketch_hex
#' @export
GeomSketchHex <- ggplot2::ggproto(
  "GeomSketchHex", ggplot2::Geom,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(colour = NA, fill = "grey50", linewidth = 0.5,
                             linetype = 1, alpha = NA),

  draw_key = draw_key_sketch_polygon,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight", "fill_roughness", "fill_seed", "na.rm")
  },

  draw_group = function(data, panel_params, coord,
                         roughness     = 1,
                         bowing        = 1,
                         n_passes      = 2L,
                         seed          = NULL,
                         fill_style    = "hachure",
                         hachure_angle = 45,
                         hachure_gap   = NULL,
                         fill_weight    = 0.5,
                         fill_roughness = NULL,
                         fill_seed      = NULL,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    # Hexagon offsets (matches ggplot2::GeomHex geometry).
    dx <- if (!is.null(data$width))  data$width[1L] / 2 else
            ggplot2::resolution(data$x, FALSE)
    dy <- if (!is.null(data$height)) data$height[1L] / 2 else
            ggplot2::resolution(data$y, FALSE) / sqrt(3) / 2 * 1.15
    hexC <- hexbin::hexcoords(dx, dy, n = 1)

    grobs <- lapply(seq_len(nrow(data)), function(i) {
      row  <- data[i, , drop = FALSE]
      poly <- coord$transform(
        data.frame(x = row$x + hexC$x, y = row$y + hexC$y),
        panel_params
      )
      gap <- hachure_gap %||% (abs(diff(range(poly$x))) * 0.2)
      sketch_polygon_grob(
        x = poly$x, y = poly$y,
        roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, i * 37L),
        fill_style = fill_style, hachure_angle = hachure_angle,
        hachure_gap = max(gap, 1e-3), fill_weight = fill_weight,
        fill_roughness = fill_roughness, fill_seed = fill_seed,
        fill_gp = gpar(col = scales::alpha(row$fill, row$alpha),
                       lineend = "round"),
        outline_gp = outline_gpar(row$colour %||% NA, row$linewidth,
                                  row$linetype, row$alpha)
      )
    })
    do.call(gList, grobs)
  }
)

# ---- geom_sketch_hex --------------------------------------------------------

#' Sketchy hexagonal heatmap
#'
#' Bins data into hexagons and draws each as a hand-drawn hexagon shaded by
#' count - the sketch analogue of [ggplot2::geom_hex()] / [ggplot2::stat_bin_hex()].
#' Requires the optional \pkg{hexbin} package.
#'
#' @inheritParams geom_sketch_col
#' @param bins Number of hexagons in each direction. Default 30.
#' @param binwidth Hexagon width(s); overrides `bins` when supplied.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' if (requireNamespace("hexbin", quietly = TRUE)) {
#'   ggplot(faithful, aes(eruptions, waiting)) +
#'     geom_sketch_hex(bins = 12, seed = 1L) +
#'     scale_fill_viridis_c() +
#'     theme_sketch()
#' }
geom_sketch_hex <- function(mapping       = NULL,
                            data          = NULL,
                            stat          = "binhex",
                            position      = "identity",
                            ...,
                            bins          = 30,
                            binwidth      = NULL,
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
  if (!requireNamespace("hexbin", quietly = TRUE)) {
    cli::cli_abort(c(
      "{.pkg hexbin} is required for {.fn geom_sketch_hex}.",
      "i" = 'Install it with {.run install.packages("hexbin")}.'
    ))
  }
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchHex,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      bins = bins, binwidth = binwidth,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, fill_style = fill_style, hachure_angle = hachure_angle,
      hachure_gap = hachure_gap, fill_weight = fill_weight, na.rm = na.rm, ...
    )
  )
}
