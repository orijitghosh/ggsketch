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
