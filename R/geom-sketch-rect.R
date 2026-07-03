# Layer 3 - geom_sketch_rect() / geom_sketch_tile() (P3-T1)
# Hachure-filled rectangles with a roughened outline, via sketch_polygon_grob().

# ---- GeomSketchRect ---------------------------------------------------------

#' @rdname geom_sketch_rect
#' @export
GeomSketchRect <- ggplot2::ggproto(
  "GeomSketchRect", ggplot2::Geom,

  required_aes = c("xmin", "xmax", "ymin", "ymax"),

  default_aes = ggplot2::aes(
    colour    = "black",
    fill      = "grey65",
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA,
    roughness = 1
  ),

  draw_key = draw_key_sketch_polygon,

  # roughness is a mappable aesthetic (per rectangle); the rest stay params.
  parameters = function(self, extra = FALSE) {
    c("bowing", "n_passes", "seed",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight", "fill_roughness", "fill_seed",
      "corner_radius", "na.rm")
  },

  draw_panel = function(data, panel_params, coord,
                         roughness     = 1,
                         bowing        = 1,
                         n_passes      = 2L,
                         seed          = NULL,
                         fill_style    = "hachure",
                         hachure_angle = 45,
                         hachure_gap    = NULL,
                         fill_weight    = 0.5,
                         fill_roughness = NULL,
                         fill_seed      = NULL,
                         corner_radius  = 0,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())

    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    grobs <- lapply(seq_len(nrow(data)), function(i) {
      row <- data[i, , drop = FALSE]

      bnd <- rect_boundary(row$xmin, row$xmax, row$ymin, row$ymax, corner_radius)
      # Under a nonlinear coord (e.g. coord_polar) straight edges must bend:
      # add intermediate vertices so the transform can curve them into arcs.
      if (!coord$is_linear()) bnd <- densify_closed(bnd$x, bnd$y)
      pts <- coord$transform(
        data.frame(x = bnd$x, y = bnd$y, stringsAsFactors = FALSE),
        panel_params
      )

      fill_col <- scales::alpha(row$fill, row$alpha)
      out_col  <- scales::alpha(row$colour, row$alpha)

      sketch_polygon_grob(
        x             = pts$x,
        y             = pts$y,
        roughness     = max(row$roughness, 0),
        bowing        = sp$bowing,
        n_passes      = sp$n_passes,
        seed          = seed_offset(sp$seed, i * 97L),
        fill_style    = fill_style,
        hachure_angle = hachure_angle,
        hachure_gap    = hachure_gap,
        fill_weight    = fill_weight,
        fill_roughness = fill_roughness,
        fill_seed      = fill_seed,
        fill_gp        = gpar(col = fill_col, lineend = "round"),
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

# ---- geom_sketch_rect -------------------------------------------------------

#' Sketchy rectangle / tile geom
#'
#' Draws filled rectangles with a hand-drawn roughened outline and a hachure,
#' cross-hatch, zigzag, dots, dashed, or solid fill.  `geom_sketch_rect()` takes
#' the `xmin`/`xmax`/`ymin`/`ymax` aesthetics; `geom_sketch_tile()` takes
#' `x`/`y` centres with optional `width`/`height` (like [ggplot2::geom_tile()]).
#'
#' @param mapping Set of aesthetic mappings created by [ggplot2::aes()].
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param roughness Non-negative roughness (0 = straight). A mappable aesthetic
#'   (default 1): pass a constant, or map it per rectangle with
#'   `aes(roughness = )` (rescaled by [scale_roughness_continuous()]).
#' @param bowing Non-negative bowing multiplier. Default 1.
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param fill_style One of `"hachure"`, `"cross_hatch"`, `"zigzag"`,
#'   `"zigzag_line"`, `"scribble"`, `"dots"`, `"dashed"`, `"stipple"`, `"pencil_shade"`, or `"solid"`. Default `"hachure"`.
#' @param hachure_angle Fill line angle in degrees. Default 45.
#' @param hachure_gap Fill line gap in device inches (`NULL` = 15% of the
#'   rectangle's smaller drawn side, clamped to \[0.04, 0.4\] inches).
#' @param fill_weight Stroke weight for fill lines. Default 0.5.
#' @param corner_radius Corner rounding as a fraction \[0, 1\] of each
#'   half-side. `0` (default) gives sharp corners; `1` fully rounds the ends.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend?
#' @param inherit.aes Override default aesthetics?
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(xmin = 1, xmax = 3, ymin = 1, ymax = 4)
#' ggplot(df) +
#'   geom_sketch_rect(aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
#'                    corner_radius = 0.3, seed = 1L) +
#'   theme_sketch()
geom_sketch_rect <- function(mapping       = NULL,
                              data          = NULL,
                              stat          = "identity",
                              position      = "identity",
                              ...,
                              roughness     = NULL,
                              bowing        = 1,
                              n_passes      = 2L,
                              seed          = NULL,
                              fill_style    = "hachure",
                              hachure_angle = 45,
                              hachure_gap   = NULL,
                              fill_weight   = 0.5,
                              corner_radius = 0,
                              na.rm         = FALSE,
                              show.legend   = NA,
                              inherit.aes   = TRUE) {
  # roughness is a mappable aesthetic: pushed as a constant only when supplied.
  params <- list(
    bowing        = bowing,
    n_passes      = as.integer(n_passes),
    seed          = seed,
    fill_style    = fill_style,
    hachure_angle = hachure_angle,
    hachure_gap   = hachure_gap,
    fill_weight   = fill_weight,
    corner_radius = corner_radius,
    na.rm         = na.rm,
    ...
  )
  if (!is.null(roughness)) params$roughness <- roughness
  ggplot2::layer(
    data        = data,
    mapping     = mapping,
    stat        = stat,
    geom        = GeomSketchRect,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = params
  )
}

# ---- GeomSketchTile ---------------------------------------------------------

#' @rdname geom_sketch_rect
#' @export
GeomSketchTile <- ggplot2::ggproto(
  "GeomSketchTile", GeomSketchRect,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    colour    = NA,
    fill      = "grey65",
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA,
    roughness = 1
  ),

  parameters = function(self, extra = FALSE) {
    c("bowing", "n_passes", "seed",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight", "fill_roughness", "fill_seed",
      "corner_radius", "width", "height", "na.rm")
  },

  setup_data = function(data, params) {
    data$width  <- data$width  %||% params$width  %||%
      ggplot2::resolution(data$x, FALSE)
    data$height <- data$height %||% params$height %||%
      ggplot2::resolution(data$y, FALSE)
    transform(
      data,
      xmin = x - width / 2,  xmax = x + width / 2,
      ymin = y - height / 2, ymax = y + height / 2,
      width = NULL, height = NULL
    )
  }
)

#' @rdname geom_sketch_rect
#' @param width,height Tile size overrides for `geom_sketch_tile()`. `NULL`
#'   uses the data resolution.
#' @export
geom_sketch_tile <- function(mapping       = NULL,
                              data          = NULL,
                              stat          = "identity",
                              position      = "identity",
                              ...,
                              width         = NULL,
                              height        = NULL,
                              roughness     = NULL,
                              bowing        = 1,
                              n_passes      = 2L,
                              seed          = NULL,
                              fill_style    = "hachure",
                              hachure_angle = 45,
                              hachure_gap   = NULL,
                              fill_weight   = 0.5,
                              corner_radius = 0,
                              na.rm         = FALSE,
                              show.legend   = NA,
                              inherit.aes   = TRUE) {
  # roughness is a mappable aesthetic: pushed as a constant only when supplied.
  params <- list(
    width         = width,
    height        = height,
    bowing        = bowing,
    n_passes      = as.integer(n_passes),
    seed          = seed,
    fill_style    = fill_style,
    hachure_angle = hachure_angle,
    hachure_gap   = hachure_gap,
    fill_weight   = fill_weight,
    corner_radius = corner_radius,
    na.rm         = na.rm,
    ...
  )
  if (!is.null(roughness)) params$roughness <- roughness
  ggplot2::layer(
    data        = data,
    mapping     = mapping,
    stat        = stat,
    geom        = GeomSketchTile,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = params
  )
}
