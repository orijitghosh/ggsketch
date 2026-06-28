# Layer 1 - network layout (pure geometry, no grid/ggplot2, no graph deps).
# A from-scratch Fruchterman-Reingold force-directed layout so the network
# flagship needs no igraph/graphlayouts. Numbers in (edge index list) -> numbers
# out (node x/y positions), seeded and deterministic.

#' Force-directed graph layout (Fruchterman-Reingold)
#'
#' A pure-R implementation of the Fruchterman-Reingold force-directed layout,
#' so [geom_sketch_node()] / [geom_sketch_edge()] can place a network with no
#' external graph dependency. Repulsive forces push every node apart; attractive
#' forces pull edge-connected nodes together; a cooling schedule settles the
#' system. Coordinates are returned rescaled to roughly `[-1, 1]` on both axes.
#'
#' @param edges A two-column matrix or data frame of **1-based integer node
#'   indices**, one row per edge (`from`, `to`). May have zero rows (an
#'   edgeless graph, laid out on a circle).
#' @param n_nodes Number of nodes. Defaults to the largest index in `edges`
#'   (so isolated high-index nodes need this set explicitly).
#' @param niter Number of iterations. Default 500.
#' @param seed Integer seed for the initial placement. `NULL` uses
#'   `getOption("ggsketch.seed", 1L)`. The layout is otherwise deterministic.
#' @return A data frame with columns `x` and `y`, one row per node in index
#'   order.
#' @export
#' @examples
#' # A small ring of five nodes
#' e <- cbind(1:5, c(2:5, 1))
#' force_layout(e, seed = 1L)
force_layout <- function(edges, n_nodes = NULL, niter = 500L, seed = NULL) {
  seed  <- resolve_seed(seed)
  edges <- as.matrix(edges)
  if (nrow(edges) > 0L) {
    if (ncol(edges) < 2L) {
      cli::cli_abort("{.arg edges} must have two columns (from, to).")
    }
    storage.mode(edges) <- "integer"
    edges <- edges[, 1:2, drop = FALSE]
  }

  n_nodes <- n_nodes %||% (if (nrow(edges) > 0L) max(edges) else 0L)
  n <- as.integer(n_nodes)
  if (is.na(n) || n <= 0L) return(data.frame(x = numeric(0), y = numeric(0)))
  if (n == 1L)            return(data.frame(x = 0, y = 0))

  # Seeded initial placement: spread on a circle plus a little jitter so the
  # forces have something asymmetric to work with (a perfect circle is a fixed
  # point of the symmetric forces).
  pos <- within_seed(seed, {
    ang <- seq(0, 2 * pi, length.out = n + 1L)[-(n + 1L)]
    cbind(cos(ang) + stats::runif(n, -0.1, 0.1),
          sin(ang) + stats::runif(n, -0.1, 0.1))
  })

  # FR constants on a unit square: optimal distance k, linear cooling.
  area <- 1
  k    <- sqrt(area / n)
  temp <- 0.1
  cool <- temp / (niter + 1L)
  eps  <- 1e-4

  for (iter in seq_len(niter)) {
    disp <- matrix(0, n, 2L)

    # Repulsive forces between every pair (vectorised over j for each node v).
    for (v in seq_len(n)) {
      dx <- pos[v, 1L] - pos[, 1L]
      dy <- pos[v, 2L] - pos[, 2L]
      dist <- sqrt(dx * dx + dy * dy)
      dist[v] <- Inf                       # no self-force
      dist[dist < eps] <- eps
      f <- k * k / dist
      disp[v, 1L] <- sum(dx / dist * f)
      disp[v, 2L] <- sum(dy / dist * f)
    }

    # Attractive forces along edges.
    if (nrow(edges) > 0L) {
      for (e in seq_len(nrow(edges))) {
        a <- edges[e, 1L]; b <- edges[e, 2L]
        if (is.na(a) || is.na(b) || a == b) next
        dx <- pos[a, 1L] - pos[b, 1L]
        dy <- pos[a, 2L] - pos[b, 2L]
        dist <- sqrt(dx * dx + dy * dy)
        if (dist < eps) dist <- eps
        f <- dist * dist / k
        fx <- dx / dist * f
        fy <- dy / dist * f
        disp[a, 1L] <- disp[a, 1L] - fx
        disp[a, 2L] <- disp[a, 2L] - fy
        disp[b, 1L] <- disp[b, 1L] + fx
        disp[b, 2L] <- disp[b, 2L] + fy
      }
    }

    # Limit displacement to the current temperature, then cool.
    dlen <- sqrt(disp[, 1L]^2 + disp[, 2L]^2)
    dlen[dlen < eps] <- eps
    scale <- pmin(dlen, temp) / dlen
    pos[, 1L] <- pos[, 1L] + disp[, 1L] * scale
    pos[, 2L] <- pos[, 2L] + disp[, 2L] * scale
    temp <- temp - cool
  }

  data.frame(x = rescale_sym(pos[, 1L]), y = rescale_sym(pos[, 2L]))
}

# Rescale a vector to [-1, 1]; a degenerate (constant) vector maps to 0.
rescale_sym <- function(v) {
  rng <- range(v)
  if (diff(rng) < 1e-9) return(rep(0, length(v)))
  2 * (v - rng[1L]) / (rng[2L] - rng[1L]) - 1
}
