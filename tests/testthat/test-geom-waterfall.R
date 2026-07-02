# T-GEOM-waterfall: running-total layout + composed bar/connector drawing.

wf_data <- function() {
  data.frame(
    step  = factor(c("Start", "Sales", "Refunds", "Costs", "Net"),
                   levels = c("Start", "Sales", "Refunds", "Costs", "Net")),
    delta = c(100, 50, -30, -45, 0),
    kind  = c("relative", "relative", "relative", "relative", "total")
  )
}

wf_layer_data <- function(df = wf_data()) {
  p <- ggplot2::ggplot(df, ggplot2::aes(step, delta, measure = kind)) +
    geom_sketch_waterfall(seed = 1L)
  ggplot2::layer_data(p, 1L)
}

test_that("running totals step correctly and the total bar spans from zero", {
  d <- wf_layer_data()
  # Start: 0 -> 100; Sales: 100 -> 150; Refunds: 150 -> 120; Costs: 120 -> 75.
  expect_equal(d$ymin, c(0, 100, 120, 75, 0))
  expect_equal(d$ymax, c(100, 150, 150, 120, 75))
  expect_equal(d$change,
               c("increase", "increase", "decrease", "decrease", "total"))
})

test_that("connectors carry the running level to the next bar", {
  d <- wf_layer_data()
  expect_equal(d$con_y[-nrow(d)], c(100, 150, 120, 75))
  expect_true(is.na(d$con_y[nrow(d)]))
  expect_true(all(d$con_xend[-nrow(d)] > d$con_x[-nrow(d)]))
})

test_that("bars are centred on the step with the requested width", {
  d <- wf_layer_data()
  expect_equal(d$xmax - d$xmin, rep(0.62, 5))
  expect_equal((d$xmin + d$xmax) / 2, 1:5)
})

grob_classes <- function(g) {
  out <- class(g)[1L]
  kids <- if (inherits(g, "gTree")) g$children else NULL
  c(out, unlist(lapply(kids, grob_classes)))
}

test_that("waterfall renders rect grobs plus connector paths", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(wf_data(),
                       ggplot2::aes(step, delta, measure = kind)) +
    geom_sketch_waterfall(seed = 1L)
  g <- ggplot2::ggplotGrob(p)
  panel <- g$grobs[[which(g$layout$name == "panel")]]
  cls <- grob_classes(panel)
  expect_true("SketchRectGrob" %in% cls || "SketchPolygonGrob" %in% cls)
  expect_true("SketchPathGrob" %in% cls)
})

test_that("connectors = FALSE draws bars only", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(wf_data(),
                       ggplot2::aes(step, delta, measure = kind)) +
    geom_sketch_waterfall(connectors = FALSE, seed = 1L)
  g <- ggplot2::ggplotGrob(p)
  panel <- g$grobs[[which(g$layout$name == "panel")]]
  expect_false("SketchPathGrob" %in% grob_classes(panel))
})

test_that("measure defaults to relative when not mapped", {
  df <- wf_data()[, c("step", "delta")]
  p <- ggplot2::ggplot(df, ggplot2::aes(step, delta)) +
    geom_sketch_waterfall(seed = 1L)
  d <- ggplot2::layer_data(p, 1L)
  expect_false("total" %in% d$change)
  expect_equal(d$ymax[5], 75)
})

test_that("direction fills can be turned off for a user fill mapping", {
  p <- ggplot2::ggplot(wf_data(),
                       ggplot2::aes(step, delta, measure = kind,
                                    fill = ggplot2::after_stat(change))) +
    geom_sketch_waterfall(fill_increase = NULL, fill_decrease = NULL,
                          fill_total = NULL, seed = 1L) +
    ggplot2::scale_fill_manual(
      values = c(increase = "green", decrease = "red", total = "blue"))
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  expect_no_error(print(p))
})

test_that("empty data yields an empty layer, not an error", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(wf_data()[0L, ],
                       ggplot2::aes(step, delta, measure = kind)) +
    geom_sketch_waterfall(seed = 1L)
  expect_no_error(print(p))
})
