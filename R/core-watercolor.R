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

#' Build a hole-aware watercolour wash for a multi-ring region
#'
#' The multi-ring analogue of [watercolor_wash()]: each wash layer is a jittered,
#' resized copy of *every* ring, so the grob can paint a layer as one even-odd
#' path and keep holes empty (rings shrink/grow about their own centroid). Used
#' by the band / multi-ring grobs (filled contours, density bands).
#'
#' @param rings A list of rings, each a list with inch-space `x` and `y` vertex
#'   vectors. Even-odd nesting defines holes.
#' @param n_layers Number of wash copies. Default 6.
#' @param bleed Edge irregularity in inches. `NULL` (default) scales to ~2% of
#'   the combined bounding diagonal.
#' @param granulation Fraction in `[0, 1]`: density of pigment specks (0 = none).
#'   Default 0. Specks land inside the even-odd region (never in holes).
#' @param seed Integer seed.
#' @return A list with `washes` (a list of layers; each layer is a list of
#'   2-column `(x, y)` ring matrices, outermost/lightest first) and `granules`
#'   (`list(x, y, r)` in inches, or `NULL`).
#' @family sketch-core
#' @export
watercolor_wash_multi <- function(rings,
                                  n_layers    = 6L,
                                  bleed       = NULL,
                                  granulation = 0,
                                  seed        = NULL) {
  rings <- lapply(rings, function(r) list(x = as.double(r$x), y = as.double(r$y)))
  rings <- Filter(function(r) length(r$x) >= 3L, rings)
  empty <- list(washes = list(), granules = NULL)
  if (!length(rings)) return(empty)

  seed     <- resolve_seed(seed)
  n_layers <- max(1L, as.integer(n_layers))

  allx <- unlist(lapply(rings, `[[`, "x"))
  ally <- unlist(lapply(rings, `[[`, "y"))
  diag  <- sqrt((max(allx) - min(allx))^2 + (max(ally) - min(ally))^2)
  bleed <- bleed %||% (diag * 0.02)

  cents    <- lapply(rings, function(r) c(mean(r$x), mean(r$y)))
  scales_k <- seq(1.05, 0.72, length.out = n_layers)

  washes <- within_seed(seed_offset(seed, 41L), {
    lapply(seq_len(n_layers), function(k) {
      sc <- scales_k[k]
      lapply(seq_along(rings), function(j) {
        r  <- rings[[j]]
        cx <- cents[[j]][1L]; cy <- cents[[j]][2L]
        nn <- length(r$x)
        jx <- stats::runif(nn, -bleed, bleed)
        jy <- stats::runif(nn, -bleed, bleed)
        matrix(c(cx + sc * (r$x - cx) + jx,
                 cy + sc * (r$y - cy) + jy),
               ncol = 2L, dimnames = list(NULL, c("x", "y")))
      })
    })
  })

  granules <- NULL
  if (granulation > 0) {
    granules <- within_seed(seed_offset(seed, 97L), {
      bbarea <- (max(allx) - min(allx)) * (max(ally) - min(ally))
      ntry   <- max(1L, as.integer(granulation * 1200 * bbarea / max(diag^2, 1e-9)))
      ntry   <- min(ntry, 600L)
      gx <- stats::runif(ntry, min(allx), max(allx))
      gy <- stats::runif(ntry, min(ally), max(ally))
      # even-odd membership across all rings keeps specks out of holes
      keep <- rep(FALSE, ntry)
      for (r in rings) keep <- xor(keep, point_in_polygon(gx, gy, r$x, r$y))
      if (!any(keep)) NULL else
        list(x = gx[keep], y = gy[keep],
             r = bleed * stats::runif(sum(keep), 0.15, 0.4))
    })
  }

  list(washes = washes, granules = granules)
}
