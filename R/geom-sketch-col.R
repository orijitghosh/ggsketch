# Layer 3 - geom_sketch_col() / geom_sketch_bar() (P3-T2)
# Each bar is a roughened polygon with hachure fill via sketch_polygon_grob().

# ---- GeomSketchCol ----------------------------------------------------------

#' @rdname geom_sketch_col
#' @export
GeomSketchCol <- ggplot2::ggproto(
  "GeomSketchCol", ggplot2::Geom,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    colour      = "black",
    fill        = "grey65",
    linewidth   = 0.5,
    linetype    = 1,
    alpha       = NA
  ),

  draw_key = draw_key_sketch_polygon,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight", "width",
      "na.rm")
  },

  setup_data = function(data, params) {
    data$width <- data$width %||%
      params$width %||%
      (ggplot2::resolution(data$x, FALSE) * 0.9)
    transform(
      data,
      xmin  = x - width / 2,
      xmax  = x + width / 2,
      ymin  = pmin(y, 0),
      ymax  = pmax(y, 0),
      width = NULL
    )
  },

  draw_panel = function(data, panel_params, coord,
                         roughness     = 1,
                         bowing        = 1,
                         n_passes      = 2L,
                         seed          = NULL,
                         fill_style    = "hachure",
                         hachure_angle = 45,
                         hachure_gap   = NULL,
                         fill_weight   = 0.5,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())

    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    grobs <- lapply(seq_len(nrow(data)), function(i) {
      row  <- data[i, , drop = FALSE]
      gap  <- hachure_gap %||% (abs(row$xmax - row$xmin) * 0.15)

      # Rectangle corners (closed)
      px <- c(row$xmin, row$xmax, row$xmax, row$xmin)
      py <- c(row$ymin, row$ymin, row$ymax, row$ymax)
      pts <- coord$transform(
        data.frame(x = px, y = py, stringsAsFactors = FALSE),
        panel_params
      )

      fill_col <- scales::alpha(row$fill, row$alpha)
      out_col  <- scales::alpha(row$colour, row$alpha)

      sketch_polygon_grob(
        x             = pts$x,
        y             = pts$y,
        roughness     = sp$roughness,
        bowing        = sp$bowing,
        n_passes      = sp$n_passes,
        seed          = seed_offset(sp$seed, i * 97L),
        fill_style    = fill_style,
        hachure_angle = hachure_angle,
        hachure_gap   = gap,
        fill_weight   = fill_weight,
        fill_gp       = gpar(col = fill_col, lineend = "round"),
        outline_gp    = gpar(
          col = out_col,
          lwd = row$linewidth * ggplot2::.pt,
          lty = row$linetype,
          lineend = "round",
          linejoin = "round"
        )
      )
    })

    do.call(gList, grobs)
  }
)

# ---- geom_sketch_col --------------------------------------------------------

#' Sketchy column / bar geom
#'
#' Draws vertical bars with a hand-drawn roughened outline and an optional
#' hachure, cross-hatch, zigzag, dots, or dashed fill pattern.  Use
#' `geom_sketch_col()` when the bar heights are already in the data; use
#' `geom_sketch_bar()` to count observations automatically.
#'
#' @param mapping Set of aesthetic mappings created by [ggplot2::aes()].
#' @param data Data to display.
#' @param stat Statistical transformation.  Default `"identity"` for
#'   `geom_sketch_col()`; `"count"` for `geom_sketch_bar()`.
#' @param position Position adjustment.  Default `"stack"`.
#' @param roughness Non-negative roughness (0 = straight lines). Default 1.
#' @param bowing Non-negative bowing multiplier. Default 1.
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param fill_style One of `"hachure"`, `"cross_hatch"`, `"zigzag"`,
#'   `"zigzag_line"`, `"scribble"`, `"dots"`, `"dashed"`, or `"solid"`. Default `"hachure"`.
#' @param hachure_angle Fill line angle in degrees. Default 45.
#' @param hachure_gap Fill line gap in data units (`NULL` = 15% of bar width).
#' @param fill_weight Stroke weight for fill lines. Default 0.5.
#' @param width Bar width override. `NULL` uses 90% of resolution.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend?
#' @param inherit.aes Override default aesthetics?
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(x = c("A","B","C","D"), y = c(3, 5, 2, 6))
#' ggplot(df, aes(x, y)) +
#'   geom_sketch_col(fill_style = "hachure", seed = 1L) +
#'   theme_sketch()
geom_sketch_col <- function(mapping       = NULL,
                              data          = NULL,
                              stat          = "identity",
                              position      = "stack",
                              ...,
                              roughness     = 1,
                              bowing        = 1,
                              n_passes      = 2L,
                              seed          = NULL,
                              fill_style    = "hachure",
                              hachure_angle = 45,
                              hachure_gap   = NULL,
                              fill_weight   = 0.5,
                              width         = NULL,
                              na.rm         = FALSE,
                              show.legend   = NA,
                              inherit.aes   = TRUE) {
  ggplot2::layer(
    data        = data,
    mapping     = mapping,
    stat        = stat,
    geom        = GeomSketchCol,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = list(
      roughness     = roughness,
      bowing        = bowing,
      n_passes      = as.integer(n_passes),
      seed          = seed,
      fill_style    = fill_style,
      hachure_angle = hachure_angle,
      hachure_gap   = hachure_gap,
      fill_weight   = fill_weight,
      width         = width,
      na.rm         = na.rm,
      ...
    )
  )
}

#' @rdname geom_sketch_col
#' @export
geom_sketch_bar <- function(mapping       = NULL,
                              data          = NULL,
                              stat          = "count",
                              position      = "stack",
                              ...,
                              roughness     = 1,
                              bowing        = 1,
                              n_passes      = 2L,
                              seed          = NULL,
                              fill_style    = "hachure",
                              hachure_angle = 45,
                              hachure_gap   = NULL,
                              fill_weight   = 0.5,
                              width         = NULL,
                              na.rm         = FALSE,
                              show.legend   = NA,
                              inherit.aes   = TRUE) {
  ggplot2::layer(
    data        = data,
    mapping     = mapping,
    stat        = stat,
    geom        = GeomSketchCol,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = list(
      roughness     = roughness,
      bowing        = bowing,
      n_passes      = as.integer(n_passes),
      seed          = seed,
      fill_style    = fill_style,
      hachure_angle = hachure_angle,
      hachure_gap   = hachure_gap,
      fill_weight   = fill_weight,
      width         = width,
      na.rm         = na.rm,
      ...
    )
  )
}
