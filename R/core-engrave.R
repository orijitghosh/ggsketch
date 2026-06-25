# Layer 1 - engraving / tonal cross-hatch fill (v2 module)
# Continuous tone via line DENSITY, the way an etcher or banknote engraver
# builds a gradient: a ladder of hatch layers, each at its own pitch and angle,
# every layer clipped to the iso-region where an underlying tone field exceeds
# that layer's threshold. Light areas keep only the sparse base layer; shadows
# accumulate every layer into dense cross-hatch. This is what the pattern
# packages cannot do -- they tile a motif; we COMPUTE tone from geometry.
# No grid:: or ggplot2:: (T-ARCH-01).

# ---- ladder -----------------------------------------------------------------

#' Build a tonal hatch ladder for engraving fills
#'
#' An engraving ladder is an ordered list of hatch layers; each is applied only
#' where the tone field is at least its `threshold`, so darker regions
#' accumulate more (and finer, cross-hatched) layers. Defaults trace the classic
#' etching progression: a sparse base layer, then denser same-angle lines, then
#' a second angle (cross-hatch), then the fine angles that read as black.
#'
#' @param n_levels Number of hatch layers. Default 5.
#' @param base_gap Pitch (inches) of the sparsest layer. Each subsequent layer
#'   tightens geometrically toward `base_gap * gap_ratio^(n_levels - 1)`.
#'   Default 0.10.
#' @param gap_ratio Multiplicative pitch shrink per layer (0 < r <= 1; smaller =
#'   faster densening). Default 0.62.
#' @param base_angle Angle (degrees) of the first layer. Default 45.
#' @param cross_after Layer index (1-based) at which cross-hatching begins; from
#'   this layer on, angles alternate by `cross_angle`. Default 3.
#' @param cross_angle Angular offset (degrees) of the cross direction.
#'   Default 90.
#' @param tone_floor,tone_ceiling Tone thresholds of the first and last layers;
#'   the layers' thresholds are spread evenly between them. A region with tone
#'   below `tone_floor` is left blank (paper); tone at or above `tone_ceiling`
#'   gets every layer. Defaults 0.12 and 0.92.
#' @return A list of layers, each `list(gap, angle, threshold)`.
#' @family sketch-core
#' @export
engrave_ladder <- function(n_levels     = 5L,
                           base_gap      = 0.10,
                           gap_ratio     = 0.62,
                           base_angle    = 45,
                           cross_after   = 3L,
                           cross_angle   = 90,
                           tone_floor    = 0.12,
                           tone_ceiling  = 0.92) {
  n_levels <- max(1L, as.integer(n_levels))
  thresholds <- if (n_levels == 1L) tone_floor
                else seq(tone_floor, tone_ceiling, length.out = n_levels)
  lapply(seq_len(n_levels), function(k) {
    gap   <- base_gap * gap_ratio^(k - 1L)
    cross <- (k >= cross_after) && ((k - cross_after) %% 2L == 1L)
    list(gap       = gap,
         angle     = base_angle + if (cross) cross_angle else 0,
         threshold = thresholds[k])
  })
}

# ---- segment gating ---------------------------------------------------------

# Keep only the runs of a straight scan segment where the tone field is at least
# `threshold`, then roughen each surviving run. `seg` is a 2-row (x, y) matrix
# in inch/data space (the rotated-back output of one scan line).
#' @noRd
gate_segment <- function(seg, field, threshold, step,
                         roughness, bowing, seed) {
  x0 <- seg[1L, "x"]; y0 <- seg[1L, "y"]
  x1 <- seg[nrow(seg), "x"]; y1 <- seg[nrow(seg), "y"]
  len <- sqrt((x1 - x0)^2 + (y1 - y0)^2)
  if (len < 1e-9) return(list())

  # Sample tone at the midpoint of each sub-step along the segment.
  n   <- max(1L, ceiling(len / step))
  tb  <- (seq_len(n) - 0.5) / n               # mid-fractions
  xm  <- x0 + tb * (x1 - x0)
  ym  <- y0 + tb * (y1 - y0)
  on  <- field(xm, ym) >= threshold
  if (!any(on)) return(list())

  # Group consecutive "on" steps into runs (each run -> one fill stroke).
  edges <- diff(c(FALSE, on, FALSE))
  starts <- which(edges == 1L)
  ends   <- which(edges == -1L) - 1L
  runs <- vector("list", length(starts))
  ri   <- 0L
  for (m in seq_along(starts)) {
    fa <- (starts[m] - 1L) / n                 # run start fraction
    fb <- ends[m] / n                          # run end fraction
    ax <- x0 + fa * (x1 - x0); ay <- y0 + fa * (y1 - y0)
    bx <- x0 + fb * (x1 - x0); by <- y0 + fb * (y1 - y0)
    ri <- ri + 1L
    if (roughness > 0) {
      s <- seed_offset(seed, ri * 17L)
      runs[[ri]] <- within_seed(s,
        roughen_segment(ax, ay, bx, by, roughness, bowing))
    } else {
      runs[[ri]] <- matrix(c(ax, bx, ay, by), nrow = 2L, ncol = 2L,
                           dimnames = list(NULL, c("x", "y")))
    }
  }
  runs[seq_len(ri)]
}

# ---- engraving fill ---------------------------------------------------------

#' Fill a region with tonal engraving (line density follows a tone field)
#'
#' The engraving counterpart of [hachure_fill_multi()]: instead of one uniform
#' hatch, it lays down a [engrave_ladder()] of hatch layers and keeps each layer
#' only where the `field` tone reaches that layer's threshold, so line density
#' (and cross-hatching) tracks the tone continuously across the region. Holes
#' are handled exactly as in [hachure_fill_multi()] (shared even-odd scan-line).
#'
#' @param rings A list of rings, each `list(x, y)` of vertex coordinates in
#'   inch/data space (see [hachure_fill_multi()]).
#' @param field A vectorised tone function `function(x, y)` returning a value in
#'   `[0, 1]` per point (0 = lightest/paper, 1 = darkest/solid).
#' @param ladder A hatch ladder from [engrave_ladder()]; if `NULL`, a default
#'   ladder is built from `...`.
#' @param roughness,bowing Sketch params applied to each surviving stroke.
#'   Defaults 0.5 and 0.
#' @param sample_step Tone-sampling step along each scan line (inches). `NULL`
#'   (default) uses a fraction of the finest ladder pitch.
#' @param seed Integer seed.
#' @param ... Passed to [engrave_ladder()] when `ladder` is `NULL`.
#' @return A list of 2-column (x, y) stroke matrices (same structure as
#'   [hachure_fill_multi()]), densest where the field is darkest.
#' @family sketch-core
#' @export
engrave_fill <- function(rings, field,
                         ladder      = NULL,
                         roughness   = 0.5,
                         bowing      = 0,
                         sample_step = NULL,
                         seed        = NULL,
                         ...) {
  seed   <- resolve_seed(seed)
  ladder <- ladder %||% engrave_ladder(...)
  if (length(rings) == 0L || length(ladder) == 0L) return(list())

  finest <- min(vapply(ladder, function(l) l$gap, numeric(1L)))
  step   <- sample_step %||% (finest * 0.5)

  out <- vector("list", length(ladder))
  for (k in seq_along(ladder)) {
    lay  <- ladder[[k]]
    # Straight scan lines for this layer (roughness applied per surviving run).
    segs <- hachure_fill_multi(rings, hachure_gap = lay$gap,
                               hachure_angle = lay$angle,
                               roughness = 0, bowing = 0,
                               seed = seed_offset(seed, k * 911L))
    if (length(segs) == 0L) { out[[k]] <- list(); next }
    gated <- lapply(seq_along(segs), function(i) {
      gate_segment(segs[[i]], field, lay$threshold, step,
                   roughness, bowing,
                   seed = seed_offset(seed, k * 911L + i * 17L))
    })
    out[[k]] <- do.call(c, gated)
  }
  do.call(c, out)
}
