# Image-snapshot (vdiffr) regression gate — SECONDARY to geometry snapshots
# (ADR-0009 / R8). Fixed seed 42 via expect_doppelganger_sketch().
#
# NOTE: vdiffr SVG baselines are platform-sensitive; per TESTING.md the Linux CI
# is the snapshot source of truth. vdiffr skips (does not fail) when the toolchain
# differs, so these are safe to keep cross-platform. T-LOOK-01 (AC-1) human
# sign-off vs tools/reference-imagery/ is tracked separately in the ledger.

skip_if_not_installed("vdiffr")

bars3 <- data.frame(x = c("A", "B", "C"), y = c(3, 5, 2))

test_that("geom_sketch_line looks right", {
  p <- ggplot2::ggplot(data.frame(x = 1:10, y = sin(1:10)),
                       ggplot2::aes(x, y)) +
    geom_sketch_line(seed = 1L) + theme_sketch()
  expect_doppelganger_sketch("line", p)
})

test_that("geom_sketch_point looks right", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) + theme_sketch()
  expect_doppelganger_sketch("point", p)
})

# T-LOOK-01 / AC-1: every fill style on a bar.
for (style in c("hachure", "cross_hatch", "zigzag", "zigzag_line",
                "dots", "dashed", "solid")) {
  local({
    s <- style
    test_that(paste0("geom_sketch_col fill style: ", s), {
      p <- ggplot2::ggplot(bars3, ggplot2::aes(x, y)) +
        geom_sketch_col(fill = "#7BAFD4", fill_style = s, seed = 1L) +
        theme_sketch()
      expect_doppelganger_sketch(paste0("col-", s), p)
    })
  })
}

test_that("geom_sketch_polygon concave star looks right", {
  ang  <- seq(0, 2 * pi, length.out = 11)[-11]
  r    <- rep(c(1, 0.45), length.out = 10)
  star <- data.frame(x = r * cos(ang), y = r * sin(ang))
  p <- ggplot2::ggplot(star, ggplot2::aes(x, y)) +
    geom_sketch_polygon(fill = "tomato", seed = 1L) +
    ggplot2::coord_equal() + theme_sketch()
  expect_doppelganger_sketch("polygon-star", p)
})

test_that("geom_sketch_boxplot looks right", {
  p <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(class, hwy)) +
    geom_sketch_boxplot(seed = 1L) + theme_sketch() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 30, hjust = 1))
  expect_doppelganger_sketch("boxplot", p)
})

test_that("dark theme preset looks right", {
  p <- ggplot2::ggplot(bars3, ggplot2::aes(x, y)) +
    geom_sketch_col(fill = "#7BAFD4", seed = 1L) + theme_sketch(dark = TRUE)
  expect_doppelganger_sketch("col-dark", p)
})
