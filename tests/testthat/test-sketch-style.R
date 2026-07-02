# T-STYLE: sketch_style() presets bundle paper + palette + defaults.

test_that("sketch_styles lists the presets", {
  s <- sketch_styles()
  expect_true(is.character(s))
  expect_true(all(c("notebook", "chalkboard", "blueprint", "field_notes",
                    "graphite") %in% s))
})

test_that("every style has a complete spec with a valid paper", {
  for (s in sketch_styles()) {
    spec <- ggsketch:::style_spec(s)
    expect_true(all(c("paper", "ink", "palette") %in% names(spec)), info = s)
    expect_true(spec$paper %in% c("none", sketch_papers()), info = s)
    expect_gte(length(spec$palette), 5L)
  }
})

test_that("sketch_style rejects unknown styles and a paper override", {
  expect_error(sketch_style("crayola"), "must be one of")
  expect_error(sketch_style("notebook", paper = "kraft"), "fixed by the style")
})

test_that("sketch_style returns addable components", {
  st <- sketch_style("notebook")
  expect_type(st, "list")
  expect_s3_class(st[[1L]], "theme")
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(mtcars,
                       ggplot2::aes(wt, mpg, colour = factor(cyl))) +
    geom_sketch_point(seed = 1L) +
    st
  expect_no_error(print(p))
})

test_that("palette = FALSE omits the discrete scales", {
  st  <- sketch_style("graphite", palette = FALSE)
  cls <- vapply(st, function(x) class(x)[1L], "")
  expect_false(any(grepl("Scale", cls, ignore.case = TRUE)))
  # A continuous colour mapping then works.
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg, colour = disp)) +
    geom_sketch_point(seed = 1L) +
    st
  expect_no_error(print(p))
})

test_that("palette interpolates past its anchors", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  df <- data.frame(x = 1:12, y = 1:12, g = factor(letters[1:12]))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, colour = g)) +
    geom_sketch_point(seed = 1L) +
    sketch_style("chalkboard")
  expect_no_error(print(p))
})

test_that("every style renders end to end", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  for (s in sketch_styles()) {
    p <- ggplot2::ggplot(mtcars,
                         ggplot2::aes(wt, mpg, colour = factor(cyl))) +
      geom_sketch_point(seed = 1L) +
      sketch_style(s)
    expect_no_error(print(p))
  }
})
