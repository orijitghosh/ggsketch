# Layer 3 - geom_sketch_waterfall() (v2.0)
# A waterfall chart: sequential deltas drawn as floating bars that step a
# running total up and down, with thin connectors carrying the level across the
# gaps. StatSketchWaterfall turns x (step) + y (delta) into running-total rects;
# drawing extends GeomSketchRect, so bars get the usual roughened outline and
# hachure / watercolour fill, plus roughened connector stubs.

# ---- StatSketchWaterfall -----------------------------------------------------

#' @rdname geom_sketch_waterfall
#' @export
StatSketchWaterfall <- ggplot2::ggproto(
  "StatSketchWaterfall", ggplot2::Stat,

  required_aes = c("x", "y"),

  optional_aes = "measure",

  # No `...`: ggplot2 reads recognised stat params from these formals.
  compute_panel = function(data, scales, width = 0.62, na.rm = FALSE) {
    if (nrow(data) == 0L) return(data)

    ord  <- order(data$x)
    data <- data[ord, , drop = FALSE]
    n    <- nrow(data)

    measure <- data$measure %||% rep("relative", n)
    is_tot  <- measure == "total"

    ymin <- ymax <- level <- numeric(n)
    cum  <- 0
    for (i in seq_len(n)) {
      if (is_tot[i]) {
        ymin[i] <- min(0, cum); ymax[i] <- max(0, cum)
      } else {
        ymin[i] <- min(cum, cum + data$y[i])
        ymax[i] <- max(cum, cum + data$y[i])
        cum     <- cum + data$y[i]
      }
      level[i] <- cum
    }

    change <- ifelse(is_tot, "total",
                     ifelse(data$y >= 0, "increase", "decrease"))

    out <- data
    out$xmin   <- data$x - width / 2
    out$xmax   <- data$x + width / 2
    out$ymin   <- ymin
    out$ymax   <- ymax
    out$change <- change
    out$group  <- seq_len(n)
    # Connector from this bar's right edge to the next bar's left edge, at the
    # running level after this bar (NA on the last row).
    out$con_x    <- c(out$xmax[-n], NA)
    out$con_xend <- c(out$xmin[-1L], NA)
    out$con_y    <- c(level[-n], NA)
    out
  }
)

# ---- GeomSketchWaterfall -----------------------------------------------------

#' @rdname geom_sketch_waterfall
#' @export
GeomSketchWaterfall <- ggplot2::ggproto(
  "GeomSketchWaterfall", GeomSketchRect,

  parameters = function(self, extra = FALSE) {
    c(ggplot2::ggproto_parent(GeomSketchRect, self)$parameters(extra),
      "fill_increase", "fill_decrease", "fill_total",
      "connectors", "connector_colour")
  },

  draw_panel = function(self, data, panel_params, coord,
                         fill_increase    = "#7fa87f",
                         fill_decrease    = "#b56b6f",
                         fill_total       = "#8391a7",
                         connectors       = TRUE,
                         connector_colour = "grey40",
                         roughness        = 1,
                         bowing           = 1,
                         n_passes         = 2L,
                         seed             = NULL,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())

    # Colour bars by direction unless any of the three is NULL (user maps fill).
    if (!is.null(fill_increase) && !is.null(fill_decrease) &&
        !is.null(fill_total) && !is.null(data$change)) {
      data$fill <- c(increase = fill_increase, decrease = fill_decrease,
                     total = fill_total)[data$change]
    }

    bars <- ggplot2::ggproto_parent(GeomSketchRect, self)$draw_panel(
      data, panel_params, coord,
      roughness = roughness, bowing = bowing, n_passes = n_passes,
      seed = seed, ...
    )
    if (!isTRUE(connectors) || is.null(data$con_x)) return(bars)

    sp   <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    keep <- which(is.finite(data$con_x) & is.finite(data$con_xend) &
                    is.finite(data$con_y) & data$con_xend > data$con_x)
    if (length(keep) == 0L) return(bars)

    from <- coord$transform(
      data.frame(x = data$con_x[keep],    y = data$con_y[keep]), panel_params)
    to   <- coord$transform(
      data.frame(x = data$con_xend[keep], y = data$con_y[keep]), panel_params)

    conns <- lapply(seq_along(keep), function(i) {
      sketch_path_grob(
        x = c(from$x[i], to$x[i]), y = c(from$y[i], to$y[i]),
        roughness = sp$roughness * 0.6, bowing = sp$bowing * 0.5,
        n_passes = 1L, seed = seed_offset(sp$seed, 4000L + i * 11L),
        gp = outline_gpar(colour = connector_colour,
                          linewidth = data$linewidth[keep[i]] * 0.8,
                          linetype = 3, alpha = data$alpha[keep[i]])
      )
    })
    do.call(gList, c(list(bars), conns))
  }
)

# ---- geom_sketch_waterfall ---------------------------------------------------

#' Sketchy waterfall chart
#'
#' Draws a hand-drawn waterfall: each step's delta (`y`) floats a bar from the
#' running total before it to the running total after it, stepping the level up
#' and down across the categories (`x`), with dotted hand-drawn connectors
#' carrying the level across the gaps. Map an optional `measure` aesthetic with
#' value `"total"` for rows that should draw the running total from zero (e.g.
#' a closing "Net" row) instead of a delta.
#'
#' Bars are coloured by direction (`fill_increase` / `fill_decrease` /
#' `fill_total`); set any of them to `NULL` and map `fill` yourself (the stat
#' exposes the direction as `after_stat(change)`).
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`
#'   (step, usually a factor in ledger order) and `y` (the delta); optionally
#'   `measure` (`"relative"` or `"total"` per row).
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"sketch_waterfall"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param width Bar width in x units. Default 0.62.
#' @param fill_increase,fill_decrease,fill_total Bar fills by direction. Set
#'   any to `NULL` to map `fill` yourself.
#' @param connectors Draw the dotted level connectors? Default `TRUE`.
#' @param connector_colour Connector colour. Default `"grey40"`.
#' @param colour Bar outline colour. Default `"grey25"`.
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
#' ledger <- data.frame(
#'   step  = factor(c("Start", "Sales", "Refunds", "Costs", "Tax", "Net"),
#'                  levels = c("Start", "Sales", "Refunds", "Costs", "Tax",
#'                             "Net")),
#'   delta = c(120, 80, -25, -60, -18, 0),
#'   kind  = c("relative", "relative", "relative", "relative", "relative",
#'             "total")
#' )
#' ggplot(ledger, aes(step, delta, measure = kind)) +
#'   geom_sketch_waterfall(seed = 1L) +
#'   theme_sketch()
geom_sketch_waterfall <- function(mapping          = NULL,
                                  data             = NULL,
                                  stat             = "sketch_waterfall",
                                  position         = "identity",
                                  ...,
                                  width            = 0.62,
                                  fill_increase    = "#7fa87f",
                                  fill_decrease    = "#b56b6f",
                                  fill_total       = "#8391a7",
                                  connectors       = TRUE,
                                  connector_colour = "grey40",
                                  colour           = "grey25",
                                  fill_style       = "hachure",
                                  roughness        = 1,
                                  bowing           = 1,
                                  n_passes         = 2L,
                                  seed             = NULL,
                                  na.rm            = FALSE,
                                  show.legend      = NA,
                                  inherit.aes      = TRUE) {
  params <- list(
    width = width,
    fill_increase = fill_increase, fill_decrease = fill_decrease,
    fill_total = fill_total,
    connectors = connectors, connector_colour = connector_colour,
    fill_style = fill_style,
    roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed, na.rm = na.rm, ...
  )
  if (!is.null(colour)) params$colour <- colour
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchWaterfall,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = params
  )
}
