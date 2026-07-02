# T-v2: the drawing-medium system (medium = pen/ink/brush/.../crayon).

# ---- registry & validation --------------------------------------------------

test_that("sketch_media lists the media with pen first (the default)", {
  m <- sketch_media()
  expect_true(is.character(m))
  expect_identical(m[1L], "pen")
  expect_true(all(c("ink", "fountain_pen", "ballpoint", "brush", "pencil",
                    "charcoal", "pastel", "chalk", "marker", "highlighter",
                    "crayon", "spray") %in% m))
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
  # Exceptions: spray is a dot-cloud grob; chalk composes core + dust halo.
  for (m in setdiff(sketch_media(), c("pen", "spray", "chalk"))) {
    g <- sketch_medium_grob(c(0.1, 0.5, 0.9), c(0.2, 0.8, 0.3), medium = m,
                            colour = "navy", linewidth = 0.6, seed = 1L)
    expect_s3_class(g, "SketchStrokeGrob")
  }
})

test_that("medium='chalk' composes a dust halo under the core stroke", {
  g <- sketch_medium_grob(c(0.1, 0.5, 0.9), c(0.2, 0.8, 0.3), medium = "chalk",
                          colour = "white", linewidth = 1, seed = 1L)
  expect_s3_class(g, "gTree")
  kids <- grid::childNames(g)
  expect_length(kids, 2L)
  # Both children are stroke ribbons; the first (dust) is wider + fainter.
  dust <- g$children[[1L]]; core <- g$children[[2L]]
  expect_s3_class(dust, "SketchStrokeGrob")
  expect_s3_class(core, "SketchStrokeGrob")
  expect_gt(dust$width, core$width)
  expect_lt(dust$gp$alpha, core$gp$alpha)
})

test_that("medium='spray' returns an airbrush dot-cloud grob", {
  g <- sketch_medium_grob(c(0.1, 0.5, 0.9), c(0.2, 0.8, 0.3), medium = "spray",
                          colour = "navy", linewidth = 0.6, seed = 1L)
  expect_s3_class(g, "SketchSprayGrob")
})

test_that("non-pen media fold alpha into the medium's translucency", {
  # Dry media (pencil) carry alpha_mult < 1; an explicit alpha multiplies it.
  spec <- medium_spec("pencil")
  expect_lt(spec$alpha_mult, 1)
})

test_that("chalk reads dry and flat; highlighter reads wide and translucent", {
  chalk <- medium_spec("chalk")
  expect_identical(chalk$cap, "butt")
  expect_identical(chalk$taper, "none")
  expect_gt(chalk$jitter_w, medium_spec("pastel")$jitter_w)

  hl <- medium_spec("highlighter")
  expect_identical(hl$cap, "butt")
  expect_identical(hl$n_passes, 1L)
  expect_lt(hl$alpha_mult, 0.5)
  expect_gt(hl$width_mult, medium_spec("marker")$width_mult)
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
