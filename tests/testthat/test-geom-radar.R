# geom_sketch_radar() - spider charts. The layout is computed by StatSketchRadar
# in its own cartesian space (custom axis/value aesthetics), then drawn by
# GeomSketchRadar$draw_panel (web + one polygon per series).

skills <- data.frame(
  axis  = rep(c("Speed", "Power", "Range", "Control", "Stamina"), 2),
  value = c(8, 6, 9, 5, 7, 5, 9, 4, 8, 6),
  who   = rep(c("A", "B"), each = 5)
)

test_that("geom_sketch_radar is registered and builds", {
  expect_true(exists("GeomSketchRadar"))
  expect_true(exists("StatSketchRadar"))
  p <- ggplot2::ggplot(skills, ggplot2::aes(axis = axis, value = value,
                                            group = who, colour = who)) +
    geom_sketch_radar(seed = 1L)
  expect_silent(b <- ggplot2::ggplot_build(p))
  expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
})

test_that("StatSketchRadar emits series + anchor rows in unit space", {
  comp <- StatSketchRadar$compute_panel(
    data = data.frame(axis = factor(skills$axis,
                                    levels = c("Speed", "Power", "Range",
                                               "Control", "Stamina")),
                      value = skills$value,
                      group = rep(1:2, each = 5)),
    scales = NULL
  )
  # 2 series x 5 axes = 10 series rows, + 5 anchor rows
  expect_equal(sum(comp$.role == "series"), 10L)
  expect_equal(sum(comp$.role == "axis"), 5L)
  # series radius never exceeds 1 (scaled by vmax = 9)
  sr <- comp[comp$.role == "series", ]
  expect_lte(max(sqrt(sr$x^2 + sr$y^2)), 1 + 1e-9)
  # vmax recorded
  expect_equal(unique(comp$.vmax), 9)
})

test_that("anchor rows do not leak NA into the fill scale / legend", {
  p <- ggplot2::ggplot(skills, ggplot2::aes(axis = axis, value = value,
                                            group = who, colour = who,
                                            fill = who)) +
    geom_sketch_radar(alpha = 0.3, seed = 1L)
  b <- ggplot2::ggplot_build(p)
  # no NA fill in the trained layer data (would add an "NA" legend key and
  # stop the colour and fill legends merging)
  expect_false(anyNA(b$data[[1]]$fill))
  fill_scale <- b$plot$scales$get_scales("fill")
  expect_false(anyNA(fill_scale$get_breaks()))
})

test_that("rmax rescales the radius", {
  base <- StatSketchRadar$compute_panel(
    data = data.frame(axis = factor(c("a", "b", "c")), value = c(1, 2, 3),
                      group = 1L),
    scales = NULL)
  big <- StatSketchRadar$compute_panel(
    data = data.frame(axis = factor(c("a", "b", "c")), value = c(1, 2, 3),
                      group = 1L),
    scales = NULL, rmax = 6)
  sb <- base[base$.role == "series", ]
  bg <- big[big$.role == "series", ]
  # same shape, half the radius when rmax doubles the data max (3 -> 6)
  rb <- sqrt(sb$x^2 + sb$y^2); rg <- sqrt(bg$x^2 + bg$y^2)
  expect_equal(rg[rb > 0], (rb / 2)[rb > 0], tolerance = 1e-9)
})

test_that("fewer than 3 axes errors", {
  expect_error(
    StatSketchRadar$compute_panel(
      data = data.frame(axis = factor(c("a", "b")), value = c(1, 2),
                        group = 1L),
      scales = NULL),
    "at least 3 axes"
  )
})

test_that("a single series builds and takes a fill style", {
  one <- subset(skills, who == "A")
  p <- ggplot2::ggplot(one, ggplot2::aes(axis = axis, value = value,
                                         group = who)) +
    geom_sketch_radar(fill = "#2E86C1", fill_style = "watercolor", seed = 2L)
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("empty data does not error", {
  empty <- skills[0, ]
  p <- ggplot2::ggplot(empty, ggplot2::aes(axis = axis, value = value,
                                           group = who)) +
    geom_sketch_radar(seed = 1L)
  expect_silent(ggplot2::ggplot_build(p))
})
