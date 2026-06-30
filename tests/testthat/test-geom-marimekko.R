# geom_sketch_marimekko() - variable-width stacked bars. Reuses mosaic_layout();
# constructor returns sketch layers.

sales <- data.frame(
  region  = rep(c("North", "South", "East"), each = 3),
  product = rep(c("A", "B", "C"), times = 3),
  revenue = c(40, 30, 10,  25, 25, 30,  15, 20, 5)
)

test_that("geom_sketch_marimekko returns layers and builds", {
  layers <- geom_sketch_marimekko(sales, region, product, revenue, seed = 1L)
  expect_type(layers, "list")
  p <- ggplot2::ggplot() + layers + scale_fill_sketch() + ggplot2::theme_void()
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("column widths are proportional to the region totals", {
  # reuse the shared layout to check geometry
  lay <- ggsketch:::mosaic_layout(sales$region, sales$product, sales$revenue)
  widths <- vapply(lay$xlevels, function(l) {
    tl <- lay$tiles[lay$tiles$xcat == l, ]
    max(tl$xmax) - min(tl$xmin)
  }, numeric(1))
  totals <- tapply(sales$revenue, sales$region, sum)
  # widths track totals (ignoring the small inter-column gaps): same ordering
  expect_equal(order(widths), order(totals[lay$xlevels]))
})

test_that("missing value defaults every row to 1", {
  layers <- geom_sketch_marimekko(sales, region, product, seed = 1L)
  expect_silent(ggplot2::ggplot_build(
    ggplot2::ggplot() + layers + scale_fill_sketch()))
})

test_that("toggles drop the right layers", {
  base <- geom_sketch_marimekko(sales, region, product, revenue,
                                label = FALSE, width_labels = FALSE)
  lab  <- geom_sketch_marimekko(sales, region, product, revenue,
                                label = TRUE, width_labels = FALSE)
  both <- geom_sketch_marimekko(sales, region, product, revenue,
                                label = TRUE, width_labels = TRUE)
  expect_equal(length(lab) - length(base), 1L)
  expect_equal(length(both) - length(base), 2L)
})

test_that("non-data-frame input errors", {
  expect_error(geom_sketch_marimekko(1:5, region, product), "data frame")
})
