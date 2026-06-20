# T-DEV-01 / T-DEV-02: Device matrix and determinism tests (P2-T6, AC-3/4)

.dev_test_plot <- function() {
  df <- data.frame(x = 1:5, y = c(2, 1, 4, 3, 5))
  ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_line(seed = 42L) +
    geom_sketch_point(seed = 42L) +
    theme_sketch()
}

# --- T-DEV-01: render to multiple graphics devices ----------------------------

test_that("line+point plot renders to grDevices PNG (T-DEV-01)", {
  p   <- .dev_test_plot()
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)

  png(tmp, width = 480, height = 480)
  print(p)
  dev.off()

  expect_true(file.exists(tmp))
  expect_gt(file.size(tmp), 0)
})

test_that("line+point plot renders to PDF (T-DEV-01)", {
  p   <- .dev_test_plot()
  tmp <- tempfile(fileext = ".pdf")
  on.exit(unlink(tmp), add = TRUE)

  pdf(tmp, width = 6, height = 6)
  print(p)
  dev.off()

  expect_true(file.exists(tmp))
  expect_gt(file.size(tmp), 0)
})

test_that("line+point plot renders to ragg PNG (T-DEV-01)", {
  skip_if_not_installed("ragg")
  p   <- .dev_test_plot()
  tmp <- tempfile(fileext = ".png")
  # Normalize path for Windows compatibility
  tmp <- normalizePath(tmp, winslash = "/", mustWork = FALSE)
  on.exit(unlink(tmp), add = TRUE)

  ragg::agg_png(tmp, width = 480, height = 480)
  print(p)
  dev.off()

  expect_true(file.exists(tmp))
  expect_gt(file.size(tmp), 0)
})

test_that("line+point plot renders to svglite SVG (T-DEV-01)", {
  skip_if_not_installed("svglite")
  p   <- .dev_test_plot()
  tmp <- tempfile(fileext = ".svg")
  # Normalize path for Windows compatibility
  tmp <- normalizePath(tmp, winslash = "/", mustWork = FALSE)
  on.exit(unlink(tmp), add = TRUE)

  svglite::svglite(tmp, width = 6, height = 6)
  print(p)
  dev.off()

  expect_true(file.exists(tmp))
  expect_gt(file.size(tmp), 0)
})

# --- T-DEV-02: determinism — same grob/seed → identical children --------------

test_that("same seed produces identical grob children (T-DEV-02)", {
  xs <- c(0.1, 0.3, 0.5, 0.7, 0.9)
  ys <- c(0.2, 0.8, 0.4, 0.6, 0.3)

  g1 <- sketch_path_grob(xs, ys, seed = 42L)
  g2 <- sketch_path_grob(xs, ys, seed = 42L)

  # Open a device so unit conversions work (npc → inches)
  tmp <- tempfile(fileext = ".png")
  on.exit({ dev.off(); unlink(tmp) }, add = TRUE)
  png(tmp, width = 4, height = 4, units = "in", res = 72)

  grid::pushViewport(grid::viewport(
    width  = grid::unit(4, "inches"),
    height = grid::unit(4, "inches")
  ))

  r1 <- grid::makeContent(g1)
  r2 <- grid::makeContent(g2)

  grid::popViewport()

  # Compare child names and count
  names1 <- grid::childNames(r1)
  names2 <- grid::childNames(r2)
  expect_equal(length(names1), length(names2))

  # Compare polyline coordinates of each child
  for (i in seq_along(names1)) {
    child1 <- grid::getGrob(r1, names1[i])
    child2 <- grid::getGrob(r2, names2[i])
    expect_identical(child1$x, child2$x)
    expect_identical(child1$y, child2$y)
  }
})
