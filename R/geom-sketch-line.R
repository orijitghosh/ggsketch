# Layer 3 — geom_sketch_line() and geom_sketch_path() (P2-T3)
# Uses only the public ggplot2 extension API (R6, ADR-0002).

# ---- GeomSketchPath ---------------------------------------------------------

#' @rdname geom_sketch_path
#' @export
GeomSketchPath <- ggplot2::ggproto(
  "GeomSketchPath", ggplot2::Geom,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    colour    = "black",
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA
  ),

  draw_key = draw_key_sketch_path,

  draw_group = function(data, panel_params, coord,
                         roughness = 1, bowing = 1, n_passes = 2L,
                         seed = NULL, ...) {
    if (nrow(data) < 2L) return(nullGrob())

    coords <- coord$transform(data, panel_params)
    sp     <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    sketch_path_grob(
      x         = coords$x,
      y         = coords$y,
      roughness = sp$roughness,
      bowing    = sp$bowing,
      n_passes  = sp$n_passes,
      seed      = sp$seed,
      gp        = outline_gpar(
        colour    = coords$colour[1L],
        linewidth = coords$linewidth[1L],
        linetype  = coords$linetype[1L],
        alpha     = coords$alpha[1L]
      )
    )
  }
)

# ---- geom_sketch_path -------------------------------------------------------

#' Sketchy path geom
#'
#' Draws a roughened, hand-drawn path connecting observations in order.
#' Equivalent to `geom_path()` with a sketch aesthetic.
#'
#' @param mapping Set of aesthetic mappings created by [ggplot2::aes()].
#' @param data Data to display.
#' @param stat Statistical transformation (default `"identity"`).
#' @param position Position adjustment (default `"identity"`).
#' @param roughness Non-negative roughness parameter (0 = straight). Default 1.
#' @param bowing Non-negative bowing multiplier. Default 1.
#' @param n_passes Number of stroke passes for the double-stroke effect.
#'   Default 2.
#' @param seed Integer seed for reproducibility. `NULL` uses
#'   `getOption("ggsketch.seed", 1L)`.
#' @param na.rm If `FALSE` (default), missing values are removed with a warning.
#' @param show.legend Logical. Should this layer be included in the legend?
#' @param inherit.aes If `FALSE`, override the default aesthetics.
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(economics, aes(date, unemploy)) +
#'   geom_sketch_path(roughness = 1.5, seed = 42L)
geom_sketch_path <- function(mapping     = NULL,
                               data        = NULL,
                               stat        = "identity",
                               position    = "identity",
                               ...,
                               roughness   = 1,
                               bowing      = 1,
                               n_passes    = 2L,
                               seed        = NULL,
                               na.rm       = FALSE,
                               show.legend = NA,
                               inherit.aes = TRUE) {
  ggplot2::layer(
    data        = data,
    mapping     = mapping,
    stat        = stat,
    geom        = GeomSketchPath,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = list(
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}

# ---- GeomSketchLine ---------------------------------------------------------

#' @rdname geom_sketch_line
#' @export
GeomSketchLine <- ggplot2::ggproto(
  "GeomSketchLine", GeomSketchPath,

  draw_panel = function(data, panel_params, coord,
                         roughness = 1, bowing = 1, n_passes = 2L,
                         seed = NULL, ...) {
    # Sort by x (like geom_line) then delegate to GeomSketchPath$draw_group
    data  <- data[order(data$x), , drop = FALSE]
    # Split by group, call draw_group on each
    groups <- split(seq_len(nrow(data)), data$group)
    grobs  <- lapply(seq_along(groups), function(gi) {
      idx <- groups[[gi]]
      GeomSketchPath$draw_group(
        data[idx, , drop = FALSE], panel_params, coord,
        roughness = roughness, bowing = bowing,
        n_passes  = n_passes,
        seed      = seed_offset(resolve_seed(seed), gi * 37L),
        ...
      )
    })
    do.call(grid::gList, grobs)
  }
)

#' Sketchy line geom
#'
#' Draws a roughened line connecting points in order of `x`. Equivalent to
#' `geom_line()` with a sketch aesthetic.
#'
#' @inheritParams geom_sketch_path
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(economics, aes(date, unemploy)) +
#'   geom_sketch_line(roughness = 1, seed = 1L)
geom_sketch_line <- function(mapping     = NULL,
                               data        = NULL,
                               stat        = "identity",
                               position    = "identity",
                               ...,
                               roughness   = 1,
                               bowing      = 1,
                               n_passes    = 2L,
                               seed        = NULL,
                               na.rm       = FALSE,
                               show.legend = NA,
                               inherit.aes = TRUE) {
  ggplot2::layer(
    data        = data,
    mapping     = mapping,
    stat        = stat,
    geom        = GeomSketchLine,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = list(
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
