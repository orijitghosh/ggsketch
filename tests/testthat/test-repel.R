# Sketch repel: Layer-1 repel_layout() solver + geoms.

test_that("repel_layout returns one centre per anchor and is seed-safe", {
  set.seed(1L); before <- .Random.seed
  a <- repel_layout(c(0, 1, 2), c(0, 0, 0), w = 0.4, h = 0.2, seed = 5L)
  b <- repel_layout(c(0, 1, 2), c(0, 0, 0), w = 0.4, h = 0.2, seed = 5L)
  expect_length(a$x, 3L)
  expect_identical(a, b)
  expect_identical(.Random.seed, before)
})

test_that("empty input yields empty output", {
  out <- repel_layout(numeric(0), numeric(0), w = 1, h = 1)
  expect_length(out$x, 0L)
})

test_that("coincident boxes are pushed apart until they no longer overlap", {
  # three labels stacked on the same point: must separate
  ax <- c(0, 0, 0); ay <- c(0, 0, 0)
  w <- 0.5; h <- 0.3
  out <- repel_layout(ax, ay, w = w, h = h, box_padding = 0.02,
                      point_padding = 0, seed = 2L)
  ok <- TRUE
  for (i in 1:2) for (j in (i + 1):3) {
    ox <- (w + 0.04) - abs(out$x[j] - out$x[i])
    oy <- (h + 0.04) - abs(out$y[j] - out$y[i])
    if (ox > 1e-6 && oy > 1e-6) ok <- FALSE     # still overlapping
  }
  expect_true(ok)
})

test_that("boxes jammed into a bounds corner escape along the edge", {
  # anchors piled in the bottom-right corner: separating along x is blocked by
  # the limit, so the solver must fan the boxes out along the edge instead of
  # clamping them back on top of each other.
  ax <- c(4.8, 4.9, 5.0, 4.95, 4.85)
  ay <- c(0.2, 0.1, 0.15, 0.05, 0.25)
  w <- 1.2; h <- 0.4; bp <- 0.05
  out <- repel_layout(ax, ay, w = w, h = h,
                      xlim = c(0, 5), ylim = c(0, 5),
                      box_padding = bp, point_padding = 0.05, seed = 1L)
  hw <- w / 2 + bp; hh <- h / 2 + bp
  n  <- length(out$x)
  for (i in seq_len(n - 1L)) for (j in seq(i + 1L, n)) {
    ox <- 2 * hw - abs(out$x[j] - out$x[i])
    oy <- 2 * hh - abs(out$y[j] - out$y[i])
    expect_true(ox <= 1e-6 || oy <= 1e-6)
  }
  expect_true(all(out$x >= hw - 1e-9 & out$x <= 5 - hw + 1e-9))
  expect_true(all(out$y >= hh - 1e-9 & out$y <= 5 - hh + 1e-9))
})

test_that("centres stay within the supplied limits", {
  out <- repel_layout(c(0.5, 0.5), c(0.5, 0.5), w = 0.2, h = 0.2,
                      xlim = c(0, 1), ylim = c(0, 1), box_padding = 0.05,
                      seed = 1L)
  expect_true(all(out$x >= 0.1 - 1e-9 & out$x <= 0.9 + 1e-9))
  expect_true(all(out$y >= 0.1 - 1e-9 & out$y <= 0.9 + 1e-9))
})

test_that("box_edge_point lands on the rectangle boundary toward the target", {
  p <- box_edge_point(0, 0, hw = 1, hh = 0.5, tx = 10, ty = 0)
  expect_equal(p, c(1, 0))                        # exits the right edge
  p2 <- box_edge_point(0, 0, hw = 1, hh = 0.5, tx = 0, ty = 10)
  expect_equal(p2, c(0, 0.5))                     # exits the top edge
})

# ---- grob + geom integration ------------------------------------------------

test_that("sketch_repel_grob draws text, and boxes only when boxed", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  grid::pushViewport(grid::viewport(width = grid::unit(5, "in"),
                                    height = grid::unit(5, "in")))
  labs <- c("alpha", "bravo", "charlie")
  bare <- sketch_repel_grob(c(0.5, 0.5, 0.5), c(0.5, 0.5, 0.5), labs,
                            boxed = FALSE, seed = 1L)
  boxed <- sketch_repel_grob(c(0.5, 0.5, 0.5), c(0.5, 0.5, 0.5), labs,
                             boxed = TRUE, seed = 1L,
                             box_gp = grid::gpar(col = "black", fill = "white"))
  bare_cls  <- vapply(grid::makeContent(bare)$children,  function(z) class(z)[1L], "")
  boxed_cls <- vapply(grid::makeContent(boxed)$children, function(z) class(z)[1L], "")
  expect_equal(sum(grepl("text", bare_cls)), 3L)
  expect_false(any(grepl("polygon", bare_cls)))          # no box fills
  expect_true(any(grepl("polygon|polyline", boxed_cls)))  # boxes present
  grid::popViewport()
})

test_that("both repel geoms render end to end", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  df <- data.frame(x = c(1, 1.02, 1.04), y = c(1, 1, 1.01),
                   lab = c("one", "two", "three"))
  p1 <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = lab)) +
    geom_sketch_point(seed = 1L) +
    geom_sketch_text_repel(family = "", seed = 1L)
  p2 <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = lab)) +
    geom_sketch_point(seed = 1L) +
    geom_sketch_label_repel(family = "", seed = 1L)
  expect_no_error(print(p1))
  expect_no_error(print(p2))
})
