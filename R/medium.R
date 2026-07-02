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
    "charcoal", "pastel", "chalk", "marker", "highlighter", "crayon", "spray")
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
    # Dry stick dragged flat on a rough board: broad, streaky and dusty. Flat
    # ends (butt cap, no taper) and a ragged edge, plus a faint wide dust halo
    # (dust_* keys, composed in sketch_medium_grob) that pastel doesn't have.
    chalk    = list(width_mult = 2.2, taper = "none", taper_frac = 0,
                    profile = NULL,    n_passes = 2L, alpha_mult = 0.55,
                    cap = "butt",  jitter_w = 0.55,
                    dust_width_mult = 5.0, dust_alpha = 0.16,
                    dust_jitter = 0.9),
    marker   = list(width_mult = 2.6, taper = "none", taper_frac = 0,
                    profile = NULL,    n_passes = 2L, alpha_mult = 0.5,
                    cap = "butt",  jitter_w = 0.05),
    # Wide chisel-tip fluorescent band: one very translucent flat pass with
    # crisp edges, so it reads as a swipe OVER the mark rather than a line.
    highlighter = list(width_mult = 4.2, taper = "none", taper_frac = 0,
                    profile = NULL,    n_passes = 1L, alpha_mult = 0.35,
                    cap = "butt",  jitter_w = 0.03),
    crayon   = list(width_mult = 2.0, taper = "both", taper_frac = 0.5,
                    profile = NULL,    n_passes = 2L, alpha_mult = 0.6,
                    cap = "round", jitter_w = 0.35),
    # Airbrush: not a ribbon at all - a soft cloud of dots scattered around the
    # centreline (see sketch_spray_grob / spray_scatter). The standard ribbon
    # keys are kept (so the spec stays uniform) but unused; the spray_* keys
    # drive the scatter. width_mult sets the base dot/cloud scale off linewidth.
    spray    = list(width_mult = 1.0, taper = "none", taper_frac = 0,
                    profile = NULL,    n_passes = 1L, alpha_mult = 0.45,
                    cap = "round", jitter_w = 0,
                    spread_mult = 1.8, density = 220, dot_r_mult = 0.55)
  )
}

# Base line width in inches for a given `linewidth` aesthetic. grid `lwd` draws
# a line lwd/96 inches wide, and ggplot2 maps linewidth -> lwd via .pt.
#' @noRd
linewidth_to_inches <- function(linewidth) {
  linewidth * ggplot2::.pt / 96
}

# Turn per-vertex pressure values (already scaled to width multipliers by
# scale_pressure_continuous) into a vectorised profile f(t) over normalised
# arc-length, so it survives the centreline being resampled by roughen_polyline.
# `x`,`y` are the original vertices (any consistent space; only their relative
# spacing matters for where each pressure sample lands along the line).
#' @noRd
make_pressure_fn <- function(pvals, x, y) {
  pvals <- as.double(pvals)
  n <- length(pvals)
  if (n < 2L) {
    v <- if (n == 1L && is.finite(pvals[1L])) pvals[1L] else 1
    return(function(t) rep(v, length(t)))
  }
  seg <- sqrt(diff(x)^2 + diff(y)^2)
  s   <- c(0, cumsum(seg))
  tot <- s[n]
  t0  <- if (tot > 0) s / tot else seq(0, 1, length.out = n)
  fill <- mean(pvals[is.finite(pvals)])
  if (!is.finite(fill)) fill <- 1
  f <- stats::approxfun(t0, pvals, rule = 2, ties = mean)
  function(t) {
    v <- f(t)
    v[!is.finite(v)] <- fill
    pmax(0, v)
  }
}

# Multiply two optional pressure profiles (NULL acts as the identity).
#' @noRd
compose_pressure <- function(a, b) {
  if (is.null(a)) return(b)
  if (is.null(b)) return(a)
  function(t) a(t) * b(t)
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
#' @param pressure_var Optional per-vertex width multipliers (a `pressure`
#'   aesthetic, already rescaled). When supplied, the line renders through the
#'   variable-width engine -- even for `medium = "pen"` -- with the width
#'   modulated along the stroke. Its profile multiplies the medium's own.
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
                               seed      = NULL,
                               pressure_var = NULL) {
  # Airbrush / spray: a dot cloud, not a stroked line (ignores pressure).
  if (identical(medium, "spray")) {
    spec     <- medium_spec("spray")
    width_in <- linewidth_to_inches(linewidth) * spec$width_mult
    a        <- if (is.na(alpha)) spec$alpha_mult else alpha * spec$alpha_mult
    return(sketch_spray_grob(
      x = x, y = y, id = id,
      spread = width_in * spec$spread_mult,
      density = spec$density,
      dot_r = width_in * spec$dot_r_mult,
      roughness = roughness, bowing = bowing, n_passes = n_passes, seed = seed,
      gp = gpar(col = colour, alpha = a)
    ))
  }

  has_press <- !is.null(pressure_var) && length(pressure_var) == length(x) &&
    any(is.finite(pressure_var))

  # Constant-width pen with no pressure mapping = the historical path grob.
  if (identical(medium, "pen") && !has_press) {
    return(sketch_path_grob(
      x = x, y = y, id = id,
      roughness = roughness, bowing = bowing, n_passes = n_passes, seed = seed,
      gp = outline_gpar(colour = colour, linewidth = linewidth,
                        linetype = linetype, alpha = alpha)
    ))
  }

  # `pen` carries no ribbon recipe; a neutral one (constant width, no taper /
  # jitter) lets a pressure mapping vary an otherwise-plain pen line.
  spec <- if (identical(medium, "pen")) {
    list(width_mult = 1, taper = "none", taper_frac = 0, profile = NULL,
         n_passes = n_passes, alpha_mult = 1, cap = "round", jitter_w = 0)
  } else {
    medium_spec(medium)
  }

  width_in    <- linewidth_to_inches(linewidth) * spec$width_mult
  a           <- if (is.na(alpha)) spec$alpha_mult else alpha * spec$alpha_mult
  prof_medium <- if (is.null(spec$profile)) NULL else stroke_profile(spec$profile)
  prof_press  <- if (has_press) make_pressure_fn(pressure_var, x, y) else NULL
  pressure    <- compose_pressure(prof_medium, prof_press)

  core <- sketch_stroke_grob(
    x = x, y = y, id = id,
    width = width_in,
    roughness = roughness, bowing = bowing,
    n_passes = spec$n_passes, seed = seed,
    taper = spec$taper, taper_frac = spec$taper_frac,
    pressure = pressure, jitter_w = spec$jitter_w, cap = spec$cap,
    gp = gpar(col = colour, alpha = a)
  )
  if (is.null(spec$dust_width_mult)) return(core)

  # Dust halo (chalk): one faint, much wider and more ragged pass under the
  # core stroke, like powder settling either side of the drawn line.
  a_dust <- if (is.na(alpha)) spec$dust_alpha else alpha * spec$dust_alpha
  dust <- sketch_stroke_grob(
    x = x, y = y, id = id,
    width = linewidth_to_inches(linewidth) * spec$dust_width_mult,
    roughness = roughness, bowing = bowing,
    n_passes = 1L, seed = seed_offset(seed %||% getOption("ggsketch.seed", 1L), 91L),
    taper = spec$taper, taper_frac = spec$taper_frac,
    pressure = pressure, jitter_w = spec$dust_jitter, cap = spec$cap,
    gp = gpar(col = colour, alpha = a_dust)
  )
  grid::grobTree(dust, core)
}
