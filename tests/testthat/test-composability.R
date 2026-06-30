# Composability smoke tests: the 2.0 additions must keep working under facets,
# theme_sketch(), and inside a patchwork composition. These are build-only
# checks (ggplot_build / ggplotGrob) - no visual diffing.

library(ggplot2)

test_that("panel-scale geoms facet without error", {
  builds <- function(p) expect_silent(ggplot2::ggplot_build(p))

  builds(ggplot(mpg, aes(displ, hwy)) +
           geom_sketch_point(seed = 1L) + facet_wrap(~drv))
  builds(ggplot(mpg, aes(class)) +
           geom_sketch_bar(seed = 1L) + facet_wrap(~drv))
  builds(ggplot(mpg, aes(class, hwy)) +
           geom_sketch_violin(seed = 1L) + facet_wrap(~drv))
  builds(ggplot(mtcars, aes(wt, mpg)) +
           geom_sketch_smooth(method = "lm", formula = y ~ x, seed = 1L) +
           facet_wrap(~cyl))
})

test_that("2.0 geoms build under theme_sketch()", {
  builds <- function(p) expect_silent(ggplot2::ggplot_build(p))

  builds(ggplot(economics, aes(date, unemploy)) +
           geom_sketch_line(seed = 1L) + theme_sketch())
  builds(ggplot(mpg, aes(class)) +
           geom_sketch_bar(seed = 1L) + theme_sketch(paper = "notebook"))
})

test_that("constructor-style chart geoms build in their own space", {
  builds <- function(p) expect_silent(ggplot2::ggplot_build(p))

  trade <- data.frame(from = c("A", "A", "B", "C"),
                      to   = c("B", "C", "C", "A"), value = c(5, 3, 2, 4))
  builds(ggplot() + geom_sketch_chord(trade, from, to, value, seed = 1L) +
           scale_fill_sketch() + coord_equal() + theme_void())

  sb <- data.frame(a = c("x", "x", "y", "y"), b = c("p", "q", "p", "q"),
                   n = c(3, 1, 2, 4))
  builds(ggplot() +
           geom_sketch_sunburst(sb, levels = c("a", "b"), value = "n", seed = 1L) +
           scale_fill_sketch() + coord_equal() + theme_void())

  df <- as.data.frame(Titanic)
  builds(ggplot() +
           geom_sketch_alluvial(df, axes = c("Class", "Sex", "Survived"),
                                value = "Freq", seed = 1L) +
           scale_fill_sketch() + theme_void())
})

test_that("sketch plots compose under patchwork", {
  skip_if_not_installed("patchwork")
  p1 <- ggplot(mpg, aes(displ, hwy)) + geom_sketch_point(seed = 1L)
  p2 <- ggplot(mpg, aes(class)) + geom_sketch_bar(seed = 2L) + theme_sketch()
  combined <- patchwork::wrap_plots(p1, p2)
  expect_s3_class(combined, "patchwork")
  expect_silent(grid::grid.force(ggplot2::ggplotGrob(p1)))
  # building the patchwork to a gtable exercises both panels together
  expect_no_error(patchwork::patchworkGrob(combined))
})
