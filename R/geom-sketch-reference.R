# Layer 3 - reference lines (Tier 1)
# geom_sketch_abline / _hline / _vline. Each spans the panel; endpoints are
# derived from panel_params ranges, then drawn as a roughened segment.

# ---- GeomSketchAbline -------------------------------------------------------

#' @rdname geom_sketch_abline
#' @export
GeomSketchAbline <- ggplot2::ggproto(
  "GeomSketchAbline", ggplot2::Geom,
  required_aes = c("slope", "intercept"),
  default_aes = ggplot2::aes(colour = "black", linewidth = 0.5, linetype = 1,
                             alpha = NA),
  draw_key = draw_key_sketch_path,
  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "na.rm")
  },
  draw_panel = function(data, panel_params, coord,
                         roughness = 0.6, bowing = 0.5, n_passes = 2L,
                         seed = NULL, ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    xr <- panel_params$x.range %||% c(0, 1)
    grobs <- lapply(seq_len(nrow(data)), function(i) {
      row <- data[i, , drop = FALSE]
      gp  <- outline_gpar(row$colour, row$linewidth, row$linetype, row$alpha)
      .sketch_seg_grob(xr[1L], xr[1L] * row$slope + row$intercept,
                       xr[2L], xr[2L] * row$slope + row$intercept,
                       coord, panel_params, sp, gp, i * 41L)
    })
    do.call(gList, grobs)
  }
)

# ---- GeomSketchHline --------------------------------------------------------

#' @rdname geom_sketch_abline
#' @export
GeomSketchHline <- ggplot2::ggproto(
  "GeomSketchHline", ggplot2::Geom,
  required_aes = "yintercept",
  default_aes = ggplot2::aes(colour = "black", linewidth = 0.5, linetype = 1,
                             alpha = NA),
  draw_key = draw_key_sketch_path,
  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "na.rm")
  },
  draw_panel = function(data, panel_params, coord,
                         roughness = 0.6, bowing = 0.5, n_passes = 2L,
                         seed = NULL, ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    xr <- panel_params$x.range %||% c(0, 1)
    grobs <- lapply(seq_len(nrow(data)), function(i) {
      row <- data[i, , drop = FALSE]
      gp  <- outline_gpar(row$colour, row$linewidth, row$linetype, row$alpha)
      .sketch_seg_grob(xr[1L], row$yintercept, xr[2L], row$yintercept,
                       coord, panel_params, sp, gp, i * 43L)
    })
    do.call(gList, grobs)
  }
)

# ---- GeomSketchVline --------------------------------------------------------

#' @rdname geom_sketch_abline
#' @export
GeomSketchVline <- ggplot2::ggproto(
  "GeomSketchVline", ggplot2::Geom,
  required_aes = "xintercept",
  default_aes = ggplot2::aes(colour = "black", linewidth = 0.5, linetype = 1,
                             alpha = NA),
  draw_key = draw_key_sketch_path,
  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "na.rm")
  },
  draw_panel = function(data, panel_params, coord,
                         roughness = 0.6, bowing = 0.5, n_passes = 2L,
                         seed = NULL, ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    yr <- panel_params$y.range %||% c(0, 1)
    grobs <- lapply(seq_len(nrow(data)), function(i) {
      row <- data[i, , drop = FALSE]
      gp  <- outline_gpar(row$colour, row$linewidth, row$linetype, row$alpha)
      .sketch_seg_grob(row$xintercept, yr[1L], row$xintercept, yr[2L],
                       coord, panel_params, sp, gp, i * 47L)
    })
    do.call(gList, grobs)
  }
)

# ---- constructors -----------------------------------------------------------

#' Sketchy reference lines
#'
#' Hand-drawn `abline` / `hline` / `vline` reference lines that span the panel - 
#' the sketch analogues of [ggplot2::geom_abline()], [ggplot2::geom_hline()], and
#' [ggplot2::geom_vline()]. As with ggplot2, you usually pass the intercepts as
#' arguments rather than mapping them.
#'
#' @param mapping,data,... Standard layer arguments. Usually omitted in favour of
#'   the intercept arguments below.
#' @param slope,intercept For `geom_sketch_abline()`.
#' @param yintercept For `geom_sketch_hline()`.
#' @param xintercept For `geom_sketch_vline()`.
#' @param roughness,bowing,n_passes,seed Sketch parameters. Reference lines
#'   default to a gentle `roughness = 0.6`.
#' @param na.rm,show.legend Standard layer arguments.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_sketch_point(seed = 1L) +
#'   geom_sketch_hline(yintercept = 20, colour = "red", seed = 2L) +
#'   geom_sketch_vline(xintercept = 3, colour = "blue", seed = 3L) +
#'   theme_sketch()
geom_sketch_abline <- function(mapping = NULL, data = NULL, ...,
                                slope, intercept, roughness = 0.6, bowing = 0.5,
                                n_passes = 2L, seed = NULL, na.rm = FALSE,
                                show.legend = NA) {
  if (missing(slope) && missing(intercept) && is.null(mapping)) {
    slope <- 1; intercept <- 0
  }
  if (!missing(slope) || !missing(intercept)) {
    if (missing(slope))     slope <- 1
    if (missing(intercept)) intercept <- 0
    n <- max(length(slope), length(intercept))
    data <- data.frame(intercept = rep_len(intercept, n),
                       slope = rep_len(slope, n))
    mapping <- ggplot2::aes(intercept = intercept, slope = slope)
    show.legend <- FALSE
  }
  ggplot2::layer(
    data = data, mapping = mapping, stat = "identity", geom = GeomSketchAbline,
    position = "identity", show.legend = show.legend, inherit.aes = FALSE,
    params = list(roughness = roughness, bowing = bowing,
                  n_passes = as.integer(n_passes), seed = seed, na.rm = na.rm,
                  ...)
  )
}

#' @rdname geom_sketch_abline
#' @export
geom_sketch_hline <- function(mapping = NULL, data = NULL, ...,
                               yintercept, roughness = 0.6, bowing = 0.5,
                               n_passes = 2L, seed = NULL, na.rm = FALSE,
                               show.legend = NA) {
  if (!missing(yintercept)) {
    data <- data.frame(yintercept = yintercept)
    mapping <- ggplot2::aes(yintercept = yintercept)
    show.legend <- FALSE
  }
  ggplot2::layer(
    data = data, mapping = mapping, stat = "identity", geom = GeomSketchHline,
    position = "identity", show.legend = show.legend, inherit.aes = FALSE,
    params = list(roughness = roughness, bowing = bowing,
                  n_passes = as.integer(n_passes), seed = seed, na.rm = na.rm,
                  ...)
  )
}

#' @rdname geom_sketch_abline
#' @export
geom_sketch_vline <- function(mapping = NULL, data = NULL, ...,
                               xintercept, roughness = 0.6, bowing = 0.5,
                               n_passes = 2L, seed = NULL, na.rm = FALSE,
                               show.legend = NA) {
  if (!missing(xintercept)) {
    data <- data.frame(xintercept = xintercept)
    mapping <- ggplot2::aes(xintercept = xintercept)
    show.legend <- FALSE
  }
  ggplot2::layer(
    data = data, mapping = mapping, stat = "identity", geom = GeomSketchVline,
    position = "identity", show.legend = show.legend, inherit.aes = FALSE,
    params = list(roughness = roughness, bowing = bowing,
                  n_passes = as.integer(n_passes), seed = seed, na.rm = na.rm,
                  ...)
  )
}
