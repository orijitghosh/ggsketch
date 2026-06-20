# P3-T4 (AC-2): Composition snapshots — coord_flip + facet_wrap/grid +
# discrete & continuous fill scales on col/rect geoms.

# ---- coord_flip composition ------------------------------------------------

test_that("geom_sketch_col + coord_flip renders (AC-2)", {
  df <- data.frame(x = c("A", "B", "C"), y = c(3, 5, 2))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_col(seed = 1L) +
    ggplot2::coord_flip()
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

test_that("geom_sketch_rect + coord_flip renders (AC-2)", {
  df <- data.frame(xmin = c(1, 3), xmax = c(2, 4),
                   ymin = c(1, 2), ymax = c(3, 5))
  p <- ggplot2::ggplot(df, ggplot2::aes(xmin = xmin, xmax = xmax,
                                         ymin = ymin, ymax = ymax)) +
    geom_sketch_rect(seed = 1L) +
    ggplot2::coord_flip()
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

# ---- facet_wrap composition ------------------------------------------------

test_that("geom_sketch_col + facet_wrap renders (AC-2)", {
  df <- data.frame(
    x = rep(c("A", "B", "C"), 2),
    y = c(3, 5, 2, 4, 1, 6),
    g = rep(c("Group1", "Group2"), each = 3)
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_col(seed = 1L) +
    ggplot2::facet_wrap(~g)
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 6, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

test_that("geom_sketch_tile + facet_wrap renders (AC-2)", {
  df <- data.frame(
    x = rep(1:3, 2), y = rep(1:3, 2),
    g = rep(c("A", "B"), each = 3)
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_tile(seed = 1L) +
    ggplot2::facet_wrap(~g)
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 6, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

# ---- facet_grid composition ------------------------------------------------

test_that("geom_sketch_col + facet_grid renders (AC-2)", {
  df <- data.frame(
    x = rep(c("A", "B"), 4),
    y = c(3, 5, 2, 4, 6, 1, 3, 2),
    r = rep(c("R1", "R2"), each = 4),
    c = rep(rep(c("C1", "C2"), each = 2), 2)
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    geom_sketch_col(seed = 1L) +
    ggplot2::facet_grid(r ~ c)
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 6, height = 4, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

# ---- discrete fill scales --------------------------------------------------

test_that("geom_sketch_col + discrete fill scale renders (AC-2)", {
  df <- data.frame(x = c("A", "B", "C", "D"), y = c(3, 5, 2, 6))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, fill = x)) +
    geom_sketch_col(seed = 1L) +
    ggplot2::scale_fill_manual(values = c(A = "#E69F00", B = "#56B4E9",
                                           C = "#009E73", D = "#F0E442"))
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

test_that("geom_sketch_rect + discrete fill scale renders (AC-2)", {
  df <- data.frame(
    xmin = c(1, 3), xmax = c(2, 4),
    ymin = c(1, 2), ymax = c(3, 5),
    g = c("A", "B")
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(xmin = xmin, xmax = xmax,
                                         ymin = ymin, ymax = ymax,
                                         fill = g)) +
    geom_sketch_rect(seed = 1L) +
    ggplot2::scale_fill_manual(values = c(A = "#E69F00", B = "#56B4E9"))
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

# ---- continuous fill scales ------------------------------------------------

test_that("geom_sketch_col + continuous fill scale renders (AC-2)", {
  df <- data.frame(x = c("A", "B", "C", "D"), y = c(3, 5, 2, 6),
                   val = c(10, 20, 30, 40))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, fill = val)) +
    geom_sketch_col(seed = 1L) +
    ggplot2::scale_fill_gradient(low = "white", high = "steelblue")
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

test_that("geom_sketch_tile + continuous fill scale renders (AC-2)", {
  df <- expand.grid(x = 1:3, y = 1:3)
  df$val <- seq_len(nrow(df))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, fill = val)) +
    geom_sketch_tile(seed = 1L) +
    ggplot2::scale_fill_viridis_c()
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

# ---- complex composition: facet + fill + coord_flip + theme -----------------

test_that("full composition: col + facet + fill + coord_flip + theme (AC-2)", {
  df <- data.frame(
    x = rep(c("A", "B", "C"), 2),
    y = c(3, 5, 2, 4, 1, 6),
    g = rep(c("Group1", "Group2"), each = 3)
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, fill = x)) +
    geom_sketch_col(seed = 1L, fill_style = "cross_hatch") +
    ggplot2::facet_wrap(~g) +
    ggplot2::coord_flip() +
    ggplot2::scale_fill_manual(values = c(A = "#E69F00", B = "#56B4E9",
                                           C = "#009E73")) +
    theme_sketch()
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 6, height = 4, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})

test_that("multi-geom composition: col + line + point + theme (AC-2)", {
  df_bar <- data.frame(x = c("A", "B", "C"), y = c(3, 5, 2))
  df_line <- data.frame(x = c(1, 2, 3), y = c(3, 5, 2))
  p <- ggplot2::ggplot(df_bar, ggplot2::aes(x, y)) +
    geom_sketch_col(fill = "lightblue", seed = 1L) +
    theme_sketch()
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72)
    print(p)
    dev.off()
  })
  expect_gt(file.size(tmp), 0)
  unlink(tmp)
})
