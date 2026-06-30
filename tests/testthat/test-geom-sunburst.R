# geom_sketch_sunburst() - nested-ring hierarchy charts. Layout is pure trig
# (sunburst_layout); the constructor returns a list of sketch layers.

df <- data.frame(
  region = c("West", "West", "West", "East", "East", "East"),
  dept   = c("Sales", "Sales", "Eng", "Sales", "Eng", "Eng"),
  team   = c("A", "B", "C", "D", "E", "F"),
  n      = c(4, 2, 6, 3, 5, 1)
)
lvls <- c("region", "dept", "team")

test_that("sunburst_layout returns one node per (depth, prefix)", {
  nodes <- ggsketch:::sunburst_layout(df, levels = lvls, value = "n")
  expect_type(nodes, "list")
  # depth 1: 2 regions; depth 2: 4 region/dept prefixes; depth 3: 6 teams
  depths <- vapply(nodes, function(x) x$depth, integer(1))
  expect_equal(as.integer(table(depths)), c(2L, 4L, 6L))
})

test_that("root ring spans the full circle", {
  nodes <- ggsketch:::sunburst_layout(df, levels = lvls, value = "n")
  roots <- Filter(function(x) x$depth == 1L, nodes)
  span  <- sum(vapply(roots, function(x) x$a1 - x$a0, numeric(1)))
  expect_equal(span, 2 * pi)
})

test_that("children nest inside their parent's angular span", {
  nodes <- ggsketch:::sunburst_layout(df, levels = lvls, value = "n")
  west  <- Filter(function(x) x$depth == 1L && x$label == "West", nodes)[[1]]
  kids  <- Filter(function(x) x$depth == 2L && x$root == "West", nodes)
  for (k in kids) {
    expect_gte(k$a0, west$a0 - 1e-9)
    expect_lte(k$a1, west$a1 + 1e-9)
  }
})

test_that("rings are radially stacked from r0", {
  nodes <- ggsketch:::sunburst_layout(df, levels = lvls, value = "n", r0 = 0.2)
  d1 <- Filter(function(x) x$depth == 1L, nodes)[[1]]
  expect_equal(d1$r_in, 0.2)
})

test_that("NULL value weights every row as 1", {
  nodes <- ggsketch:::sunburst_layout(df, levels = lvls, value = NULL)
  expect_equal(sum(vapply(Filter(function(x) x$depth == 3L, nodes),
                          function(x) x$a1 - x$a0, numeric(1))), 2 * pi)
})

test_that("missing columns error", {
  expect_error(ggsketch:::sunburst_layout(df, levels = c("region", "nope")),
               "not found")
})

test_that("no complete rows errors", {
  bad <- data.frame(a = NA_character_, b = NA_character_)
  expect_error(ggsketch:::sunburst_layout(bad, levels = c("a", "b")),
               "no complete rows")
})

test_that("geom_sketch_sunburst returns layers and builds", {
  layers <- geom_sketch_sunburst(df, levels = lvls, value = "n", seed = 1L)
  expect_type(layers, "list")
  p <- ggplot2::ggplot() + layers + scale_fill_sketch() +
    ggplot2::coord_equal()
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("fill_by options all build", {
  for (fb in c("root", "self", "depth")) {
    layers <- geom_sketch_sunburst(df, levels = lvls, value = "n",
                                   fill_by = fb, seed = 1L)
    expect_silent(ggplot2::ggplot_build(
      ggplot2::ggplot() + layers + ggplot2::coord_equal()))
  }
})

test_that("label = TRUE adds a label layer", {
  a <- geom_sketch_sunburst(df, levels = lvls, value = "n", label = TRUE)
  b <- geom_sketch_sunburst(df, levels = lvls, value = "n", label = FALSE)
  expect_equal(length(a) - length(b), 1L)
})

test_that("an unknown value column errors", {
  expect_error(geom_sketch_sunburst(df, levels = lvls, value = "nope"),
               "not found")
})

test_that("a single level builds (one ring)", {
  layers <- geom_sketch_sunburst(df, levels = "region", value = "n", seed = 1L)
  expect_silent(ggplot2::ggplot_build(
    ggplot2::ggplot() + layers + ggplot2::coord_equal()))
})
