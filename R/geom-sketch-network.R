# Layer 3 - network flagship: geom_sketch_edge() / geom_sketch_node() plus the
# sketch_graph() helper that turns an edge list (or an igraph) into ready-to-plot
# node and edge data frames using the pure-R force_layout(). No graph package is
# required; igraph is an optional, guarded convenience for ingestion only.

# ---- GeomSketchEdge ---------------------------------------------------------

#' @rdname geom_sketch_edge
#' @export
GeomSketchEdge <- ggplot2::ggproto(
  "GeomSketchEdge", ggplot2::Geom,

  required_aes = c("x", "y", "xend", "yend"),

  default_aes = ggplot2::aes(
    colour    = "grey50",
    linewidth = 0.4,
    linetype  = 1,
    alpha     = NA
  ),

  draw_key = draw_key_sketch_path,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "curvature", "na.rm")
  },

  draw_panel = function(data, panel_params, coord,
                         curvature = 0,
                         roughness = 1,
                         bowing    = 1,
                         n_passes  = 2L,
                         seed      = NULL,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    t  <- seq(0, 1, length.out = 40L)

    grobs <- lapply(seq_len(nrow(data)), function(i) {
      row <- data[i, , drop = FALSE]
      p   <- coord$transform(
        data.frame(x = c(row$x, row$xend), y = c(row$y, row$yend)),
        panel_params
      )
      x0 <- p$x[1L]; y0 <- p$y[1L]; x1 <- p$x[2L]; y1 <- p$y[2L]
      if (isTRUE(curvature == 0)) {
        bx <- c(x0, x1); by <- c(y0, y1)
      } else {
        # Quadratic Bezier with a perpendicular-offset control point, matching
        # geom_sketch_curve() so arc edges read the same.
        mx <- (x0 + x1) / 2; my <- (y0 + y1) / 2
        dx <- x1 - x0;       dy <- y1 - y0
        cx <- mx - dy * curvature * 0.5
        cy <- my + dx * curvature * 0.5
        bx <- (1 - t)^2 * x0 + 2 * (1 - t) * t * cx + t^2 * x1
        by <- (1 - t)^2 * y0 + 2 * (1 - t) * t * cy + t^2 * y1
      }
      sketch_path_grob(
        x = bx, y = by,
        roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, i * 53L),
        gp = outline_gpar(row$colour, row$linewidth, row$linetype, row$alpha)
      )
    })
    do.call(gList, grobs)
  }
)

# ---- geom_sketch_edge -------------------------------------------------------

#' Sketchy network edges and nodes
#'
#' A hand-drawn take on network/graph plotting. `geom_sketch_edge()` draws a
#' roughened connector between `(x, y)` and `(xend, yend)`; `geom_sketch_node()`
#' draws roughened node markers with optional handwriting `label`s. Pair them
#' with [sketch_graph()], which computes node positions with a pure-R
#' force-directed layout ([force_layout()]) and returns the two data frames
#' these geoms expect - no graph package required.
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()].
#' @param data Data to display. For `geom_sketch_edge()` the rows need
#'   `x`/`y`/`xend`/`yend`; for `geom_sketch_node()` they need `x`/`y` (and an
#'   optional `label`). Typically the `$edges` and `$nodes` from [sketch_graph()].
#' @param stat,position Statistical transformation and position adjustment.
#'   Default `"identity"` for both.
#' @param curvature Edge bend. `0` (default) draws straight roughened edges;
#'   non-zero gives arc edges (a quadratic Bezier), like
#'   [geom_sketch_curve()].
#' @param roughness,bowing,n_passes,seed Sketch parameters; see
#'   [geom_sketch_path()]. For `geom_sketch_node()`, `roughness` is a mappable
#'   aesthetic (per node).
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend,inherit.aes Standard layer arguments.
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @seealso [sketch_graph()], [force_layout()].
#' @export
#' @examples
#' library(ggplot2)
#' edges <- data.frame(
#'   from = c("A", "A", "B", "C", "C", "D"),
#'   to   = c("B", "C", "C", "D", "E", "E")
#' )
#' g <- sketch_graph(edges, seed = 1L)
#' ggplot() +
#'   geom_sketch_edge(data = g$edges,
#'                    aes(x = x, y = y, xend = xend, yend = yend), seed = 1L) +
#'   geom_sketch_node(data = g$nodes,
#'                    aes(x = x, y = y, label = name), size = 6, seed = 2L) +
#'   coord_equal() +
#'   theme_void()
geom_sketch_edge <- function(mapping     = NULL,
                             data        = NULL,
                             stat        = "identity",
                             position    = "identity",
                             ...,
                             curvature   = 0,
                             roughness   = 1,
                             bowing      = 1,
                             n_passes    = 2L,
                             seed        = NULL,
                             na.rm       = FALSE,
                             show.legend = NA,
                             inherit.aes = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchEdge,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      curvature = curvature,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}

# ---- GeomSketchNode ---------------------------------------------------------

#' @rdname geom_sketch_edge
#' @export
GeomSketchNode <- ggplot2::ggproto(
  "GeomSketchNode", ggplot2::Geom,

  required_aes = c("x", "y"),

  # `label` is optional: listing it suppresses the unknown-aesthetic warning.
  optional_aes = "label",

  # Same surface as GeomSketchPoint (roughness is a mappable aesthetic); kept
  # explicit rather than inherited to avoid a source-time load-order coupling.
  default_aes = ggplot2::aes(
    colour    = "black",
    size      = 1.5,
    fill      = NA,
    alpha     = NA,
    shape     = 19,
    stroke    = 0.5,
    roughness = 0.5
  ),

  draw_key = draw_key_sketch_point,

  parameters = function(self, extra = FALSE) {
    c("bowing", "n_passes", "seed", "label_size", "label_colour",
      "label_family", "na.rm")
  },

  draw_panel = function(data, panel_params, coord,
                         bowing = 1, n_passes = 2L, seed = NULL,
                         label_size = 3.2, label_colour = "grey15",
                         label_family = NULL, ...) {
    if (nrow(data) == 0L) return(nullGrob())
    coords <- coord$transform(data, panel_params)

    pts <- sketch_point_grob(
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

    if (is.null(coords$label)) return(pts)

    keep <- !is.na(coords$label)
    if (!any(keep)) return(pts)
    fam <- label_family %||% resolve_sketch_font()
    labels <- grid::textGrob(
      label = as.character(coords$label[keep]),
      x     = grid::unit(coords$x[keep], "npc"),
      y     = grid::unit(coords$y[keep], "npc") + grid::unit(0.5, "lines"),
      vjust = 0,
      gp    = grid::gpar(col = label_colour,
                         fontsize = label_size * ggplot2::.pt,
                         fontfamily = fam)
    )
    grid::gList(pts, labels)
  }
)

# ---- geom_sketch_node -------------------------------------------------------

#' @rdname geom_sketch_edge
#' @param label_size Handwriting label size (mm). Default 3.2.
#' @param label_colour Label colour. Default `"grey15"`.
#' @param label_family Label font family. Defaults to the first installed
#'   handwriting face (as [geom_sketch_text()] uses).
#' @export
geom_sketch_node <- function(mapping      = NULL,
                             data         = NULL,
                             stat         = "identity",
                             position     = "identity",
                             ...,
                             roughness    = NULL,
                             bowing       = NULL,
                             n_passes     = 2L,
                             seed         = NULL,
                             label_size   = 3.2,
                             label_colour = "grey15",
                             label_family = NULL,
                             na.rm        = FALSE,
                             show.legend  = NA,
                             inherit.aes  = TRUE) {
  params <- list(
    n_passes = as.integer(n_passes), seed = seed,
    label_size = label_size, label_colour = label_colour,
    na.rm = na.rm, ...
  )
  # roughness is a mappable aesthetic here (per node); only push a constant.
  if (!is.null(roughness))    params$roughness    <- roughness
  if (!is.null(bowing))       params$bowing       <- bowing
  if (!is.null(label_family)) params$label_family <- label_family
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchNode,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = params
  )
}

# ---- sketch_graph() ---------------------------------------------------------

# Normalise an edge input to a list(from, to, node_names, attrs). Accepts a
# data frame / matrix (first two columns are endpoints) or an igraph object.
as_sketch_edges <- function(edges) {
  if (inherits(edges, "igraph")) {
    if (!requireNamespace("igraph", quietly = TRUE)) {
      cli::cli_abort(c(
        "{.pkg igraph} is required to use an {.cls igraph} object here.",
        "i" = 'Install it with {.run install.packages("igraph")}, or pass a
               two-column data frame of edges instead.'
      ))
    }
    el <- igraph::as_edgelist(edges, names = TRUE)
    nm <- igraph::V(edges)$name
    if (is.null(nm)) nm <- as.character(seq_len(igraph::gorder(edges)))
    return(list(from = as.character(el[, 1L]), to = as.character(el[, 2L]),
                node_names = nm, attrs = NULL))
  }
  edges <- as.data.frame(edges, stringsAsFactors = FALSE)
  if (ncol(edges) < 2L) {
    cli::cli_abort("{.arg edges} needs at least two columns (from, to).")
  }
  attrs <- if (ncol(edges) > 2L) edges[, -(1:2), drop = FALSE] else NULL
  list(from = as.character(edges[[1L]]), to = as.character(edges[[2L]]),
       node_names = NULL, attrs = attrs)
}

#' Build node and edge data for a sketch network
#'
#' Turns an edge list into the two data frames that [geom_sketch_node()] and
#' [geom_sketch_edge()] consume, placing nodes with the pure-R force-directed
#' [force_layout()]. Accepts a plain two-column data frame (extra columns are
#' carried through as edge attributes) or - optionally - an \pkg{igraph} object.
#'
#' @param edges A data frame or matrix whose first two columns are the edge
#'   endpoints (any identifiers), or an `igraph` object. Extra data-frame
#'   columns are kept as edge attributes.
#' @param nodes Optional. A character vector of node identifiers, or a data
#'   frame whose first column is the identifier (further columns are kept as
#'   node attributes). Sets the node universe and ordering; defaults to the
#'   identifiers seen in `edges`.
#' @param niter,seed Passed to [force_layout()].
#' @return A list with two data frames: `nodes` (`name`, `x`, `y`, plus any
#'   node attributes) and `edges` (`from`, `to`, `x`, `y`, `xend`, `yend`, plus
#'   any edge attributes).
#' @family sketch-geoms
#' @seealso [geom_sketch_edge()], [force_layout()].
#' @export
#' @examples
#' edges <- data.frame(from = c("A", "A", "B"), to = c("B", "C", "C"))
#' g <- sketch_graph(edges, seed = 1L)
#' g$nodes
#' g$edges
sketch_graph <- function(edges, nodes = NULL, niter = 500L, seed = NULL) {
  e <- as_sketch_edges(edges)

  node_attrs <- NULL
  if (!is.null(nodes)) {
    if (is.data.frame(nodes)) {
      node_names <- as.character(nodes[[1L]])
      if (ncol(nodes) > 1L) node_attrs <- nodes[, -1L, drop = FALSE]
    } else {
      node_names <- as.character(nodes)
    }
  } else if (!is.null(e$node_names)) {
    node_names <- e$node_names
  } else {
    node_names <- unique(c(e$from, e$to))
  }

  fi <- match(e$from, node_names)
  ti <- match(e$to,   node_names)
  keep <- !is.na(fi) & !is.na(ti)

  el  <- cbind(fi[keep], ti[keep])
  pos <- force_layout(el, n_nodes = length(node_names),
                      niter = niter, seed = seed)

  nodes_df <- data.frame(name = node_names, x = pos$x, y = pos$y,
                         stringsAsFactors = FALSE)
  if (!is.null(node_attrs)) nodes_df <- cbind(nodes_df, node_attrs)

  edges_df <- data.frame(
    from = e$from[keep], to = e$to[keep],
    x    = pos$x[fi[keep]], y    = pos$y[fi[keep]],
    xend = pos$x[ti[keep]], yend = pos$y[ti[keep]],
    stringsAsFactors = FALSE
  )
  if (!is.null(e$attrs)) {
    edges_df <- cbind(edges_df, e$attrs[keep, , drop = FALSE])
  }

  list(nodes = nodes_df, edges = edges_df)
}
