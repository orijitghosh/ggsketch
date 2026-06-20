# T-GEOM-area: geom_sketch_ribbon / _area / _density tests (P4-T2, P4-T3)

png_render <- function(p) {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  png(tmp, width = 4, height = 4, units = "in", res = 72)
  print(p)
  dev.off()
  file.size(tmp)
}

df_band <- data.frame(x = 1:10, lo = (1:10) - 2, hi = (1:10) + 2)

test_that("geom_sketch_ribbon() builds and renders", {
  p <- ggplot2::ggplot(df_band, ggplot2::aes(x)) +
    geom_sketch_ribbon(ggplot2::aes(ymin = lo, ymax = hi),
                       fill = "plum", seed = 1L)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_area() builds and renders", {
  df <- data.frame(x = 1:10, y = c(1, 3, 2, 5, 4, 6, 5, 8, 6, 9))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_area(fill = "lightgreen", seed = 2L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_area sets ymin = 0 in setup_data", {
  df <- data.frame(x = 1:3, y = c(2, 4, 3), PANEL = factor(1),
                   group = 1L)
  out <- GeomSketchArea$setup_data(df, list())
  expect_true(all(out$ymin == 0))
  expect_equal(out$ymax, out$y)
})

test_that("geom_sketch_density() builds and renders", {
  p <- ggplot2::ggplot(faithful, ggplot2::aes(eruptions)) +
    geom_sketch_density(fill = "khaki", seed = 3L)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_gt(png_render(p), 0)
})

test_that("geom_sketch_ribbon degenerate (< 2 rows) returns minimal grob", {
  grob <- GeomSketchRibbon$draw_group(
    data.frame(x = 1, ymin = 0, ymax = 1, fill = "grey", colour = NA,
               linewidth = 0.5, linetype = 1, alpha = NA),
    list(), ggplot2::coord_cartesian(), seed = 1L
  )
  expect_s3_class(grob, "grob")
})

test_that("geom_sketch_ribbon composes with facets (AC-2)", {
  df <- rbind(
    cbind(df_band, g = "A"),
    cbind(transform(df_band, lo = lo + 3, hi = hi + 3), g = "B")
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(x)) +
    geom_sketch_ribbon(ggplot2::aes(ymin = lo, ymax = hi), seed = 1L) +
    ggplot2::facet_wrap(~g)
  expect_gt(png_render(p), 0)
})
