# T-SCALE-roughness: continuous roughness scale

test_that("scale_roughness_continuous rescales mapped roughness to its range", {
  df <- data.frame(x = 1:5, y = 1:5, z = c(0, 25, 50, 75, 100))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, roughness = z)) +
    geom_sketch_point(seed = 1L) +
    scale_roughness_continuous(range = c(0.01, 0.75))
  built <- ggplot2::ggplot_build(p)$data[[1]]
  expect_equal(min(built$roughness), 0.01)
  expect_equal(max(built$roughness), 0.75)
})

test_that("a custom range is honoured", {
  df <- data.frame(x = 1:3, y = 1:3, z = c(0, 1, 2))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, roughness = z)) +
    geom_sketch_point(seed = 1L) +
    scale_roughness_continuous(range = c(0, 2))
  built <- ggplot2::ggplot_build(p)$data[[1]]
  expect_equal(range(built$roughness), c(0, 2))
})

test_that("mapped continuous roughness uses the default scale automatically", {
  df <- data.frame(x = 1:5, y = 1:5, z = c(0, 25, 50, 75, 100))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, roughness = z)) +
    geom_sketch_point(seed = 1L)
  built <- ggplot2::ggplot_build(p)$data[[1]]
  # default range upper bound is 0.75
  expect_equal(max(built$roughness), 0.75)
  expect_gt(length(unique(built$roughness)), 1L)
})

test_that("scale_roughness is an alias for scale_roughness_continuous", {
  expect_identical(scale_roughness, scale_roughness_continuous)
})
