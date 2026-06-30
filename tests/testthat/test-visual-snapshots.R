# Visual regression snapshots for the flagship geoms / features (vdiffr).
# These lock the *look* so a refactor of the roughening, fills, media, arrows or
# repel cannot silently change the rendered output. They render with family = ""
# and fixed seeds for determinism, skip on CRAN/CI (rendering varies by machine)
# and when vdiffr / svglite are unavailable.

skip_if_no_vdiffr <- function() {
  skip_if_not_installed("vdiffr")
  skip_if_not_installed("svglite")
  testthat::skip_on_cran()
  testthat::skip_on_ci()
}

vd <- function(title, fig) {
  skip_if_no_vdiffr()
  vdiffr::expect_doppelganger(title, fig)
}

library(ggplot2)

test_that("core marks look right", {
  vd("points", ggplot(mtcars, aes(wt, mpg)) +
       geom_sketch_point(seed = 1L) + theme_sketch())
  vd("col-hachure", ggplot(mpg, aes(class)) +
       geom_sketch_bar(fill = "#7BAFD4", seed = 1L) + theme_sketch())
  vd("col-watercolor", ggplot(mpg, aes(class)) +
       geom_sketch_bar(fill = "#C0392B", fill_style = "watercolor", seed = 1L) +
       theme_sketch())
})

test_that("new fills look right", {
  base <- ggplot() + coord_equal() + xlim(0, 1) + ylim(0, 1) +
    theme_sketch()
  vd("fill-stipple", base +
       annotate_sketch("rect", xmin = 0, xmax = 1, ymin = 0, ymax = 1,
                       fill = "#34495E", fill_style = "stipple",
                       hachure_gap = 0.06, seed = 1L))
  vd("fill-pencil-shade", base +
       annotate_sketch("rect", xmin = 0, xmax = 1, ymin = 0, ymax = 1,
                       fill = "#34495E", fill_style = "pencil_shade",
                       hachure_gap = 0.06, seed = 2L))
})

test_that("arrows and callouts look right", {
  vd("arrow-barb-double", ggplot() + xlim(0, 1) + ylim(0, 1) + theme_sketch() +
       annotate_sketch_arrow(x = 0.15, y = 0.2, xend = 0.85, yend = 0.8,
                             arrow_head = "barb", ends = "both", seed = 1L))
  vd("callout-elbow", ggplot() + xlim(0, 1) + ylim(0, 1) + theme_sketch() +
       annotate_sketch_callout(x = 0.3, y = 0.8, xend = 0.75, yend = 0.25,
                               label = "here", leader = "elbow",
                               arrow_head = "triangle_filled", seed = 1L))
})

test_that("repel labels look right", {
  df <- head(mtcars, 8); df$name <- rownames(df)
  vd("label-repel", ggplot(df, aes(wt, mpg, label = name)) +
       geom_sketch_point(seed = 1L) +
       geom_sketch_label_repel(family = "", seed = 2L, size = 3) +
       theme_sketch())
})

test_that("paper grounds look right", {
  vd("paper-kraft", ggplot(mpg, aes(class)) +
       geom_sketch_bar(fill = "#7BAFD4", seed = 1L) +
       theme_sketch(paper = "kraft"))
})
