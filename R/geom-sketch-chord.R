# Layer 3 - geom_sketch_chord() (v2.0 breadth)
# A chord diagram: nodes sit on a circle, each given an arc proportional to its
# total flow, and every weighted relation is drawn as a ribbon whose two ends
# are sub-arcs (one per endpoint) joined by quadratic beziers through the centre.
# Like geom_sketch_sf(), this is a constructor that computes the geometry up
# front in a unit-circle space and returns ordinary sketch layers (ribbons and
# rim segments as roughened polygons, plus handwriting labels), so it composes
# with `+` and needs `coord_equal()` + `theme_void()`. No new dependencies
# (cf. circlize::chordDiagram()).

# ---- layout (pure trig, no grid/ggplot2) ------------------------------------

# Sample `n` points along a circular arc of radius `r`, from angle `a0` to `a1`
# (radians, 0 = north, clockwise). Returns a two-column matrix.
chord_arc <- function(a0, a1, r, n = 24L) {
  t <- seq(a0, a1, length.out = max(n, 2L))
  cbind(r * sin(t), r * cos(t))
}

# Sample a quadratic bezier from p0 to p1 with control point c (here the origin),
# giving the pinched-through-the-middle chord shape.
chord_bezier <- function(p0, p1, ctrl = c(0, 0), n = 24L) {
  t <- seq(0, 1, length.out = max(n, 2L))
  x <- (1 - t)^2 * p0[1] + 2 * (1 - t) * t * ctrl[1] + t^2 * p1[1]
  y <- (1 - t)^2 * p0[2] + 2 * (1 - t) * t * ctrl[2] + t^2 * p1[2]
  cbind(x, y)
}

# Compute the full chord layout from a (from, to, value) edge table.
# Returns ribbons (one polygon per flow), rim segments (one per node), and label
# anchors, all in unit-circle coordinates.
chord_layout <- function(from, to, value, nodes = NULL,
                          gap = 0.04, r_attach = 0.92,
                          rim_outer = 1.0, rim_inner = 0.9) {
  keep <- from != to                       # self-loops are not drawn
  if (!all(keep)) {
    from <- from[keep]; to <- to[keep]; value <- value[keep]
  }
  if (length(from) == 0L) {
    cli::cli_abort("{.fn geom_sketch_chord}: no non-self edges to draw.")
  }

  if (is.null(nodes)) {
    nodes <- sort(unique(c(as.character(from), as.character(to))))
  }
  n <- length(nodes)
  fi <- match(as.character(from), nodes)
  ti <- match(as.character(to),   nodes)

  total <- numeric(n)
  for (k in seq_along(value)) {
    total[fi[k]] <- total[fi[k]] + value[k]
    total[ti[k]] <- total[ti[k]] + value[k]
  }
  total[total == 0] <- .Machine$double.eps

  # Node spans: split the circle (minus the inter-node gaps) by total flow.
  avail     <- 2 * pi - n * gap
  node_span <- avail * total / sum(total)
  node_start <- numeric(n); acc <- 0
  for (i in seq_len(n)) {
    node_start[i] <- acc + gap / 2
    acc <- node_start[i] + node_span[i] + gap / 2
  }

  # Allocate sub-arcs within each node. Each edge consumes one sub-arc on its
  # `from` node and one on its `to` node; a running cursor per node lays them out.
  cursor <- node_start
  ends <- vector("list", length(value))     # each: list(node=, a0=, a1=)
  # Process endpoints node by node for a tidy, deterministic arrangement.
  end_from <- vector("list", length(value))
  end_to   <- vector("list", length(value))
  for (i in seq_len(n)) {
    # edges with an endpoint on node i, in input order
    on_from <- which(fi == i)
    on_to   <- which(ti == i)
    order_k <- c(on_from, on_to)
    for (k in order_k) {
      w  <- node_span[i] * value[k] / total[i]
      a0 <- cursor[i]; a1 <- cursor[i] + w
      cursor[i] <- a1
      if (k %in% on_from && is.null(end_from[[k]])) {
        end_from[[k]] <- c(a0, a1)
      } else {
        end_to[[k]] <- c(a0, a1)
      }
    }
  }

  # Ribbon polygons.
  ribbons <- vector("list", length(value))
  for (k in seq_along(value)) {
    ef <- end_from[[k]]; et <- end_to[[k]]
    arc_f <- chord_arc(ef[1], ef[2], r_attach)
    arc_t <- chord_arc(et[1], et[2], r_attach)
    b1 <- chord_bezier(arc_f[nrow(arc_f), ], arc_t[1, ])
    b2 <- chord_bezier(arc_t[nrow(arc_t), ], arc_f[1, ])
    poly <- rbind(arc_f, b1, arc_t, b2)
    ribbons[[k]] <- data.frame(
      x = poly[, 1], y = poly[, 2],
      flow = k, source = nodes[fi[k]], target = nodes[ti[k]],
      value = value[k]
    )
  }
  ribbons <- do.call(rbind, ribbons)

  # Rim segments (annular sectors) + label anchors.
  rim <- vector("list", n); lab <- vector("list", n)
  for (i in seq_len(n)) {
    a0 <- node_start[i]; a1 <- node_start[i] + node_span[i]
    outer <- chord_arc(a0, a1, rim_outer)
    inner <- chord_arc(a1, a0, rim_inner)        # reversed -> closed ring band
    ring  <- rbind(outer, inner)
    rim[[i]] <- data.frame(x = ring[, 1], y = ring[, 2], node = nodes[i])
    amid <- (a0 + a1) / 2
    lab[[i]] <- data.frame(
      x = (rim_outer + 0.06) * sin(amid),
      y = (rim_outer + 0.06) * cos(amid),
      node = nodes[i], angle = amid
    )
  }

  list(ribbons = ribbons,
       rim     = do.call(rbind, rim),
       labels  = do.call(rbind, lab),
       nodes   = nodes)
}

# ---- geom_sketch_chord ------------------------------------------------------

#' Sketchy chord diagram
#'
#' Draws a hand-drawn chord diagram: nodes are placed on a circle, each given an
#' arc proportional to its total flow, and every weighted relation becomes a
#' ribbon whose ends are sub-arcs on the two nodes, joined by curves through the
#' centre. Like [geom_sketch_sf()], this is a constructor that returns a list of
#' ordinary sketch layers (roughened ribbons, rim segments and handwriting
#' labels), so it composes with `+`; pair it with `coord_equal()` and
#' `theme_void()`. No new dependencies (cf. `circlize::chordDiagram()`).
#'
#' Supply an edge table as `data` and name the `from`, `to` and `value` columns
#' (unquoted). Ribbons are coloured by their source node; add
#' [scale_fill_sketch()] (or any fill scale) to control the palette.
#'
#' @param data A data frame of weighted edges (one row per relation).
#' @param from,to Unquoted column names giving the two endpoints of each edge.
#' @param value Unquoted column name giving the edge weight. Default: every edge
#'   counts as 1.
#' @param gap Angular gap between adjacent nodes, in radians. Default 0.04.
#' @param rim_width Width of the node rim, as a fraction of the radius.
#'   Default 0.1.
#' @param fill_style Ribbon fill style; see [geom_sketch_polygon()]. Default
#'   `"solid"`.
#' @param alpha Ribbon fill opacity. Default 0.65.
#' @param label Draw node labels? Default `TRUE`.
#' @param label_size,label_colour Label text controls.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param ... Other arguments passed on to the ribbon layer.
#' @return A list of `ggplot2` layers.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' trade <- data.frame(
#'   from  = c("A", "A", "B", "C", "C", "D"),
#'   to    = c("B", "C", "C", "D", "A", "B"),
#'   value = c(5, 3, 2, 4, 1, 6)
#' )
#' ggplot() +
#'   geom_sketch_chord(trade, from, to, value, seed = 1L) +
#'   scale_fill_sketch() +
#'   coord_equal() +
#'   theme_void()
geom_sketch_chord <- function(data,
                              from, to, value,
                              ...,
                              gap          = 0.04,
                              rim_width    = 0.1,
                              fill_style   = "solid",
                              alpha        = 0.65,
                              label        = TRUE,
                              label_size   = 4,
                              label_colour = "grey20",
                              roughness    = 1,
                              bowing       = 1,
                              n_passes     = 2L,
                              seed         = NULL) {
  if (missing(data) || !is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame of edges.")
  }
  from_col <- rlang::as_name(rlang::ensym(from))
  to_col   <- rlang::as_name(rlang::ensym(to))
  from <- as.character(data[[from_col]])
  to   <- as.character(data[[to_col]])
  if (missing(value)) {
    value <- rep(1, nrow(data))
  } else {
    value <- as.numeric(data[[rlang::as_name(rlang::ensym(value))]])
  }

  lay <- chord_layout(from, to, value, gap = gap,
                      rim_outer = 1.0, rim_inner = 1.0 - rim_width)

  layers <- list(
    # ribbons, coloured by source node
    geom_sketch_polygon(
      data = lay$ribbons,
      mapping = ggplot2::aes(x = .data$x, y = .data$y,
                             group = .data$flow, fill = .data$source),
      fill_style = fill_style, alpha = alpha,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, inherit.aes = FALSE, ...
    ),
    # node rim segments, same fill scale
    geom_sketch_polygon(
      data = lay$rim,
      mapping = ggplot2::aes(x = .data$x, y = .data$y,
                             group = .data$node, fill = .data$node),
      fill_style = "solid", colour = NA, show.legend = FALSE,
      roughness = roughness * 0.6, bowing = bowing,
      n_passes = as.integer(n_passes), seed = seed, inherit.aes = FALSE
    )
  )

  if (isTRUE(label)) {
    layers <- c(layers, list(geom_sketch_text(
      data = lay$labels,
      mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$node),
      size = label_size, colour = label_colour,
      family = resolve_label_family(), inherit.aes = FALSE
    )))
  }

  layers
}
