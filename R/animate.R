# Layer 3 - animate_sketch() (v2.0 Tier C: motion)
# "Boil" a sketch plot: render it many times, shifting every roughening seed by
# a per-frame amount, so the whole drawing shimmers and re-draws itself like a
# hand-animated cel (the classic "boiling line"). The shift rides on the global
# `ggsketch.seed_jitter` option, which resolve_seed() adds to every resolved
# seed - explicit or inherited - so a plot boils even when its layers set their
# own seeds. Frame 1 uses jitter 0, so it is identical to the static render.
#
# Output is vector-safe in spirit (each frame is an ordinary device render) and
# needs no new hard dependency: frames are stitched into a GIF when gifski or
# magick is installed, otherwise the frame paths are returned for the user to
# assemble.

# Per-frame jitter: a large prime stride keeps successive frames visually
# decorrelated while staying fully reproducible.
.boil_stride <- 997L

# Pick a PNG device opener, preferring ragg (better antialiasing + font
# handling) and falling back to grDevices::png with a cairo type when present.
pick_png_device <- function(device = NULL) {
  use <- device
  if (is.null(use)) {
    use <- if (requireNamespace("ragg", quietly = TRUE)) "ragg" else "png"
  }
  if (identical(use, "ragg")) {
    if (!requireNamespace("ragg", quietly = TRUE)) {
      cli::cli_abort('{.arg device} = "ragg" needs the {.pkg ragg} package.')
    }
    return(function(path, width, height, units, res, background) {
      ragg::agg_png(path, width = width, height = height, units = units,
                    res = res, background = background)
    })
  }
  cairo_ok <- capabilities("cairo")
  function(path, width, height, units, res, background) {
    grDevices::png(path, width = width, height = height, units = units,
                   res = res, bg = background,
                   type = if (cairo_ok) "cairo" else NULL)
  }
}

# Stitch frames into a GIF (gifski or magick), or return the frame paths.
assemble_animation <- function(frames, file, fps, loop, renderer,
                                width_px, height_px) {
  have_gifski <- requireNamespace("gifski", quietly = TRUE)
  have_magick <- requireNamespace("magick", quietly = TRUE)

  pick <- renderer
  if (pick == "auto") {
    pick <- if (have_gifski) "gifski" else if (have_magick) "magick" else "none"
  }
  if (is.null(file) || pick == "none") {
    if (!is.null(file) && pick == "none") {
      cli::cli_warn(c(
        "Neither {.pkg gifski} nor {.pkg magick} is installed.",
        "i" = "Returning the {length(frames)} frame path{?s} instead of writing {.path {file}}."
      ))
    }
    return(invisible(frames))
  }

  if (pick == "gifski") {
    if (!have_gifski) cli::cli_abort("{.pkg gifski} is not installed.")
    gifski::gifski(frames, gif_file = file, width = width_px,
                   height = height_px, delay = 1 / fps, loop = isTRUE(loop),
                   progress = FALSE)
  } else if (pick == "magick") {
    if (!have_magick) cli::cli_abort("{.pkg magick} is not installed.")
    # magick::image_animate() only accepts an fps that divides 100; snap to the
    # nearest such value (gifski has no such limit).
    valid <- c(1L, 2L, 4L, 5L, 10L, 20L, 25L, 50L, 100L)
    fps2  <- valid[which.min(abs(valid - fps))]
    if (fps2 != fps) {
      cli::cli_inform(c("i" = "{.pkg magick} requires fps to divide 100; using {fps2} instead of {fps}."))
    }
    imgs <- magick::image_read(frames)
    anim <- magick::image_animate(imgs, fps = fps2,
                                  loop = if (isTRUE(loop)) 0L else 1L,
                                  optimize = TRUE)
    magick::image_write(anim, path = file)
  }
  invisible(file)
}

#' Animate a sketch plot by "boiling" its lines
#'
#' Renders a ggplot built with ggsketch geoms `nframes` times, shifting every
#' roughening seed by a per-frame amount, so the whole drawing shimmers and
#' re-draws itself like a hand-animated cel (the "boiling line" effect). Because
#' the shift is added to *every* resolved seed -- whether a layer set its own
#' `seed` or inherited the global one -- a plot boils without any change to its
#' code. Frame 1 reproduces the static plot exactly.
#'
#' Frames are stitched into a GIF when \pkg{gifski} or \pkg{magick} is installed
#' (neither is a hard dependency); otherwise the frame image paths are returned
#' so you can assemble them yourself. Everything is reproducible: the same `seed`
#' yields the same animation.
#'
#' @param plot A ggplot object using ggsketch geoms.
#' @param nframes Number of frames. Default 12.
#' @param fps Frames per second in the output GIF. Default 10.
#' @param type Motion type. Currently only `"boil"`.
#' @param file Output GIF path. If `NULL` (default), no GIF is written and the
#'   frame paths are returned invisibly.
#' @param width,height,units,res Frame size and resolution, passed to the
#'   graphics device (`units` one of `"in"`, `"cm"`, `"mm"`, `"px"`).
#' @param background Frame background colour. Default `"white"`.
#' @param device Graphics device: `"ragg"` (default when installed) or `"png"`.
#' @param seed Base seed (`NULL` uses `getOption("ggsketch.seed", 1L)`).
#' @param renderer GIF backend: `"auto"` (default), `"gifski"`, `"magick"`, or
#'   `"none"` (always return frame paths).
#' @param loop Loop the GIF forever? Default `TRUE`.
#' @return Invisibly, the GIF path (when written) or a character vector of frame
#'   image paths.
#' @export
#' @examples
#' \donttest{
#' library(ggplot2)
#' p <- ggplot(mpg, aes(class)) +
#'   geom_sketch_bar(fill = "#7BAFD4", seed = 1L) +
#'   theme_sketch()
#' # Write a GIF if gifski/magick is available, else get frame paths back:
#' gif <- animate_sketch(p, nframes = 8, file = tempfile(fileext = ".gif"))
#' }
animate_sketch <- function(plot,
                           nframes    = 12L,
                           fps        = 10,
                           type       = c("boil"),
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
  type     <- match.arg(type)
  renderer <- match.arg(renderer)
  if (!ggplot2::is.ggplot(plot)) {
    cli::cli_abort("{.arg plot} must be a {.cls ggplot} object.")
  }
  nframes <- max(2L, as.integer(nframes))
  base    <- as.integer((seed %||% getOption("ggsketch.seed", 1L))[[1L]])

  frame_dir <- tempfile("ggsketch_frames_")
  dir.create(frame_dir)
  pad    <- max(2L, nchar(as.character(nframes)))
  frames <- file.path(frame_dir,
                      sprintf(paste0("frame_%0", pad, "d.png"), seq_len(nframes)))

  open_dev <- pick_png_device(device)

  # Save and restore the jitter option (frame 1 == static render).
  old_jit <- getOption("ggsketch.seed_jitter")
  on.exit(options(ggsketch.seed_jitter = old_jit), add = TRUE)

  for (f in seq_len(nframes)) {
    # frame 1 -> jitter 0 (identical to the static render); later frames step
    # every seed by a growing multiple of the stride.
    options(ggsketch.seed_jitter = (f - 1L) * .boil_stride)
    open_dev(frames[f], width, height, units, res, background)
    ok <- tryCatch({ print(plot); TRUE },
                   error = function(e) { grDevices::dev.off(); stop(e) })
    grDevices::dev.off()
  }
  options(ggsketch.seed_jitter = old_jit)

  width_px  <- if (units == "px") width  else round(width  * res / dev_per_inch(units))
  height_px <- if (units == "px") height else round(height * res / dev_per_inch(units))

  assemble_animation(frames, file, fps, loop, renderer, width_px, height_px)
}

# inches-per-unit so we can convert device size to pixels for the GIF encoder
dev_per_inch <- function(units) {
  switch(units, "in" = 1, "cm" = 2.54, "mm" = 25.4, "px" = NA_real_, 1)
}
