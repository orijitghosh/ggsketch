# Layer 3 - geom_sketch_dendrogram() (v2.0 breadth)
# A hierarchical-clustering tree: leaves on one axis, merges at their cluster
# height, joined by elbow connectors. A constructor that builds the layout from
# an hclust object (or computes one from a numeric data frame via
# stats::hclust(dist(...))) and returns ordinary sketch layers (roughened elbow
# paths + leaf labels). The right-angle elbows pick up the hand-drawn wobble.
# Pure base stats; no new dependencies (cf. ggdendro).

# ---- layout (pure arithmetic) -----------------------------------------------

# Map raw (x = leaf position, y = height) coordinates into one of four
# orientations. Extra columns are preserved.
dendro_orient <- function(df, orientation) {
  x <- df$x; y <- df$y
  out <- switch(orientation,
    up    = data.frame(x = x,  y = y),
    down  = data.frame(x = x,  y = -y),
    right = data.frame(x = y,  y = x),
    left  = data.frame(x = -y, y = x)
  )
  extra <- setdiff(names(df), c("x", "y"))
  if (length(extra)) out[extra] <- df[extra]
  out
}

# Build the dendrogram layout from an hclust object. Returns elbow segments (one
# group per merge), leaf anchors with labels, and the orientation.
dendro_layout <- function(hc, orientation = c("up", "down", "left", "right")) {
  orientation <- match.arg(orientation)
  if (!inherits(hc, "hclust")) {
    cli::cli_abort("{.arg hc} must be an {.cls hclust} object.")
  }
  merge  <- hc$merge
  height <- hc$height
  ord    <- hc$order
  n      <- length(ord)
  labs   <- hc$labels %||% as.character(seq_len(n))

  leaf_x <- integer(n)
  leaf_x[ord] <- seq_len(n)              # leaf i sits at its rank in the order
  node_x <- numeric(nrow(merge))

  coord <- function(child) {
    if (child < 0) list(x = leaf_x[-child], y = 0)
    else           list(x = node_x[child], y = height[child])
  }

  segs <- vector("list", nrow(merge))
  for (m in seq_len(nrow(merge))) {
    a <- coord(merge[m, 1L]); b <- coord(merge[m, 2L])
    h <- height[m]
    node_x[m] <- (a$x + b$x) / 2
    segs[[m]] <- data.frame(
      x   = c(a$x, a$x, b$x, b$x),
      y   = c(a$y, h,   h,   b$y),
      seg = m
    )
  }
  segments <- do.call(rbind, segs)
  leaves   <- data.frame(x = seq_len(n), y = 0, label = labs[ord],
                         stringsAsFactors = FALSE)

  list(
    segments    = dendro_orient(segments, orientation),
    leaves      = dendro_orient(leaves, orientation),
    orientation = orientation,
    hmax        = max(height)
  )
}

# ---- geom_sketch_dendrogram -------------------------------------------------

#' Sketchy dendrogram (hierarchical-clustering tree)
#'
#' Draws a hand-drawn dendrogram: leaves along one axis and each merge bracketed
#' at its cluster height, with the right-angle elbows roughened into a hand-drawn
#' wobble. Pass either a ready [stats::hclust()] object or a numeric data frame /
#' matrix (a tree is then computed via `stats::hclust(stats::dist(x))`). Like
#' [geom_sketch_chord()] it is a constructor returning a list of ordinary sketch
#' layers (elbow paths + leaf labels), so it composes with `+`; pair it with
#' `theme_void()` or `theme_sketch()`. Pure base stats; no new dependencies
#' (cf. `ggdendro`).
#'
#' @param data An [stats::hclust()] object, or a numeric data frame / matrix to
#'   cluster (non-numeric columns are dropped; row names become leaf labels).
#' @param orientation Tree direction: `"up"` (default, root at top), `"down"`,
#'   `"left"`, or `"right"`.
#' @param method,distance Linkage method and distance metric, used only when
#'   `data` is not already an `hclust` (passed to [stats::hclust()] and
#'   [stats::dist()]). Defaults `"complete"` / `"euclidean"`.
#' @param line_colour,line_width Connector colour and width.
#' @param label Draw leaf labels? Default `TRUE`.
#' @param label_size,label_colour Label text controls.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param ... Other arguments passed on to the connector layer.
#' @return A list of `ggplot2` layers.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot() +
#'   geom_sketch_dendrogram(mtcars[1:8, c("mpg", "wt", "hp")], seed = 1L) +
#'   theme_void()
geom_sketch_dendrogram <- function(data,
                                   ...,
                                   orientation  = c("up", "down", "left", "right"),
                                   method       = "complete",
                                   distance     = "euclidean",
                                   line_colour  = "grey25",
                                   line_width   = 0.8,
                                   label        = TRUE,
                                   label_size   = 3,
                                   label_colour = "grey20",
                                   roughness    = 1,
                                   bowing       = 1,
                                   n_passes     = 2L,
                                   seed         = NULL) {
  orientation <- match.arg(orientation)
  if (inherits(data, "hclust")) {
    hc <- data
  } else if (is.data.frame(data) || is.matrix(data)) {
    m <- as.data.frame(data)
    num <- vapply(m, is.numeric, logical(1))
    if (!any(num)) cli::cli_abort("{.arg data} has no numeric columns to cluster.")
    M <- as.matrix(m[, num, drop = FALSE])
    if (nrow(M) < 2L) cli::cli_abort("Need at least 2 rows to cluster.")
    hc <- stats::hclust(stats::dist(M, method = distance), method = method)
  } else {
    cli::cli_abort("{.arg data} must be an {.cls hclust} object or a numeric data frame.")
  }

  lay <- dendro_layout(hc, orientation = orientation)

  off <- 0.03 * lay$hmax
  # Rotated labels anchor at the string end nearest the leaf (hjust 1/0), so
  # the text always hangs away from the tree instead of straddling the leaf.
  lab_nudge <- switch(orientation,
    up    = list(x = 0,    y = -off, hjust = 1,   vjust = 0.5, angle = 90),
    down  = list(x = 0,    y =  off, hjust = 0,   vjust = 0.5, angle = 90),
    right = list(x = -off, y = 0,    hjust = 1,   vjust = 0.5, angle = 0),
    left  = list(x =  off, y = 0,    hjust = 0,   vjust = 0.5, angle = 0)
  )

  layers <- list(
    geom_sketch_path(
      data = lay$segments,
      mapping = ggplot2::aes(x = .data$x, y = .data$y, group = .data$seg),
      colour = line_colour, linewidth = line_width,
      roughness = roughness, bowing = bowing,
      n_passes = as.integer(n_passes), seed = seed, inherit.aes = FALSE, ...
    )
  )

  if (isTRUE(label)) {
    labs <- lay$leaves
    labs$x <- labs$x + lab_nudge$x
    labs$y <- labs$y + lab_nudge$y
    # Reserve room for the hanging labels (scaled to the longest one) so they
    # are not clipped at the panel edge under theme_void().
    pad <- min(0.05 + 0.02 * max(nchar(labs$label)), 0.5) * lay$hmax
    pad_lim <- switch(orientation,
      up    = ggplot2::expand_limits(y = min(labs$y) - pad),
      down  = ggplot2::expand_limits(y = max(labs$y) + pad),
      right = ggplot2::expand_limits(x = min(labs$x) - pad),
      left  = ggplot2::expand_limits(x = max(labs$x) + pad)
    )
    layers <- c(layers, list(
      geom_sketch_text(
        data = labs,
        mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$label),
        size = label_size, colour = label_colour,
        hjust = lab_nudge$hjust, vjust = lab_nudge$vjust, angle = lab_nudge$angle,
        family = resolve_label_family(), inherit.aes = FALSE
      ),
      pad_lim
    ))
  }

  layers
}
