# T-ROUGH-aes: roughness as a mappable aesthetic on col/bar and rect/tile

test_that("col/rect accept roughness as a constant, a mapping, or the default", {
  df <- data.frame(g = c("a", "b", "c"), y = c(3, 5, 2), z = c(0, 1, 2))
  # default (no roughness)
  expect_no_error(ggplot2::ggplot_build(
    ggplot2::ggplot(df, ggplot2::aes(g, y)) + geom_sketch_col(seed = 1L)))
  # constant
  expect_no_error(ggplot2::ggplot_build(
    ggplot2::ggplot(df, ggplot2::aes(g, y)) + geom_sketch_col(roughness = 2, seed = 1L)))
  # mapped (auto scale_roughness_continuous)
  p <- ggplot2::ggplot(df, ggplot2::aes(g, y, roughness = z)) +
    geom_sketch_col(seed = 1L)
  built <- ggplot2::ggplot_build(p)$data[[1]]
  expect_true("roughness" %in% names(built))
  expect_gt(length(unique(built$roughness)), 1L)
})

test_that("per-bar roughness reaches the geom (I() passes raw values)", {
  df <- data.frame(g = c("a", "b"), y = c(3, 3), z = c(0, 3))
  p <- ggplot2::ggplot(df, ggplot2::aes(g, y, roughness = I(z))) +
    geom_sketch_col(seed = 1L)
  built <- ggplot2::ggplot_build(p)$data[[1]]
  expect_setequal(built$roughness, c(0, 3))
})

test_that("default roughness is preserved (still 1) for col and rect", {
  # GeomSketchCol/Rect default_aes must keep roughness = 1 so existing output
  # is unchanged.
  expect_equal(GeomSketchCol$default_aes$roughness, 1)
  expect_equal(GeomSketchRect$default_aes$roughness, 1)
  expect_equal(GeomSketchTile$default_aes$roughness, 1)
  # roughness must NOT be a layer parameter any more (it is an aesthetic).
  expect_false("roughness" %in% GeomSketchCol$parameters())
  expect_false("roughness" %in% GeomSketchRect$parameters())
})

test_that("sketch_ellipse_grob applies roughness per shape (indexed)", {
  xs <- function(g) unname(lapply(grid::makeContent(g)$children,
                                  function(z) as.numeric(z$x)))
  mk <- function(r) sketch_ellipse_grob(
    x = c(0.3, 0.7), y = c(0.5, 0.5), rx = c(0.2, 0.2), ry = c(0.2, 0.2),
    roughness = r, seed = 1L, outline_gp = grid::gpar(col = "black"))
  a <- xs(mk(c(0, 3)))   # ellipse 1 clean, ellipse 2 wobbly
  b <- xs(mk(c(3, 3)))   # ellipse 1 wobbly, ellipse 2 wobbly
  # ellipse 1 (children 1:2) differs (0 vs 3); ellipse 2 (3:4) is identical.
  expect_false(isTRUE(all.equal(a[1:2], b[1:2])))
  expect_identical(a[3:4], b[3:4])
})

test_that("roughness is mappable on circle/ellipse and segment/spoke", {
  cdf <- data.frame(x = c(1, 3), y = c(1, 1), r = c(0.5, 0.5), z = c(0, 3))
  expect_no_error(ggplot2::ggplot_build(
    ggplot2::ggplot(cdf, ggplot2::aes(x, y, r = r, roughness = z)) +
      geom_sketch_circle(seed = 1L)))

  sdf <- data.frame(x = c(1, 2), y = c(1, 2), xend = c(2, 3), yend = c(2, 1),
                    z = c(0, 3))
  p <- ggplot2::ggplot(sdf, ggplot2::aes(x, y, xend = xend, yend = yend,
                                         roughness = I(z))) +
    geom_sketch_segment(seed = 1L)
  built <- ggplot2::ggplot_build(p)$data[[1]]
  expect_setequal(built$roughness, c(0, 3))
})

test_that("jitter keeps roughness mappable; count's constant no longer clobbers", {
  df <- data.frame(x = c(1, 2), y = c(1, 2), z = c(0, 3))
  # jitter (stat identity) carries the per-point roughness through.
  pj <- ggplot2::ggplot(df, ggplot2::aes(x, y, roughness = I(z))) +
    geom_sketch_jitter(seed = 1L)
  expect_true(all(c(0, 3) %in% ggplot2::ggplot_build(pj)$data[[1]]$roughness))
  # count uses stat_sum (which may aggregate); just confirm a constant works and
  # the default no longer forces 0.5 over a mapping.
  expect_no_error(ggplot2::ggplot_build(
    ggplot2::ggplot(df, ggplot2::aes(x, y)) + geom_sketch_count(roughness = 2, seed = 1L)))
})

test_that("derived geoms (histogram, bin2d) still build", {
  expect_no_error(ggplot2::ggplot_build(
    ggplot2::ggplot(faithful, ggplot2::aes(eruptions)) +
      geom_sketch_histogram(bins = 10, seed = 1L)))
  expect_no_error(ggplot2::ggplot_build(
    ggplot2::ggplot(faithful, ggplot2::aes(eruptions, waiting)) +
      geom_sketch_bin2d(bins = 8, seed = 1L)))
})
