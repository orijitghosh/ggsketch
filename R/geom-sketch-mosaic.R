# Layer 3 - geom_sketch_mosaic() (v2.0 breadth)
# A mosaic plot: the unit square is split into columns by the marginal counts of
# one categorical variable, then each column is split vertically by the
# conditional counts of a second - so every tile's area is the joint frequency
# of that category combination. Like geom_sketch_chord(), this is a constructor
# that computes the tile rectangles up front and returns ordinary sketch layers
# (roughened rectangles + labels) in plain x/y space. No new dependencies
# (cf. graphics::mosaicplot(), ggmosaic).

# ---- layout (pure arithmetic) -----------------------------------------------

# Build mosaic tiles from two category vectors and weights. Columns (x) are
# sized by marginal weight; rows within each column (y) by conditional weight,
# with a small `gap` between columns and between rows.
mosaic_layout <- function(xcat, ycat, w, gap = 0.012) {
  xcat <- if (is.factor(xcat)) droplevels(xcat) else factor(xcat)
  ycat <- if (is.factor(ycat)) droplevels(ycat) else factor(ycat)
  xl <- levels(xcat); yl <- levels(ycat)
  nx <- length(xl);   ny <- length(yl)
  if (nx < 1L || ny < 1L) {
    cli::cli_abort("{.fn geom_sketch_mosaic} needs non-empty x and y.")
  }

  colw <- vapply(xl, function(l) sum(w[xcat == l]), numeric(1))
  colw <- colw / sum(colw)
  xgap_tot <- (nx - 1L) * gap
  xspan    <- 1 - xgap_tot

  tiles <- list()
  xacc  <- 0
  for (j in seq_len(nx)) {
    xw   <- xspan * colw[j]
    xmin <- xacc
    xmax <- xacc + xw
    xacc <- xmax + gap

    inx  <- xcat == xl[j]
    rowh <- vapply(yl, function(l) sum(w[inx & ycat == l]), numeric(1))
    tot  <- sum(rowh)
    if (tot <= 0) next
    rowh <- rowh / tot
    present <- which(rowh > 0)
    ygap_tot <- (length(present) - 1L) * gap
    yspan    <- 1 - ygap_tot
    yacc <- 0
    for (k in present) {
      yh   <- yspan * rowh[k]
      ymin <- yacc
      ymax <- yacc + yh
      yacc <- ymax + gap
      tiles[[length(tiles) + 1L]] <- data.frame(
        xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
        xcat = xl[j], ycat = yl[k], xcen = (xmin + xmax) / 2
      )
    }
  }
  tiles <- do.call(rbind, tiles)
  labels <- data.frame(
    x = vapply(xl, function(l) mean(tiles$xcen[tiles$xcat == l]), numeric(1)),
    y = -0.03, xcat = xl
  )
  list(tiles = tiles, labels = labels, xlevels = xl, ylevels = yl)
}

# ---- geom_sketch_mosaic -----------------------------------------------------

#' Sketchy mosaic plot
#'
#' Draws a hand-drawn mosaic plot of two categorical variables: the width of
#' each column is the marginal frequency of `x`, and the height of each tile
#' within a column is the conditional frequency of `y`, so every tile's *area*
#' is the joint frequency. Like [geom_sketch_chord()] it is a constructor that
#' returns a list of ordinary sketch layers (roughened tiles coloured by `y`,
#' plus column labels), so it composes with `+` and any fill scale; pair it with
#' `theme_void()` or `theme_sketch()`. No new dependencies
#' (cf. `graphics::mosaicplot()`, `ggmosaic`).
#'
#' @param data A data frame.
#' @param x,y Unquoted column names: `x` splits the columns, `y` splits each
#'   column vertically.
#' @param value Optional column name giving each row's weight (`NULL` = 1 each).
#' @param fill_by Which variable colours the tiles: `"y"` (default) or `"x"`.
#' @param gap Gap between columns and rows, in unit-square fractions.
#'   Default 0.012.
#' @param fill_style Tile fill style; see [geom_sketch_rect()]. Default
#'   `"solid"`.
#' @param alpha Tile opacity. Default 1.
#' @param label Draw column labels? Default `TRUE`.
#' @param label_size,label_colour Label text controls.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param ... Other arguments passed on to the tile layer.
#' @return A list of `ggplot2` layers.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- as.data.frame(Titanic)
#' ggplot() +
#'   geom_sketch_mosaic(df, x = Class, y = Survived, value = Freq, seed = 1L) +
#'   scale_fill_sketch() +
#'   theme_void()
geom_sketch_mosaic <- function(data,
                               x, y,
                               value        = NULL,
                               ...,
                               fill_by      = c("y", "x"),
                               gap          = 0.012,
                               fill_style   = "solid",
                               alpha        = 1,
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
  fill_by <- match.arg(fill_by)
  xcol <- rlang::as_name(rlang::ensym(x))
  ycol <- rlang::as_name(rlang::ensym(y))
  w <- if (missing(value)) rep(1, nrow(data))
       else as.numeric(data[[rlang::as_name(rlang::ensym(value))]])

  lay <- mosaic_layout(data[[xcol]], data[[ycol]], w, gap = gap)
  lay$tiles$fill <- if (fill_by == "y") lay$tiles$ycat else lay$tiles$xcat

  layers <- list(
    geom_sketch_rect(
      data = lay$tiles,
      mapping = ggplot2::aes(xmin = .data$xmin, xmax = .data$xmax,
                             ymin = .data$ymin, ymax = .data$ymax,
                             fill = .data$fill,
                             group = interaction(.data$xcat, .data$ycat)),
      fill_style = fill_style, alpha = alpha, colour = "grey30",
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, inherit.aes = FALSE, ...
    )
  )

  if (isTRUE(label)) {
    layers <- c(layers, list(geom_sketch_text(
      data = lay$labels,
      mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$xcat),
      size = label_size, colour = label_colour, vjust = 1, inherit.aes = FALSE
    )))
  }

  layers
}
