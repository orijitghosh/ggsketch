# Layer 3 - geom_sketch_line() and geom_sketch_path() (P2-T3)
# Uses only the public ggplot2 extension API (R6, ADR-0002).

# ---- GeomSketchPath ---------------------------------------------------------

#' @rdname geom_sketch_path
#' @export
GeomSketchPath <- ggplot2::ggproto(
  "GeomSketchPath", ggplot2::Geom,

  required_aes = c("x", "y"),

  # `medium` is an optional, mappable aesthetic (one medium per group). Listing
  # it here means a mapped `aes(medium = )` is recognised (no "unknown
  # aesthetic" warning); when unmapped the `medium` layer param supplies it.
  optional_aes = "medium",

  default_aes = ggplot2::aes(
    colour    = "black",
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA
  ),

  draw_key = draw_key_sketch_medium,

  draw_group = function(data, panel_params, coord,
                         roughness = 1, bowing = 1, n_passes = 2L,
                         seed = NULL, medium = "pen", ...) {
    if (nrow(data) < 2L) return(nullGrob())

    coords <- coord$transform(data, panel_params)
    sp     <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    # a mapped `medium` aesthetic (per group) overrides the layer param
    medium <- if (!is.null(coords$medium)) as.character(coords$medium[1L])
              else medium
    check_medium(medium)

    sketch_medium_grob(
      x         = coords$x,
      y         = coords$y,
      medium    = medium,
      colour    = coords$colour[1L],
      linewidth = coords$linewidth[1L],
      linetype  = coords$linetype[1L],
      alpha     = coords$alpha[1L],
      roughness = sp$roughness,
      bowing    = sp$bowing,
      n_passes  = sp$n_passes,
      seed      = sp$seed
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
#' @param medium Drawing medium for the stroke: one of [sketch_media()]
#'   (`"pen"`, `"ink"`, `"brush"`, `"pencil"`, `"charcoal"`, `"marker"`,
#'   `"crayon"`). `NULL` (default) uses `"pen"`, the classic constant-width
#'   double stroke; the others render through the variable-width
#'   [stroke_ribbon()] engine (tapered ink, brushy swells, grainy
#'   pencil/charcoal, ...). `medium` is also a mappable aesthetic: map it with
#'   `aes(medium = )` (one medium per group) and control the mapping with
#'   [scale_medium_discrete()].
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
                               medium      = NULL,
                               na.rm       = FALSE,
                               show.legend = NA,
                               inherit.aes = TRUE) {
  # `medium` is also a mappable aesthetic; only push it as a constant param when
  # supplied, so it doesn't override an `aes(medium = )` mapping.
  params <- list(
    roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed, na.rm = na.rm, ...
  )
  if (!is.null(medium)) params$medium <- medium
  ggplot2::layer(
    data        = data,
    mapping     = mapping,
    stat        = stat,
    geom        = GeomSketchPath,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = params
  )
}

# ---- GeomSketchLine ---------------------------------------------------------

#' @rdname geom_sketch_line
#' @export
GeomSketchLine <- ggplot2::ggproto(
  "GeomSketchLine", GeomSketchPath,

  draw_panel = function(data, panel_params, coord,
                         roughness = 1, bowing = 1, n_passes = 2L,
                         seed = NULL, medium = "pen", ...) {
    # Sort by x (like geom_line) then delegate to GeomSketchPath$draw_group
    data  <- data[order(data$x), , drop = FALSE]
    # Split by group, call draw_group on each
    groups <- split(seq_len(nrow(data)), data$group)
    grobs  <- lapply(seq_along(groups), function(gi) {
      idx <- groups[[gi]]
      GeomSketchPath$draw_group(
        data[idx, , drop = FALSE], panel_params, coord,
        roughness = roughness, bowing = bowing,
        n_passes  = n_passes, medium = medium,
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
#' @return A `ggplot2` layer (a `LayerInstance` object) that can be added to a
#'   plot with `+`.
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
                               medium      = NULL,
                               na.rm       = FALSE,
                               show.legend = NA,
                               inherit.aes = TRUE) {
  params <- list(
    roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed, na.rm = na.rm, ...
  )
  if (!is.null(medium)) params$medium <- medium
  ggplot2::layer(
    data        = data,
    mapping     = mapping,
    stat        = stat,
    geom        = GeomSketchLine,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = params
  )
}
