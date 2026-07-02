# Layer 3 helper - annotate_sketch() (P5-T4)
# A sketch-flavoured analogue of ggplot2::annotate(): adds a single, fixed
# annotation layer (constant aesthetics, inherit.aes = FALSE) using one of the
# sketch geoms.

#' Sketchy annotations
#'
#' The sketch analogue of [ggplot2::annotate()].  Creates a one-off layer of
#' fixed, hand-drawn marks that do not inherit the plot's aesthetics - useful
#' for highlighting, callouts, and reference shapes.
#'
#' @param geom Name of the sketch geom to draw. One of `"point"`, `"line"`,
#'   `"path"`, `"segment"`, `"rect"`, `"polygon"`, `"circle"`, `"ellipse"`.
#' @param x,y,xmin,xmax,ymin,ymax,xend,yend Positioning aesthetics (numeric
#'   vectors, recycled to a common length). Supply the ones the chosen geom
#'   needs (e.g. `xmin/xmax/ymin/ymax` for `"rect"`, `xend/yend` for
#'   `"segment"`).
#' @param r,a,b Radius (`"circle"`) or semi-axes (`"ellipse"`).
#' @param seed Integer seed for reproducible wobble.
#' @param na.rm If `FALSE` (default), missing values trigger a warning.
#' @param ... Other arguments passed to the underlying `geom_sketch_*()` layer
#'   (e.g. `colour`, `fill`, `roughness`, `fill_style`).
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_sketch_point(seed = 1L) +
#'   annotate_sketch("rect", xmin = 3, xmax = 4, ymin = 15, ymax = 22,
#'                   fill = NA, colour = "red", seed = 2L) +
#'   annotate_sketch("segment", x = 2, y = 30, xend = 3.5, yend = 20,
#'                   colour = "blue", seed = 3L) +
#'   theme_sketch()
annotate_sketch <- function(geom,
                            x = NULL, y = NULL,
                            xmin = NULL, xmax = NULL,
                            ymin = NULL, ymax = NULL,
                            xend = NULL, yend = NULL,
                            r = NULL, a = NULL, b = NULL,
                            seed = NULL,
                            na.rm = FALSE,
                            ...) {
  geom <- rlang::arg_match(
    geom,
    c("point", "line", "path", "segment", "rect", "polygon",
      "circle", "ellipse")
  )

  position <- list(
    x = x, y = y, xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
    xend = xend, yend = yend, r = r, a = a, b = b
  )
  position <- position[lengths(position) > 0L]
  if (length(position) == 0L) {
    cli::cli_abort("{.fn annotate_sketch} needs at least one position aesthetic.")
  }

  # Recycle to a common length (vctrs-free, base recycling check).
  lens <- lengths(position)
  n    <- max(lens)
  if (!all(lens %in% c(1L, n))) {
    cli::cli_abort(c(
      "Unequal positioning aesthetic lengths.",
      i = "Each must be length 1 or {n}."
    ))
  }
  position <- lapply(position, rep_len, length.out = n)
  data <- as.data.frame(position, stringsAsFactors = FALSE)

  mapping <- ggplot2::aes()
  for (nm in names(data)) mapping[[nm]] <- rlang::sym(nm)

  layer_fun <- switch(
    geom,
    point   = geom_sketch_point,
    line    = geom_sketch_line,
    path    = geom_sketch_path,
    segment = geom_sketch_segment,
    rect    = geom_sketch_rect,
    polygon = geom_sketch_polygon,
    circle  = geom_sketch_circle,
    ellipse = geom_sketch_ellipse
  )

  layer_fun(
    mapping     = mapping,
    data        = data,
    stat        = "identity",
    position    = "identity",
    seed        = seed,
    na.rm       = na.rm,
    show.legend = FALSE,
    inherit.aes = FALSE,
    ...
  )
}

# ---- annotate_sketch_highlight / annotate_sketch_underline -------------------

#' Highlighter swipes and hand-drawn underlines
#'
#' Two one-off emphasis annotations (constant positions,
#' `inherit.aes = FALSE`):
#'
#' * `annotate_sketch_highlight()` lays a wide, translucent chisel-tip band
#'   (the `"highlighter"` medium) from `(x, y)` to `(xend, yend)` -- swipe it
#'   over a line, a label or a region of interest like a fluorescent marker.
#' * `annotate_sketch_underline()` draws a quick wobbly stroke from `(x, y)` to
#'   `(xend, y)` -- an underline for a data point or a piece of text.
#'   `strokes > 1` re-draws it with fresh wobble for an emphatic scrawl.
#'
#' @param x,y,xend,yend Endpoint positions in data units (vectors recycle).
#'   `annotate_sketch_underline()` is horizontal: `yend` defaults to `y`.
#' @param colour Ink colour. Highlight defaults to fluorescent yellow.
#' @param linewidth Stroke width. The highlighter medium multiplies it into a
#'   wide band; the underline stays a line.
#' @param strokes Number of overlapped underline strokes. Default 1.
#' @param roughness Wobble amount. Underlines default a little shakier.
#' @param bowing Bow of the underline stroke (kept low so repeated strokes
#'   stay together). Default 0.4.
#' @param seed Integer seed for reproducible wobble.
#' @param ... Other arguments passed to [geom_sketch_segment()].
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(economics[1:60, ], aes(date, unemploy)) +
#'   geom_sketch_line(seed = 1L) +
#'   annotate_sketch_highlight(
#'     x = as.Date("1969-01-01"), y = 2800,
#'     xend = as.Date("1970-06-01"), yend = 2800
#'   ) +
#'   theme_sketch()
annotate_sketch_highlight <- function(x, y, xend, yend,
                                      colour    = "#f7e017",
                                      linewidth = 8,
                                      seed      = NULL,
                                      ...) {
  pos  <- list(x = x, y = y, xend = xend, yend = yend)
  lens <- lengths(pos)
  n    <- max(lens)
  if (!all(lens %in% c(1L, n))) {
    cli::cli_abort("Each of {.arg x}, {.arg y}, {.arg xend}, {.arg yend} must
                    be length 1 or {n}.")
  }
  data <- as.data.frame(lapply(pos, rep_len, length.out = n))
  geom_sketch_segment(
    mapping = ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
    data = data, medium = "highlighter", colour = colour,
    linewidth = linewidth, seed = seed,
    show.legend = FALSE, inherit.aes = FALSE, ...
  )
}

#' @rdname annotate_sketch_highlight
#' @export
annotate_sketch_underline <- function(x, y, xend,
                                      colour    = "grey15",
                                      linewidth = 0.7,
                                      strokes   = 1L,
                                      roughness = 1.6,
                                      bowing    = 0.4,
                                      seed      = NULL,
                                      ...) {
  pos  <- list(x = x, y = y, xend = xend)
  lens <- lengths(pos)
  n    <- max(lens)
  if (!all(lens %in% c(1L, n))) {
    cli::cli_abort("Each of {.arg x}, {.arg y}, {.arg xend} must be length 1
                    or {n}.")
  }
  base <- as.data.frame(lapply(pos, rep_len, length.out = n))
  strokes <- max(1L, as.integer(strokes))
  layers  <- lapply(seq_len(strokes), function(s) {
    geom_sketch_segment(
      mapping = ggplot2::aes(x = x, y = y, xend = xend, yend = y),
      data = base, colour = colour, linewidth = linewidth,
      roughness = roughness, bowing = bowing, n_passes = 1L,
      seed = seed_offset(resolve_seed(seed), s * 17L),
      show.legend = FALSE, inherit.aes = FALSE, ...
    )
  })
  if (strokes == 1L) layers[[1L]] else layers
}
