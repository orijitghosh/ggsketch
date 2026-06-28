# Layer 3 - sketchy legend keys (P5-T5)
# Custom draw_key functions so legends match the hand-drawn body of each geom.
# Each returns a grid grob drawn in the key viewport (npc [0,1]); the Layer-2
# grobs convert npc -> inches inside that viewport via makeContent().

#' Sketchy legend keys
#'
#' `draw_key_*` functions used by the sketch geoms so their legends render with
#' the same hand-drawn character.  Not called directly; passed as the `draw_key`
#' field of a geom (see [ggplot2::draw_key]).
#'
#' @param data A single-row data frame of the key's aesthetics.
#' @param params The layer's parameter list (roughness, seed, fill_style, ...).
#' @param size Key size in mm (unused; kept for the draw_key contract).
#' @return A grid grob.
#' @name draw_key_sketch
#' @keywords internal
NULL

#' @rdname draw_key_sketch
#' @export
draw_key_sketch_path <- function(data, params, size) {
  sketch_path_grob(
    x         = c(0.1, 0.4, 0.6, 0.9),
    y         = c(0.5, 0.55, 0.45, 0.5),
    roughness = params$roughness %||% 1,
    bowing    = params$bowing %||% 1,
    n_passes  = params$n_passes %||% 2L,
    seed      = params$seed %||% 1L,
    gp        = outline_gpar(
      colour    = data$colour %||% "black",
      linewidth = (data$linewidth %||% 0.5),
      linetype  = data$linetype %||% 1,
      alpha     = data$alpha
    )
  )
}

#' @rdname draw_key_sketch
#' @export
draw_key_sketch_medium <- function(data, params, size) {
  medium <- data$medium %||% params$medium %||% "pen"
  if (!is.character(medium) || length(medium) != 1L ||
      !medium %in% sketch_media()) {
    medium <- "pen"
  }
  sketch_medium_grob(
    x         = c(0.1, 0.4, 0.6, 0.9),
    y         = c(0.5, 0.55, 0.45, 0.5),
    medium    = medium,
    colour    = data$colour %||% "black",
    linewidth = data$linewidth %||% 0.5,
    linetype  = data$linetype %||% 1,
    alpha     = data$alpha,
    roughness = params$roughness %||% 1,
    bowing    = params$bowing %||% 1,
    n_passes  = params$n_passes %||% 2L,
    seed      = params$seed %||% 1L
  )
}

#' @rdname draw_key_sketch
#' @export
draw_key_sketch_point <- function(data, params, size) {
  sketch_point_grob(
    x         = 0.5,
    y         = 0.5,
    size      = (data$size %||% 1.5) * 1.2,
    roughness = params$roughness %||% 0.5,
    n_passes  = params$n_passes %||% 2L,
    seed      = params$seed %||% 1L,
    gp        = gpar(
      col     = scales::alpha(data$colour %||% "black", data$alpha %||% NA),
      lwd     = (data$stroke %||% 0.5) * ggplot2::.pt,
      lineend = "round"
    )
  )
}

#' @rdname draw_key_sketch
#' @export
draw_key_sketch_polygon <- function(data, params, size) {
  fill_style <- params$fill_style %||% "hachure"
  has_fill   <- !is.null(data$fill) && !all(is.na(data$fill))
  sketch_polygon_grob(
    x             = c(0.12, 0.88, 0.88, 0.12),
    y             = c(0.12, 0.12, 0.88, 0.88),
    roughness     = params$roughness %||% 1,
    bowing        = params$bowing %||% 1,
    n_passes      = params$n_passes %||% 2L,
    seed          = params$seed %||% 1L,
    fill_style    = if (has_fill) fill_style else "solid",
    hachure_angle = params$hachure_angle %||% 45,
    hachure_gap   = 0.22,
    fill_weight   = params$fill_weight %||% 0.5,
    fill_gp       = gpar(
      col = scales::alpha(data$fill %||% "grey65", data$alpha %||% NA),
      lineend = "round"
    ),
    outline_gp    = outline_gpar(
      colour    = data$colour %||% "black",
      linewidth = (data$linewidth %||% 0.5),
      linetype  = data$linetype %||% 1,
      alpha     = data$alpha
    )
  )
}
