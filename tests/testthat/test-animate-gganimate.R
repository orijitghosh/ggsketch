# Tier D motion: gganimate bridge (boil_gganimate). gganimate is an optional
# Suggests, so every test that needs it skips when it is not installed.

make_anim <- function() {
  ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(class, fill = drv)) +
    geom_sketch_bar(position = "dodge", seed = 1L) +
    gganimate::transition_states(drv, transition_length = 2, state_length = 1)
}

test_that("boil_gganimate rejects a non-gganim plot", {
  p <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(class)) + geom_sketch_bar()
  expect_error(boil_gganimate(p), "gganimate animation")
})

test_that("boil_gganimate returns one frame path per frame and boils them", {
  skip_if_not_installed("gganimate")
  skip_if_not_installed("ragg")
  fp <- boil_gganimate(make_anim(), nframes = 3L, renderer = "none",
                       width = 3, height = 2, res = 70)
  expect_length(fp, 3L)
  expect_true(all(file.exists(fp)))
  # boiling re-seeds each frame, so the rendered bytes differ frame to frame.
  sizes <- file.info(fp)$size
  expect_gt(length(unique(sizes)), 1L)
})

test_that("boil_gganimate restores the seed-jitter option afterwards", {
  skip_if_not_installed("gganimate")
  skip_if_not_installed("ragg")
  withr::local_options(ggsketch.seed_jitter = 12345L)
  invisible(boil_gganimate(make_anim(), nframes = 2L, renderer = "none",
                           width = 2, height = 2, res = 60))
  expect_identical(getOption("ggsketch.seed_jitter"), 12345L)
})

test_that("nframes is clamped to a sane minimum", {
  skip_if_not_installed("gganimate")
  skip_if_not_installed("ragg")
  fp <- boil_gganimate(make_anim(), nframes = 1L, renderer = "none",
                       width = 2, height = 2, res = 60)
  expect_length(fp, 2L)               # bumped to 2
})
