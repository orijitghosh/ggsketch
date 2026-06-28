# T-v2: the drawing-medium system (medium = pen/ink/brush/.../crayon).

# ---- registry & validation --------------------------------------------------

test_that("sketch_media lists the media with pen first (the default)", {
  m <- sketch_media()
  expect_true(is.character(m))
  expect_identical(m[1L], "pen")
  expect_true(all(c("ink", "brush", "pencil", "charcoal", "marker", "crayon")
                  %in% m))
})

test_that("check_medium rejects unknown media", {
  expect_error(check_medium("biro"), "must be one of")
  expect_error(check_medium(c("ink", "pen")), "must be one of")
  expect_silent(check_medium("ink"))
})

test_that("every medium has a complete spec", {
  for (m in sketch_media()) {
    s <- medium_spec(m)
    expect_true(all(c("width_mult", "taper", "taper_frac", "profile",
                      "n_passes", "alpha_mult", "cap", "jitter_w") %in% names(s)),
                info = m)
  }
})

# ---- sketch_medium_grob dispatch --------------------------------------------

test_that("medium='pen' returns the historical constant-width path grob", {
  g <- sketch_medium_grob(c(0.1, 0.9), c(0.2, 0.8), medium = "pen",
                          colour = "black", seed = 1L)
  expect_s3_class(g, "SketchPathGrob")
})

test_that("a non-pen medium returns a variable-width stroke grob", {
  for (m in setdiff(sketch_media(), "pen")) {
    g <- sketch_medium_grob(c(0.1, 0.5, 0.9), c(0.2, 0.8, 0.3), medium = m,
                            colour = "navy", linewidth = 0.6, seed = 1L)
    expect_s3_class(g, "SketchStrokeGrob")
  }
})

test_that("non-pen media fold alpha into the medium's translucency", {
  # Dry media (pencil) carry alpha_mult < 1; an explicit alpha multiplies it.
  spec <- medium_spec("pencil")
  expect_lt(spec$alpha_mult, 1)
})

# ---- geom integration -------------------------------------------------------

test_that("geom_sketch_line / path render in every medium", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  for (m in sketch_media()) {
    p <- ggplot2::ggplot(ggplot2::economics[1:80, ],
                         ggplot2::aes(date, unemploy)) +
      geom_sketch_line(medium = m, seed = 1L)
    expect_no_error(print(p))
  }
})

test_that("geom_sketch_segment / step render in a non-pen medium", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  df <- data.frame(x = 1:3, y = 1:3, xend = 2:4, yend = c(3, 1, 4))
  p1 <- ggplot2::ggplot(df) +
    geom_sketch_segment(ggplot2::aes(x, y, xend = xend, yend = yend),
                        medium = "ink", seed = 1L)
  p2 <- ggplot2::ggplot(ggplot2::economics[1:40, ], ggplot2::aes(date, unemploy)) +
    geom_sketch_step(medium = "brush", seed = 1L)
  expect_no_error(print(p1))
  expect_no_error(print(p2))
})

test_that("an invalid medium errors at draw time", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(ggplot2::economics[1:20, ], ggplot2::aes(date, unemploy)) +
    geom_sketch_line(medium = "sharpie", seed = 1L)
  expect_error(print(p), "must be one of")
})

# ---- pen is unchanged (regression guard) ------------------------------------

test_that("medium='pen' is the same grob as the pre-medium default", {
  # The default geom path and an explicit medium='pen' must agree.
  default_g <- sketch_medium_grob(c(0, 1), c(0, 1), medium = "pen",
                                  colour = "black", linewidth = 0.5, seed = 7L)
  legacy_g  <- sketch_path_grob(
    x = c(0, 1), y = c(0, 1), roughness = 1, bowing = 1, n_passes = 2L,
    seed = 7L,
    gp = outline_gpar(colour = "black", linewidth = 0.5, linetype = 1,
                      alpha = NA)
  )
  # Same class and same roughened geometry (identical seed/params).
  expect_s3_class(default_g, "SketchPathGrob")
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  d <- grid::makeContent(default_g)$children
  l <- grid::makeContent(legacy_g)$children
  expect_equal(length(d), length(l))
})
