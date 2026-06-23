# Layer 3 - geom_sketch_dotplot() (v1.7; promised since 1.3.0)
# A Wilkinson-style dot plot: bin the data along x, then stack one roughened
# circular dot per observation. Binning ("histodot": fixed-width bins) is done
# in setup_data; the circular stacking is done at draw time in
# sketch_dotplot_grob, so dots stay round on any panel aspect.

# ---- GeomSketchDotplot ------------------------------------------------------

#' @rdname geom_sketch_dotplot
#' @export
GeomSketchDotplot <- ggplot2::ggproto(
  "GeomSketchDotplot", ggplot2::Geom,

  required_aes = c("x"),

  default_aes = ggplot2::aes(
    y         = 0,
    colour    = "black",
    fill      = "black",
    alpha     = NA,
    stroke    = 0.5,
    linetype  = 1
  ),

  draw_key = draw_key_sketch_point,

  parameters = function(self, extra = FALSE) {
    c("binwidth", "dotsize", "stackratio", "stackdir",
      "roughness", "bowing", "n_passes", "seed", "na.rm")
  },

  setup_data = function(data, params) {
    bw <- params$binwidth
    key <- interaction(data$PANEL, data$group %||% 1L, drop = TRUE)
    parts <- lapply(split(data, key), function(d) {
      w <- bw %||% (diff(range(d$x)) / 30)
      if (!is.finite(w) || w <= 0) w <- 1
      origin <- min(d$x)
      bin    <- floor((d$x - origin) / w + 0.5)
      d$x    <- origin + bin * w
      d <- d[order(d$x), , drop = FALSE]
      d$stackpos <- stats::ave(seq_len(nrow(d)), d$x, FUN = seq_along)
      d$count    <- stats::ave(seq_len(nrow(d)), d$x, FUN = length)
      d$binwidth <- w
      d
    })
    data <- do.call(rbind, parts)
    rownames(data) <- NULL
    # The y axis carries the per-bin count; dots themselves are sized by the
    # bin width and drawn circular, so the axis is approximate (as in
    # ggplot2::geom_dotplot()). Hide it with scale_y_continuous(NULL) if noisy.
    data$y    <- 0
    data$ymin <- 0
    data$ymax <- max(data$count)
    data
  },

  draw_group = function(data, panel_params, coord,
                         binwidth   = NULL,
                         dotsize    = 1,
                         stackratio = 1,
                         stackdir   = "up",
                         roughness  = 0.6,
                         bowing     = 1,
                         n_passes   = 2L,
                         seed       = NULL,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    bw  <- data$binwidth[1L]
    ref <- coord$transform(
      data.frame(x = c(min(data$x), min(data$x) + bw), y = c(0, 0)),
      panel_params
    )
    dia_npc <- abs(ref$x[2L] - ref$x[1L]) * dotsize

    tp <- coord$transform(
      data.frame(x = data$x, y = rep(0, nrow(data))), panel_params
    )

    sketch_dotplot_grob(
      x          = tp$x,
      stackpos   = data$stackpos,
      dia        = dia_npc,
      baseline   = tp$y[1L],
      stackratio = stackratio,
      roughness  = sp$roughness,
      n_passes   = sp$n_passes,
      seed       = sp$seed,
      fill_gp    = gpar(col = scales::alpha(data$fill, data$alpha)),
      outline_gp = gpar(
        col = scales::alpha(data$colour, data$alpha),
        lwd = data$stroke[1L] * ggplot2::.pt, lineend = "round"
      )
    )
  }
)

# ---- geom_sketch_dotplot ----------------------------------------------------

#' Sketchy dot plot
#'
#' Draws a hand-drawn Wilkinson-style dot plot: the data are binned along `x`
#' into fixed-width bins, and one roughened circular dot per observation is
#' stacked upward in each bin. The sketch analogue of
#' [ggplot2::geom_dotplot()].
#'
#' As in `ggplot2::geom_dotplot()`, the dots are sized by the bin width and the
#' y axis (the per-bin count) is only approximate; turn it off with
#' `scale_y_continuous(NULL, breaks = NULL)` for a clean look.
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`.
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param binwidth Bin width in data units. `NULL` (default) uses 1/30 of the
#'   data range.
#' @param dotsize Dot diameter as a multiple of the bin width. Default 1.
#' @param stackratio Vertical spacing between stacked dots, as a fraction of the
#'   dot diameter. Default 1.
#' @param stackdir Stacking direction. Only `"up"` is currently supported.
#' @param roughness Non-negative dot roughness. Default 0.6.
#' @param bowing Non-negative bowing multiplier. Default 1.
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend?
#' @param inherit.aes Override default aesthetics?
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(faithful, aes(eruptions)) +
#'   geom_sketch_dotplot(binwidth = 0.12, fill = "#7BAFD4", seed = 1L) +
#'   scale_y_continuous(NULL, breaks = NULL) +
#'   theme_sketch()
geom_sketch_dotplot <- function(mapping     = NULL,
                                data        = NULL,
                                stat        = "identity",
                                position    = "identity",
                                ...,
                                binwidth    = NULL,
                                dotsize     = 1,
                                stackratio  = 1,
                                stackdir    = "up",
                                roughness   = 0.6,
                                bowing      = 1,
                                n_passes    = 2L,
                                seed        = NULL,
                                na.rm       = FALSE,
                                show.legend = NA,
                                inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchDotplot,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      binwidth = binwidth, dotsize = dotsize, stackratio = stackratio,
      stackdir = stackdir, roughness = roughness, bowing = bowing,
      n_passes = as.integer(n_passes), seed = seed, na.rm = na.rm, ...
    )
  )
}
