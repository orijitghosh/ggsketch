# T-GEOM-stages: funnel (centred shrinking bars) + pyramid (mirrored bars).

grob_classes <- function(g) {
  out <- class(g)[1L]
  kids <- if (inherits(g, "gTree")) g$children else NULL
  c(out, unlist(lapply(kids, grob_classes)))
}

funnel_data <- function() {
  data.frame(
    stage = factor(c("Visited", "Signed up", "Activated", "Paid"),
                   levels = rev(c("Visited", "Signed up", "Activated",
                                  "Paid"))),
    n     = c(1200, 460, 210, 80)
  )
}

test_that("funnel bars are centred on zero with width = value", {
  p <- ggplot2::ggplot(funnel_data(), ggplot2::aes(n, stage)) +
    geom_sketch_funnel(seed = 1L)
  d <- ggplot2::layer_data(p, 1L)
  expect_equal(d$xmax, -d$xmin)
  expect_equal(sort(d$xmax - d$xmin), sort(funnel_data()$n))
  expect_equal(d$ymax - d$ymin, rep(0.7, 4))
})

test_that("funnel rows come out top stage first", {
  p <- ggplot2::ggplot(funnel_data(), ggplot2::aes(n, stage)) +
    geom_sketch_funnel(seed = 1L)
  d <- ggplot2::layer_data(p, 1L)
  ymid <- (d$ymin + d$ymax) / 2
  expect_true(all(diff(ymid) < 0))
})

test_that("funnel draws connector polygons between stages", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  base <- ggplot2::ggplot(funnel_data(), ggplot2::aes(n, stage))
  g1 <- ggplot2::ggplotGrob(base + geom_sketch_funnel(seed = 1L))
  g0 <- ggplot2::ggplotGrob(base +
    geom_sketch_funnel(connectors = FALSE, seed = 1L))
  n1 <- sum(grob_classes(g1$grobs[[which(g1$layout$name == "panel")]]) ==
              "polygon")
  n0 <- sum(grob_classes(g0$grobs[[which(g0$layout$name == "panel")]]) ==
              "polygon")
  expect_equal(n1 - n0, 3L)   # one trapezoid per gap
})

pyramid_data <- function() {
  data.frame(
    age = factor(rep(c("0-19", "20-39", "40-59", "60+"), 2),
                 levels = c("0-19", "20-39", "40-59", "60+")),
    sex = rep(c("Female", "Male"), each = 4),
    n   = c(340, 420, 380, 240, 360, 440, 370, 200)
  )
}

test_that("pyramid mirrors the first side level to the left", {
  p <- ggplot2::ggplot(pyramid_data(),
                       ggplot2::aes(n, age, side = sex)) +
    geom_sketch_pyramid(seed = 1L)
  d <- ggplot2::layer_data(p, 1L)
  left  <- d[d$xmin < 0, ]
  right <- d[d$xmax > 0, ]
  expect_equal(nrow(left), 4L)
  expect_equal(nrow(right), 4L)
  expect_true(all(left$xmax == 0))
  expect_true(all(right$xmin == 0))
  expect_equal(sort(-left$xmin), sort(pyramid_data()$n[1:4]))
})

test_that("pyramid errors clearly without exactly two side levels", {
  df <- pyramid_data()
  df$sex <- "Female"
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, side = sex)) +
    geom_sketch_pyramid(seed = 1L)
  expect_error(ggplot2::ggplot_build(p), "two")
})

test_that("funnel and pyramid render end to end with fills", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p1 <- ggplot2::ggplot(funnel_data(),
                        ggplot2::aes(n, stage, fill = stage)) +
    geom_sketch_funnel(seed = 1L, show.legend = FALSE)
  p2 <- ggplot2::ggplot(pyramid_data(),
                        ggplot2::aes(n, age, side = sex, fill = sex)) +
    geom_sketch_pyramid(seed = 1L) +
    ggplot2::scale_x_continuous(labels = abs)
  expect_no_error(print(p1))
  expect_no_error(print(p2))
})

test_that("empty data yields empty layers, not errors", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p1 <- ggplot2::ggplot(funnel_data()[0L, ], ggplot2::aes(n, stage)) +
    geom_sketch_funnel(seed = 1L)
  p2 <- ggplot2::ggplot(pyramid_data()[0L, ],
                        ggplot2::aes(n, age, side = sex)) +
    geom_sketch_pyramid(seed = 1L)
  expect_no_error(print(p1))
  expect_no_error(print(p2))
})
