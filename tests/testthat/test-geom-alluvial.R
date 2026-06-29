# geom_sketch_alluvial() - alluvial / Sankey diagrams. Layout is pure arithmetic
# (alluvial_layout); the constructor returns a list of sketch layers.

df <- as.data.frame(Titanic)

test_that("alluvial_layout returns strata, flows and labels", {
  lay <- ggsketch:::alluvial_layout(df, axes = c("Class", "Sex", "Survived"),
                                    value = "Freq")
  expect_named(lay, c("strata", "flows", "labels", "axes"))
  # strata: 4 Class + 2 Sex + 2 Survived = 8 boxes
  expect_equal(nrow(lay$strata), 8L)
  # every stratum box has positive height
  expect_true(all(lay$strata$ymax > lay$strata$ymin))
  # flows present for 2 gaps
  expect_gt(length(unique(lay$flows$flow)), 0L)
})

test_that("stratum totals equal the data totals", {
  lay <- ggsketch:::alluvial_layout(df, axes = c("Class", "Survived"),
                                    value = "Freq")
  cls <- lay$strata[lay$strata$axis == "Class", ]
  h   <- cls$ymax - cls$ymin
  tot <- tapply(df$Freq, df$Class, sum)
  expect_equal(sort(h), sort(as.numeric(tot)))
  # the axis spans the same total height on both axes
  surv <- lay$strata[lay$strata$axis == "Survived", ]
  expect_equal(max(cls$ymax), max(surv$ymax))
})

test_that("fewer than 2 axes errors", {
  expect_error(
    ggsketch:::alluvial_layout(df, axes = "Class", value = "Freq"),
    "at least 2 axes"
  )
})

test_that("missing columns error", {
  expect_error(
    ggsketch:::alluvial_layout(df, axes = c("Class", "Nope"), value = "Freq"),
    "not found"
  )
})

test_that("value defaults to 1 per row", {
  small <- data.frame(a = c("x", "x", "y"), b = c("p", "q", "q"))
  lay <- ggsketch:::alluvial_layout(small, axes = c("a", "b"))
  ax_a <- lay$strata[lay$strata$axis == "a", ]
  expect_equal(sum(ax_a$ymax - ax_a$ymin), 3)   # 3 rows, weight 1 each
})

test_that("geom_sketch_alluvial returns layers and builds", {
  layers <- geom_sketch_alluvial(df, axes = c("Class", "Sex", "Survived"),
                                 value = "Freq", seed = 1L)
  expect_type(layers, "list")
  expect_gte(length(layers), 2L)
  p <- ggplot2::ggplot() + layers + scale_fill_sketch()
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("fill by an explicit column builds", {
  layers <- geom_sketch_alluvial(df, axes = c("Class", "Survived"),
                                 value = "Freq", fill = "Survived", seed = 2L)
  p <- ggplot2::ggplot() + layers + scale_fill_sketch()
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("label = FALSE drops the label layer", {
  a <- geom_sketch_alluvial(df, axes = c("Class", "Survived"), value = "Freq",
                            label = TRUE)
  b <- geom_sketch_alluvial(df, axes = c("Class", "Survived"), value = "Freq",
                            label = FALSE)
  expect_equal(length(a) - length(b), 1L)
})
