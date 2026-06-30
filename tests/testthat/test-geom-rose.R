# geom_sketch_rose() - coxcomb / Nightingale rose charts. Layout is pure trig
# (rose_layout, reusing chord_arc); constructor returns sketch layers.

deaths <- data.frame(
  month = factor(month.abb, levels = month.abb),
  n     = c(12, 18, 25, 30, 22, 15, 10, 14, 20, 28, 24, 16)
)

test_that("rose_layout makes one sector per non-empty category", {
  lay <- ggsketch:::rose_layout(deaths$month, deaths$n)
  expect_named(lay, c("sectors", "labels", "cats", "segs"))
  expect_equal(length(unique(lay$sectors$sector)), 12L)
  expect_equal(nrow(lay$labels), 12L)
})

test_that("the largest category reaches the outer radius (~1)", {
  lay <- ggsketch:::rose_layout(deaths$month, deaths$n)
  rad <- sqrt(lay$sectors$x^2 + lay$sectors$y^2)
  expect_equal(max(rad), 1, tolerance = 1e-6)
})

test_that("area_true uses sqrt radius (smaller than linear for the max)", {
  lin  <- ggsketch:::rose_layout(deaths$month, deaths$n, area_true = FALSE)
  area <- ggsketch:::rose_layout(deaths$month, deaths$n, area_true = TRUE)
  # both normalise the max to 1; a mid-value wedge is relatively larger under
  # the sqrt (area-true) mapping than under the linear one
  mid_lin  <- max(sqrt(lin$sectors$x[lin$sectors$cat == "Jan"]^2 +
                       lin$sectors$y[lin$sectors$cat == "Jan"]^2))
  mid_area <- max(sqrt(area$sectors$x[area$sectors$cat == "Jan"]^2 +
                       area$sectors$y[area$sectors$cat == "Jan"]^2))
  expect_gt(mid_area, mid_lin)
})

test_that("a stacked fill produces one sector per cat x seg", {
  d <- data.frame(
    quarter = rep(c("Q1", "Q2", "Q3", "Q4"), each = 2),
    cause   = rep(c("A", "B"), times = 4),
    n       = c(5, 3, 6, 2, 4, 4, 7, 1)
  )
  lay <- ggsketch:::rose_layout(d$quarter, d$n, seg = d$cause)
  expect_equal(length(unique(lay$sectors$sector)), 8L)
})

test_that("geom_sketch_rose builds (simple and area-true)", {
  layers <- geom_sketch_rose(deaths, month, n, area_true = TRUE, seed = 1L)
  expect_type(layers, "list")
  # 12 months exceed the 8-colour sketch palette, which warns by design; we only
  # assert the plot builds.
  p <- ggplot2::ggplot() + layers + scale_fill_sketch() +
    ggplot2::coord_equal() + ggplot2::theme_void()
  expect_no_error(suppressWarnings(ggplot2::ggplot_build(p)))
})

test_that("geom_sketch_rose builds with a stacked fill", {
  d <- data.frame(
    quarter = rep(c("Q1", "Q2", "Q3", "Q4"), each = 2),
    cause   = rep(c("Disease", "Wounds"), times = 4),
    n       = c(5, 3, 6, 2, 4, 4, 7, 1)
  )
  layers <- geom_sketch_rose(d, quarter, n, fill = cause, seed = 2L)
  expect_silent(ggplot2::ggplot_build(
    ggplot2::ggplot() + layers + scale_fill_sketch() + ggplot2::coord_equal()))
})

test_that("label = FALSE drops the label layer", {
  a <- geom_sketch_rose(deaths, month, n, label = TRUE)
  b <- geom_sketch_rose(deaths, month, n, label = FALSE)
  expect_equal(length(a) - length(b), 1L)
})

test_that("non-data-frame input errors", {
  expect_error(geom_sketch_rose(1:5, month, n), "data frame")
})
