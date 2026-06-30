# Layer 3 - the drawing-medium system (v2)
# `medium` is the orthogonal "how is the line laid down" axis: pen / ink / brush
# / pencil / charcoal / marker / crayon. It maps to a recipe of variable-width
# stroke parameters (width multiple, taper, pressure profile, pass count, alpha,
# cap, width jitter) that the geoms feed to sketch_stroke_grob(). `medium="pen"`
# is the historical constant-width double-stroke path, so existing plots are
# unchanged. Uses only the public ggplot2 API + Layer-1/2 grobs.

#' The available drawing media
#'
#' The valid values for the `medium` argument of the path-like sketch geoms.
#' `"pen"` is the default and reproduces the classic constant-width double
#' stroke; the others render through the variable-width [stroke_ribbon()] engine.
#'
#' @return A character vector of medium names.
#' @family sketch-media
#' @export
#' @examples
#' sketch_media()
sketch_media <- function() {
  c("pen", "ink", "fountain_pen", "ballpoint", "brush", "pencil",
    "charcoal", "pastel", "marker", "crayon")
}

#' Validate a `medium` choice
#' @noRd
check_medium <- function(x, arg = rlang::caller_arg(x),
                         call = rlang::caller_env()) {
  choices <- sketch_media()
  if (!is.character(x) || length(x) != 1L || !x %in% choices) {
    cli::cli_abort(
      "{.arg {arg}} must be one of {.or {choices}}, not {.val {x}}.",
      call = call
    )
  }
  invisible(x)
}

# Recipe for each medium. `width_mult` scales the base line width; `n_passes`
# overrides the geom's pass count (more passes + alpha_mult < 1 builds grainy
# tone for the dry media); `profile` is a stroke_profile() name or NULL.
#' @noRd
medium_spec <- function(medium) {
  switch(medium,
    pen      = list(width_mult = 1.0, taper = "none", taper_frac = 0,
                    profile = NULL,    n_passes = NA_integer_, alpha_mult = 1,
                    cap = "round", jitter_w = 0),
    ink      = list(width_mult = 1.6, taper = "both", taper_frac = 0.5,
                    profile = NULL,    n_passes = 1L, alpha_mult = 1,
                    cap = "round", jitter_w = 0.08),
    # Wet, crisp fountain line with mild ink pooling: thin even body that swells
    # at the ends (belly profile reversed via taper) and a touch of width jitter.
    fountain_pen = list(width_mult = 1.25, taper = "both", taper_frac = 0.55,
                    profile = NULL,    n_passes = 1L, alpha_mult = 1,
                    cap = "round", jitter_w = 0.12),
    # Thin, even, slightly skipping line: hard narrow stroke, faint single pass.
    ballpoint = list(width_mult = 0.65, taper = "none", taper_frac = 0,
                    profile = NULL,    n_passes = 1L, alpha_mult = 0.9,
                    cap = "round", jitter_w = 0.06),
    brush    = list(width_mult = 3.2, taper = "both", taper_frac = 0.15,
                    profile = "belly", n_passes = 1L, alpha_mult = 1,
                    cap = "round", jitter_w = 0.22),
    pencil   = list(width_mult = 0.9, taper = "both", taper_frac = 0.5,
                    profile = NULL,    n_passes = 3L, alpha_mult = 0.5,
                    cap = "round", jitter_w = 0.25),
    charcoal = list(width_mult = 3.4, taper = "both", taper_frac = 0.4,
                    profile = NULL,    n_passes = 2L, alpha_mult = 0.5,
                    cap = "round", jitter_w = 0.40),
    # Broad, soft, grainy and translucent - like charcoal but lighter-pressure:
    # wide stroke, heavy width jitter, low alpha built over several passes.
    pastel   = list(width_mult = 3.0, taper = "both", taper_frac = 0.5,
                    profile = NULL,    n_passes = 3L, alpha_mult = 0.4,
                    cap = "round", jitter_w = 0.48),
    marker   = list(width_mult = 2.6, taper = "none", taper_frac = 0,
                    profile = NULL,    n_passes = 2L, alpha_mult = 0.5,
                    cap = "butt",  jitter_w = 0.05),
    crayon   = list(width_mult = 2.0, taper = "both", taper_frac = 0.5,
                    profile = NULL,    n_passes = 2L, alpha_mult = 0.6,
                    cap = "round", jitter_w = 0.35)
  )
}

# Base line width in inches for a given `linewidth` aesthetic. grid `lwd` draws
# a line lwd/96 inches wide, and ggplot2 maps linewidth -> lwd via .pt.
#' @noRd
linewidth_to_inches <- function(linewidth) {
  linewidth * ggplot2::.pt / 96
}

#' Draw a path through the chosen medium
#'
#' Shared by the path-like sketch geoms. For `medium = "pen"` it returns the
#' historical [sketch_path_grob()] (constant width, unchanged output); for any
#' other medium it returns a variable-width [sketch_stroke_grob()] built from the
#' medium's recipe.
#'
#' @param x,y,id npc coordinates and optional group ids.
#' @param medium A value from [sketch_media()].
#' @param colour,linewidth,linetype,alpha Aesthetic values (scalars).
#' @param roughness,bowing,n_passes,seed Sketch parameters for the centreline.
#' @return A grid grob.
#' @noRd
sketch_medium_grob <- function(x, y, id = NULL,
                               medium    = "pen",
                               colour    = "black",
                               linewidth = 0.5,
                               linetype  = 1,
                               alpha     = NA,
                               roughness = 1,
                               bowing    = 1,
                               n_passes  = 2L,
                               seed      = NULL) {
  if (identical(medium, "pen")) {
    return(sketch_path_grob(
      x = x, y = y, id = id,
      roughness = roughness, bowing = bowing, n_passes = n_passes, seed = seed,
      gp = outline_gpar(colour = colour, linewidth = linewidth,
                        linetype = linetype, alpha = alpha)
    ))
  }

  spec     <- medium_spec(medium)
  width_in <- linewidth_to_inches(linewidth) * spec$width_mult
  a        <- if (is.na(alpha)) spec$alpha_mult else alpha * spec$alpha_mult
  pressure <- if (is.null(spec$profile)) NULL else stroke_profile(spec$profile)

  sketch_stroke_grob(
    x = x, y = y, id = id,
    width = width_in,
    roughness = roughness, bowing = bowing,
    n_passes = spec$n_passes, seed = seed,
    taper = spec$taper, taper_frac = spec$taper_frac,
    pressure = pressure, jitter_w = spec$jitter_w, cap = spec$cap,
    gp = gpar(col = colour, alpha = a)
  )
}
