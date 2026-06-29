# Layer 3 - geom_sketch_parallel() (v2.0 breadth)
# A parallel-coordinates plot: several numeric axes drawn as vertical lines, and
# each observation a polyline crossing every axis at its (independently scaled)
# value. Like geom_sketch_chord(), this is a constructor that computes the
# geometry up front and returns ordinary sketch layers (roughened axis lines,
# roughened polylines, axis labels) in plain x/y space, so it composes with `+`
# and any colour scale. No new dependencies (cf. GGally::ggparcoord(),
# MASS::parcoord()).

# ---- layout (pure arithmetic) -----------------------------------------------

# Rescale a numeric vector to [0, 1]; a constant column maps to 0.5.
parallel_rescale01 <- function(v) {
  rng <- range(v, na.rm = TRUE)
  if (!all(is.finite(rng)) || diff(rng) == 0) return(rep(0.5, length(v)))
  (v - rng[1L]) / diff(rng)
}

# Build the parallel-coordinates layout from numeric `axes` columns. Returns the
# polyline data (one row per observation per axis), the axis verticals, axis
# labels, and the per-axis value range (for tick labels).
parallel_layout <- function(data, axes, scale = c("minmax", "none")) {
  scale <- match.arg(scale)
  if (length(axes) < 2L) {
    cli::cli_abort("{.fn geom_sketch_parallel} needs at least 2 axes.")
  }
  miss <- setdiff(axes, names(data))
  if (length(miss)) {
    cli::cli_abort("Column{?s} {.val {miss}} not found in {.arg data}.")
  }
  M <- vapply(axes, function(a) as.numeric(data[[a]]), numeric(nrow(data)))
  if (is.null(dim(M))) M <- matrix(M, nrow = nrow(data))
  ranges <- apply(M, 2L, range, na.rm = TRUE)
  Y <- if (scale == "minmax") apply(M, 2L, parallel_rescale01) else M
  if (is.null(dim(Y))) Y <- matrix(Y, nrow = nrow(data))

  K <- length(axes)
  lines <- data.frame(
    x   = rep(seq_len(K), each = nrow(data)),
    y   = as.numeric(Y),
    id  = rep(seq_len(nrow(data)), times = K)
  )
  axis_df <- data.frame(x = seq_len(K), ymin = 0, ymax = 1, axis = axes)
  labels  <- data.frame(x = seq_len(K), y = -0.04, axis = axes)
  list(lines = lines[order(lines$id, lines$x), , drop = FALSE],
       axes = axis_df, labels = labels, ranges = ranges, axis_names = axes)
}

# ---- geom_sketch_parallel ---------------------------------------------------

#' Sketchy parallel-coordinates plot
#'
#' Draws a hand-drawn parallel-coordinates plot: each numeric column in `axes`
#' becomes a vertical axis, and every observation becomes a roughened polyline
#' crossing the axes at its values. Axes are scaled independently to a common
#' height by default. Like [geom_sketch_chord()] it is a constructor returning a
#' list of ordinary sketch layers, so it composes with `+`; map `colour` to a
#' column (add [scale_colour_sketch()] or any colour scale) and pair with
#' `theme_void()` or `theme_sketch()`. No new dependencies
#' (cf. `GGally::ggparcoord()`, `MASS::parcoord()`).
#'
#' @param data A data frame.
#' @param axes Character vector of numeric column names to use as axes, in order
#'   (at least two).
#' @param colour Optional column name to colour the lines by (`NULL` = one
#'   colour). Add a colour scale to style it.
#' @param scale Per-axis scaling: `"minmax"` (default, each axis to `[0, 1]`) or
#'   `"none"` (raw values; only sensible when the axes share units).
#' @param line_colour Colour used when `colour` is `NULL`. Default `"#1F618D"`.
#' @param alpha Line opacity. Default 0.7.
#' @param axis_colour Colour of the vertical axes. Default `"grey60"`.
#' @param label Draw axis labels? Default `TRUE`.
#' @param label_size,label_colour Axis-label text controls.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param ... Other arguments passed on to the line layer.
#' @return A list of `ggplot2` layers.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot() +
#'   geom_sketch_parallel(iris,
#'     axes = c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"),
#'     colour = "Species", seed = 1L) +
#'   scale_colour_sketch() +
#'   theme_void()
geom_sketch_parallel <- function(data,
                                 axes,
                                 colour       = NULL,
                                 ...,
                                 scale        = "minmax",
                                 line_colour  = "#1F618D",
                                 alpha        = 0.7,
                                 axis_colour  = "grey60",
                                 label        = TRUE,
                                 label_size   = 3.5,
                                 label_colour = "grey20",
                                 roughness    = 1,
                                 bowing       = 1,
                                 n_passes     = 2L,
                                 seed         = NULL) {
  if (missing(data) || !is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame.")
  }
  if (!is.null(colour) && !colour %in% names(data)) {
    cli::cli_abort("Colour column {.val {colour}} not found in {.arg data}.")
  }
  lay <- parallel_layout(data, axes = axes, scale = scale)

  if (!is.null(colour)) {
    lay$lines[[colour]] <- data[[colour]][lay$lines$id]
    line_map <- ggplot2::aes(x = .data$x, y = .data$y, group = .data$id,
                             colour = .data[[colour]])
    line_args <- list(mapping = line_map)
  } else {
    line_map  <- ggplot2::aes(x = .data$x, y = .data$y, group = .data$id)
    line_args <- list(mapping = line_map, colour = line_colour)
  }

  layers <- list(
    # axes behind the data
    geom_sketch_segment(
      data = lay$axes,
      mapping = ggplot2::aes(x = .data$x, xend = .data$x,
                             y = .data$ymin, yend = .data$ymax),
      colour = axis_colour, linewidth = 0.4,
      roughness = roughness * 0.5, bowing = bowing,
      n_passes = 1L, seed = seed, inherit.aes = FALSE
    ),
    do.call(geom_sketch_path, c(
      list(data = lay$lines), line_args,
      list(alpha = alpha, roughness = roughness, bowing = bowing,
           n_passes = as.integer(n_passes), seed = seed, inherit.aes = FALSE),
      list(...)
    ))
  )

  if (isTRUE(label)) {
    layers <- c(layers, list(geom_sketch_text(
      data = lay$labels,
      mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$axis),
      size = label_size, colour = label_colour, vjust = 1, inherit.aes = FALSE
    )))
  }

  layers
}
