# Layer 3 - geom_sketch_arc_diagram() (v2.0 breadth)
# An arc diagram: nodes laid on a 1-D line, every edge a semicircle arching over
# (or under) the axis between its two endpoints. Like geom_sketch_chord() but
# linear instead of circular. A constructor that computes geometry up front and
# returns ordinary sketch layers (roughened arcs, node points, labels), so it
# composes with `+`; pair with theme_void() / theme_sketch(). No new deps
# (cf. arcdiagram, ggraph's "arc" layout).

# ---- layout (pure trig) -----------------------------------------------------

# Sample an upper semicircle spanning x0..x1 on the axis, `n` points. `side`
# multiplies y (+1 over the axis, -1 under). Returns a two-column matrix.
arc_semicircle <- function(x0, x1, side = 1, n = 48L) {
  cx <- (x0 + x1) / 2
  r  <- abs(x1 - x0) / 2
  th <- seq(0, pi, length.out = max(n, 3L))
  cbind(cx + r * cos(th), side * r * sin(th))
}

# Build the arc-diagram layout from a (from, to, value) edge table. Nodes are
# placed at integer positions 1..k in `nodes` order. Self-loops are dropped.
arc_diagram_layout <- function(from, to, value, nodes = NULL,
                               side = 1, n = 48L) {
  keep <- from != to
  if (!all(keep)) { from <- from[keep]; to <- to[keep]; value <- value[keep] }
  if (length(from) == 0L) {
    cli::cli_abort("{.fn geom_sketch_arc_diagram}: no non-self edges to draw.")
  }
  if (is.null(nodes)) {
    nodes <- sort(unique(c(as.character(from), as.character(to))))
  }
  pos <- stats::setNames(seq_along(nodes), nodes)
  fi  <- pos[as.character(from)]
  ti  <- pos[as.character(to)]

  edges <- vector("list", length(value))
  for (k in seq_along(value)) {
    arc <- arc_semicircle(fi[k], ti[k], side = side, n = n)
    edges[[k]] <- data.frame(
      x = arc[, 1], y = arc[, 2], edge = k, value = value[k],
      source = nodes[fi[k]], target = nodes[ti[k]]
    )
  }
  edges <- do.call(rbind, edges)

  # node weight = total incident value (drives point size)
  total <- numeric(length(nodes))
  for (k in seq_along(value)) {
    total[fi[k]] <- total[fi[k]] + value[k]
    total[ti[k]] <- total[ti[k]] + value[k]
  }
  span    <- (length(nodes) - 1L) / 2          # max arc radius
  lab_off <- side * -0.06 * max(span, 1)
  list(
    edges  = edges,
    nodes  = data.frame(x = seq_along(nodes), y = 0, node = nodes,
                        weight = total),
    labels = data.frame(x = seq_along(nodes), y = lab_off, node = nodes),
    k      = length(nodes)
  )
}

# ---- geom_sketch_arc_diagram ------------------------------------------------

#' Sketchy arc diagram
#'
#' Draws a hand-drawn arc diagram: nodes are placed along a horizontal line and
#' every weighted relation is a roughened semicircle arching over (or under) the
#' axis between its two endpoints. Like [geom_sketch_chord()] but linear, it is a
#' constructor that returns a list of ordinary sketch layers (arcs, node points
#' and handwriting labels), so it composes with `+`; pair it with `theme_void()`
#' or `theme_sketch()`. Edges are coloured by their source node; add
#' [scale_colour_sketch()] (or any colour scale). No new dependencies.
#'
#' @param data A data frame of weighted edges (one row per relation).
#' @param from,to Unquoted column names giving the two endpoints of each edge.
#' @param value Unquoted column name giving the edge weight. Default: every edge
#'   counts as 1 (and node size is the edge count).
#' @param nodes Optional character vector fixing the node order along the axis
#'   (default: sorted unique endpoints).
#' @param side Which way the arcs bow: `"top"` (default) or `"bottom"`.
#' @param node_size,node_colour Node-point size (scaled by incident weight) and
#'   colour.
#' @param max_linewidth Arc stroke width at the heaviest edge (lighter edges
#'   scale down). Default 2.
#' @param alpha Arc opacity. Default 0.7.
#' @param label Draw node labels? Default `TRUE`.
#' @param label_size,label_colour Label text controls.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param ... Other arguments passed on to the arc layer.
#' @return A list of `ggplot2` layers.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' rel <- data.frame(
#'   from  = c("A", "A", "B", "C", "C", "D"),
#'   to    = c("B", "C", "C", "D", "E", "E"),
#'   value = c(3, 1, 2, 4, 2, 1)
#' )
#' ggplot() +
#'   geom_sketch_arc_diagram(rel, from, to, value, seed = 1L) +
#'   scale_colour_sketch() +
#'   theme_void()
geom_sketch_arc_diagram <- function(data,
                                    from, to, value,
                                    ...,
                                    nodes         = NULL,
                                    side          = c("top", "bottom"),
                                    node_size     = 3,
                                    node_colour   = "grey25",
                                    max_linewidth = 2,
                                    alpha         = 0.7,
                                    label         = TRUE,
                                    label_size    = 3.5,
                                    label_colour  = "grey20",
                                    roughness     = 1,
                                    bowing        = 1,
                                    n_passes      = 2L,
                                    seed          = NULL) {
  if (missing(data) || !is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame of edges.")
  }
  side <- match.arg(side)
  from_v <- as.character(data[[rlang::as_name(rlang::ensym(from))]])
  to_v   <- as.character(data[[rlang::as_name(rlang::ensym(to))]])
  if (missing(value)) {
    value_v <- rep(1, nrow(data))
  } else {
    value_v <- as.numeric(data[[rlang::as_name(rlang::ensym(value))]])
  }

  lay <- arc_diagram_layout(from_v, to_v, value_v, nodes = nodes,
                            side = if (side == "top") 1 else -1)

  # per-edge stroke width scaled by value
  vmax <- max(lay$edges$value)
  lay$edges$lwd <- max_linewidth *
    (0.35 + 0.65 * lay$edges$value / if (vmax > 0) vmax else 1)

  layers <- list(
    geom_sketch_path(
      data = lay$edges,
      mapping = ggplot2::aes(x = .data$x, y = .data$y, group = .data$edge,
                             colour = .data$source, linewidth = .data$lwd),
      alpha = alpha, roughness = roughness, bowing = bowing,
      n_passes = as.integer(n_passes), seed = seed, inherit.aes = FALSE, ...
    ),
    ggplot2::scale_linewidth_identity(),
    geom_sketch_point(
      data = lay$nodes,
      mapping = ggplot2::aes(x = .data$x, y = .data$y),
      size = node_size, colour = node_colour, seed = seed,
      inherit.aes = FALSE
    )
  )

  if (isTRUE(label)) {
    layers <- c(layers, list(geom_sketch_text(
      data = lay$labels,
      mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$node),
      size = label_size, colour = label_colour,
      vjust = if (side == "top") 1 else 0,
      family = resolve_label_family(), inherit.aes = FALSE
    )))
  }

  layers
}
