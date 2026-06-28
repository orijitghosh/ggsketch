# Layer 3 - geom_sketch_ridgeline() (v2.0)
# Ridgeline / joyplot: a kernel density per category, each raised to its own
# baseline on a discrete y so the ridges overlap. StatSketchDensityRidges
# computes the densities and positions them (ymin = baseline, ymax = baseline +
# scaled density); GeomSketchRidgeline reuses the ribbon band drawing
# (sketch_polygon_grob via GeomSketchRibbon), drawing back-to-front so nearer
# ridges sit on top. The sketch take on ggridges::geom_density_ridges().

# ---- StatSketchDensityRidges -------------------------------------------------

#' @rdname geom_sketch_ridgeline
#' @export
StatSketchDensityRidges <- ggplot2::ggproto(
  "StatSketchDensityRidges", ggplot2::Stat,

  required_aes = c("x", "y"),

  # No `...`: ggplot2 reads recognised stat params from these formals.
  compute_panel = function(data, scales, bandwidth = NULL, n = 256L,
                            scale = 1.8, rel_min_height = 0, na.rm = FALSE) {
    if (nrow(data) == 0L) return(data)

    groups <- split(data, data$group)
    dens <- lapply(groups, function(d) {
      d <- d[is.finite(d$x), , drop = FALSE]
      if (nrow(d) < 2L) return(NULL)
      dd <- if (is.null(bandwidth)) stats::density(d$x, n = n)
            else stats::density(d$x, bw = bandwidth, n = n)
      list(proto = d[1L, , drop = FALSE], base = d$y[1L], x = dd$x, y = dd$y)
    })
    dens <- Filter(Negate(is.null), dens)
    if (!length(dens)) return(data[0L, , drop = FALSE])

    gmax <- max(vapply(dens, function(z) max(z$y), numeric(1)))
    s    <- if (gmax > 0) scale / gmax else 0

    parts <- lapply(dens, function(z) {
      keep <- z$y >= rel_min_height * gmax
      if (!any(keep)) return(NULL)
      k  <- sum(keep)
      df <- z$proto[rep(1L, k), , drop = FALSE]
      df$x       <- z$x[keep]
      df$density <- z$y[keep]
      df$ymin    <- z$base
      df$ymax    <- z$base + z$y[keep] * s
      df$height  <- z$y[keep] * s
      df
    })
    parts <- Filter(Negate(is.null), parts)
    do.call(rbind, parts)
  }
)

# ---- GeomSketchRidgeline -----------------------------------------------------

#' @rdname geom_sketch_ridgeline
#' @export
GeomSketchRidgeline <- ggplot2::ggproto(
  "GeomSketchRidgeline", GeomSketchRibbon,

  required_aes = c("x", "ymin", "ymax"),

  # Draw ridges from the back (highest baseline) to the front (lowest) so the
  # nearer curve overlaps the one behind it.
  draw_panel = function(self, data, panel_params, coord, ...) {
    if (nrow(data) == 0L) return(nullGrob())
    groups <- split(data, data$group)
    base   <- vapply(groups, function(d) min(d$ymin), numeric(1))
    groups <- groups[order(base, decreasing = TRUE)]
    grobs  <- lapply(groups, function(d)
      self$draw_group(d, panel_params, coord, ...))
    do.call(gList, grobs)
  }
)

# ---- geom_sketch_ridgeline ---------------------------------------------------

#' Sketchy ridgeline (joyplot)
#'
#' Draws a hand-drawn ridgeline plot: a kernel density of `x` for each category
#' on the discrete `y`, raised to its own baseline so the ridges overlap and the
#' changing shape of the distribution is easy to compare. Densities are computed
#' and positioned by [StatSketchDensityRidges]; each ridge is filled and outlined
#' with the usual sketch look, and ridges are drawn back-to-front so nearer ones
#' sit on top (cf. `ggridges::geom_density_ridges()`).
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`
#'   and a (usually discrete) `y`.
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"sketch_density_ridges"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param scale Vertical scaling: how many `y` units the tallest ridge spans.
#'   Values above 1 make ridges overlap. Default 1.8.
#' @param bandwidth Kernel bandwidth passed to [stats::density()]. Default
#'   `NULL` (automatic per group).
#' @param n Number of density evaluation points. Default 256.
#' @param rel_min_height Drop the density tails below this fraction of the global
#'   peak, trimming long thin feet. Default 0 (keep all).
#' @param roughness Non-negative roughness (0 = straight). Default 1.
#' @param bowing Non-negative bowing multiplier. Default 1.
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param fill_style One of `"hachure"`, `"cross_hatch"`, `"zigzag"`,
#'   `"zigzag_line"`, `"scribble"`, `"dots"`, `"dashed"`, `"solid"`, or
#'   `"watercolor"`. Default `"hachure"`.
#' @param hachure_angle Fill line angle in degrees. Default 45.
#' @param hachure_gap Fill line gap in npc units (`NULL` = 6% of diagonal).
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
#' ggplot(iris, aes(Sepal.Length, Species, fill = Species)) +
#'   geom_sketch_ridgeline(scale = 1.6, seed = 1L) +
#'   theme_sketch()
geom_sketch_ridgeline <- function(mapping        = NULL,
                                  data           = NULL,
                                  stat           = "sketch_density_ridges",
                                  position       = "identity",
                                  ...,
                                  scale          = 1.8,
                                  bandwidth      = NULL,
                                  n              = 256L,
                                  rel_min_height = 0,
                                  roughness      = 1,
                                  bowing         = 1,
                                  n_passes       = 2L,
                                  seed           = NULL,
                                  fill_style     = "hachure",
                                  hachure_angle  = 45,
                                  hachure_gap    = NULL,
                                  fill_weight    = 0.5,
                                  na.rm          = FALSE,
                                  show.legend    = NA,
                                  inherit.aes    = TRUE) {
  ggplot2::layer(
    data        = data,
    mapping     = mapping,
    stat        = stat,
    geom        = GeomSketchRidgeline,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = list(
      scale          = scale,
      bandwidth      = bandwidth,
      n              = as.integer(n),
      rel_min_height = rel_min_height,
      roughness      = roughness,
      bowing         = bowing,
      n_passes       = as.integer(n_passes),
      seed           = seed,
      fill_style     = fill_style,
      hachure_angle  = hachure_angle,
      hachure_gap    = hachure_gap,
      fill_weight    = fill_weight,
      na.rm          = na.rm,
      ...
    )
  )
}
