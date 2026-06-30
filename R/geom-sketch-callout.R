# Layer 3 - geom_sketch_callout() / annotate_sketch_callout() (v1.7 toolkit)
# A handwriting label in a roughened rounded box, optionally with a leader arrow
# pointing at a target (xend, yend). Built on sketch_callout_grob(), which sizes
# the box to the label and leaves the leader from the box edge.

# ---- GeomSketchCallout ------------------------------------------------------

#' @rdname geom_sketch_callout
#' @export
GeomSketchCallout <- ggplot2::ggproto(
  "GeomSketchCallout", ggplot2::Geom,

  required_aes = c("x", "y", "label"),

  default_aes = ggplot2::aes(
    xend      = NA,
    yend      = NA,
    colour    = "black",
    fill      = "white",
    linewidth = 0.5,
    alpha     = NA,
    size      = 3.88
  ),

  draw_key = draw_key_sketch_polygon,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "padding", "corner_radius",
      "arrow_length", "arrow_angle", "arrow_head", "leader", "curvature",
      "family", "na.rm")
  },

  draw_panel = function(data, panel_params, coord,
                         roughness     = 1,
                         bowing        = 0.6,
                         n_passes      = 2L,
                         seed          = NULL,
                         padding       = 0.06,
                         corner_radius = 0.3,
                         arrow_length  = NULL,
                         arrow_angle   = 25,
                         arrow_head    = NULL,
                         leader        = "straight",
                         curvature     = 0.3,
                         family        = NULL,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp  <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    fam <- resolve_label_family(family)

    box <- coord$transform(data.frame(x = data$x, y = data$y), panel_params)

    has_target <- !is.null(data$xend) && !is.null(data$yend) &&
      any(is.finite(data$xend) & is.finite(data$yend))
    if (has_target) {
      tgt <- coord$transform(
        data.frame(x = data$xend, y = data$yend), panel_params
      )
    } else {
      tgt <- data.frame(x = rep(NA_real_, nrow(data)),
                        y = rep(NA_real_, nrow(data)))
    }

    grobs <- lapply(seq_len(nrow(data)), function(i) {
      sketch_callout_grob(
        x = box$x[i], y = box$y[i], xend = tgt$x[i], yend = tgt$y[i],
        label = data$label[i],
        padding = padding, corner_radius = corner_radius,
        roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, i * 53L),
        arrow_length = arrow_length, arrow_angle = arrow_angle,
        arrow_head = arrow_head, leader = leader, curvature = curvature,
        text_gp = grid::gpar(
          col = scales::alpha(data$colour[i], data$alpha[i]),
          fontfamily = fam, fontsize = data$size[i] * ggplot2::.pt
        ),
        box_gp = grid::gpar(
          col = scales::alpha(data$colour[i], data$alpha[i]),
          fill = scales::alpha(data$fill[i], data$alpha[i]),
          lwd = data$linewidth[i] * ggplot2::.pt,
          lineend = "round", linejoin = "round"
        ),
        arrow_gp = grid::gpar(
          col = scales::alpha(data$colour[i], data$alpha[i]),
          lwd = data$linewidth[i] * ggplot2::.pt, lineend = "round"
        )
      )
    })
    do.call(gList, grobs)
  }
)

# ---- geom_sketch_callout ----------------------------------------------------

#' Sketchy callouts (boxed labels with a leader arrow)
#'
#' Draws a handwriting `label` inside a roughened rounded box, optionally with a
#' hand-drawn leader arrow pointing from the box to a target `(xend, yend)`. The
#' box auto-sizes to the label, and the leader leaves from the box edge nearest
#' the target. The sketch take on a speech-bubble / callout annotation.
#'
#' For one-off annotations, [annotate_sketch_callout()] is the easiest entry
#' point.
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`,
#'   `y`, and `label`; map `xend`/`yend` to add a leader arrow to a target.
#' @param data Data with one row per callout.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param roughness Non-negative roughness (0 = clean). Default 1.
#' @param bowing Non-negative bowing multiplier. Default 0.6.
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param padding Box padding around the label, in inches. Default 0.06.
#' @param corner_radius Box corner rounding (fraction of half-side). Default 0.3.
#' @param arrow_length Leader arrowhead length in inches. `NULL` (default)
#'   adapts it to the leader length.
#' @param arrow_angle Half-angle of the leader arrowhead in degrees. Default 25.
#' @param arrow_head Leader head style, one of [sketch_arrowheads()]. `NULL`
#'   (default) draws the open V.
#' @param leader Leader routing: `"straight"` (default), `"elbow"` (horizontal
#'   then vertical, flowchart style) or `"curved"` (a bowed Bezier).
#' @param curvature Bow size when `leader = "curved"`. Default 0.3.
#' @param family Font family for the label. Defaults to the same family as
#'   [theme_sketch()] (`getOption("ggsketch.base_family", "")`, i.e. the device
#'   default), so the label matches the plot's other text; set
#'   `options(ggsketch.base_family = "auto")` for a handwriting face, or pass an
#'   explicit family here.
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
#'   annotate_sketch_callout(x = 4, y = 32, label = "outlier?",
#'                           xend = 5.25, yend = 18, seed = 2L) +
#'   theme_sketch()
geom_sketch_callout <- function(mapping       = NULL,
                                data          = NULL,
                                stat          = "identity",
                                position      = "identity",
                                ...,
                                roughness     = 1,
                                bowing        = 0.6,
                                n_passes      = 2L,
                                seed          = NULL,
                                padding       = 0.06,
                                corner_radius = 0.3,
                                arrow_length  = NULL,
                                arrow_angle   = 25,
                                arrow_head    = NULL,
                                leader        = "straight",
                                curvature     = 0.3,
                                family        = NULL,
                                na.rm         = FALSE,
                                show.legend   = FALSE,
                                inherit.aes   = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchCallout,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, padding = padding, corner_radius = corner_radius,
      arrow_length = arrow_length, arrow_angle = arrow_angle,
      arrow_head = arrow_head, leader = leader, curvature = curvature,
      family = family, na.rm = na.rm, ...
    )
  )
}

# ---- annotate_sketch_callout ------------------------------------------------

#' Add a one-off sketchy callout annotation
#'
#' The easiest way to add a boxed note: a single hand-drawn callout (with an
#' optional leader arrow) that does not inherit the plot's aesthetics. A thin
#' wrapper around [geom_sketch_callout()] in the spirit of [ggplot2::annotate()].
#'
#' @param x,y Box position. Numeric, recycled.
#' @param label Label text.
#' @param xend,yend Optional target the leader points at. `NULL` (default) draws
#'   a boxed label with no leader.
#' @param seed Passed to [geom_sketch_callout()].
#' @param ... Other arguments passed on to [geom_sketch_callout()] (e.g.
#'   `colour`, `fill`, `roughness`, `corner_radius`, `family`).
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(faithful, aes(eruptions, waiting)) +
#'   geom_sketch_point(seed = 1L) +
#'   annotate_sketch_callout(x = 2.2, y = 95, label = "short waits",
#'                           xend = 1.9, yend = 75, seed = 3L) +
#'   theme_sketch()
annotate_sketch_callout <- function(x, y, label,
                                    xend = NULL, yend = NULL,
                                    seed = NULL,
                                    ...) {
  pos  <- list(x = x, y = y, label = label, xend = xend, yend = yend)
  pos  <- pos[lengths(pos) > 0L]
  lens <- lengths(pos)
  n    <- max(lens)
  if (!all(lens %in% c(1L, n))) {
    cli::cli_abort(c(
      "Unequal callout aesthetic lengths.",
      i = "Each supplied argument must be length 1 or {n}."
    ))
  }
  data <- as.data.frame(lapply(pos, rep_len, length.out = n),
                        stringsAsFactors = FALSE)

  mapping <- ggplot2::aes(x = x, y = y, label = label)
  if (!is.null(xend)) mapping$xend <- rlang::sym("xend")
  if (!is.null(yend)) mapping$yend <- rlang::sym("yend")

  geom_sketch_callout(
    mapping = mapping, data = data, seed = seed, inherit.aes = FALSE, ...
  )
}
