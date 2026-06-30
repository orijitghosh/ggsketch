# Layer 3 - geom_sketch_mark_circle() / _ellipse() / _rect() (v1.7)
# Roughened bounding shapes drawn around each group of points - the sketch
# analogues of ggforce::geom_mark_circle() / _ellipse() / _rect(), completing
# the mark family started by geom_sketch_mark_hull(). The boundary is computed
# in data space so the panel expands to fit the mark (no overflow), then drawn
# with sketch_polygon_grob() (sharing hull's fill / outline logic).

# Bounding ring (in data units) around a group's points. `shape` is "circle",
# "ellipse", or "rect"; returns a list(x, y) of boundary vertices, or NULL when
# there are too few points.
#' @noRd
mark_shape_ring <- function(x, y, shape, expand = 0.05) {
  if (length(x) < 2L) return(NULL)
  cx <- (min(x) + max(x)) / 2
  cy <- (min(y) + max(y)) / 2
  hx <- (max(x) - min(x)) / 2
  hy <- (max(y) - min(y)) / 2
  # Keep a degenerate (zero-width/height) group from collapsing to a line.
  if (hx <= 0) hx <- if (hy > 0) hy * 0.5 else 0.5
  if (hy <= 0) hy <- if (hx > 0) hx * 0.5 else 0.5

  if (identical(shape, "rect")) {
    ex <- hx * (1 + expand)
    ey <- hy * (1 + expand)
    return(list(x = c(cx - ex, cx + ex, cx + ex, cx - ex),
                y = c(cy - ey, cy - ey, cy + ey, cy + ey)))
  }

  # Axis-aligned ellipse through the bbox corners encloses the points (the
  # sqrt(2)). A "circle" uses one radius in data units, so it is a true circle
  # only under coord_equal() (as for geom_sketch_circle()); otherwise prefer the
  # ellipse.
  if (identical(shape, "circle")) {
    rx <- ry <- max(hx, hy) * sqrt(2) * (1 + expand)
  } else {
    rx <- hx * sqrt(2) * (1 + expand)
    ry <- hy * sqrt(2) * (1 + expand)
  }
  th <- seq(0, 2 * pi, length.out = 64L)[-64L]
  list(x = cx + rx * cos(th), y = cy + ry * sin(th))
}

# setup_data factory: expand the position scales to contain the mark.
#' @noRd
mark_shape_setup <- function(shape) {
  function(data, params) {
    expand <- params$expand %||% 0.05
    parts <- lapply(split(data, data$group %||% rep(1L, nrow(data))), function(d) {
      ring <- mark_shape_ring(d$x, d$y, shape, expand)
      if (!is.null(ring)) {
        d$xmin <- min(ring$x); d$xmax <- max(ring$x)
        d$ymin <- min(ring$y); d$ymax <- max(ring$y)
      }
      d
    })
    data <- do.call(rbind, parts)
    rownames(data) <- NULL
    data
  }
}

# draw_group factory: build the ring in data space, transform, draw.
#' @noRd
mark_shape_draw <- function(shape) {
  function(data, panel_params, coord,
           expand        = 0.05,
           roughness     = 1,
           bowing        = 1,
           n_passes      = 2L,
           seed          = NULL,
           fill_style    = "hachure",
           hachure_angle = 45,
           hachure_gap   = 0.07,
           fill_weight   = 0.5,
           ...) {
    ring <- mark_shape_ring(data$x, data$y, shape, expand)
    if (is.null(ring)) return(nullGrob())
    sp  <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    pts <- coord$transform(data.frame(x = ring$x, y = ring$y), panel_params)

    has_fill   <- !all(is.na(data$fill))
    fill_style <- if (has_fill) fill_style else "solid"

    sketch_polygon_grob(
      x = pts$x, y = pts$y,
      roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
      seed = sp$seed,
      fill_style = fill_style, hachure_angle = hachure_angle,
      hachure_gap = hachure_gap, fill_weight = fill_weight,
      fill_gp = gpar(col = scales::alpha(data$fill[1L], data$alpha[1L]),
                     lineend = "round"),
      outline_gp = gpar(col = scales::alpha(data$colour[1L], data$alpha[1L]),
                        lwd = data$linewidth[1L] * ggplot2::.pt,
                        lty = data$linetype[1L],
                        lineend = "round", linejoin = "round")
    )
  }
}

# ---- ggproto objects --------------------------------------------------------

#' @rdname geom_sketch_mark_circle
#' @export
GeomSketchMarkCircle <- ggplot2::ggproto(
  "GeomSketchMarkCircle", ggplot2::Geom,
  required_aes = c("x", "y"),
  default_aes  = ggplot2::aes(colour = "black", fill = NA, linewidth = 0.5,
                              linetype = 1, alpha = NA),
  draw_key = draw_key_sketch_polygon,
  parameters = function(self, extra = FALSE) {
    c("expand", "roughness", "bowing", "n_passes", "seed",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight", "na.rm")
  },
  setup_data = mark_shape_setup("circle"),
  draw_group = mark_shape_draw("circle")
)

#' @rdname geom_sketch_mark_circle
#' @export
GeomSketchMarkEllipse <- ggplot2::ggproto(
  "GeomSketchMarkEllipse", GeomSketchMarkCircle,
  setup_data = mark_shape_setup("ellipse"),
  draw_group = mark_shape_draw("ellipse")
)

#' @rdname geom_sketch_mark_circle
#' @export
GeomSketchMarkRect <- ggplot2::ggproto(
  "GeomSketchMarkRect", GeomSketchMarkCircle,
  setup_data = mark_shape_setup("rect"),
  draw_group = mark_shape_draw("rect")
)

# ---- constructors -----------------------------------------------------------

# Shared layer builder so the three constructors stay in lockstep.
#' @noRd
mark_shape_layer <- function(geom, mapping, data, stat, position,
                             expand, roughness, bowing, n_passes, seed,
                             fill_style, hachure_angle, hachure_gap,
                             fill_weight, na.rm, show.legend, inherit.aes,
                             dots) {
  params <- c(list(
    expand = expand, roughness = roughness, bowing = bowing,
    n_passes = as.integer(n_passes), seed = seed, fill_style = fill_style,
    hachure_angle = hachure_angle, hachure_gap = hachure_gap,
    fill_weight = fill_weight, na.rm = na.rm
  ), dots)
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = geom,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = params
  )
}

#' Sketchy bounding marks around point groups
#'
#' Draw a hand-drawn bounding shape around each group of points - the sketch
#' analogues of `ggforce::geom_mark_circle()` / `geom_mark_ellipse()` /
#' `geom_mark_rect()`, completing the family started by
#' [geom_sketch_mark_hull()]. Group the points with an aesthetic such as
#' `group`, `colour`, or `fill`; each group gets its own mark. With `fill`
#' mapped the mark is shaded (using `fill_style`); otherwise it is outline-only.
#' The position scales expand to contain the marks, so they are not clipped.
#'
#' The boundary is computed in data units, so a `geom_sketch_mark_circle()` is a
#' true circle only under [ggplot2::coord_equal()] (as for
#' [geom_sketch_circle()]); on a non-square panel prefer
#' `geom_sketch_mark_ellipse()`.
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`
#'   and `y`; map `group`/`colour`/`fill` to separate the clusters.
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param expand Fractional outward inflation of the mark, so it sits around the
#'   points rather than through them. Default `0.05`.
#' @param roughness Non-negative roughness (0 = clean). Default 1.
#' @param bowing Non-negative bowing multiplier. Default 1.
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param fill_style Fill style when `fill` is mapped: `"hachure"`,
#'   `"cross_hatch"`, `"zigzag"`, `"scribble"`, `"dots"`, `"dashed"`, `"stipple"`, `"pencil_shade"`, or
#'   `"solid"`. Default `"hachure"`.
#' @param hachure_angle Fill line angle in degrees. Default 45.
#' @param hachure_gap Fill line gap (npc fraction). Default 0.07.
#' @param fill_weight Stroke weight for fill lines. Default 0.5.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend?
#' @param inherit.aes Override default aesthetics?
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, colour = Species)) +
#'   geom_sketch_mark_ellipse(aes(fill = Species), seed = 1L) +
#'   geom_sketch_point(seed = 2L) +
#'   theme_sketch()
geom_sketch_mark_circle <- function(mapping       = NULL,
                                    data          = NULL,
                                    stat          = "identity",
                                    position      = "identity",
                                    ...,
                                    expand        = 0.05,
                                    roughness     = 1,
                                    bowing        = 1,
                                    n_passes      = 2L,
                                    seed          = NULL,
                                    fill_style    = "hachure",
                                    hachure_angle = 45,
                                    hachure_gap   = 0.07,
                                    fill_weight   = 0.5,
                                    na.rm         = FALSE,
                                    show.legend   = NA,
                                    inherit.aes   = TRUE) {
  mark_shape_layer(GeomSketchMarkCircle, mapping, data, stat, position,
                   expand, roughness, bowing, n_passes, seed,
                   fill_style, hachure_angle, hachure_gap, fill_weight,
                   na.rm, show.legend, inherit.aes, list(...))
}

#' @rdname geom_sketch_mark_circle
#' @export
geom_sketch_mark_ellipse <- function(mapping       = NULL,
                                     data          = NULL,
                                     stat          = "identity",
                                     position      = "identity",
                                     ...,
                                     expand        = 0.05,
                                     roughness     = 1,
                                     bowing        = 1,
                                     n_passes      = 2L,
                                     seed          = NULL,
                                     fill_style    = "hachure",
                                     hachure_angle = 45,
                                     hachure_gap   = 0.07,
                                     fill_weight   = 0.5,
                                     na.rm         = FALSE,
                                     show.legend   = NA,
                                     inherit.aes   = TRUE) {
  mark_shape_layer(GeomSketchMarkEllipse, mapping, data, stat, position,
                   expand, roughness, bowing, n_passes, seed,
                   fill_style, hachure_angle, hachure_gap, fill_weight,
                   na.rm, show.legend, inherit.aes, list(...))
}

#' @rdname geom_sketch_mark_circle
#' @export
geom_sketch_mark_rect <- function(mapping       = NULL,
                                  data          = NULL,
                                  stat          = "identity",
                                  position      = "identity",
                                  ...,
                                  expand        = 0.05,
                                  roughness     = 1,
                                  bowing        = 1,
                                  n_passes      = 2L,
                                  seed          = NULL,
                                  fill_style    = "hachure",
                                  hachure_angle = 45,
                                  hachure_gap   = 0.07,
                                  fill_weight   = 0.5,
                                  na.rm         = FALSE,
                                  show.legend   = NA,
                                  inherit.aes   = TRUE) {
  mark_shape_layer(GeomSketchMarkRect, mapping, data, stat, position,
                   expand, roughness, bowing, n_passes, seed,
                   fill_style, hachure_angle, hachure_gap, fill_weight,
                   na.rm, show.legend, inherit.aes, list(...))
}
