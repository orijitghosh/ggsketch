# Layer 3 — rough theme elements (v1.4 "complete the look")
# Hand-drawn gridlines, panel borders and axis ticks. `element_grob()` is an S3
# generic (UseMethod) in both ggplot2 3.5 and 4.0, so we prepend an
# "element_sketch_*" S3 class to a normal element and supply the method. ggplot2
# 4.0 elements are S7 and do not allow `$<-`, so the sketch parameters are stored
# as attributes (these survive theme-element merging; verified on 4.0.3).

# ---- attribute helpers ------------------------------------------------------

#' @noRd
sk_set_attrs <- function(el, roughness, bowing, n_passes, seed) {
  attr(el, "sk_roughness") <- roughness
  attr(el, "sk_bowing")    <- bowing
  attr(el, "sk_n_passes")  <- as.integer(n_passes)
  attr(el, "sk_seed")      <- seed
  el
}

#' @noRd
sk_get <- function(el, name, default) {
  v <- attr(el, name, exact = TRUE)
  if (is.null(v)) default else v
}

# ---- constructors -----------------------------------------------------------

#' Hand-drawn theme elements
#'
#' Sketch counterparts of [ggplot2::element_line()] and [ggplot2::element_rect()].
#' Use them in [ggplot2::theme()] (or via `theme_sketch(rough_frame = TRUE)`) to
#' render gridlines, panel borders, and axis ticks with the same wobbly,
#' double-stroke look as the geoms. They accept the usual element arguments plus
#' the shared sketch parameters (`roughness`, `bowing`, `n_passes`, `seed`).
#'
#' @param colour,color Line/border colour.
#' @param linewidth Line width.
#' @param linetype Line type.
#' @param lineend Line end style.
#' @param fill Fill colour (`element_sketch_rect()` only). `NA` draws the
#'   outline only — the usual choice for a panel border.
#' @param roughness,bowing,n_passes,seed Sketch parameters (see
#'   [geom_sketch_path()]). Defaults are gentle, suited to a frame.
#' @param ... Passed to the underlying ggplot2 element constructor.
#' @return A ggplot2 theme element carrying an `element_sketch_*` subclass.
#' @family sketch-theme
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_sketch_point(seed = 1L) +
#'   theme_sketch() +
#'   theme(panel.grid.major = element_sketch_line(colour = "grey80", seed = 7L))
element_sketch_line <- function(colour    = NULL,
                                linewidth = NULL,
                                linetype  = NULL,
                                lineend   = NULL,
                                color     = NULL,
                                roughness = 0.5,
                                bowing    = 0.5,
                                n_passes  = 2L,
                                seed      = NULL,
                                ...) {
  if (!is.null(color)) colour <- color
  el <- ggplot2::element_line(colour = colour, linewidth = linewidth,
                              linetype = linetype, lineend = lineend, ...)
  el <- sk_set_attrs(el, roughness, bowing, n_passes, seed)
  class(el) <- c("element_sketch_line", class(el))
  el
}

#' @rdname element_sketch_line
#' @export
element_sketch_rect <- function(fill      = NULL,
                                colour    = NULL,
                                linewidth = NULL,
                                linetype  = NULL,
                                color     = NULL,
                                roughness = 0.6,
                                bowing    = 0.4,
                                n_passes  = 2L,
                                seed      = NULL,
                                ...) {
  if (!is.null(color)) colour <- color
  el <- ggplot2::element_rect(fill = fill, colour = colour,
                              linewidth = linewidth, linetype = linetype, ...)
  el <- sk_set_attrs(el, roughness, bowing, n_passes, seed)
  class(el) <- c("element_sketch_rect", class(el))
  el
}

# ---- element_grob methods ---------------------------------------------------

#' @exportS3Method ggplot2::element_grob
element_grob.element_sketch_line <- function(element, x = 0:1, y = 0:1,
                                             colour = NULL, linewidth = NULL,
                                             linetype = NULL, lineend = NULL,
                                             default.units = "npc",
                                             id.lengths = NULL, ...) {
  n <- length(x)
  if (n == 0L) return(ggplot2::zeroGrob())

  id <- if (!is.null(id.lengths)) rep.int(seq_along(id.lengths), id.lengths) else rep(1L, n)

  # ggplot2 passes out-of-range gridlines as NA (polylineGrob just skips them);
  # drop any line group that contains a non-finite coordinate.
  xn <- suppressWarnings(as.numeric(x))
  yn <- suppressWarnings(as.numeric(y))
  finite <- is.finite(xn) & is.finite(yn)
  if (!all(finite)) {
    keep <- !(id %in% unique(id[!finite]))
    if (!any(keep)) return(ggplot2::zeroGrob())
    x  <- x[keep]
    y  <- y[keep]
    id <- id[keep]
  }

  gp <- outline_gpar(
    colour    = colour    %||% element$colour    %||% "grey20",
    linewidth = linewidth %||% element$linewidth %||% 0.5,
    linetype  = linetype  %||% element$linetype  %||% 1
  )

  # Honour the requested units (gridlines pass numeric npc; ticks pass units).
  xs <- if (is.unit(x)) x else unit(x, default.units)
  ys <- if (is.unit(y)) y else unit(y, default.units)

  sketch_path_grob(
    x = xs, y = ys, id = id,
    roughness = sk_get(element, "sk_roughness", 0.5),
    bowing    = sk_get(element, "sk_bowing", 0.5),
    n_passes  = sk_get(element, "sk_n_passes", 2L),
    seed      = sk_get(element, "sk_seed", NULL),
    gp = gp
  )
}

#' @exportS3Method ggplot2::element_grob
element_grob.element_sketch_rect <- function(element, x = 0.5, y = 0.5,
                                             width = 1, height = 1,
                                             fill = NULL, colour = NULL,
                                             linewidth = NULL, linetype = NULL,
                                             ...) {
  fill   <- fill   %||% element$fill
  colour <- colour %||% element$colour

  # Rectangle corners (npc). x/y/width/height are numeric npc from ggplot2.
  xn <- if (is.unit(x)) as.numeric(x) else x
  yn <- if (is.unit(y)) as.numeric(y) else y
  wn <- if (is.unit(width))  as.numeric(width)  else width
  hn <- if (is.unit(height)) as.numeric(height) else height

  xl <- xn - wn / 2; xr <- xn + wn / 2
  yb <- yn - hn / 2; yt <- yn + hn / 2
  px <- c(xl, xr, xr, xl)
  py <- c(yb, yb, yt, yt)

  has_fill <- !is.null(fill) && !is.na(fill)
  grobs <- list()

  # Solid background fill (kept ruler-straight so the paper reaches the corners);
  # only the outline is roughened.
  if (has_fill) {
    grobs[[length(grobs) + 1L]] <- rectGrob(
      x = unit(xn, "npc"), y = unit(yn, "npc"),
      width = unit(wn, "npc"), height = unit(hn, "npc"),
      gp = gpar(fill = fill, col = NA)
    )
  }

  if (!is.null(colour) && !is.na(colour)) {
    grobs[[length(grobs) + 1L]] <- sketch_polygon_grob(
      x = px, y = py,
      roughness = sk_get(element, "sk_roughness", 0.6),
      bowing    = sk_get(element, "sk_bowing", 0.4),
      n_passes  = sk_get(element, "sk_n_passes", 2L),
      seed      = sk_get(element, "sk_seed", NULL),
      fill_style = "solid",
      outline_gp = outline_gpar(
        colour    = colour,
        linewidth = linewidth %||% element$linewidth %||% 0.8,
        linetype  = linetype  %||% element$linetype  %||% 1
      )
    )
  }

  if (length(grobs) == 0L) return(ggplot2::zeroGrob())
  do.call(grid::grobTree, grobs)
}
