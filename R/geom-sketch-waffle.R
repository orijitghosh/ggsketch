# Layer 3 - geom_sketch_waffle() (v2.0)
# A waffle chart: a square grid where each cell is coloured by category, so the
# count of cells reads as a part-to-whole proportion. StatSketchWaffle tallies
# the categories and lays them out on an integer grid; drawing reuses
# GeomSketchTile, so the cells get the usual roughened outline and hachure /
# watercolour fill. No new dependencies (cf. waffle::geom_waffle()).

# ---- StatSketchWaffle --------------------------------------------------------

#' @rdname geom_sketch_waffle
#' @export
StatSketchWaffle <- ggplot2::ggproto(
  "StatSketchWaffle", ggplot2::Stat,

  required_aes = "fill",

  default_aes = ggplot2::aes(weight = 1),

  # No `...`: ggplot2 reads recognised stat params from these formals.
  compute_panel = function(data, scales, n_rows = 10L, cells = 100L,
                            flip = FALSE, na.rm = FALSE) {
    if (nrow(data) == 0L) return(data)

    w      <- data$weight %||% rep(1, nrow(data))
    fills  <- unique(data$fill)                       # first-appearance order
    counts <- vapply(fills, function(f) sum(w[data$fill == f]), numeric(1))
    total  <- sum(counts)
    if (total <= 0) return(data[0L, , drop = FALSE])

    # Largest-remainder rounding so the cell counts sum exactly to `cells`.
    raw  <- counts / total * cells
    base <- floor(raw)
    rem  <- cells - sum(base)
    if (rem > 0) {
      ord <- order(raw - base, decreasing = TRUE)
      base[ord[seq_len(rem)]] <- base[ord[seq_len(rem)]] + 1
    }

    fill_seq <- rep(fills, base)
    ncells   <- length(fill_seq)
    if (ncells == 0L) return(data[0L, , drop = FALSE])

    idx <- seq_len(ncells) - 1L
    col <- idx %/% n_rows
    row <- idx %%  n_rows

    out <- data[rep(1L, ncells), , drop = FALSE]
    out$fill   <- fill_seq
    out$x      <- col + 1
    out$y      <- if (isTRUE(flip)) (n_rows - row) else (row + 1)
    out$group  <- match(fill_seq, fills)
    out$weight <- NULL
    out
  }
)

# ---- geom_sketch_waffle ------------------------------------------------------

#' Sketchy waffle chart
#'
#' Draws a hand-drawn waffle: a square grid (default 10x10 = 100 cells) where
#' each cell is coloured by category, so the number of cells of a colour reads as
#' that category's share of the whole. Map the category to `fill`; map a count to
#' `weight` if the data is already summarised (otherwise each row counts as one).
#' Cells are drawn with [geom_sketch_tile()], so they take the usual roughened
#' outline and `fill_style` (including `"watercolor"`). Add [ggplot2::coord_equal()]
#' to keep the cells square. (cf. `waffle::geom_waffle()`).
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires
#'   `fill`; optionally `weight` (a per-row count).
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"sketch_waffle"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param n_rows Number of rows in the grid. Default 10.
#' @param cells Total number of cells (the grid resolution). Default 100, i.e. a
#'   percentage waffle.
#' @param flip Fill columns top-down instead of bottom-up? Default `FALSE`.
#' @param width,height Cell size in grid units (gaps appear below 1). Default
#'   0.9.
#' @param colour Outline colour for each cell. Default `"grey35"`.
#' @param fill_style Cell fill style; see [geom_sketch_rect()]. Default
#'   `"hachure"`.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend?
#' @param inherit.aes Override default aesthetics?
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(grp = c("Rent", "Food", "Travel", "Other"),
#'                  spend = c(45, 25, 20, 10))
#' ggplot(df, aes(fill = grp, weight = spend)) +
#'   geom_sketch_waffle(seed = 1L) +
#'   coord_equal() +
#'   theme_sketch()
geom_sketch_waffle <- function(mapping     = NULL,
                               data        = NULL,
                               stat        = "sketch_waffle",
                               position    = "identity",
                               ...,
                               n_rows      = 10L,
                               cells       = 100L,
                               flip        = FALSE,
                               width       = 0.9,
                               height      = 0.9,
                               colour      = "grey35",
                               fill_style  = "hachure",
                               roughness   = 1,
                               bowing      = 1,
                               n_passes    = 2L,
                               seed        = NULL,
                               na.rm       = FALSE,
                               show.legend = NA,
                               inherit.aes = TRUE) {
  # A bounded cell reads as a waffle square; `colour` outlines each cell. Push it
  # as a constant only when set (NA / NULL leaves cells outline-free).
  params <- list(
    n_rows = as.integer(n_rows), cells = as.integer(cells), flip = flip,
    width = width, height = height, fill_style = fill_style,
    roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed, na.rm = na.rm, ...
  )
  if (!is.null(colour)) params$colour <- colour
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchTile,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = params
  )
}
