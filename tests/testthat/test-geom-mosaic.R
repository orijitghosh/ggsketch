# geom_sketch_mosaic() - mosaic plots. Layout is pure arithmetic
# (mosaic_layout); the constructor returns a list of sketch layers.

df <- as.data.frame(Titanic)

test_that("mosaic_layout tiles cover the unit square by frequency", {
  lay <- ggsketch:::mosaic_layout(df$Class, df$Survived, df$Freq, gap = 0)
  expect_named(lay, c("tiles", "labels", "xlevels", "ylevels"))
  # 4 classes x 2 survival = up to 8 tiles (all present here)
  expect_equal(nrow(lay$tiles), 8L)
  # with gap 0, total tile area = 1 (the whole square)
  area <- with(lay$tiles, sum((xmax - xmin) * (ymax - ymin)))
  expect_equal(area, 1, tolerance = 1e-9)
})

test_that("column widths match marginal x frequencies", {
  lay <- ggsketch:::mosaic_layout(df$Class, df$Survived, df$Freq, gap = 0)
  w <- tapply(df$Freq, df$Class, sum); w <- w / sum(w)
  # width of each class column (same for all its tiles)
  cw <- tapply(lay$tiles$xmax - lay$tiles$xmin, lay$tiles$xcat, max)
  expect_equal(as.numeric(cw[names(w)]), as.numeric(w), tolerance = 1e-9)
})

test_that("tile heights within a column are conditional frequencies", {
  lay <- ggsketch:::mosaic_layout(df$Class, df$Survived, df$Freq, gap = 0)
  first <- lay$tiles[lay$tiles$xcat == "1st", ]
  h <- (first$ymax - first$ymin)
  expect_equal(sum(h), 1, tolerance = 1e-9)   # column fully stacked
})

test_that("empty cells are skipped", {
  small <- data.frame(x = c("a", "a", "b"), y = c("p", "p", "q"),
                      w = c(2, 1, 4))
  lay <- ggsketch:::mosaic_layout(small$x, small$y, small$w, gap = 0)
  # column a has only y=p, column b only y=q -> 2 tiles, not 4
  expect_equal(nrow(lay$tiles), 2L)
})

test_that("geom_sketch_mosaic returns layers and builds", {
  layers <- geom_sketch_mosaic(df, x = Class, y = Survived, value = Freq,
                               seed = 1L)
  expect_type(layers, "list")
  expect_gte(length(layers), 1L)
  p <- ggplot2::ggplot() + layers + scale_fill_sketch()
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("fill_by = x colours by the column variable", {
  layers <- geom_sketch_mosaic(df, x = Class, y = Survived, value = Freq,
                               fill_by = "x", seed = 2L)
  p <- ggplot2::ggplot() + layers + scale_fill_sketch()
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("value defaults to 1 per row", {
  small <- data.frame(a = c("x", "x", "y"), b = c("p", "q", "q"))
  layers <- geom_sketch_mosaic(small, x = a, y = b, seed = 1L)
  expect_silent(ggplot2::ggplot_build(ggplot2::ggplot() + layers))
})

test_that("label = FALSE drops the label layer", {
  a <- geom_sketch_mosaic(df, x = Class, y = Survived, value = Freq, label = TRUE)
  b <- geom_sketch_mosaic(df, x = Class, y = Survived, value = Freq, label = FALSE)
  expect_equal(length(a) - length(b), 1L)
})
