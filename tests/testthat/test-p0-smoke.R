# P0-T3 smoke tests: skeleton builds, GeomSketchNull returns nullGrob

test_that("geom_sketch_null() produces a valid layer", {
  p <- ggplot2::ggplot(data.frame(x = 1), ggplot2::aes(x = x)) +
    geom_sketch_null()
  expect_s3_class(p, "ggplot")
  # Building the plot should not error
  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
})

test_that("geom_sketch_null() draw_panel returns nullGrob", {
  grob <- GeomSketchNull$draw_panel(
    data = data.frame(),
    panel_params = list(),
    coord = ggplot2::coord_cartesian()
  )
  expect_s3_class(grob, "grob")
  expect_true(inherits(grob, "null"))
})

test_that("ggsketch package loads without errors", {
  expect_true("ggsketch" %in% loadedNamespaces())
})
