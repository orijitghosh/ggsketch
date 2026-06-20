# Layer 3 — geom_sketch_point() (P2-T4)
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

  # Convert npc → inches
  xi   <- as.numeric(convertX(unit(x$x, "npc"), "inches"))
  yi   <- as.numeric(convertY(unit(x$y, "npc"), "inches"))

  # Size: ggplot2 uses mm units; 1 mm ≈ 0.0394 inches
  # Default size 1.5 pt → radius ≈ 0.01 inches
  sizes_in <- as.numeric(x$size) * 0.0394 / 2  # radius in inches

  children <- vector("list", length(xi))

  for (i in seq_along(xi)) {
    r   <- max(sizes_in[min(i, length(sizes_in))], 0.002)
    s_i <- seed_offset(x$seed, i * 53L)
    passes <- rough_ellipse(
      cx = xi[i], cy = yi[i],
      rx = r, ry = r,
      roughness = x$roughness,
      n_passes  = x$n_passes,
      seed      = s_i
    )

    pass_grobs <- lapply(passes, function(p) {
      polylineGrob(
        x  = unit(p[, "x"], "inches"),
        y  = unit(p[, "y"], "inches"),
        gp = x$gp
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
    stroke    = 0.5
  ),

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "na.rm")
  },

  draw_key = draw_key_sketch_point,

  draw_group = function(data, panel_params, coord,
                         roughness = 0.5, bowing = 1, n_passes = 2L,
                         seed = NULL, ...) {
    if (nrow(data) == 0L) return(nullGrob())

    coords <- coord$transform(data, panel_params)
    sp     <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    sketch_point_grob(
      x         = coords$x,
      y         = coords$y,
      size      = coords$size,
      roughness = sp$roughness,
      n_passes  = sp$n_passes,
      seed      = sp$seed,
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
#' @inheritParams geom_sketch_path
#' @param mapping Set of aesthetic mappings. Supports `x`, `y`, `colour`,
#'   `size`, `alpha`.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_sketch_point(roughness = 0.5, seed = 1L)
geom_sketch_point <- function(mapping     = NULL,
                               data        = NULL,
                               stat        = "identity",
                               position    = "identity",
                               ...,
                               roughness   = 0.5,
                               bowing      = 1,
                               n_passes    = 2L,
                               seed        = NULL,
                               na.rm       = FALSE,
                               show.legend = NA,
                               inherit.aes = TRUE) {
  ggplot2::layer(
    data        = data,
    mapping     = mapping,
    stat        = stat,
    geom        = GeomSketchPoint,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = list(
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
