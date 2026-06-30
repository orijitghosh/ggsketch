# Layer 1 - watercolour wash fill (v2)
# Unlike the line-based fill styles (which return stroke segments), a watercolour
# wash is a stack of translucent, jittered, slightly-resized copies of the
# boundary: where they overlap the colour deepens (toward the interior), and the
# irregular edges feather like pigment bleeding into wet paper. Optional pigment
# granulation scatters a few darker specks. Two media-physics couplings ride on
# top: `grain` ties the edge feathering to the paper tooth (rough paper wicks
# more, in coherent capillary channels), and `wash_bleed()` mixes pigment where
# two wet washes overlap. Everything is plain polygons + dots + colour math, so
# it stays vector and reproduces on every device. No grid:: or ggplot2::.

# Coherent periodic displacement field over `n` loop vertices, values ~[-1, 1].
# Sum of a few low-frequency sinusoids with random phases; periodic in the vertex
# index so a closed boundary stays continuous (vertex n meets vertex 1). Models
# the paper tooth: neighbouring edge points feather together along capillary
# channels instead of independent salt-and-pepper jitter.
#' @noRd
wash_grain_field <- function(n, seed = NULL) {
  if (n < 1L) return(numeric(0))
  within_seed(resolve_seed(seed), {
    th    <- 2 * pi * (seq_len(n) - 1L) / n
    freqs <- c(2, 3, 5)
    amps  <- stats::runif(length(freqs), 0.4, 1)
    phs   <- stats::runif(length(freqs), 0, 2 * pi)
    v <- rowSums(vapply(seq_along(freqs), function(i)
      amps[i] * sin(freqs[i] * th + phs[i]), numeric(n)))
    v / max(abs(v), 1e-9)
  })
}

# Add paper-grain feathering to a set of per-vertex jitters. Given the existing
# uniform jitter (jx, jy) and the boundary about centroid (cx, cy), push each
# vertex in/out along its radial direction by a coherent grain field. A no-op
# when grain <= 0 (and draws no RNG then, so existing seeds reproduce exactly).
#' @noRd
apply_wash_grain <- function(px, py, cx, cy, jx, jy, grain, seed) {
  if (grain <= 0) return(list(jx = jx, jy = jy))
  n  <- length(px)
  f  <- wash_grain_field(n, seed = seed)
  rr <- sqrt((px - cx)^2 + (py - cy)^2); rr[rr < 1e-9] <- 1e-9
  push <- grain * 1.5 * f                     # in the same units as the jitter
  list(jx = jx + push * (px - cx) / rr,
       jy = jy + push * (py - cy) / rr)
}

# Mix two colours in sRGB, weight `w` toward `b`. Returns a hex string.
#' @noRd
blend_colours <- function(a, b, w = 0.5) {
  ca <- grDevices::col2rgb(a); cb <- grDevices::col2rgb(b)
  m  <- (1 - w) * ca + w * cb
  grDevices::rgb(m[1L], m[2L], m[3L], maxColorValue = 255)
}

#' Pigment bleed between two overlapping wash regions
#'
#' Where two wet watercolour washes overlap the pigments diffuse and the colours
#' mix - the "wet-on-wet" bleed. This approximates it without polygon clipping:
#' it samples points lying inside *both* polygons (the overlap region) and
#' returns soft translucent specks tinted with the blended colour. The grob layer
#' paints the specks at low alpha over the two washes, so the shared area reads as
#' mingled pigment. Pure geometry + colour math; reproduces on every device.
#'
#' @param ax,ay,bx,by Vertices (inch space) of the two wash polygons.
#' @param col_a,col_b The two wash colours (any R colour spec).
#' @param density Fraction in `[0, 1]`: speck density in the overlap. Default
#'   0.5.
#' @param bleed Speck radius scale in inches. `NULL` (default) scales to ~2.5% of
#'   the overlap's bounding diagonal.
#' @param seed Integer seed.
#' @return A `list(x, y, r, fill)` of bleed specks (inch space), or `NULL` when
#'   the polygons' bounding boxes - or the sampled overlap - do not meet.
#' @family sketch-core
#' @export
wash_bleed <- function(ax, ay, bx, by, col_a, col_b,
                       density = 0.5, bleed = NULL, seed = NULL) {
  ax <- as.double(ax); ay <- as.double(ay)
  bx <- as.double(bx); by <- as.double(by)
  if (length(ax) < 3L || length(bx) < 3L) return(NULL)
  # Cheap bounding-box reject before any point-in-polygon work.
  if (max(ax) < min(bx) || min(ax) > max(bx) ||
      max(ay) < min(by) || min(ay) > max(by)) return(NULL)

  ox0 <- max(min(ax), min(bx)); ox1 <- min(max(ax), max(bx))
  oy0 <- max(min(ay), min(by)); oy1 <- min(max(ay), max(by))
  if (ox1 <= ox0 || oy1 <= oy0) return(NULL)

  seed  <- resolve_seed(seed)
  diag  <- sqrt((ox1 - ox0)^2 + (oy1 - oy0)^2)
  bleed <- bleed %||% (diag * 0.025)

  within_seed(seed_offset(seed, 53L), {
    ntry <- min(500L, max(8L, as.integer(density * 400)))
    gx   <- stats::runif(ntry, ox0, ox1)
    gy   <- stats::runif(ntry, oy0, oy1)
    keep <- point_in_polygon(gx, gy, ax, ay) &
            point_in_polygon(gx, gy, bx, by)
    if (!any(keep)) NULL else
      list(x = gx[keep], y = gy[keep],
           r = bleed * stats::runif(sum(keep), 0.4, 1.1),
           fill = blend_colours(col_a, col_b))
  })
}

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
#' @param grain Paper-grain coupling in `[0, ~1]`: how strongly the edge feathers
#'   along the paper tooth. 0 (default) is the historical pure-uniform jitter;
#'   higher values wick the edge in coherent capillary channels (see
#'   [paper_grain()]). 0 draws no extra randomness, so existing seeds reproduce.
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
                            grain       = 0,
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

  grain <- max(0, grain)
  washes <- within_seed(seed_offset(seed, 41L), {
    lapply(seq_len(n_layers), function(k) {
      sc <- scales_k[k]
      jx <- stats::runif(n, -bleed, bleed)
      jy <- stats::runif(n, -bleed, bleed)
      gj <- apply_wash_grain(px, py, cx, cy, jx, jy,
                             grain * bleed, seed_offset(seed, 41L + k))
      matrix(c(cx + sc * (px - cx) + gj$jx,
               cy + sc * (py - cy) + gj$jy),
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
#' @param grain Paper-grain coupling in `[0, ~1]`: how strongly each ring's edge
#'   feathers along the paper tooth. 0 (default) is the historical pure-uniform
#'   jitter and draws no extra randomness. See [paper_grain()].
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
                                  grain       = 0,
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
  grain    <- max(0, grain)

  washes <- within_seed(seed_offset(seed, 41L), {
    lapply(seq_len(n_layers), function(k) {
      sc <- scales_k[k]
      lapply(seq_along(rings), function(j) {
        r  <- rings[[j]]
        cx <- cents[[j]][1L]; cy <- cents[[j]][2L]
        nn <- length(r$x)
        jx <- stats::runif(nn, -bleed, bleed)
        jy <- stats::runif(nn, -bleed, bleed)
        gj <- apply_wash_grain(r$x, r$y, cx, cy, jx, jy,
                               grain * bleed, seed_offset(seed, 41L + k * 7L + j))
        matrix(c(cx + sc * (r$x - cx) + gj$jx,
                 cy + sc * (r$y - cy) + gj$jy),
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
