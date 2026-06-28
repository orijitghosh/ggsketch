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

test_that("empty data builds without error", {
  df <- data.frame(day = as.Date(character(0)), value = numeric(0))
  p <- ggplot2::ggplot(df, ggplot2::aes(date = day, fill = value)) +
    geom_sketch_calendar(seed = 1L)
  expect_no_error(ggplot2::ggplot_build(p))
})
