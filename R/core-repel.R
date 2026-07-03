# Layer 1 - label repulsion layout (v2.0)
# A ggrepel-style force solver: given anchor points and the size of each label
# box, nudge the boxes so they stop overlapping each other and stop covering the
# anchor points, while a weak spring keeps every box near its own anchor. Runs in
# a single isotropic space (the grob passes device inches) so distances read
# evenly on any panel aspect. Pure geometry - no grid:: or ggplot2:: - so it is
# testable on its own and reproduces on every device.

#' Repel overlapping label boxes away from each other and their anchors
#'
#' A small physical solver behind [geom_sketch_text_repel()] /
#' [geom_sketch_label_repel()]. Each label starts near its anchor and is pushed
#' by three forces, iterated to rest: boxes that overlap shove each other apart
#' along their axis of least penetration (preferring an axis with room left
#' inside the bounds, so pairs pressed into a panel corner escape along the
#' edge instead of staying stuck); a box covering any anchor point slides
#' off it; and a weak spring pulls each box back toward its own anchor so labels
#' stay close to what they name. Positions are clamped to `xlim` / `ylim`.
#'
#' @param ax,ay Anchor points (one per label), in a single isotropic space
#'   (e.g. device inches).
#' @param w,h Label box width and height (same units), recycled to the anchors.
#' @param xlim,ylim Length-2 bounds the box centres are kept within.
#' @param box_padding,point_padding Extra clearance around boxes and around
#'   anchor points, in the same units.
#' @param max_iter Maximum solver iterations. Default 2000.
#' @param seed Integer seed (for the tiny start jitter that separates labels
#'   sharing an anchor).
#' @return A list with `x`, `y` (the resolved box centres) and `iter` (iterations
#'   actually run).
#' @family sketch-core
#' @export
#' @examples
#' repel_layout(c(0, 0.1, 0.1), c(0, 0, 0.05), w = 0.4, h = 0.2, seed = 1L)
repel_layout <- function(ax, ay, w, h,
                         xlim          = c(-Inf, Inf),
                         ylim          = c(-Inf, Inf),
                         box_padding   = 0.1,
                         point_padding = 0.05,
                         max_iter      = 2000L,
                         seed          = NULL) {
  ax <- as.double(ax); ay <- as.double(ay)
  n  <- length(ax)
  if (n == 0L) return(list(x = numeric(0), y = numeric(0), iter = 0L))
  w  <- rep_len(as.double(w), n); h <- rep_len(as.double(h), n)
  hw <- w / 2 + box_padding; hh <- h / 2 + box_padding
  seed <- resolve_seed(seed)

  # Start each box a touch off its anchor, so coincident labels separate and the
  # solver is deterministic.
  jit <- within_seed(seed_offset(seed, 17L),
                     list(jx = stats::runif(n, -1, 1), jy = stats::runif(n, -1, 1)))
  px <- ax + jit$jx * hw * 0.5
  py <- ay + jit$jy * hh * 0.5

  slack  <- 0.01                      # leave a small gap, not just touching
  it_run <- 0L
  for (it in seq_len(max(1L, as.integer(max_iter)))) {
    it_run <- it

    # --- soft forces: slide off anchor points + a weak spring home ---
    fx <- numeric(n); fy <- numeric(n)
    for (i in seq_len(n)) {
      for (k in seq_len(n)) {
        dx <- ax[k] - px[i]; dy <- ay[k] - py[i]
        ox <- (hw[i] + point_padding) - abs(dx)
        oy <- (hh[i] + point_padding) - abs(dy)
        if (ox > 0 && oy > 0) {
          if (ox < oy) {
            fx[i] <- fx[i] - (if (dx >= 0) 1 else -1) * ox
          } else {
            fy[i] <- fy[i] - (if (dy >= 0) 1 else -1) * oy
          }
        }
      }
    }
    fx <- fx + (ax - px) * 0.005
    fy <- fy + (ay - py) * 0.005
    px <- px + fx * 0.8
    py <- py + fy * 0.8

    # --- hard pass: separate overlapping boxes, run last so it always wins ---
    sep_moved <- FALSE
    if (n >= 2L) {
      for (pass in seq_len(4L)) {
        any_ov <- FALSE
        for (i in seq_len(n - 1L)) {
          for (j in seq(i + 1L, n)) {
            dx <- px[j] - px[i]; dy <- py[j] - py[i]
            ox <- (hw[i] + hw[j] + slack) - abs(dx)
            oy <- (hh[i] + hh[j] + slack) - abs(dy)
            if (ox > 0 && oy > 0) {
              # Separate along the axis that has room inside the bounds, not
              # blindly along the least penetration: a pair clamped into a
              # panel corner would otherwise keep pushing along the blocked
              # axis, get clamped straight back, and stay overlapped.
              sx <- if (dx >= 0) 1 else -1     # j sits to the +x side of i
              sy <- if (dy >= 0) 1 else -1
              room_ix <- max(if (sx > 0) px[i] - (xlim[1L] + hw[i])
                             else (xlim[2L] - hw[i]) - px[i], 0)
              room_jx <- max(if (sx > 0) (xlim[2L] - hw[j]) - px[j]
                             else px[j] - (xlim[1L] + hw[j]), 0)
              room_iy <- max(if (sy > 0) py[i] - (ylim[1L] + hh[i])
                             else (ylim[2L] - hh[i]) - py[i], 0)
              room_jy <- max(if (sy > 0) (ylim[2L] - hh[j]) - py[j]
                             else py[j] - (ylim[1L] + hh[j]), 0)
              avail_x <- room_ix + room_jx
              avail_y <- room_iy + room_jy
              use_x <- if (avail_x >= ox && avail_y >= oy) ox < oy
                       else if (avail_x >= ox) TRUE
                       else if (avail_y >= oy) FALSE
                       else (avail_x / max(ox, 1e-9)) >= (avail_y / max(oy, 1e-9))
              if (use_x) {
                mi <- min(ox * 0.5, room_ix)
                mj <- min(ox - mi, room_jx)
                px[i] <- px[i] - sx * mi; px[j] <- px[j] + sx * mj
              } else {
                mi <- min(oy * 0.5, room_iy)
                mj <- min(oy - mi, room_jy)
                py[i] <- py[i] - sy * mi; py[j] <- py[j] + sy * mj
              }
              any_ov <- TRUE; sep_moved <- TRUE
            }
          }
        }
        if (!any_ov) break
      }
    }

    px <- pmin(pmax(px, xlim[1L] + hw), xlim[2L] - hw)
    py <- pmin(pmax(py, ylim[1L] + hh), ylim[2L] - hh)

    if (!sep_moved && it > 5L) break
  }

  list(x = px, y = py, iter = it_run)
}

# Where a ray from a box centre toward a target leaves the box (axis-aligned
# rectangle, half-extents hw/hh). Used to start the leader at the box edge.
#' @noRd
box_edge_point <- function(cx, cy, hw, hh, tx, ty) {
  dx <- tx - cx; dy <- ty - cy
  if (abs(dx) < 1e-9 && abs(dy) < 1e-9) return(c(cx, cy))
  sc <- min(hw / max(abs(dx), 1e-9), hh / max(abs(dy), 1e-9))
  c(cx + dx * sc, cy + dy * sc)
}
