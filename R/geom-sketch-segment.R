# Layer 3 - geom_sketch_segment() / geom_sketch_step() (P5-T2)
# Segment: one roughened 2-point path per row (x,y)->(xend,yend).
# Step: stairstep the data, then draw as a single sketch path.

# ---- GeomSketchSegment ------------------------------------------------------

#' @rdname geom_sketch_segment
#' @export
GeomSketchSegment <- ggplot2::ggproto(
  "GeomSketchSegment", ggplot2::Geom,

  required_aes = c("x", "y", "xend", "yend"),

  default_aes = ggplot2::aes(
    colour    = "black",
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA,
    roughness = 1
  ),

  draw_key = draw_key_sketch_path,

  # roughness is a mappable aesthetic (per segment); the rest stay layer params.
  parameters = function(self, extra = FALSE) {
    c("bowing", "n_passes", "seed", "medium", "na.rm")
  },

  draw_panel = function(data, panel_params, coord,
                         roughness = 1, bowing = 1, n_passes = 2L,
                         seed = NULL, medium = "pen", ...) {
    if (nrow(data) == 0L) return(nullGrob())

    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    check_medium(medium)

    grobs <- lapply(seq_len(nrow(data)), function(i) {
      row  <- data[i, , drop = FALSE]
      pts  <- coord$transform(
        data.frame(x = c(row$x, row$xend), y = c(row$y, row$yend)),
        panel_params
      )
      sketch_medium_grob(
        x = pts$x, y = pts$y,
        medium = medium,
        colour = row$colour, linewidth = row$linewidth,
        linetype = row$linetype, alpha = row$alpha,
        roughness = max(row$roughness, 0), bowing = sp$bowing,
        n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, i * 53L)
      )
    })
    do.call(gList, grobs)
  }
)

# ---- geom_sketch_segment ----------------------------------------------------

#' Sketchy segment and step geoms
#'
#' `geom_sketch_segment()` draws roughened straight segments from `(x, y)` to
#' `(xend, yend)`.  `geom_sketch_step()` connects points with a hand-drawn
#' stairstep.  Sketch analogues of [ggplot2::geom_segment()] /
#' [ggplot2::geom_step()].
#'
#' @param mapping Set of aesthetic mappings created by [ggplot2::aes()].
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param roughness Non-negative roughness (0 = straight). Default 1. For
#'   `geom_sketch_segment()` this is a mappable aesthetic (map it per segment
#'   with `aes(roughness = )`, rescaled by [scale_roughness_continuous()]); for
#'   `geom_sketch_step()` it is a layer parameter (one path per group).
#' @param bowing Non-negative bowing multiplier. Default 1.
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param medium Drawing medium for the stroke: one of [sketch_media()]. The
#'   default `"pen"` is the classic constant-width double stroke; the others
#'   (`"ink"`, `"brush"`, `"pencil"`, `"charcoal"`, `"marker"`, `"crayon"`)
#'   render through the variable-width [stroke_ribbon()] engine.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend?
#' @param inherit.aes Override default aesthetics?
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(x = 1:3, y = 1:3, xend = 2:4, yend = c(3, 1, 4))
#' ggplot(df) +
#'   geom_sketch_segment(aes(x = x, y = y, xend = xend, yend = yend),
#'                       seed = 1L) +
#'   theme_sketch()
geom_sketch_segment <- function(mapping     = NULL,
                                 data        = NULL,
                                 stat        = "identity",
                                 position    = "identity",
                                 ...,
                                 roughness   = NULL,
                                 bowing      = 1,
                                 n_passes    = 2L,
                                 seed        = NULL,
                                 medium      = "pen",
                                 na.rm       = FALSE,
                                 show.legend = NA,
                                 inherit.aes = TRUE) {
  # roughness is a mappable aesthetic: only push a constant when supplied.
  params <- list(
    bowing = bowing, n_passes = as.integer(n_passes),
    seed = seed, medium = medium, na.rm = na.rm, ...
  )
  if (!is.null(roughness)) params$roughness <- roughness
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchSegment,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = params
  )
}

# ---- GeomSketchStep ---------------------------------------------------------

# Expand points into a stairstep path. direction "hv" = horizontal then
# vertical (default, like geom_step); "vh" = vertical then horizontal.
stairstep <- function(x, y, direction = "hv") {
  n <- length(x)
  if (n < 2L) return(data.frame(x = x, y = y))
  if (direction == "vh") {
    # vertical first: move y at the current x, then step x
    xs <- c(x[1L], rep(x[-1L], each = 2L))
    ys <- c(rep(y[-n], each = 2L), y[n])
    # swap roles: hold x, change y first
    xs <- c(rep(x[-n], each = 2L), x[n])
    ys <- c(y[1L], rep(y[-1L], each = 2L))
  } else {
    # horizontal first: hold y, step x, then change y
    xs <- c(x[1L], rep(x[-1L], each = 2L))
    ys <- c(rep(y[-n], each = 2L), y[n])
  }
  data.frame(x = xs, y = ys)
}

#' @rdname geom_sketch_segment
#' @export
GeomSketchStep <- ggplot2::ggproto(
  "GeomSketchStep", ggplot2::Geom,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    colour    = "black",
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA
  ),

  draw_key = draw_key_sketch_path,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "direction", "medium", "na.rm")
  },

  draw_group = function(data, panel_params, coord,
                         roughness = 1, bowing = 1, n_passes = 2L,
                         seed = NULL, direction = "hv", medium = "pen", ...) {
    if (nrow(data) < 2L) return(nullGrob())

    data <- data[order(data$x), , drop = FALSE]
    step <- stairstep(data$x, data$y, direction = direction)
    pts  <- coord$transform(step, panel_params)
    sp   <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    check_medium(medium)
    first <- data[1L, , drop = FALSE]

    sketch_medium_grob(
      x = pts$x, y = pts$y,
      medium = medium,
      colour = first$colour, linewidth = first$linewidth,
      linetype = first$linetype, alpha = first$alpha,
      roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
      seed = sp$seed
    )
  }
)

#' @rdname geom_sketch_segment
#' @param direction For `geom_sketch_step()`: `"hv"` (horizontal then vertical,
#'   default) or `"vh"`.
#' @export
geom_sketch_step <- function(mapping     = NULL,
                              data        = NULL,
                              stat        = "identity",
                              position    = "identity",
                              ...,
                              direction   = "hv",
                              roughness   = 1,
                              bowing      = 1,
                              n_passes    = 2L,
                              seed        = NULL,
                              medium      = "pen",
                              na.rm       = FALSE,
                              show.legend = NA,
                              inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchStep,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      direction = direction,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, medium = medium, na.rm = na.rm, ...
    )
  )
}
