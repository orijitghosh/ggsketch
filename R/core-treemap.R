# Layer 1 - squarified treemap layout (v2)
# Partition a rectangle into sub-rectangles whose areas are proportional to a set
# of values, keeping each rectangle as close to square as possible (the
# "squarified treemap" of Bruls, Huizing & van Wijk, 2000). Pure number-to-number
# geometry: no grid:: / ggplot2::.

# Worst (largest) aspect ratio in a row of areas laid along a side of length
# `side`. Lower is squarer. (Bruls et al., eq. for `worst`.)
#' @noRd
treemap_worst <- function(row, side) {
  s  <- sum(row)
  mx <- max(row)
  mn <- min(row)
  if (s <= 0) return(Inf)
  max(side * side * mx / (s * s), s * s / (side * side * mn))
}

#' Squarified treemap layout
#'
#' Lays out one rectangle per value inside the box `[x, x + width] x
#' [y, y + height]`, with area proportional to the value and aspect ratios kept
#' close to 1. Returns rectangles in the original input order.
#'
#' @param values Non-negative numeric vector (one per tile). Zero / negative
#'   values produce zero-area tiles.
#' @param x,y Lower-left corner of the bounding box. Default 0.
#' @param width,height Bounding box size. Default 1.
#' @return A data frame with columns `xmin`, `xmax`, `ymin`, `ymax`, one row per
#'   input value, in input order.
#' @family sketch-core
#' @export
#' @examples
#' treemap_layout(c(6, 3, 2, 1))
treemap_layout <- function(values, x = 0, y = 0, width = 1, height = 1) {
  n <- length(values)
  out <- data.frame(xmin = rep(x, n), xmax = rep(x, n),
                    ymin = rep(y, n), ymax = rep(y, n))
  if (n == 0L) return(out)

  values <- as.numeric(values)
  values[!is.finite(values) | values < 0] <- 0
  total <- sum(values)
  if (total <= 0) return(out)

  areas <- values / total * (width * height)
  ord   <- order(areas, decreasing = TRUE)        # largest first
  idx   <- ord[areas[ord] > 0]                     # skip zero-area tiles

  free <- list(x = x, y = y, w = width, h = height)

  place_row <- function(members, free) {
    a    <- areas[members]
    area <- sum(a)
    if (free$w >= free$h) {
      thick <- area / free$h                       # strip width, along x
      cy <- free$y
      for (k in seq_along(members)) {
        ch <- a[k] / thick
        out[members[k], ] <<- list(free$x, free$x + thick, cy, cy + ch)
        cy <- cy + ch
      }
      list(x = free$x + thick, y = free$y, w = free$w - thick, h = free$h)
    } else {
      thick <- area / free$w                       # strip height, along y
      cx <- free$x
      for (k in seq_along(members)) {
        cw <- a[k] / thick
        out[members[k], ] <<- list(cx, cx + cw, free$y, free$y + thick)
        cx <- cx + cw
      }
      list(x = free$x, y = free$y + thick, w = free$w, h = free$h - thick)
    }
  }

  row <- integer(0)
  pos <- 1L
  while (pos <= length(idx)) {
    cand <- idx[pos]
    side <- min(free$w, free$h)
    if (length(row) == 0L ||
        treemap_worst(areas[c(row, cand)], side) <=
        treemap_worst(areas[row], side)) {
      row <- c(row, cand)
      pos <- pos + 1L
    } else {
      free <- place_row(row, free)
      row  <- integer(0)
    }
  }
  if (length(row)) free <- place_row(row, free)

  out
}
