# Layer 3 - geom_sketch_gantt() (v2.0)
# A Gantt / timeline chart: one hand-drawn bar per task from `x` (start) to
# `xend` (end) on a discrete `y`, the whiteboard-planning look. Extends
# GeomSketchRect (roughened outline, any fill_style, rounded corners), and an
# optional `progress` aesthetic overlays a solid completion bar.
# File is named -timeline (not -gantt) so it collates AFTER geom-sketch-rect.R:
# the ggproto inherit needs GeomSketchRect to exist at load time.

# ---- GeomSketchGantt ---------------------------------------------------------

#' @rdname geom_sketch_gantt
#' @export
GeomSketchGantt <- ggplot2::ggproto(
  "GeomSketchGantt", GeomSketchRect,

  required_aes = c("x", "xend", "y"),

  optional_aes = "progress",

  setup_data = function(data, params) {
    height <- params$height %||% 0.55
    transform(data,
              xmin = pmin(x, xend), xmax = pmax(x, xend),
              ymin = y - height / 2, ymax = y + height / 2)
  },

  parameters = function(self, extra = FALSE) {
    c(ggplot2::ggproto_parent(GeomSketchRect, self)$parameters(extra),
      "height", "progress_shade")
  },

  draw_panel = function(self, data, panel_params, coord,
                         height         = 0.55,
                         progress_shade = 0.65,
                         fill_style     = "hachure",
                         hachure_gap    = NULL,
                         seed           = NULL,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())

    # Task bars are wide and flat; the parent's width-based default gap would
    # give a few huge overshooting strokes, so default to a fixed fine pitch.
    hachure_gap <- hachure_gap %||% 0.12

    parent <- ggplot2::ggproto_parent(GeomSketchRect, self)
    bars   <- parent$draw_panel(data, panel_params, coord,
                                fill_style = fill_style,
                                hachure_gap = hachure_gap, seed = seed, ...)

    prog <- data$progress
    if (is.null(prog) || !any(is.finite(prog))) return(bars)

    # Completion overlay: a slimmer, always-solid bar over the first
    # progress-fraction of the task, in a darkened version of its fill.
    keep <- which(is.finite(prog) & prog > 0)
    if (length(keep) == 0L) return(bars)
    ov <- data[keep, , drop = FALSE]
    frac    <- pmin(1, ov$progress)
    inset   <- (ov$ymax - ov$ymin) * 0.275
    ov$xmax <- ov$xmin + (ov$xmax - ov$xmin) * frac
    ov$ymin <- ov$ymin + inset
    ov$ymax <- ov$ymax - inset
    ov$fill   <- grDevices::adjustcolor(ov$fill, red.f = progress_shade,
                                        green.f = progress_shade,
                                        blue.f = progress_shade)
    ov$colour <- NA
    sp <- resolve_sketch_params(1, 1, 2L, seed)
    overlay <- parent$draw_panel(
      ov, panel_params, coord,
      fill_style = "solid", seed = seed_offset(sp$seed, 6100L), ...
    )
    gList(bars, overlay)
  }
)

# ---- geom_sketch_gantt -------------------------------------------------------

#' Sketchy Gantt / timeline chart
#'
#' Draws a hand-drawn Gantt chart: one roughened bar per task from `x` (start)
#' to `xend` (end) on a discrete `y` -- the whiteboard project-planning look.
#' Map an optional `progress` aesthetic (0 to 1) to overlay a slimmer, darker
#' solid bar over the completed fraction of each task. Works with dates,
#' date-times or plain numbers on the x axis, and with every `fill_style`
#' (including `"watercolor"`); `corner_radius` rounds the bar ends.
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`,
#'   `xend` and `y`; optionally `progress` (completed fraction, 0-1).
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param height Bar height in y units. Default 0.55.
#' @param progress_shade Channel multiplier (< 1 darkens) for the progress
#'   overlay's fill. Default 0.65.
#' @param corner_radius Corner rounding of the bars; see [geom_sketch_rect()].
#'   Default 0.15.
#' @param fill_style Bar fill style; see [geom_sketch_rect()]. Default
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
#' plan <- data.frame(
#'   task  = factor(c("Design", "Build", "Test", "Ship"),
#'                  levels = rev(c("Design", "Build", "Test", "Ship"))),
#'   start = as.Date(c("2026-01-05", "2026-01-19", "2026-02-09", "2026-02-23")),
#'   end   = as.Date(c("2026-01-23", "2026-02-13", "2026-02-27", "2026-03-06")),
#'   done  = c(1, 0.7, 0.25, 0)
#' )
#' ggplot(plan, aes(x = start, xend = end, y = task, fill = task,
#'                  progress = done)) +
#'   geom_sketch_gantt(seed = 1L, show.legend = FALSE) +
#'   theme_sketch()
geom_sketch_gantt <- function(mapping        = NULL,
                              data           = NULL,
                              stat           = "identity",
                              position       = "identity",
                              ...,
                              height         = 0.55,
                              progress_shade = 0.65,
                              corner_radius  = 0.15,
                              fill_style     = "hachure",
                              roughness      = 1,
                              bowing         = 1,
                              n_passes       = 2L,
                              seed           = NULL,
                              na.rm          = FALSE,
                              show.legend    = NA,
                              inherit.aes    = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchGantt,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      height = height, progress_shade = progress_shade,
      corner_radius = corner_radius, fill_style = fill_style,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
