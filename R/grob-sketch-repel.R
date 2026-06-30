# Layer 2 - repelled-label grob (v2.0)
# Lays out labels with repel_layout() at draw time (text metrics are only known
# then) and paints each as handwriting text - optionally in a roughened box -
# joined to its anchor point by a hand-drawn leader when it has moved away. The
# layout runs in device inches so repulsion is isotropic on any panel aspect.

#' Create a sketchy repelled-label grob
#'
#' Places `label`s near their anchors `(x, y)` but nudged apart so they do not
#' overlap each other or sit on the points, via [repel_layout()] (run in device
#' inches at draw time). Each displaced label is tied back to its anchor with a
#' roughened leader line. With `boxed = TRUE` the labels sit in roughened rounded
#' boxes (the [geom_sketch_label_repel()] look); otherwise they are bare text
#' (the [geom_sketch_text_repel()] look).
#'
#' @param x,y Anchor points in npc \[0,1\] (vectors).
#' @param label Character labels (recycled to the anchors).
#' @param boxed Draw each label in a rounded box? Default `FALSE`.
#' @param padding Text-to-edge / text clearance, in inches. Default 0.07.
#' @param corner_radius Box corner rounding (fraction of half-side). Default 0.3.
#' @param box_padding,point_padding Extra clearance between boxes and around
#'   anchor points, in inches.
#' @param min_segment Shortest leader drawn, in inches (shorter = no leader).
#' @param max_iter Solver iteration cap. Default 2000.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param text_gp,box_gp,seg_gp `gpar()`s for the text, the box, and the leader.
#' @param name,vp Passed to `grid::gTree()`.
#' @return A `SketchRepelGrob` grob subclass.
#' @family grob-layer
#' @export
sketch_repel_grob <- function(x, y, label,
                              boxed         = FALSE,
                              padding       = 0.07,
                              corner_radius = 0.3,
                              box_padding   = 0.1,
                              point_padding = 0.05,
                              min_segment   = 0.06,
                              max_iter      = 2000L,
                              roughness     = 1,
                              bowing        = 0.6,
                              n_passes      = 2L,
                              seed          = NULL,
                              text_gp       = gpar(),
                              box_gp        = gpar(),
                              seg_gp        = gpar(),
                              name          = NULL,
                              vp            = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    x = x, y = y, label = label, boxed = boxed,
    padding = padding, corner_radius = corner_radius,
    box_padding = box_padding, point_padding = point_padding,
    min_segment = min_segment, max_iter = as.integer(max_iter),
    roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed,
    text_gp = text_gp, box_gp = box_gp, seg_gp = seg_gp,
    name = name, vp = vp,
    cl = "SketchRepelGrob"
  )
}

#' @method makeContent SketchRepelGrob
#' @export
makeContent.SketchRepelGrob <- function(x) {
  n <- length(x$label)
  if (n == 0L) return(setChildren(x, gList(nullGrob())))

  W <- as.numeric(convertWidth(unit(1, "npc"), "inches"))
  H <- as.numeric(convertHeight(unit(1, "npc"), "inches"))
  ax <- as.numeric(convertX(unit(x$x, "npc"), "inches"))
  ay <- as.numeric(convertY(unit(x$y, "npc"), "inches"))

  # Box size from device-space text metrics (per label, font may vary by row).
  tw <- numeric(n); th <- numeric(n)
  for (i in seq_len(n)) {
    tg <- grid::textGrob(as.character(x$label[i]), gp = index_gpar(x$text_gp, i))
    tw[i] <- as.numeric(convertWidth(grid::grobWidth(tg), "inches"))
    th[i] <- as.numeric(convertHeight(grid::grobHeight(tg), "inches"))
  }
  hw <- tw / 2 + x$padding
  hh <- th / 2 + x$padding

  lay <- repel_layout(
    ax, ay, w = 2 * hw, h = 2 * hh,
    xlim = c(0, W), ylim = c(0, H),
    box_padding = x$box_padding, point_padding = x$point_padding,
    max_iter = x$max_iter, seed = x$seed
  )
  cx <- lay$x; cy <- lay$y

  children <- list()
  inch <- function(v) unit(v, "inches")

  for (i in seq_len(n)) {
    s_base <- seed_offset(x$seed, i * 53L)

    # --- leader: from the box edge toward the anchor, if displaced enough ---
    ep   <- box_edge_point(cx[i], cy[i], hw[i], hh[i], ax[i], ay[i])
    dist <- sqrt((ax[i] - ep[1L])^2 + (ay[i] - ep[2L])^2)
    if (dist > x$min_segment) {
      seg <- roughen_polyline(
        c(ep[1L], ax[i]), c(ep[2L], ay[i]),
        roughness = max(x$roughness, 0), bowing = x$bowing,
        n_passes  = x$n_passes, seed = seed_offset(s_base, 100L)
      )
      for (pass in seg) {
        children[[length(children) + 1L]] <- polylineGrob(
          x = inch(pass[, "x"]), y = inch(pass[, "y"]), gp = index_gpar(x$seg_gp, i)
        )
      }
    }

    # --- box (optional) ---
    if (isTRUE(x$boxed)) {
      rr <- rounded_rect_xy(cx[i] - hw[i], cx[i] + hw[i],
                            cy[i] - hh[i], cy[i] + hh[i],
                            rx = x$corner_radius * hw[i],
                            ry = x$corner_radius * hh[i])
      passes <- roughen_polyline(
        c(rr$x, rr$x[1L]), c(rr$y, rr$y[1L]),
        roughness = max(x$roughness, 0), bowing = x$bowing,
        n_passes  = x$n_passes, seed = seed_offset(s_base, 2000L)
      )
      box_gp_i <- index_gpar(x$box_gp, i)
      box_fill <- box_gp_i$fill
      if (length(box_fill) && !is.na(box_fill)) {
        fp <- passes[[1L]]
        children[[length(children) + 1L]] <- polygonGrob(
          x = inch(fp[, "x"]), y = inch(fp[, "y"]),
          gp = gpar(fill = box_fill, col = NA)
        )
      }
      out_gp <- box_gp_i; out_gp$fill <- NA
      for (pass in passes) {
        children[[length(children) + 1L]] <- polylineGrob(
          x = inch(pass[, "x"]), y = inch(pass[, "y"]), gp = out_gp
        )
      }
    }

    # --- the label text, centred in its box ---
    children[[length(children) + 1L]] <- grid::textGrob(
      as.character(x$label[i]), x = inch(cx[i]), y = inch(cy[i]),
      hjust = 0.5, vjust = 0.5, gp = index_gpar(x$text_gp, i)
    )
  }

  setChildren(x, do.call(gList, children))
}
