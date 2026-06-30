# geom_sketch_bump() - ranking-over-time charts. Layout is pure arithmetic
# (bump_layout, reusing alluvial_scurve); constructor returns sketch layers.

df <- data.frame(
  year = rep(2018:2021, each = 4),
  team = rep(c("A", "B", "C", "D"), times = 4),
  pts  = c(10, 8, 6, 4,  6, 10, 8, 4,  8, 6, 10, 5,  4, 8, 6, 12)
)

test_that("bump_layout ranks within each time and places rank 1 on top", {
  lay <- ggsketch:::bump_layout(df, "year", "team", "pts")
  expect_named(lay, c("segments", "points", "left", "right", "xlevels", "groups"))
  expect_equal(length(lay$xlevels), 4L)
  # in 2018, A has the highest pts (10) -> rank 1 -> top y = nG = 4
  a2018 <- lay$points[lay$points$group == "A" & lay$points$x == 1L, ]
  expect_equal(a2018$rank, 1)
  expect_equal(a2018$y, 4)            # nG - rank + 1 = 4 - 1 + 1
})

test_that("asc direction flips the ranking", {
  lay <- ggsketch:::bump_layout(df, "year", "team", "pts", direction = "asc")
  # lowest pts in 2018 is D (4) -> rank 1 (top)
  d2018 <- lay$points[lay$points$group == "D" & lay$points$x == 1L, ]
  expect_equal(d2018$rank, 1)
})

test_that("one connector segment per group per adjacent time pair", {
  lay <- ggsketch:::bump_layout(df, "year", "team", "pts")
  # 4 groups x (4 times - 1) = 12 segments
  expect_equal(length(unique(lay$segments$seg)), 12L)
})

test_that("fewer than 2 distinct x errors", {
  one <- df[df$year == 2018, ]
  expect_error(ggsketch:::bump_layout(one, "year", "team", "pts"),
               "at least 2 distinct")
})

test_that("missing columns error", {
  expect_error(ggsketch:::bump_layout(df, "year", "nope", "pts"), "not found")
})

test_that("geom_sketch_bump returns layers and builds", {
  layers <- geom_sketch_bump(df, year, team, pts, seed = 1L)
  expect_type(layers, "list")
  p <- ggplot2::ggplot() + layers + scale_colour_sketch() +
    ggplot2::theme_void()
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("label = FALSE drops both end-label layers", {
  a <- geom_sketch_bump(df, year, team, pts, label = TRUE)
  b <- geom_sketch_bump(df, year, team, pts, label = FALSE)
  expect_equal(length(a) - length(b), 2L)
})
