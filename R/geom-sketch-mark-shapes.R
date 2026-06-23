# Layer 3 - geom_sketch_mark_circle() / _ellipse() / _rect() (v1.7)
# Roughened bounding shapes drawn around each group of points - the sketch
# analogues of ggforce::geom_mark_circle() / _ellipse() / _rect(), completing
# the mark family started by geom_sketch_mark_hull(). Circle/ellipse reuse
# sketch_ellipse_grob(); rect reuses sketch_polygon_grob().

# Shared draw_group factory: compute a bounding shape (in npc) around the group
# and hand it to the right grob. `shape` is "circle", "ellipse", or "rect".
#' @noRd
mark_shape_draw <- function(shape) {
  function(data, panel_params, coord,
           expand        = 0.05,
           radius        = NULL,
           roughness     = 1,
           bowing        = 1,
           n_passes      = 2L,
           seed          = NULL,
           fill_style    = "hachure",
           hachure_angle = 45,
           hachure_gap   = 0.07,
           fill_weight   = 0.5,
           ...) {
    if (nrow(data) < 2L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    pts <- coord$transform(data.frame(x = data$x, y = data$y), panel_params)
    px  <- pts$x; py <- pts$y

    cx <- (min(px) + max(px)) / 2
    cy <- (min(py) + max(py)) / 2
    hx <- (max(px) - min(px)) / 2
    hy <- (max(py) - min(py)) / 2

    has_fill   <- !all(is.na(data$fill))
    fill_style <- if (has_fill) fill_style else "solid"
    fill_gp    <- gpar(col = scales::alpha(data$fill[1L], data$alpha[1L]),
                       lineend = "round")
    outline_gp <- gpar(col = scales::alpha(data$colour[1L], data$alpha[1L]),
                       lwd = data$linewidth[1L] * ggplot2::.pt,
                       lty = data$linetype[1L],
                       lineend = "round", linejoin = "round")

    if (identical(shape, "rect")) {
      # Expanded bounding box as a rectangle polygon.
      ex <- hx * (1 + expand) + 0.01
      ey <- hy * (1 + expand) + 0.01
      rx <- c(cx - ex, cx + ex, cx + ex, cx - ex)
      ry <- c(cy - ey, cy - ey, cy + ey, cy + ey)
      return(sketch_polygon_grob(
        x = rx, y = ry,
        roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
        seed = sp$seed,
        fill_style = fill_style, hachure_angle = hachure_angle,
        hachure_gap = hachure_gap, fill_weight = fill_weight,
        fill_gp = fill_gp, outline_gp = outline_gp
      ))
    }

    if (identical(shape, "circle")) {
      # Smallest enclosing-ish circle: max npc distance from the centre.
      r  <- max(sqrt((px - cx)^2 + (py - cy)^2))
      r  <- (radius %||% r) * (1 + expand) + 0.01
      rxv <- r; ryv <- r
    } else {
      # Axis-aligned ellipse through the bbox corners encloses the points.
      rxv <- (hx * sqrt(2)) * (1 + expand) + 0.01
      ryv <- (hy * sqrt(2)) * (1 + expand) + 0.01
    }

    sketch_ellipse_grob(
      x = cx, y = cy, rx = rxv, ry = ryv,
      roughness = sp$roughness, n_passes = sp$n_passes, seed = sp$seed,
      fill_style = fill_style, hachure_angle = hachure_angle,
      hachure_gap = hachure_gap, fill_weight = fill_weight,
      fill_gp = fill_gp, outline_gp = outline_gp
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
    c("expand", "radius", "roughness", "bowing", "n_passes", "seed",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight", "na.rm")
  },
  draw_group = mark_shape_draw("circle")
)

#' @rdname geom_sketch_mark_circle
#' @export
GeomSketchMarkEllipse <- ggplot2::ggproto(
  "GeomSketchMarkEllipse", GeomSketchMarkCircle,
  parameters = function(self, extra = FALSE) {
    c("expand", "roughness", "bowing", "n_passes", "seed",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight", "na.rm")
  },
  draw_group = mark_shape_draw("ellipse")
)

#' @rdname geom_sketch_mark_circle
#' @export
GeomSketchMarkRect <- ggplot2::ggproto(
  "GeomSketchMarkRect", GeomSketchMarkEllipse,
  draw_group = mark_shape_draw("rect")
)

# ---- constructors -----------------------------------------------------------

# Shared layer builder so the three constructors stay in lockstep.
#' @noRd
mark_shape_layer <- function(geom, mapping, data, stat, position,
                             expand, radius, roughness, bowing, n_passes, seed,
                             fill_style, hachure_angle, hachure_gap,
                             fill_weight, na.rm, show.legend, inherit.aes,
                             dots) {
  params <- c(list(
    expand = expand, roughness = roughness, bowing = bowing,
    n_passes = as.integer(n_passes), seed = seed, fill_style = fill_style,
    hachure_angle = hachure_angle, hachure_gap = hachure_gap,
    fill_weight = fill_weight, na.rm = na.rm
  ), dots)
  if (!is.null(radius)) params$radius <- radius
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
#'
#' Like [geom_sketch_circle()], the shapes are computed in panel-relative space,
#' so a "circle" may appear elliptical on a non-square panel; use
#' [ggplot2::coord_equal()] for a true circle.
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`
#'   and `y`; map `group`/`colour`/`fill` to separate the clusters.
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param expand Fractional outward inflation of the mark, so it sits around the
#'   points rather than through them. Default `0.05`.
#' @param radius For `geom_sketch_mark_circle()` only: a fixed circle radius
#'   (npc fraction) instead of the auto enclosing radius. Default `NULL`.
#' @param roughness Non-negative roughness (0 = clean). Default 1.
#' @param bowing Non-negative bowing multiplier. Default 1.
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param fill_style Fill style when `fill` is mapped: `"hachure"`,
#'   `"cross_hatch"`, `"zigzag"`, `"scribble"`, `"dots"`, `"dashed"`, or
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
                                    radius        = NULL,
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
                   expand, radius, roughness, bowing, n_passes, seed,
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
                   expand, NULL, roughness, bowing, n_passes, seed,
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
                   expand, NULL, roughness, bowing, n_passes, seed,
                   fill_style, hachure_angle, hachure_gap, fill_weight,
                   na.rm, show.legend, inherit.aes, list(...))
}
