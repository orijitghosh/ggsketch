# Layer 3 - geom_sketch_point() (P2-T4)
# Each point is a small rough ellipse rendered in makeContent().

# ---- SketchPointGrob --------------------------------------------------------

#' Create a sketchy point grob
#'
#' Each observation is rendered as a small roughened ellipse (the rough.js
#' circle/ellipse approach) with size proportional to the `size` aesthetic.
#'
#' @param x,y npc coordinates.
#' @param size Numeric vector of sizes (in mm, same convention as ggplot2).
#' @param roughness,n_passes,seed Sketch parameters.
#' @param gp `gpar()` for the strokes.
#' @noRd
sketch_point_grob <- function(x, y,
                               size      = 1.5,
                               roughness = 0.5,
                               n_passes  = 2L,
                               seed      = NULL,
                               gp        = gpar(),
                               name      = NULL,
                               vp        = NULL) {
  seed <- resolve_seed(seed)
  gTree(
    x = x, y = y, size = size,
    roughness = roughness, n_passes = as.integer(n_passes), seed = seed,
    gp = gp, name = name, vp = vp,
    cl = "SketchPointGrob"
  )
}

#' @method makeContent SketchPointGrob
#' @export
makeContent.SketchPointGrob <- function(x) {
  if (length(x$x) == 0L) {
    return(setChildren(x, gList(nullGrob())))
  }

  # Convert npc -> inches
  xi   <- as.numeric(convertX(unit(x$x, "npc"), "inches"))
  yi   <- as.numeric(convertY(unit(x$y, "npc"), "inches"))

  # Size: ggplot2 uses mm units; 1 mm approx 0.0394 inches
  # Default size 1.5 pt -> radius approx 0.01 inches
  sizes_in <- as.numeric(x$size) * 0.0394 / 2  # radius in inches
  rough    <- as.numeric(x$roughness)          # may be per-point (aes mappable)

  children <- vector("list", length(xi))

  for (i in seq_along(xi)) {
    r   <- max(sizes_in[min(i, length(sizes_in))], 0.002)
    r_i <- max(rough[[((i - 1L) %% length(rough)) + 1L]], 0)
    s_i <- seed_offset(x$seed, i * 53L)
    gp_i <- index_gpar(x$gp, i)  # per-point colour/lwd (aesthetics map per row)
    passes <- rough_ellipse(
      cx = xi[i], cy = yi[i],
      rx = r, ry = r,
      roughness = r_i,
      n_passes  = x$n_passes,
      seed      = s_i
    )

    pass_grobs <- lapply(passes, function(p) {
      polylineGrob(
        x  = unit(p[, "x"], "inches"),
        y  = unit(p[, "y"], "inches"),
        gp = gp_i
      )
    })
    children[[i]] <- do.call(gList, pass_grobs)
  }

  setChildren(x, do.call(gList, lapply(children, function(g) {
    gTree(children = g)
  })))
}

# ---- GeomSketchPoint --------------------------------------------------------

#' @rdname geom_sketch_point
#' @export
GeomSketchPoint <- ggplot2::ggproto(
  "GeomSketchPoint", ggplot2::Geom,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    colour    = "black",
    size      = 1.5,
    fill      = NA,
    alpha     = NA,
    shape     = 19,
    stroke    = 0.5,
    roughness = 0.5
  ),

  # roughness is an aesthetic here (mappable per point); n_passes/seed stay
  # layer params. bowing is accepted but unused (points are roughened ellipses).
  parameters = function(self, extra = FALSE) {
    c("bowing", "n_passes", "seed", "na.rm")
  },

  draw_key = draw_key_sketch_point,

  draw_group = function(data, panel_params, coord,
                         bowing = 1, n_passes = 2L, seed = NULL, ...) {
    if (nrow(data) == 0L) return(nullGrob())

    coords <- coord$transform(data, panel_params)

    sketch_point_grob(
      x         = coords$x,
      y         = coords$y,
      size      = coords$size,
      roughness = coords$roughness,
      n_passes  = max(1L, as.integer(n_passes)),
      seed      = resolve_seed(seed),
      gp        = gpar(
        col = scales::alpha(coords$colour, coords$alpha),
        lwd = coords$stroke * ggplot2::.pt,
        lineend = "round"
      )
    )
  }
)

#' Sketchy point geom
#'
#' Draws points as small roughened ellipses, giving each a hand-drawn feel.
#' Equivalent to `geom_point()` with a sketch aesthetic.
#'
#' Unlike the other geoms, `roughness` is a *mappable aesthetic* here: set it to a
#' constant (`geom_sketch_point(roughness = 2)`) so every point wobbles the same
#' amount, or map it to a variable (`aes(roughness = z)`) so each point wobbles
#' more or less. A mapped variable is rescaled to a legible roughness band by
#' [scale_roughness_continuous()] (the default range is `c(0.01, 0.75)`), exactly
#' as `scale_size()` rescales to a size range. Wrap values in [base::I()] to use
#' them as raw roughness instead.
#'
#' @inheritParams geom_sketch_path
#' @param mapping Set of aesthetic mappings. Supports `x`, `y`, `colour`,
#'   `size`, `alpha`, and `roughness`.
#' @return A `ggplot2` layer (a `LayerInstance` object) that can be added to a
#'   plot with `+`.
#' @family sketch-geoms
#' @seealso [scale_roughness_continuous()] to control how a mapped variable is
#'   turned into roughness.
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_sketch_point(roughness = 0.5, seed = 1L)
#'
#' # A constant sets how wobbly every point is.
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_sketch_point(roughness = 0, size = 3, seed = 1L)    # clean circles
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_sketch_point(roughness = 1.5, size = 3, seed = 1L)  # very sketchy
#'
#' # Map roughness to a variable: rescaled to c(0.01, 0.75) by default.
#' ggplot(mtcars, aes(wt, mpg, roughness = hp)) +
#'   geom_sketch_point(size = 3, seed = 1L)
geom_sketch_point <- function(mapping     = NULL,
                               data        = NULL,
                               stat        = "identity",
                               position    = "identity",
                               ...,
                               roughness   = NULL,
                               bowing      = NULL,
                               n_passes    = 2L,
                               seed        = NULL,
                               na.rm       = FALSE,
                               show.legend = NA,
                               inherit.aes = TRUE) {
  # `roughness` is a mappable aesthetic here. It defaults to NULL so we only set
  # it as a constant when the user passes one; otherwise an `aes(roughness = )`
  # mapping (or the default_aes value) is used and not overridden.
  params <- list(n_passes = as.integer(n_passes), seed = seed, na.rm = na.rm, ...)
  if (!is.null(roughness)) params$roughness <- roughness
  if (!is.null(bowing))    params$bowing    <- bowing
  ggplot2::layer(
    data        = data,
    mapping     = mapping,
    stat        = stat,
    geom        = GeomSketchPoint,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = params
  )
}
