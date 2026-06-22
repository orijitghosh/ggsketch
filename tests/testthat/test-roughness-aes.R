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

test_that("derived geoms (histogram, bin2d) still build", {
  expect_no_error(ggplot2::ggplot_build(
    ggplot2::ggplot(faithful, ggplot2::aes(eruptions)) +
      geom_sketch_histogram(bins = 10, seed = 1L)))
  expect_no_error(ggplot2::ggplot_build(
    ggplot2::ggplot(faithful, ggplot2::aes(eruptions, waiting)) +
      geom_sketch_bin2d(bins = 8, seed = 1L)))
})
