# Layer 3 - geom_sketch_arrow() / annotate_sketch_arrow() (v1.7 annotation toolkit)
# A hand-drawn arrow from (x, y) to (xend, yend) with an optional handwriting
# label at the source end. "Content-aware": the shaft curvature defaults to a
# pleasing automatic bow, the arrowhead orients itself to the curve's end
# tangent, and the label justifies itself away from the target so it never sits
# under the shaft.

# ---- GeomSketchArrow --------------------------------------------------------

#' @rdname geom_sketch_arrow
#' @export
GeomSketchArrow <- ggplot2::ggproto(
  "GeomSketchArrow", ggplot2::Geom,

  required_aes = c("x", "y", "xend", "yend"),

  default_aes = ggplot2::aes(
    label     = NA,
    colour    = "black",
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA,
    size      = 3.88
  ),

  draw_key = draw_key_sketch_path,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "curvature",
      "arrow_length", "arrow_angle", "arrow_type", "arrow_head", "ends",
      "family", "label_gap", "na.rm")
  },

  draw_panel = function(data, panel_params, coord,
                         curvature    = "auto",
                         roughness    = 1,
                         bowing       = 1,
                         n_passes     = 2L,
                         seed         = NULL,
                         arrow_length = NULL,
                         arrow_angle  = 25,
                         arrow_type   = "open",
                         arrow_head   = NULL,
                         ends         = "last",
                         family       = NULL,
                         label_gap    = 0.012,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp  <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    fam <- resolve_label_family(family)

    p0 <- coord$transform(data.frame(x = data$x,    y = data$y),    panel_params)
    p1 <- coord$transform(data.frame(x = data$xend, y = data$yend), panel_params)
    x0 <- p0$x; y0 <- p0$y
    x1 <- p1$x; y1 <- p1$y
    dx <- x1 - x0; dy <- y1 - y0

    # Content-aware curvature: a gentle, consistent bow whose side follows the
    # direction of travel. A numeric `curvature` overrides it (0 = straight).
    if (identical(curvature, "auto")) {
      k <- ifelse(sign(dx) == 0, 0.3, 0.3 * sign(dx))
    } else {
      k <- rep(as.numeric(curvature), length.out = length(dx))
    }
    mx <- (x0 + x1) / 2; my <- (y0 + y1) / 2
    cx <- mx - dy * k * 0.5
    cy <- my + dx * k * 0.5

    arrow_grob <- sketch_arrow_grob(
      x0 = x0, y0 = y0, cx = cx, cy = cy, x1 = x1, y1 = y1,
      roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
      seed = sp$seed,
      arrow_length = arrow_length, arrow_angle = arrow_angle,
      arrow_type = arrow_type, arrow_head = arrow_head, ends = ends,
      gp = gpar(col = scales::alpha(data$colour, data$alpha),
                lwd = data$linewidth * ggplot2::.pt,
                lineend = "round", linejoin = "round")
    )

    grobs <- list(arrow_grob)

    for (i in seq_len(nrow(data))) {
      lab <- data$label[i]
      if (is.null(lab) || is.na(lab) || !nzchar(as.character(lab))) next
      sx <- if (dx[i] == 0) 0 else sign(dx[i])
      sy <- if (dy[i] == 0) 0 else sign(dy[i])
      grobs[[length(grobs) + 1L]] <- grid::textGrob(
        label = as.character(lab),
        x = unit(x0[i] - sx * label_gap, "npc"),
        y = unit(y0[i] - sy * label_gap, "npc"),
        hjust = 0.5 + 0.5 * sx,
        vjust = 0.5 + 0.5 * sy,
        gp = grid::gpar(
          col = scales::alpha(data$colour[i], data$alpha[i]),
          fontfamily = fam,
          fontsize = data$size[i] * ggplot2::.pt
        )
      )
    }
    do.call(gList, grobs)
  }
)

# ---- geom_sketch_arrow ------------------------------------------------------

#' Sketchy content-aware arrows
#'
#' Draws a hand-drawn arrow from `(x, y)` to `(xend, yend)`, with an optional
#' handwriting `label` at the source. It is "content-aware" in three ways:
#'
#' * the shaft curvature defaults to an automatic, pleasing bow whose side
#'   follows the direction of travel (`curvature = "auto"`);
#' * the arrowhead is roughened and oriented to the curve's *end tangent*, so it
#'   always points at the target however the shaft bends;
#' * the label justifies itself away from the target, so it never sits under the
#'   shaft.
#'
#' For one-off annotations, [annotate_sketch_arrow()] is the easiest entry point.
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`,
#'   `y`, `xend`, `yend`; `label` is optional.
#' @param data Data with one row per arrow.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param curvature Shaft bend. `"auto"` (default) picks a gentle bow; a number
#'   sets it explicitly (`0` straight, positive/negative bow to either side).
#' @param roughness Non-negative roughness (0 = clean). Default 1.
#' @param bowing Non-negative bowing multiplier. Default 1.
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param arrow_length Arrowhead length in inches. `NULL` (default) adapts it to
#'   the shaft length.
#' @param arrow_angle Half-angle of the arrowhead in degrees. Default 25.
#' @param arrow_type `"open"` (default) draws a two-stroke V; `"closed"` draws a
#'   filled rough triangle. Superseded by `arrow_head`; kept for back-compat.
#' @param arrow_head Arrowhead style, one of [sketch_arrowheads()]:
#'   `"triangle_open"`, `"triangle_filled"`, `"barb"` (swept harpoon barbs),
#'   `"fishtail"` (forked swallowtail), `"dot"` (a blob) or `"bar"` (a
#'   perpendicular tick). `NULL` (default) derives it from `arrow_type`.
#' @param ends Which end(s) carry a head: `"last"` (default), `"first"` or
#'   `"both"` (a double-headed arrow).
#' @param family Font family for the label. Defaults to the same family as
#'   [theme_sketch()] (`getOption("ggsketch.base_family", "")`, i.e. the device
#'   default), so the label matches the plot's other text; set
#'   `options(ggsketch.base_family = "auto")` for a handwriting face, or pass an
#'   explicit family here.
#' @param label_gap Gap between the label anchor and the source point, in npc.
#'   Default `0.012`.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend? Default `FALSE`.
#' @param inherit.aes Inherit aesthetics from the plot? Default `TRUE`.
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_sketch_point(seed = 1L) +
#'   annotate_sketch_arrow(x = 4.5, y = 30, xend = 5.25, yend = 18,
#'                         label = "heavy & thirsty", seed = 2L) +
#'   theme_sketch()
geom_sketch_arrow <- function(mapping      = NULL,
                              data         = NULL,
                              stat         = "identity",
                              position     = "identity",
                              ...,
                              curvature    = "auto",
                              roughness    = 1,
                              bowing       = 1,
                              n_passes     = 2L,
                              seed         = NULL,
                              arrow_length = NULL,
                              arrow_angle  = 25,
                              arrow_type   = "open",
                              arrow_head   = NULL,
                              ends         = "last",
                              family       = NULL,
                              label_gap    = 0.012,
                              na.rm        = FALSE,
                              show.legend  = FALSE,
                              inherit.aes  = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchArrow,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      curvature = curvature, roughness = roughness, bowing = bowing,
      n_passes = as.integer(n_passes), seed = seed,
      arrow_length = arrow_length, arrow_angle = arrow_angle,
      arrow_type = arrow_type, arrow_head = arrow_head, ends = ends,
      family = family, label_gap = label_gap,
      na.rm = na.rm, ...
    )
  )
}

# ---- annotate_sketch_arrow --------------------------------------------------

#' Add a one-off sketchy arrow annotation
#'
#' The easiest way to point at something: a single hand-drawn arrow (with an
#' optional handwriting label) that does not inherit the plot's aesthetics. A
#' thin wrapper around [geom_sketch_arrow()] in the spirit of
#' [ggplot2::annotate()].
#'
#' @param x,y Source point (where the label sits). Numeric, recycled.
#' @param xend,yend Target point (where the arrow points). Numeric, recycled.
#' @param label Optional text shown at the source. `NULL` draws a bare arrow.
#' @param curvature,roughness,arrow_type,seed Passed to [geom_sketch_arrow()].
#' @param ... Other arguments passed on to [geom_sketch_arrow()] (e.g.
#'   `colour`, `linewidth`, `arrow_length`, `family`).
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(faithful, aes(eruptions, waiting)) +
#'   geom_sketch_point(seed = 1L) +
#'   annotate_sketch_arrow(x = 2.2, y = 90, xend = 1.9, yend = 75,
#'                         label = "short bursts", colour = "#C0392B",
#'                         seed = 3L) +
#'   theme_sketch()
annotate_sketch_arrow <- function(x, y, xend, yend,
                                  label     = NULL,
                                  curvature = "auto",
                                  roughness = 1,
                                  arrow_type = "open",
                                  seed      = NULL,
                                  ...) {
  pos <- list(x = x, y = y, xend = xend, yend = yend, label = label)
  pos <- pos[lengths(pos) > 0L]
  lens <- lengths(pos)
  n    <- max(lens)
  if (!all(lens %in% c(1L, n))) {
    cli::cli_abort(c(
      "Unequal arrow aesthetic lengths.",
      i = "Each of {.arg x}, {.arg y}, {.arg xend}, {.arg yend}, {.arg label} \\
           must be length 1 or {n}."
    ))
  }
  data <- as.data.frame(lapply(pos, rep_len, length.out = n),
                        stringsAsFactors = FALSE)

  mapping <- ggplot2::aes(x = x, y = y, xend = xend, yend = yend)
  if (!is.null(label)) mapping$label <- rlang::sym("label")

  geom_sketch_arrow(
    mapping = mapping, data = data,
    curvature = curvature, roughness = roughness, arrow_type = arrow_type,
    seed = seed, inherit.aes = FALSE, ...
  )
}
