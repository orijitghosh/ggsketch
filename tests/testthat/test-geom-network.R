# Tier B flagship: pure-R network layout + geom_sketch_edge/node + sketch_graph.

grob_classes <- function(g) {
  out <- class(g)
  if (!is.null(g$grobs))    out <- c(out, unlist(lapply(g$grobs, grob_classes)))
  if (!is.null(g$children)) out <- c(out, unlist(lapply(g$children, grob_classes)))
  out
}

ring_edges <- function(n = 5L) cbind(seq_len(n), c(seq_len(n)[-1L], 1L))

# ---- force_layout() ---------------------------------------------------------

test_that("force_layout returns one x/y row per node", {
  p <- force_layout(ring_edges(5L), seed = 1L)
  expect_s3_class(p, "data.frame")
  expect_named(p, c("x", "y"))
  expect_equal(nrow(p), 5L)
  expect_true(all(is.finite(p$x)) && all(is.finite(p$y)))
})

test_that("force_layout output is rescaled to [-1, 1]", {
  p <- force_layout(ring_edges(8L), seed = 1L)
  expect_gte(min(p$x), -1 - 1e-8)
  expect_lte(max(p$x),  1 + 1e-8)
  expect_gte(min(p$y), -1 - 1e-8)
  expect_lte(max(p$y),  1 + 1e-8)
})

test_that("force_layout is deterministic for a given seed", {
  a <- force_layout(ring_edges(6L), seed = 42L)
  b <- force_layout(ring_edges(6L), seed = 42L)
  expect_identical(a, b)
  c <- force_layout(ring_edges(6L), seed = 7L)
  expect_false(isTRUE(all.equal(a, c)))
})

test_that("force_layout does not disturb the global RNG", {
  set.seed(99); before <- runif(1)
  invisible(force_layout(ring_edges(5L), seed = 1L))
  set.seed(99); after <- runif(1)
  expect_identical(before, after)
})

test_that("force_layout handles edge cases", {
  expect_equal(nrow(force_layout(matrix(integer(0), 0, 2), n_nodes = 0L)), 0L)
  one <- force_layout(matrix(integer(0), 0, 2), n_nodes = 1L)
  expect_equal(one, data.frame(x = 0, y = 0))
  # edgeless but several nodes still get distinct positions
  edgeless <- force_layout(matrix(integer(0), 0, 2), n_nodes = 4L, seed = 1L)
  expect_equal(nrow(edgeless), 4L)
})

test_that("force_layout errors on a one-column edge matrix", {
  expect_error(force_layout(matrix(1:3, ncol = 1L)), "two columns")
})

# ---- sketch_graph() ---------------------------------------------------------

test_that("sketch_graph builds node and edge frames from a data frame", {
  e <- data.frame(from = c("A", "A", "B"), to = c("B", "C", "C"))
  g <- sketch_graph(e, seed = 1L)
  expect_named(g, c("nodes", "edges"))
  expect_named(g$nodes, c("name", "x", "y"))
  expect_true(all(c("from", "to", "x", "y", "xend", "yend") %in% names(g$edges)))
  expect_equal(nrow(g$nodes), 3L)               # A, B, C
  expect_equal(nrow(g$edges), 3L)
  # edge endpoints match the node positions
  ax <- g$nodes$x[match(g$edges$from, g$nodes$name)]
  expect_equal(g$edges$x, ax)
})

test_that("sketch_graph carries edge and node attributes through", {
  e <- data.frame(from = c("A", "B"), to = c("B", "C"), weight = c(2, 5))
  nodes <- data.frame(id = c("A", "B", "C"), grp = c("x", "x", "y"))
  g <- sketch_graph(e, nodes = nodes, seed = 1L)
  expect_true("weight" %in% names(g$edges))
  expect_equal(g$edges$weight, c(2, 5))
  expect_true("grp" %in% names(g$nodes))
  expect_equal(g$nodes$name, c("A", "B", "C"))
})

test_that("sketch_graph respects a supplied node ordering", {
  e <- data.frame(from = "A", to = "B")
  g <- sketch_graph(e, nodes = c("B", "A", "Z"), seed = 1L)
  expect_equal(g$nodes$name, c("B", "A", "Z"))    # Z is isolated but kept
  expect_equal(nrow(g$nodes), 3L)
})

test_that("sketch_graph ingests an igraph object when available", {
  skip_if_not_installed("igraph")
  e <- data.frame(from = c("A", "A", "B"), to = c("B", "C", "C"))
  ig <- igraph::graph_from_data_frame(e, directed = FALSE)
  g <- sketch_graph(ig, seed = 1L)
  expect_setequal(g$nodes$name, c("A", "B", "C"))
  expect_equal(nrow(g$edges), 3L)
})

# ---- geoms ------------------------------------------------------------------

test_that("geom_sketch_edge / geom_sketch_node are registered geoms", {
  expect_s3_class(GeomSketchEdge, "Geom")
  expect_s3_class(GeomSketchNode, "Geom")
  expect_true("label" %in% GeomSketchNode$optional_aes)
})

test_that("a sketch network builds and draws", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  e <- data.frame(from = c("A", "A", "B"), to = c("B", "C", "C"))
  g <- sketch_graph(e, seed = 1L)
  p <- ggplot2::ggplot() +
    geom_sketch_edge(data = g$edges,
                     ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
                     seed = 1L) +
    geom_sketch_node(data = g$nodes,
                     ggplot2::aes(x = x, y = y, label = name),
                     size = 6, seed = 2L)
  gt <- ggplot2::ggplotGrob(p)
  cc <- grob_classes(gt)
  expect_true("SketchPathGrob" %in% cc)
  expect_true("SketchPointGrob" %in% cc)
  expect_no_error(grid::grid.draw(gt))
})

test_that("curved edges build", {
  d <- data.frame(x = 0, y = 0, xend = 1, yend = 1)
  p <- ggplot2::ggplot(d) +
    geom_sketch_edge(ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
                     curvature = 0.4, seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("empty network data builds without error", {
  d <- data.frame(x = numeric(0), y = numeric(0),
                  xend = numeric(0), yend = numeric(0))
  p <- ggplot2::ggplot(d) +
    geom_sketch_edge(ggplot2::aes(x = x, y = y, xend = xend, yend = yend))
  expect_no_error(ggplot2::ggplot_build(p))
})
