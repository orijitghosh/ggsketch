# Layer 1 - watercolour wash fill (v2)
# Unlike the line-based fill styles (which return stroke segments), a watercolour
# wash is a stack of translucent, jittered, slightly-resized copies of the
# boundary: where they overlap the colour deepens (toward the interior), and the
# irregular edges feather like pigment bleeding into wet paper. Optional pigment
# granulation scatters a few darker specks. Everything is plain polygons + dots,
# so it stays vector and reproduces on every device. No grid:: or ggplot2::.

#' Build a watercolour wash for a polygon region
#'
#' Returns a stack of translucent boundary copies plus optional granulation
#' specks; the grob layer paints the copies at a low alpha so overlap accumulates
#' tone. The look the line-based fill styles cannot give: soft, pooled, bleeding
#' colour.
#'
#' @param px,py Polygon vertices (inch space).
#' @param n_layers Number of wash copies. More = smoother, deeper, slower.
#'   Default 6.
#' @param bleed Edge irregularity in inches. `NULL` (default) scales to ~2% of
#'   the shape's bounding diagonal.
#' @param granulation Fraction in `[0, 1]`: density of pigment specks (0 = none).
#'   Default 0.
#' @param seed Integer seed.
#' @return A list with `washes` (a list of 2-column `(x, y)` polygon matrices,
#'   outermost/lightest first) and `granules` (`list(x, y, r)` in inches, or
#'   `NULL`).
#' @family sketch-core
#' @export
watercolor_wash <- function(px, py,
                            n_layers    = 6L,
                            bleed       = NULL,
                            granulation = 0,
                            seed        = NULL) {
  px <- as.double(px); py <- as.double(py)
  n  <- length(px)
  empty <- list(washes = list(), granules = NULL)
  if (n < 3L) return(empty)

  seed     <- resolve_seed(seed)
  n_layers <- max(1L, as.integer(n_layers))

  cx <- mean(px); cy <- mean(py)
  diag  <- sqrt((max(px) - min(px))^2 + (max(py) - min(py))^2)
  bleed <- bleed %||% (diag * 0.02)

  # Layer scales: the first copy bulges slightly past the boundary (soft outer
  # feather), later copies shrink inward (deepening centre).
  scales_k <- seq(1.05, 0.72, length.out = n_layers)

  washes <- within_seed(seed_offset(seed, 41L), {
    lapply(seq_len(n_layers), function(k) {
      sc <- scales_k[k]
      jx <- stats::runif(n, -bleed, bleed)
      jy <- stats::runif(n, -bleed, bleed)
      matrix(c(cx + sc * (px - cx) + jx,
               cy + sc * (py - cy) + jy),
             ncol = 2L, dimnames = list(NULL, c("x", "y")))
    })
  })

  granules <- NULL
  if (granulation > 0) {
    granules <- within_seed(seed_offset(seed, 97L), {
      # Aim for a speck count proportional to area and granulation.
      area  <- abs(sum(px * c(py[-1L], py[1L]) - c(px[-1L], px[1L]) * py)) / 2
      ntry  <- max(1L, as.integer(granulation * 1200 * area / max(diag^2, 1e-9)))
      ntry  <- min(ntry, 600L)
      gx <- stats::runif(ntry, min(px), max(px))
      gy <- stats::runif(ntry, min(py), max(py))
      keep <- point_in_polygon(gx, gy, px, py)
      if (!any(keep)) NULL else
        list(x = gx[keep], y = gy[keep],
             r = bleed * stats::runif(sum(keep), 0.15, 0.4))
    })
  }

  list(washes = washes, granules = granules)
}
