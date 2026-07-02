# T-GEOM-gantt: task bars from x..xend on a discrete y, progress overlay.

gantt_data <- function() {
  data.frame(
    task  = factor(c("Design", "Build", "Test"),
                   levels = c("Test", "Build", "Design")),
    start = c(1, 4, 8),
    end   = c(5, 9, 11),
    done  = c(1, 0.5, 0)
  )
}

grob_classes <- function(g) {
  out <- class(g)[1L]
  kids <- if (inherits(g, "gTree")) g$children else NULL
  c(out, unlist(lapply(kids, grob_classes)))
}

test_that("bars span start..end centred on the task row", {
  p <- ggplot2::ggplot(gantt_data(),
                       ggplot2::aes(x = start, xend = end, y = task)) +
    geom_sketch_gantt(seed = 1L)
  d <- ggplot2::layer_data(p, 1L)
  expect_equal(d$xmin, c(1, 4, 8))
  expect_equal(d$xmax, c(5, 9, 11))
  # Design is level 3, Build 2, Test 1.
  expect_equal((d$ymin + d$ymax) / 2, c(3, 2, 1))
  expect_equal(d$ymax - d$ymin, rep(0.55, 3))
})

test_that("height parameter controls the bar thickness", {
  p <- ggplot2::ggplot(gantt_data(),
                       ggplot2::aes(x = start, xend = end, y = task)) +
    geom_sketch_gantt(height = 0.3, seed = 1L)
  d <- ggplot2::layer_data(p, 1L)
  expect_equal(d$ymax - d$ymin, rep(0.3, 3))
})

test_that("reversed start/end still yields a positive-width bar", {
  df <- data.frame(task = "A", start = 5, end = 2)
  p <- ggplot2::ggplot(df, ggplot2::aes(x = start, xend = end, y = task)) +
    geom_sketch_gantt(seed = 1L)
  d <- ggplot2::layer_data(p, 1L)
  expect_equal(d$xmin, 2)
  expect_equal(d$xmax, 5)
})

test_that("the x scale trains on xend so the last bar fits", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(gantt_data(),
                       ggplot2::aes(x = start, xend = end, y = task)) +
    geom_sketch_gantt(seed = 1L)
  b <- ggplot2::ggplot_build(p)
  expect_gte(max(b$layout$panel_params[[1L]]$x.range), 11)
})

test_that("progress adds a solid overlay; none without the aesthetic", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  base <- ggplot2::ggplot(gantt_data(),
                          ggplot2::aes(x = start, xend = end, y = task))
  g1 <- ggplot2::ggplotGrob(base +
    geom_sketch_gantt(ggplot2::aes(progress = done), seed = 1L))
  g0 <- ggplot2::ggplotGrob(base + geom_sketch_gantt(seed = 1L))
  n1 <- length(grob_classes(g1$grobs[[which(g1$layout$name == "panel")]]))
  n0 <- length(grob_classes(g0$grobs[[which(g0$layout$name == "panel")]]))
  expect_gt(n1, n0)
})

test_that("gantt renders with dates and watercolour fill", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  plan <- data.frame(
    task  = c("A", "B"),
    start = as.Date(c("2026-01-05", "2026-01-19")),
    end   = as.Date(c("2026-01-23", "2026-02-13"))
  )
  p <- ggplot2::ggplot(plan,
                       ggplot2::aes(x = start, xend = end, y = task,
                                    fill = task)) +
    geom_sketch_gantt(fill_style = "watercolor", seed = 1L)
  expect_no_error(print(p))
})

test_that("empty data yields an empty layer, not an error", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(gantt_data()[0L, ],
                       ggplot2::aes(x = start, xend = end, y = task)) +
    geom_sketch_gantt(seed = 1L)
  expect_no_error(print(p))
})
