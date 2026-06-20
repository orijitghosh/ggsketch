# Layer 3 — interval geoms (Tier 1)
# geom_sketch_linerange / _pointrange / _errorbar / _crossbar.
# All express an uncertainty interval (ymin..ymax) at x; built from sketch paths
# (and a point or box). Vertical orientation; horizontal is a future addition.

# Internal: a roughened straight segment from (x0,y0) to (x1,y1) in data space.
.sketch_seg_grob <- function(x0, y0, x1, y1, coord, panel_params, sp, gp, off) {
  pts <- coord$transform(data.frame(x = c(x0, x1), y = c(y0, y1)), panel_params)
  sketch_path_grob(
    x = pts$x, y = pts$y,
    roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
    seed = seed_offset(sp$seed, off), gp = gp
  )
}

.interval_params <- function(self, extra = FALSE) {
  c("roughness", "bowing", "n_passes", "seed", "width", "fatten",
    "fill_style", "hachure_angle", "hachure_gap", "fill_weight", "na.rm")
}

# ---- linerange --------------------------------------------------------------

#' @rdname geom_sketch_linerange
#' @export
GeomSketchLinerange <- ggplot2::ggproto(
  "GeomSketchLinerange", ggplot2::Geom,
  required_aes = c("x", "ymin", "ymax"),
  default_aes = ggplot2::aes(colour = "black", linewidth = 0.5, linetype = 1,
                             alpha = NA),
  draw_key = draw_key_sketch_path,
  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "na.rm")
  },
  draw_panel = function(data, panel_params, coord,
                         roughness = 1, bowing = 1, n_passes = 2L, seed = NULL,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    grobs <- lapply(seq_len(nrow(data)), function(i) {
      row <- data[i, , drop = FALSE]
      gp  <- outline_gpar(row$colour, row$linewidth, row$linetype, row$alpha)
      .sketch_seg_grob(row$x, row$ymin, row$x, row$ymax,
                       coord, panel_params, sp, gp, i * 53L)
    })
    do.call(gList, grobs)
  }
)

# ---- pointrange -------------------------------------------------------------

#' @rdname geom_sketch_linerange
#' @export
GeomSketchPointrange <- ggplot2::ggproto(
  "GeomSketchPointrange", ggplot2::Geom,
  required_aes = c("x", "y", "ymin", "ymax"),
  default_aes = ggplot2::aes(colour = "black", linewidth = 0.5, size = 0.5,
                             linetype = 1, shape = 19, fill = NA, alpha = NA,
                             stroke = 1),
  draw_key = draw_key_sketch_point,
  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "fatten", "na.rm")
  },
  draw_panel = function(data, panel_params, coord,
                         roughness = 0.7, bowing = 1, n_passes = 2L, seed = NULL,
                         fatten = 4, ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    grobs <- list()
    for (i in seq_len(nrow(data))) {
      row <- data[i, , drop = FALSE]
      gp  <- outline_gpar(row$colour, row$linewidth, row$linetype, row$alpha)
      grobs[[length(grobs) + 1L]] <-
        .sketch_seg_grob(row$x, row$ymin, row$x, row$ymax,
                         coord, panel_params, sp, gp, i * 53L)
      pt <- coord$transform(data.frame(x = row$x, y = row$y), panel_params)
      grobs[[length(grobs) + 1L]] <- sketch_point_grob(
        x = pt$x, y = pt$y, size = row$size * fatten,
        roughness = sp$roughness, n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, i * 53L + 1L),
        gp = gpar(col = scales::alpha(row$colour, row$alpha),
                  lwd = row$stroke * ggplot2::.pt, lineend = "round")
      )
    }
    do.call(gList, grobs)
  }
)

# ---- errorbar ---------------------------------------------------------------

#' @rdname geom_sketch_linerange
#' @export
GeomSketchErrorbar <- ggplot2::ggproto(
  "GeomSketchErrorbar", ggplot2::Geom,
  required_aes = c("x", "ymin", "ymax"),
  default_aes = ggplot2::aes(colour = "black", linewidth = 0.5, linetype = 1,
                             width = 0.5, alpha = NA),
  draw_key = draw_key_sketch_path,
  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "width", "na.rm")
  },
  setup_data = function(data, params) {
    data$width <- data$width %||% params$width %||%
      (ggplot2::resolution(data$x, FALSE) * 0.9)
    transform(data, xmin = x - width / 2, xmax = x + width / 2)
  },
  draw_panel = function(data, panel_params, coord,
                         roughness = 0.7, bowing = 1, n_passes = 2L, seed = NULL,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    grobs <- list()
    for (i in seq_len(nrow(data))) {
      row <- data[i, , drop = FALSE]
      gp  <- outline_gpar(row$colour, row$linewidth, row$linetype, row$alpha)
      b   <- i * 71L
      grobs[[length(grobs) + 1L]] <-
        .sketch_seg_grob(row$x, row$ymin, row$x, row$ymax,
                         coord, panel_params, sp, gp, b)          # stem
      grobs[[length(grobs) + 1L]] <-
        .sketch_seg_grob(row$xmin, row$ymax, row$xmax, row$ymax,
                         coord, panel_params, sp, gp, b + 1L)     # top cap
      grobs[[length(grobs) + 1L]] <-
        .sketch_seg_grob(row$xmin, row$ymin, row$xmax, row$ymin,
                         coord, panel_params, sp, gp, b + 2L)     # bottom cap
    }
    do.call(gList, grobs)
  }
)

# ---- crossbar ---------------------------------------------------------------

#' @rdname geom_sketch_linerange
#' @export
GeomSketchCrossbar <- ggplot2::ggproto(
  "GeomSketchCrossbar", ggplot2::Geom,
  required_aes = c("x", "y", "ymin", "ymax"),
  default_aes = ggplot2::aes(colour = "black", fill = NA, linewidth = 0.5,
                             linetype = 1, width = 0.5, alpha = NA),
  draw_key = draw_key_sketch_polygon,
  parameters = .interval_params,
  setup_data = function(data, params) {
    data$width <- data$width %||% params$width %||%
      (ggplot2::resolution(data$x, FALSE) * 0.9)
    transform(data, xmin = x - width / 2, xmax = x + width / 2)
  },
  draw_panel = function(data, panel_params, coord,
                         roughness = 0.7, bowing = 1, n_passes = 2L, seed = NULL,
                         fill_style = "solid", hachure_angle = 45,
                         hachure_gap = NULL, fill_weight = 0.5, ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    grobs <- list()
    for (i in seq_len(nrow(data))) {
      row <- data[i, , drop = FALSE]
      b   <- i * 89L
      box <- coord$transform(
        data.frame(x = c(row$xmin, row$xmax, row$xmax, row$xmin),
                   y = c(row$ymin, row$ymin, row$ymax, row$ymax)),
        panel_params
      )
      gap <- hachure_gap %||% (abs(box$x[2L] - box$x[1L]) * 0.15)
      grobs[[length(grobs) + 1L]] <- sketch_polygon_grob(
        x = box$x, y = box$y,
        roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, b),
        fill_style = fill_style, hachure_angle = hachure_angle,
        hachure_gap = max(gap, 1e-3), fill_weight = fill_weight,
        fill_gp = gpar(col = scales::alpha(row$fill, row$alpha),
                       lineend = "round"),
        outline_gp = outline_gpar(row$colour, row$linewidth, row$linetype,
                                  row$alpha)
      )
      gp <- outline_gpar(row$colour, row$linewidth * 2, row$linetype, row$alpha)
      grobs[[length(grobs) + 1L]] <-
        .sketch_seg_grob(row$xmin, row$y, row$xmax, row$y,
                         coord, panel_params, sp, gp, b + 1L)  # median line
    }
    do.call(gList, grobs)
  }
)

# ---- constructors -----------------------------------------------------------

#' Sketchy interval geoms
#'
#' Hand-drawn uncertainty intervals at each `x`: `geom_sketch_linerange()` draws
#' a vertical range from `ymin` to `ymax`; `geom_sketch_pointrange()` adds a point
#' at `y`; `geom_sketch_errorbar()` adds end caps; `geom_sketch_crossbar()` draws
#' a rough box with a line at `y`. Sketch analogues of
#' [ggplot2::geom_linerange()] and friends. Vertical orientation only in this
#' release.
#'
#' @param mapping,data,stat,position,na.rm,show.legend,inherit.aes,... Standard
#'   layer arguments.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param fatten For `pointrange`, multiply the point `size` by this factor.
#' @param width For `errorbar`/`crossbar`, the cap/box width in data units.
#' @param fill_style,hachure_angle,hachure_gap,fill_weight Fill parameters for
#'   the `crossbar` box.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(x = c("a", "b", "c"), y = c(2, 5, 4),
#'                  lo = c(1, 4, 2.5), hi = c(3, 6, 5.5))
#' ggplot(df, aes(x, y)) +
#'   geom_sketch_pointrange(aes(ymin = lo, ymax = hi), seed = 1L) +
#'   theme_sketch()
geom_sketch_linerange <- function(mapping = NULL, data = NULL, stat = "identity",
                                   position = "identity", ..., roughness = 0.7,
                                   bowing = 1, n_passes = 2L, seed = NULL,
                                   na.rm = FALSE, show.legend = NA,
                                   inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchLinerange,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(roughness = roughness, bowing = bowing,
                  n_passes = as.integer(n_passes), seed = seed, na.rm = na.rm,
                  ...)
  )
}

#' @rdname geom_sketch_linerange
#' @export
geom_sketch_pointrange <- function(mapping = NULL, data = NULL,
                                    stat = "identity", position = "identity",
                                    ..., fatten = 4, roughness = 0.7, bowing = 1,
                                    n_passes = 2L, seed = NULL, na.rm = FALSE,
                                    show.legend = NA, inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchPointrange,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(fatten = fatten, roughness = roughness, bowing = bowing,
                  n_passes = as.integer(n_passes), seed = seed, na.rm = na.rm,
                  ...)
  )
}

#' @rdname geom_sketch_linerange
#' @export
geom_sketch_errorbar <- function(mapping = NULL, data = NULL, stat = "identity",
                                  position = "identity", ..., width = 0.5,
                                  roughness = 0.7, bowing = 1, n_passes = 2L,
                                  seed = NULL, na.rm = FALSE, show.legend = NA,
                                  inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchErrorbar,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(width = width, roughness = roughness, bowing = bowing,
                  n_passes = as.integer(n_passes), seed = seed, na.rm = na.rm,
                  ...)
  )
}

#' @rdname geom_sketch_linerange
#' @export
geom_sketch_crossbar <- function(mapping = NULL, data = NULL, stat = "identity",
                                  position = "identity", ..., width = 0.5,
                                  roughness = 0.7, bowing = 1, n_passes = 2L,
                                  seed = NULL, fill_style = "solid",
                                  hachure_angle = 45, hachure_gap = NULL,
                                  fill_weight = 0.5, na.rm = FALSE,
                                  show.legend = NA, inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchCrossbar,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(width = width, roughness = roughness, bowing = bowing,
                  n_passes = as.integer(n_passes), seed = seed,
                  fill_style = fill_style, hachure_angle = hachure_angle,
                  hachure_gap = hachure_gap, fill_weight = fill_weight,
                  na.rm = na.rm, ...)
  )
}
