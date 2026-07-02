# Layer 3 - geom_sketch_funnel() + geom_sketch_pyramid() (v2.0)
# Two staged-bar charts. Funnel: horizontal bars centred on zero shrinking down
# the stages, with translucent trapezoid connectors carrying one stage into the
# next. Pyramid: mirrored back-to-back bars (population pyramid) split by a
# two-level group. Both are Stats feeding the GeomSketchRect machinery.
# File is named -stages so it collates AFTER geom-sketch-rect.R: the ggproto
# inherit needs GeomSketchRect to exist at load time.

# ---- StatSketchFunnel --------------------------------------------------------

#' @rdname geom_sketch_funnel
#' @export
StatSketchFunnel <- ggplot2::ggproto(
  "StatSketchFunnel", ggplot2::Stat,

  required_aes = c("x", "y"),

  # No `...`: ggplot2 reads recognised stat params from these formals.
  compute_panel = function(data, scales, bar_width = 0.7, na.rm = FALSE) {
    if (nrow(data) == 0L) return(data)

    data <- data[order(-data$y), , drop = FALSE]   # top stage first
    out  <- data
    out$xmin  <- -abs(data$x) / 2
    out$xmax  <-  abs(data$x) / 2
    out$x     <- 0                     # don't let the raw value pad the axis
    out$ymin  <- data$y - bar_width / 2
    out$ymax  <- data$y + bar_width / 2
    out$group <- seq_len(nrow(out))
    out
  }
)

# ---- GeomSketchFunnel --------------------------------------------------------

#' @rdname geom_sketch_funnel
#' @export
GeomSketchFunnel <- ggplot2::ggproto(
  "GeomSketchFunnel", GeomSketchRect,

  parameters = function(self, extra = FALSE) {
    c(ggplot2::ggproto_parent(GeomSketchRect, self)$parameters(extra),
      "connectors", "connector_alpha", "bar_width")
  },

  draw_panel = function(self, data, panel_params, coord,
                         connectors      = TRUE,
                         connector_alpha = 0.3,
                         bar_width       = 0.7,
                         hachure_gap     = NULL,
                         seed            = NULL,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())

    # Funnel bars are wide and flat; fix the pitch (see geom_sketch_gantt).
    hachure_gap <- hachure_gap %||% 0.12

    parent <- ggplot2::ggproto_parent(GeomSketchRect, self)
    bars   <- parent$draw_panel(data, panel_params, coord,
                                hachure_gap = hachure_gap, seed = seed, ...)
    if (!isTRUE(connectors) || nrow(data) < 2L) return(bars)

    # Trapezoids from the bottom edge of each bar to the top edge of the next
    # (rows arrive top stage first from the stat).
    data <- data[order(-((data$ymin + data$ymax) / 2)), , drop = FALSE]
    sp   <- resolve_sketch_params(1, 1, 2L, seed)
    conns <- lapply(seq_len(nrow(data) - 1L), function(i) {
      a <- data[i, ]; b <- data[i + 1L, ]
      pts <- coord$transform(
        data.frame(x = c(a$xmin, a$xmax, b$xmax, b$xmin),
                   y = c(a$ymin, a$ymin, b$ymax, b$ymax)),
        panel_params
      )
      grid::polygonGrob(
        pts$x, pts$y,
        gp = gpar(fill = scales::alpha(a$fill, connector_alpha), col = NA)
      )
    })
    do.call(gList, c(conns, list(bars)))
  }
)

# ---- geom_sketch_funnel ------------------------------------------------------

#' Sketchy funnel chart
#'
#' Draws a hand-drawn funnel: one horizontal bar per stage, centred on zero,
#' whose width is the stage's value (`x`), so the shrinking bars read as
#' drop-off down the stages (`y`). Translucent trapezoids connect each stage to
#' the next. Put the first stage at the top by ordering the `y` factor levels
#' accordingly (or add `scale_y_discrete(limits = rev)`); hide the mirrored
#' x axis with `theme(axis.text.x = element_blank())` or relabel it with
#' `scale_x_continuous(labels = abs)`.
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`
#'   (the stage value) and `y` (the stage).
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"sketch_funnel"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param bar_width Bar thickness in y units. Default 0.7.
#' @param connectors Draw the trapezoid connectors? Default `TRUE`.
#' @param connector_alpha Connector translucency. Default 0.3.
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
#' funnel <- data.frame(
#'   stage = factor(c("Visited", "Signed up", "Activated", "Paid"),
#'                  levels = rev(c("Visited", "Signed up", "Activated",
#'                                 "Paid"))),
#'   n     = c(1200, 460, 210, 80)
#' )
#' ggplot(funnel, aes(n, stage, fill = stage)) +
#'   geom_sketch_funnel(seed = 1L, show.legend = FALSE) +
#'   scale_x_continuous(labels = abs) +
#'   theme_sketch()
geom_sketch_funnel <- function(mapping         = NULL,
                               data            = NULL,
                               stat            = "sketch_funnel",
                               position        = "identity",
                               ...,
                               bar_width       = 0.7,
                               connectors      = TRUE,
                               connector_alpha = 0.3,
                               fill_style      = "hachure",
                               roughness       = 1,
                               bowing          = 1,
                               n_passes        = 2L,
                               seed            = NULL,
                               na.rm           = FALSE,
                               show.legend     = NA,
                               inherit.aes     = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchFunnel,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      bar_width = bar_width, connectors = connectors,
      connector_alpha = connector_alpha, fill_style = fill_style,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}

# ---- StatSketchPyramid -------------------------------------------------------

#' @rdname geom_sketch_pyramid
#' @export
StatSketchPyramid <- ggplot2::ggproto(
  "StatSketchPyramid", ggplot2::Stat,

  required_aes = c("x", "y", "side"),

  # No `...`: ggplot2 reads recognised stat params from these formals.
  compute_panel = function(data, scales, bar_width = 0.8, na.rm = FALSE) {
    if (nrow(data) == 0L) return(data)

    sides <- sort(unique(data$side))
    if (length(sides) != 2L) {
      cli::cli_abort(
        "{.fn geom_sketch_pyramid} needs exactly two {.field side} levels, not
         {length(sides)}."
      )
    }
    signed <- ifelse(data$side == sides[1L], -abs(data$x), abs(data$x))

    out <- data
    out$xmin  <- pmin(0, signed)
    out$xmax  <- pmax(0, signed)
    out$x     <- signed                # keep the raw value off the wrong side
    out$ymin  <- data$y - bar_width / 2
    out$ymax  <- data$y + bar_width / 2
    out$group <- seq_len(nrow(out))
    out
  }
)

# ---- GeomSketchPyramid -------------------------------------------------------

#' @rdname geom_sketch_pyramid
#' @export
GeomSketchPyramid <- ggplot2::ggproto(
  "GeomSketchPyramid", GeomSketchRect,

  parameters = function(self, extra = FALSE) {
    c(ggplot2::ggproto_parent(GeomSketchRect, self)$parameters(extra),
      "bar_width")
  },

  draw_panel = function(self, data, panel_params, coord,
                         bar_width   = 0.8,
                         hachure_gap = NULL,
                         seed        = NULL,
                         ...) {
    # Bars are long and flat; fix the pitch (see geom_sketch_gantt).
    hachure_gap <- hachure_gap %||% 0.12
    ggplot2::ggproto_parent(GeomSketchRect, self)$draw_panel(
      data, panel_params, coord, hachure_gap = hachure_gap, seed = seed, ...
    )
  }
)

# ---- geom_sketch_pyramid -----------------------------------------------------

#' Sketchy population pyramid
#'
#' Draws a hand-drawn population pyramid: back-to-back horizontal bars per
#' category (`y`), mirrored about zero by a two-level `side` aesthetic (the
#' first level in sort order grows left, the second right). Usually you also
#' map `fill` to the same variable as `side`; relabel the mirrored axis with
#' `scale_x_continuous(labels = abs)`.
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`
#'   (the count), `y` (the category) and `side` (the two-level split).
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"sketch_pyramid"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param bar_width Bar thickness in y units. Default 0.8.
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
#' pop <- data.frame(
#'   age = factor(rep(c("0-19", "20-39", "40-59", "60+"), 2),
#'                levels = c("0-19", "20-39", "40-59", "60+")),
#'   sex = rep(c("Female", "Male"), each = 4),
#'   n   = c(340, 420, 380, 240, 360, 440, 370, 200)
#' )
#' ggplot(pop, aes(n, age, side = sex, fill = sex)) +
#'   geom_sketch_pyramid(seed = 1L) +
#'   scale_x_continuous(labels = abs) +
#'   theme_sketch()
geom_sketch_pyramid <- function(mapping     = NULL,
                                data        = NULL,
                                stat        = "sketch_pyramid",
                                position    = "identity",
                                ...,
                                bar_width   = 0.8,
                                fill_style  = "hachure",
                                roughness   = 1,
                                bowing      = 1,
                                n_passes    = 2L,
                                seed        = NULL,
                                na.rm       = FALSE,
                                show.legend = NA,
                                inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchPyramid,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      bar_width = bar_width, fill_style = fill_style,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
