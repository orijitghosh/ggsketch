# Layer 3 - gganimate bridge (v2.0 Tier D: motion)
# animate_sketch() boils a *static* plot. This bridges the other family of
# motion: gganimate's data transitions (bars growing, points flying between
# states, lines drawing along x). gganimate renders ggsketch geoms statically
# per frame just fine; what it cannot do on its own is make the hand-drawn
# wobble re-draw each frame. boil_gganimate() adds exactly that, on top of any
# gganimate transition, by advancing the global `ggsketch.seed_jitter` once per
# frame as gganimate draws it - so the data tweens AND the lines boil together.
#
# Mechanism: prerender the animation, wrap the scene's per-frame draw to step the
# seed jitter (keyed to a frame counter, so frame 1 is the un-boiled render and
# the sequence is fully reproducible), let gganimate draw the frames, then stitch
# them with the same assembler animate_sketch() uses. gganimate is an optional
# Suggests; everything degrades to a clear error if it is missing.

# Fetch a gganimate internal, with a clear message if the package is absent or
# its internals have moved (so the bridge fails loudly, never silently wrong).
gganimate_internal <- function(name, call = rlang::caller_env()) {
  if (!requireNamespace("gganimate", quietly = TRUE)) {
    cli::cli_abort(c(
      "{.pkg gganimate} is required for {.fn boil_gganimate}.",
      "i" = 'Install it with {.run install.packages("gganimate")}.'
    ), call = call)
  }
  fn <- tryCatch(utils::getFromNamespace(name, "gganimate"),
                 error = function(e) NULL)
  if (!is.function(fn)) {
    cli::cli_abort(c(
      "This version of {.pkg gganimate} is not compatible with the ggsketch bridge.",
      "x" = "Could not find the internal {.fn {name}} it relies on.",
      "i" = "Please report this at the ggsketch issue tracker."
    ), call = call)
  }
  fn
}

#' Boil a gganimate animation (sketch wobble + data transitions)
#'
#' Render a \pkg{gganimate} animation - any plot built with ggsketch geoms plus a
#' `transition_*()` - so that, on top of gganimate's data tweening, the
#' hand-drawn lines *boil*: every roughening seed is shifted once per frame, so
#' the drawing shimmers and re-draws itself like a hand-animated cel while the
#' bars grow, points fly, or a line draws itself along `x`. It is the moving-data
#' companion to [animate_sketch()], which boils a static plot.
#'
#' The boil rides on the global `ggsketch.seed_jitter` option (the same lever
#' [animate_sketch()] uses), advanced by a per-frame counter so frame 1 is the
#' un-boiled drawing and the whole animation is reproducible. Frames are stitched
#' with the same backend as [animate_sketch()] (\pkg{gifski} or \pkg{magick});
#' if neither is installed the frame paths are returned. \pkg{gganimate} itself
#' is an optional dependency.
#'
#' @param animation A \pkg{gganimate} animation: a ggplot using ggsketch geoms
#'   with a `transition_*()` added (class `gganim`).
#' @param nframes Number of frames. Default 100 (gganimate's default).
#' @param fps Frames per second in the output. Default 10.
#' @param intensity Boil strength: scales how far the seed jitter steps each
#'   frame. 1 (default) matches [animate_sketch()]; higher shimmers more.
#' @param detail Tween sub-frames per frame, passed through to gganimate's
#'   prerender for smoother motion (rendered frames are sampled back down to
#'   `nframes`). Default 1.
#' @param file Output path (e.g. a `.gif`). If `NULL` (default), no file is
#'   written and the frame paths are returned invisibly.
#' @param width,height,units,res Frame size and resolution. `units` one of
#'   `"in"`, `"cm"`, `"mm"`, `"px"`.
#' @param background Frame background colour. Default `"white"`.
#' @param device Graphics device: `NULL` (default; `"ragg"` when installed, else
#'   `"png"`), `"ragg"`/`"png"`, or any device string gganimate accepts
#'   (`"ragg_png"`, `"svglite"`, ...).
#' @param seed Integer offset for the boil sequence (`NULL` = 0, so frame 1 is
#'   un-boiled). Change it to vary the shimmer without touching the plot.
#' @param renderer GIF backend: `"auto"` (default), `"gifski"`, `"magick"`, or
#'   `"none"` (always return frame paths).
#' @param loop Loop the output forever? Default `TRUE`.
#' @return Invisibly, the output path (when written) or a character vector of
#'   frame image paths.
#' @seealso [animate_sketch()] for boiling or drawing-on a static plot.
#' @export
#' @examplesIf requireNamespace("gganimate", quietly = TRUE) && requireNamespace("gifski", quietly = TRUE)
#' \donttest{
#' library(ggplot2)
#' library(gganimate)
#' p <- ggplot(mpg, aes(class, fill = drv)) +
#'   geom_sketch_bar(position = "dodge", seed = 1L) +
#'   scale_fill_sketch() +
#'   theme_sketch() +
#'   transition_states(drv, transition_length = 2, state_length = 1)
#' boil_gganimate(p, nframes = 30, file = tempfile(fileext = ".gif"))
#' }
boil_gganimate <- function(animation,
                           nframes    = 100L,
                           fps        = 10,
                           intensity  = 1,
                           detail     = 1L,
                           file       = NULL,
                           width      = 7,
                           height     = 5,
                           units      = "in",
                           res        = 120,
                           background = "white",
                           device     = NULL,
                           seed       = NULL,
                           renderer   = c("auto", "gifski", "magick", "none"),
                           loop       = TRUE) {
  renderer <- match.arg(renderer)
  if (!inherits(animation, "gganim")) {
    cli::cli_abort(c(
      "{.arg animation} must be a {.pkg gganimate} animation.",
      "i" = "Add a {.fn transition_*} (e.g. {.fn transition_states}) to your ggsketch plot."
    ))
  }
  nframes   <- max(2L, as.integer(nframes))
  detail    <- max(1L, as.integer(detail))
  intensity <- max(0, intensity)
  start     <- as.integer((seed %||% 0L)[[1L]])

  prerender   <- gganimate_internal("prerender")
  get_nframes <- gganimate_internal("get_nframes")
  draw_frames <- gganimate_internal("draw_frames")

  # Map our device names to gganimate's device strings.
  dev <- device %||% (if (requireNamespace("ragg", quietly = TRUE)) "ragg" else "png")
  dev <- switch(dev, ragg = "ragg_png", png = "png", dev)

  # Build the tweened scene, then resolve which frames to render.
  total  <- (nframes - 1L) * detail + 1L
  built  <- prerender(animation, total)
  nf     <- get_nframes(built)
  frame_ind <- unique(round(seq(1, nf, length.out = nframes)))

  # Wrap the scene's per-frame draw so each frame boils. The wrapper runs once
  # per rendered frame; a counter (not the frame index, which may be non-
  # contiguous) keys the jitter, so frame 1 is un-boiled and the run reproduces.
  scene <- built$scene
  orig  <- scene$plot_frame
  counter <- 0L
  old_jit <- getOption("ggsketch.seed_jitter")
  on.exit(options(ggsketch.seed_jitter = old_jit), add = TRUE)
  scene$plot_frame <- function(self, plot, i, ...) {
    counter <<- counter + 1L
    options(ggsketch.seed_jitter =
              as.integer((start + counter - 1L) * .boil_stride * intensity))
    orig(plot, i, ...)
  }

  frame_vars <- draw_frames(
    plot = built, frames = frame_ind, device = dev, ref_frame = 1L,
    width = width, height = height, units = units, res = res,
    background = background, bg = background
  )
  options(ggsketch.seed_jitter = old_jit)

  frames    <- frame_vars$frame_source
  width_px  <- if (units == "px") width  else round(width  * res / dev_per_inch(units))
  height_px <- if (units == "px") height else round(height * res / dev_per_inch(units))
  assemble_animation(frames, file, fps, loop, renderer, width_px, height_px)
}
