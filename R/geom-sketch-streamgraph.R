# Layer 3 - geom_sketch_streamgraph() (v2.0)
# A streamgraph (ThemeRiver): a stacked area whose baseline floats so the bands
# flow symmetrically around a moving centre. StatSketchStream stacks the values
# per x and offsets the baseline (zero / silhouette / wiggle); each band is then
# drawn as a roughened ribbon via GeomSketchRibbon. No new dependencies
# (cf. ggstream::geom_stream()).

# ---- StatSketchStream --------------------------------------------------------

#' @rdname geom_sketch_streamgraph
#' @export
StatSketchStream <- ggplot2::ggproto(
  "StatSketchStream", ggplot2::Stat,

  required_aes = c("x", "y"),

  # No `...`: ggplot2 reads recognised stat params from these formals.
  compute_panel = function(data, scales,
                            offset = c("silhouette", "zero", "wiggle"),
                            na.rm = FALSE) {
    if (nrow(data) == 0L) return(data)
    offset <- match.arg(offset)

    grp   <- if (!is.null(data$group)) data$group else rep(1L, nrow(data))
    groups <- sort(unique(grp))
    xs     <- sort(unique(data$x))
    n      <- length(groups)

    # value matrix [x, group], missing combinations treated as 0
    vmat <- matrix(0, length(xs), n)
    gi <- match(grp, groups); xi <- match(data$x, xs)
    for (k in seq_len(nrow(data))) vmat[xi[k], gi[k]] <- vmat[xi[k], gi[k]] + data$y[k]

    # representative metadata per group (fill, colour, ...) and the proto row
    proto    <- data[match(groups, grp), , drop = FALSE]
    n_xs     <- length(xs)

    parts <- lapply(seq_len(n_xs), function(r) {
      f  <- vmat[r, ]
      g0 <- switch(offset,
        zero       = 0,
        silhouette = -sum(f) / 2,
        wiggle     = -sum((n - seq_len(n) + 1) * f) / (n + 1)
      )
      top <- g0 + cumsum(f)
      bot <- g0 + c(0, top[-n] - g0)            # bottom_i = g0 + sum_{j<i} f_j
      df <- proto
      df$x    <- xs[r]
      df$ymin <- bot
      df$ymax <- top
      df
    })
    out <- do.call(rbind, parts)
    out$y <- NULL
    out[order(out$group, out$x), , drop = FALSE]
  }
)

# ---- geom_sketch_streamgraph -------------------------------------------------

#' Sketchy streamgraph
#'
#' Draws a hand-drawn streamgraph (a.k.a. ThemeRiver): a stacked area chart whose
#' baseline floats so the coloured bands flow around a moving centre, good for
#' showing how a few categories rise and fall over time. Map `x` (usually time),
#' `y` (value), and `fill` (category). Values are stacked and the baseline offset
#' by [StatSketchStream]; each band is drawn as a roughened ribbon, so it takes
#' any `fill_style` (including `"watercolor"`). No new dependencies
#' (cf. `ggstream::geom_stream()`).
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`
#'   and `y`; usually map `fill` (or `group`) to the category.
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"sketch_stream"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param offset Baseline placement: `"silhouette"` (centred, the classic
#'   streamgraph, default), `"zero"` (a normal stacked area), or `"wiggle"`
#'   (minimises the overall slope).
#' @param fill_style Band fill style; see [geom_sketch_ribbon()]. Default
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
#' set.seed(1)
#' df <- expand.grid(t = 1:12, grp = c("a", "b", "c", "d"))
#' df$v <- abs(sin(df$t / 3 + match(df$grp, letters)) + 1.2) * 5
#' ggplot(df, aes(t, v, fill = grp)) +
#'   geom_sketch_streamgraph(seed = 1L) +
#'   theme_sketch()
geom_sketch_streamgraph <- function(mapping     = NULL,
                                    data        = NULL,
                                    stat        = "sketch_stream",
                                    position    = "identity",
                                    ...,
                                    offset      = "silhouette",
                                    fill_style  = "hachure",
                                    roughness   = 1,
                                    bowing      = 1,
                                    n_passes    = 2L,
                                    seed        = NULL,
                                    na.rm       = FALSE,
                                    show.legend = NA,
                                    inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchRibbon,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      offset = offset, fill_style = fill_style,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
