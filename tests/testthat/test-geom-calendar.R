# T-v2: geom_sketch_calendar() - GitHub-style calendar heatmap.

grob_classes <- function(g) {
  out <- class(g)
  if (!is.null(g$grobs))    out <- c(out, unlist(lapply(g$grobs, grob_classes)))
  if (!is.null(g$children)) out <- c(out, unlist(lapply(g$children, grob_classes)))
  out
}

cal_df <- function() {
  df <- data.frame(day = as.Date("2024-01-01") + 0:120)
  df$value <- seq_len(nrow(df))
  df
}

test_that("geom_sketch_calendar builds and computes the week/day grid", {
  d <- ggplot2::layer_data(
    ggplot2::ggplot(cal_df(), ggplot2::aes(date = day, fill = value)) +
      geom_sketch_calendar(seed = 1L)
  )
  expect_true(all(c("x", "y") %in% names(d)))
  expect_s3_class(StatSketchCalendar, "Stat")
  # weekdays span 7 rows
  expect_true(all(d$y >= 1 & d$y <= 7))
})

test_that("consecutive days advance by one weekday (then wrap a week)", {
  d <- ggplot2::layer_data(
    ggplot2::ggplot(cal_df(), ggplot2::aes(date = day, fill = value)) +
      geom_sketch_calendar(week_start = "sunday", seed = 1L)
  )
  d <- d[order(d$fill), ]                     # value == day order
  # Jan 1 2024 is a Monday -> with Sunday start, row 6 (7 - 1)
  expect_equal(d$y[1], 6)
  expect_equal(d$x[1], 1)
  # seven days later we move one column right, same row
  expect_equal(d$x[8], d$x[1] + 1)
  expect_equal(d$y[8], d$y[1])
})

test_that("week_start = monday shifts the rows", {
  ds <- ggplot2::layer_data(
    ggplot2::ggplot(cal_df(), ggplot2::aes(date = day, fill = value)) +
      geom_sketch_calendar(week_start = "sunday", seed = 1L)
  )
  dm <- ggplot2::layer_data(
    ggplot2::ggplot(cal_df(), ggplot2::aes(date = day, fill = value)) +
      geom_sketch_calendar(week_start = "monday", seed = 1L)
  )
  # Jan 1 2024 (Monday) is the top row when the week starts on Monday
  dm <- dm[order(dm$fill), ]
  expect_equal(dm$y[1], 7)
  expect_false(isTRUE(all.equal(ds$y, dm$y)))
})

test_that("calendar draws sketch tiles", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(cal_df(), ggplot2::aes(date = day, fill = value)) +
    geom_sketch_calendar(seed = 1L)
  gt <- ggplot2::ggplotGrob(p)
  expect_true("SketchPolygonGrob" %in% grob_classes(gt))
  expect_no_error(grid::grid.draw(gt))
})

test_that("labels = TRUE returns the layer plus weekday/month axis scales", {
  out <- geom_sketch_calendar(seed = 1L)
  expect_type(out, "list")
  expect_length(out, 3L)
  expect_true(inherits(out[[1L]], "Layer"))
  expect_true(inherits(out[[2L]], "Scale"))
  expect_true(inherits(out[[3L]], "Scale"))
  lyr <- geom_sketch_calendar(seed = 1L, labels = FALSE)
  expect_true(inherits(lyr, "Layer"))
})

test_that("axes read weekdays and months, honouring week_start", {
  p <- ggplot2::ggplot(cal_df(), ggplot2::aes(date = day, fill = value)) +
    geom_sketch_calendar(seed = 1L)
  b <- ggplot2::ggplot_build(p)
  ylab <- b$layout$panel_scales_y[[1L]]$get_labels()
  xlab <- b$layout$panel_scales_x[[1L]]$get_labels()
  expect_equal(ylab[length(ylab)], "Sun")        # top row (y = 7) = week start
  expect_true(all(c("Jan", "Feb", "Mar", "Apr") %in% xlab))

  pm <- ggplot2::ggplot(cal_df(), ggplot2::aes(date = day, fill = value)) +
    geom_sketch_calendar(seed = 1L, week_start = "monday")
  bm <- ggplot2::ggplot_build(pm)
  ylabm <- bm$layout$panel_scales_y[[1L]]$get_labels()
  expect_equal(ylabm[length(ylabm)], "Mon")
})

test_that("empty data builds without error", {
  df <- data.frame(day = as.Date(character(0)), value = numeric(0))
  p <- ggplot2::ggplot(df, ggplot2::aes(date = day, fill = value)) +
    geom_sketch_calendar(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})
