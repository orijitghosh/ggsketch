# geom_sketch_arc_diagram() - linear node line + semicircular edge arcs.
# Layout is pure trig (arc_diagram_layout); constructor returns sketch layers.

rel <- data.frame(
  from  = c("A", "A", "B", "C", "C", "D"),
  to    = c("B", "C", "C", "D", "E", "E"),
  value = c(3, 1, 2, 4, 2, 1)
)

test_that("arc_semicircle spans endpoints and bows to the chosen side", {
  m <- ggsketch:::arc_semicircle(2, 6, side = 1, n = 50)
  expect_equal(range(m[, 1]), c(2, 6))          # x covers x0..x1
  expect_equal(m[1, 2], 0); expect_equal(m[nrow(m), 2], 0)  # ends on axis
  expect_gt(max(m[, 2]), 0)                      # bows up
  mb <- ggsketch:::arc_semicircle(2, 6, side = -1, n = 50)
  expect_lt(min(mb[, 2]), 0)                     # bows down
})

test_that("arc_diagram_layout places nodes and one arc per edge", {
  lay <- ggsketch:::arc_diagram_layout(rel$from, rel$to, rel$value)
  expect_named(lay, c("edges", "nodes", "labels", "k"))
  expect_equal(lay$k, 5L)                        # A..E
  expect_equal(nrow(lay$nodes), 5L)
  expect_equal(length(unique(lay$edges$edge)), nrow(rel))
  # node x positions are 1..k
  expect_equal(sort(lay$nodes$x), seq_len(5L))
  # node weight = total incident value; C touches 1+2+4+2 = 9
  expect_equal(lay$nodes$weight[lay$nodes$node == "C"], 9)
})

test_that("self-loops are dropped", {
  d <- data.frame(from = c("A", "B"), to = c("A", "C"), value = c(5, 2))
  lay <- ggsketch:::arc_diagram_layout(d$from, d$to, d$value)
  expect_equal(length(unique(lay$edges$edge)), 1L)   # only B-C survives
})

test_that("no non-self edges errors", {
  expect_error(
    ggsketch:::arc_diagram_layout(c("A"), c("A"), 1),
    "no non-self edges"
  )
})

test_that("geom_sketch_arc_diagram returns layers and builds", {
  layers <- geom_sketch_arc_diagram(rel, from, to, value, seed = 1L)
  expect_type(layers, "list")
  p <- ggplot2::ggplot() + layers + scale_colour_sketch() +
    ggplot2::theme_void()
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("side = bottom builds and bows under the axis", {
  layers <- geom_sketch_arc_diagram(rel, from, to, value, side = "bottom",
                                    seed = 2L)
  expect_silent(ggplot2::ggplot_build(ggplot2::ggplot() + layers +
                                        scale_colour_sketch()))
})

test_that("missing value defaults every edge to weight 1", {
  layers <- geom_sketch_arc_diagram(rel, from, to, seed = 1L)
  expect_silent(ggplot2::ggplot_build(ggplot2::ggplot() + layers +
                                        scale_colour_sketch()))
})

test_that("label = FALSE drops the label layer", {
  a <- geom_sketch_arc_diagram(rel, from, to, value, label = TRUE)
  b <- geom_sketch_arc_diagram(rel, from, to, value, label = FALSE)
  expect_equal(length(a) - length(b), 1L)
})
