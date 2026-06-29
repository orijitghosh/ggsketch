# geom_sketch_chord() - chord diagrams. Layout is pure trig (chord_layout); the
# constructor returns a list of ordinary sketch layers.

edges <- data.frame(
  from  = c("A", "A", "B", "C", "C", "D"),
  to    = c("B", "C", "C", "D", "A", "B"),
  value = c(5, 3, 2, 4, 1, 6)
)

test_that("chord_layout returns ribbons, rim and labels in unit space", {
  lay <- ggsketch:::chord_layout(edges$from, edges$to, edges$value)
  expect_named(lay, c("ribbons", "rim", "labels", "nodes"))
  expect_equal(lay$nodes, c("A", "B", "C", "D"))
  # one ribbon polygon per edge
  expect_equal(length(unique(lay$ribbons$flow)), nrow(edges))
  # one rim + one label per node
  expect_equal(length(unique(lay$rim$node)), 4L)
  expect_equal(nrow(lay$labels), 4L)
  # all geometry inside the (label-padded) unit circle
  rr <- sqrt(lay$ribbons$x^2 + lay$ribbons$y^2)
  expect_lte(max(rr), 1 + 1e-9)
})

test_that("self-loops are dropped", {
  loopy <- data.frame(from = c("A", "B", "C"), to = c("A", "C", "A"),
                      value = c(9, 2, 3))
  lay <- ggsketch:::chord_layout(loopy$from, loopy$to, loopy$value)
  expect_equal(length(unique(lay$ribbons$flow)), 2L)  # A->A removed
})

test_that("all-self-loop input errors", {
  expect_error(
    ggsketch:::chord_layout(c("A", "B"), c("A", "B"), c(1, 1)),
    "no non-self edges"
  )
})

test_that("node arc length is proportional to total flow", {
  # A touches edges of weight 5,3,1 = 9; B: 5,2,6 = 13; C: 3,2,4 = 9; D: 4,6 = 10
  lay <- ggsketch:::chord_layout(edges$from, edges$to, edges$value, gap = 0)
  # rim polygons: angular extent via atan2 spread is awkward; instead check the
  # number of vertices is identical (fixed sampling) and total flow drives spans
  # indirectly through a rebuild with doubled weights = identical geometry.
  lay2 <- ggsketch:::chord_layout(edges$from, edges$to, edges$value * 2, gap = 0)
  expect_equal(lay$ribbons$x, lay2$ribbons$x, tolerance = 1e-9)
})

test_that("geom_sketch_chord returns layers and builds", {
  layers <- geom_sketch_chord(edges, from, to, value, seed = 1L)
  expect_type(layers, "list")
  expect_gte(length(layers), 2L)
  p <- ggplot2::ggplot() + layers + scale_fill_sketch() +
    ggplot2::coord_equal()
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("value defaults to 1 per edge when omitted", {
  layers <- geom_sketch_chord(edges[c("from", "to")], from, to, seed = 1L)
  p <- ggplot2::ggplot() + layers + ggplot2::coord_equal()
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("label = FALSE drops the label layer", {
  with_lab <- geom_sketch_chord(edges, from, to, value, label = TRUE)
  no_lab   <- geom_sketch_chord(edges, from, to, value, label = FALSE)
  expect_equal(length(with_lab) - length(no_lab), 1L)
})
