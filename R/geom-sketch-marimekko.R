# Layer 3 - geom_sketch_marimekko() (v2.0 breadth)
# A Marimekko / Mekko chart: variable-width stacked bars. Each column's *width*
# is one category's share of a continuous total, and within a column the stacked
# segments are a second category's shares - so every tile's area is the joint
# value. This is the value-weighted, segment-coloured cousin of the mosaic plot,
# so it reuses mosaic_layout() and returns ordinary sketch layers (roughened
# tiles + column labels + optional width-% labels). No new dependencies.

# ---- geom_sketch_marimekko --------------------------------------------------

#' Sketchy Marimekko (variable-width stacked bar) chart
#'
#' Draws a hand-drawn Marimekko / Mekko chart: each column's *width* is one
#' category's (`x`) share of the total, and within a column the stacked segments
#' are a second category's (`fill`) shares, so every roughened tile's *area* is
#' the joint value. It is the value-weighted, segment-coloured cousin of
#' [geom_sketch_mosaic()] (and reuses its layout). Like [geom_sketch_chord()] it
#' is a constructor returning a list of ordinary sketch layers (tiles coloured by
#' `fill`, column labels, and optional width-percent labels), so it composes with
#' `+` and any fill scale; pair it with `theme_void()` or `theme_sketch()`.
#'
#' @param data A data frame.
#' @param x Unquoted column name of the category that sets column widths.
#' @param fill Unquoted column name of the category stacked within each column.
#' @param value Unquoted column name giving the weight. Default: every row counts
#'   as 1.
#' @param gap Gap between columns / segments, as a fraction of the unit square.
#'   Default 0.008 (Marimekko charts sit closer than mosaics).
#' @param fill_style Tile fill style; see [geom_sketch_rect()]. Default `"solid"`.
#' @param alpha Tile fill opacity. Default 1.
#' @param colour Tile outline colour. Default `"grey30"`.
#' @param label Draw column (`x`) labels under the chart? Default `TRUE`.
#' @param width_labels Draw each column's width percentage on top? Default
#'   `TRUE`.
#' @param label_size,label_colour Label text controls.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param ... Other arguments passed on to the tile layer.
#' @return A list of `ggplot2` layers.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' sales <- data.frame(
#'   region  = rep(c("North", "South", "East"), each = 3),
#'   product = rep(c("A", "B", "C"), times = 3),
#'   revenue = c(40, 30, 10,  25, 25, 30,  15, 20, 5)
#' )
#' ggplot() +
#'   geom_sketch_marimekko(sales, region, product, revenue, seed = 1L) +
#'   scale_fill_sketch() +
#'   theme_void()
geom_sketch_marimekko <- function(data,
                                  x, fill, value,
                                  ...,
                                  gap          = 0.008,
                                  fill_style   = "solid",
                                  alpha        = 1,
                                  colour       = "grey30",
                                  label        = TRUE,
                                  width_labels = TRUE,
                                  label_size   = 3.2,
                                  label_colour = "grey20",
                                  roughness    = 1,
                                  bowing       = 1,
                                  n_passes     = 2L,
                                  seed         = NULL) {
  if (missing(data) || !is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame.")
  }
  xcol    <- rlang::as_name(rlang::ensym(x))
  fillcol <- rlang::as_name(rlang::ensym(fill))
  w <- if (missing(value)) rep(1, nrow(data))
       else as.numeric(data[[rlang::as_name(rlang::ensym(value))]])

  lay <- mosaic_layout(data[[xcol]], data[[fillcol]], w, gap = gap)
  lay$tiles$fill <- lay$tiles$ycat

  layers <- list(
    geom_sketch_rect(
      data = lay$tiles,
      mapping = ggplot2::aes(xmin = .data$xmin, xmax = .data$xmax,
                             ymin = .data$ymin, ymax = .data$ymax,
                             fill = .data$fill,
                             group = interaction(.data$xcat, .data$ycat)),
      fill_style = fill_style, alpha = alpha, colour = colour,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, inherit.aes = FALSE, ...
    )
  )

  if (isTRUE(label)) {
    layers <- c(layers, list(geom_sketch_text(
      data = lay$labels,
      mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$xcat),
      size = label_size, colour = label_colour, vjust = 1,
      family = resolve_label_family(), inherit.aes = FALSE
    )))
  }

  if (isTRUE(width_labels)) {
    # column width fraction -> percentage, placed just above each column
    wl <- do.call(rbind, lapply(lay$xlevels, function(l) {
      tl <- lay$tiles[lay$tiles$xcat == l, , drop = FALSE]
      frac <- max(tl$xmax) - min(tl$xmin)
      data.frame(x = mean(tl$xcen), y = 1.03,
                 label = paste0(round(100 * frac), "%"),
                 stringsAsFactors = FALSE)
    }))
    layers <- c(layers, list(geom_sketch_text(
      data = wl,
      mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$label),
      size = label_size * 0.85, colour = label_colour, vjust = 0,
      family = resolve_label_family(), inherit.aes = FALSE
    )))
  }

  layers
}
