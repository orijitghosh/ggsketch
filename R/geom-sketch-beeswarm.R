# Layer 3 - geom_sketch_beeswarm() (v2.0)
# A beeswarm / dot-strip chart: points at a categorical x are offset sideways so
# they don't overlap, revealing the distribution shape. The offset is computed
# deterministically in DATA space (a "centre" swarm: bin y, then fan each bin's
# points symmetrically around the category centre), so it needs no device
# metrics and is fully reproducible. Drawing reuses GeomSketchPoint, so the dots
# get the usual hand-drawn wobble. The sketch take on ggbeeswarm::geom_beeswarm().

# ---- StatSketchBeeswarm ------------------------------------------------------

#' @rdname geom_sketch_beeswarm
#' @export
StatSketchBeeswarm <- ggplot2::ggproto(
  "StatSketchBeeswarm", ggplot2::Stat,

  required_aes = c("x", "y"),

  # No `...` here: ggplot2 derives the stat's recognised parameters from
  # compute_panel's formals only when it has no dots, so binwidth/width/nbins
  # must be named here to be accepted as layer params.
  compute_panel = function(data, scales, binwidth = NULL, width = NULL,
                            nbins = 30L, na.rm = FALSE) {
    if (nrow(data) == 0L) return(data)

    yr   <- range(data$y, na.rm = TRUE)
    span <- diff(yr)
    bw   <- binwidth %||% (if (span > 0) span / nbins else 1)

    # global bin index per point, so the swarm width is consistent across
    # categories and we can size the step to keep the widest bin in bounds.
    bin_all <- if (bw > 0) floor((data$y - yr[1L]) / bw) else rep(0, nrow(data))
    counts  <- table(interaction(data$x, bin_all, drop = TRUE))
    maxmag  <- (max(counts) %/% 2L)
    w       <- width %||% min(0.1, 0.4 / max(maxmag, 1L))

    parts <- lapply(split(seq_len(nrow(data)), data$x), function(idx) {
      d <- data[idx, , drop = FALSE]
      o <- order(d$y)
      d <- d[o, , drop = FALSE]
      bin <- if (bw > 0) floor((d$y - yr[1L]) / bw) else rep(0, nrow(d))
      offs <- numeric(nrow(d))
      for (b in unique(bin)) {
        sel  <- which(bin == b)
        k    <- length(sel)
        i    <- seq_len(k)
        mag  <- i %/% 2L                       # 0,1,1,2,2,...
        sign <- ifelse(i %% 2L == 0L, 1, -1)   # +, - alternating
        offs[sel] <- sign * mag * w
      }
      d$x <- d$x + offs
      d
    })
    do.call(rbind, parts)
  }
)

# ---- geom_sketch_beeswarm ----------------------------------------------------

#' Sketchy beeswarm chart
#'
#' Draws a hand-drawn beeswarm (dot-strip) plot: at each categorical `x`, the
#' points are nudged sideways so they no longer overlap, so the width of the
#' swarm reads as the local density of `y`. The sideways offset is computed
#' deterministically in data space (bin `y`, then fan each bin symmetrically
#' around the category centre), so it is fully reproducible and device
#' independent. Dots are drawn with [geom_sketch_point()], so they keep the
#' usual hand-drawn wobble (cf. `ggbeeswarm::geom_beeswarm()`).
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`
#'   (usually discrete) and `y`.
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"sketch_beeswarm"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param binwidth Height of the `y` bins used to group points into rows.
#'   Default `NULL` chooses `nbins` even bins across the `y` range.
#' @param nbins Number of `y` bins when `binwidth` is `NULL`. Default 30.
#' @param width Sideways spacing between adjacent points in a row, in category
#'   units. Default `NULL` auto-sizes so the widest row stays within the
#'   category. Increase for a wider swarm.
#' @param roughness Point roughness. Default `NULL` (the geom default).
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend?
#' @param inherit.aes Override default aesthetics?
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(iris, aes(Species, Sepal.Length, colour = Species)) +
#'   geom_sketch_beeswarm(seed = 1L) +
#'   theme_sketch()
geom_sketch_beeswarm <- function(mapping     = NULL,
                                 data        = NULL,
                                 stat        = "sketch_beeswarm",
                                 position    = "identity",
                                 ...,
                                 binwidth    = NULL,
                                 nbins       = 30L,
                                 width       = NULL,
                                 roughness   = NULL,
                                 n_passes    = 2L,
                                 seed        = NULL,
                                 na.rm       = FALSE,
                                 show.legend = NA,
                                 inherit.aes = TRUE) {
  # `roughness` is a mappable aesthetic on GeomSketchPoint; only set it as a
  # constant when the user passes one (mirrors geom_sketch_point()).
  params <- list(
    binwidth = binwidth, nbins = as.integer(nbins), width = width,
    n_passes = as.integer(n_passes), seed = seed, na.rm = na.rm, ...
  )
  if (!is.null(roughness)) params$roughness <- roughness
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchPoint,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = params
  )
}
