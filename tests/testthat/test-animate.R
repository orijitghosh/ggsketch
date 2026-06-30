# animate_sketch() - "boil" a sketch plot by shifting every roughening seed per
# frame. The shift rides on the ggsketch.seed_jitter option, applied in
# resolve_seed().

test_that("resolve_seed adds the jitter option, default unchanged", {
  withr::local_options(ggsketch.seed_jitter = 0L)
  expect_equal(ggsketch:::resolve_seed(5L), 5L)        # 0 jitter = no change
  withr::local_options(ggsketch.seed_jitter = 100L)
  expect_equal(ggsketch:::resolve_seed(5L), ggsketch:::seed_offset(5L, 100L))
  # works for inherited (NULL) seeds too
  withr::local_options(ggsketch.seed = 1L)
  expect_equal(ggsketch:::resolve_seed(NULL), ggsketch:::seed_offset(1L, 100L))
})

test_that("a missing/invalid jitter option is ignored", {
  withr::local_options(ggsketch.seed_jitter = NULL)
  expect_equal(ggsketch:::resolve_seed(7L), 7L)
  withr::local_options(ggsketch.seed_jitter = NA_integer_)
  expect_equal(ggsketch:::resolve_seed(7L), 7L)
})

test_that("animate_sketch rejects a non-ggplot", {
  expect_error(animate_sketch(1:10), "ggplot")
})

test_that("animate_sketch returns one frame path per frame", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L)
  frames <- animate_sketch(p, nframes = 3, renderer = "none",
                           width = 3, height = 2, res = 72)
  expect_length(frames, 3L)
  expect_true(all(file.exists(frames)))
  unlink(dirname(frames[1]), recursive = TRUE)
})

test_that("boil frames differ but frame 1 is the static render", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L)
  frames <- animate_sketch(p, nframes = 4, renderer = "none",
                           width = 3, height = 2, res = 72)
  md5 <- tools::md5sum(frames)
  expect_equal(length(unique(md5)), 4L)   # every frame distinct
  unlink(dirname(frames[1]), recursive = TRUE)
})

test_that("animate_sketch restores the jitter option afterwards", {
  withr::local_options(ggsketch.seed_jitter = 42L)
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L)
  frames <- animate_sketch(p, nframes = 2, renderer = "none",
                           width = 3, height = 2, res = 72)
  expect_equal(getOption("ggsketch.seed_jitter"), 42L)
  unlink(dirname(frames[1]), recursive = TRUE)
})

test_that("draw_on returns one frame per frame, each revealing more", {
  p <- ggplot2::ggplot(ggplot2::economics, ggplot2::aes(date, unemploy)) +
    geom_sketch_line(seed = 1L)
  frames <- animate_sketch(p, type = "draw_on", nframes = 4, renderer = "none",
                           width = 3, height = 2, res = 72)
  expect_length(frames, 4L)
  expect_true(all(file.exists(frames)))
  expect_equal(length(unique(tools::md5sum(frames))), 4L)  # progressive reveal
  unlink(dirname(frames[1]), recursive = TRUE)
})

test_that("draw_on accepts every reveal direction", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L)
  for (d in c("lr", "rl", "bt", "tb", "diag", "radial")) {
    frames <- animate_sketch(p, type = "draw_on", direction = d, nframes = 3,
                             renderer = "none", width = 3, height = 2, res = 72)
    expect_length(frames, 3L)
    # The reveal progresses, so frames differ.
    expect_equal(length(unique(tools::md5sum(frames))), 3L)
    unlink(dirname(frames[1]), recursive = TRUE)
  }
})

test_that("draw_on accepts every easing curve", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L)
  for (e in c("linear", "ease_in", "ease_out", "ease_in_out")) {
    frames <- animate_sketch(p, type = "draw_on", easing = e, nframes = 3,
                             renderer = "none", width = 3, height = 2, res = 72)
    expect_length(frames, 3L)
    unlink(dirname(frames[1]), recursive = TRUE)
  }
})

test_that("ease_fraction is monotone, pinned at the ends, and ordered", {
  for (e in c("linear", "ease_in", "ease_out", "ease_in_out")) {
    v <- ggsketch:::ease_fraction(seq(0, 1, length.out = 11), e)
    expect_equal(v[1], 0)
    expect_equal(v[length(v)], 1)
    expect_true(all(diff(v) >= -1e-9))            # non-decreasing
    expect_true(all(v >= -1e-9 & v <= 1 + 1e-9))  # stays in [0, 1]
  }
  # Clamps out-of-range input.
  expect_equal(ggsketch:::ease_fraction(c(-1, 2), "linear"), c(0, 1))
  # ease_in starts slower than linear; ease_out faster.
  expect_lt(ggsketch:::ease_fraction(0.25, "ease_in"), 0.25)
  expect_gt(ggsketch:::ease_fraction(0.25, "ease_out"), 0.25)
})

test_that("clip_halfplane keeps the correct side of the line", {
  sq <- matrix(c(0, 0, 1, 0, 1, 1, 0, 1), ncol = 2L, byrow = TRUE)
  # Keep x <= 0.5: a vertical half of the unit square (area 0.5).
  half <- ggsketch:::clip_halfplane(sq, a = 1, b = 0, c = 0.5)
  expect_true(all(half[, 1L] <= 0.5 + 1e-9))
  expect_gte(nrow(half), 3L)
  # A line entirely outside (keep x <= -1) clips to nothing.
  expect_equal(nrow(ggsketch:::clip_halfplane(sq, 1, 0, -1)), 0L)
})

test_that("grob_canvas falls back when no background fill is found", {
  expect_equal(ggsketch:::grob_canvas(list(), "white"), "white")
})

test_that("writing a GIF works when a renderer is present", {
  skip_if_not(requireNamespace("gifski", quietly = TRUE) ||
              requireNamespace("magick", quietly = TRUE))
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L)
  gif <- tempfile(fileext = ".gif")
  out <- animate_sketch(p, nframes = 3, fps = 10, file = gif,
                        width = 3, height = 2, res = 72)
  expect_true(file.exists(gif))
  expect_gt(file.info(gif)$size, 0)
  unlink(gif)
})
