# theme_sketch tests (P2-T5, P6-T1) + font fallback (P6-T2 / T-DEV-03)

png_render <- function(p) {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  png(tmp, width = 4, height = 4, units = "in", res = 72)
  print(p)
  dev.off()
  file.size(tmp)
}

test_that("theme_sketch() returns a complete theme", {
  th <- theme_sketch()
  expect_s3_class(th, "theme")
  expect_true(attr(th, "complete"))
})

test_that("light and dark presets differ in panel background", {
  light <- theme_sketch(dark = FALSE)
  dark  <- theme_sketch(dark = TRUE)
  expect_false(identical(light$panel.background$fill,
                         dark$panel.background$fill))
})

test_that("dark preset renders without error", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    geom_sketch_point(seed = 1L) + theme_sketch(dark = TRUE)
  expect_gt(png_render(p), 0)
})

test_that("base_family = 'auto' resolves to a string without error", {
  th <- theme_sketch(base_family = "auto")
  expect_s3_class(th, "theme")
})

test_that("resolve_sketch_font never errors and returns one string", {
  f <- resolve_sketch_font()
  expect_type(f, "character")
  expect_length(f, 1L)
})

test_that("ggsketch_check_fonts() is silent-safe and returns logical (T-DEV-03)", {
  res <- suppressMessages(ggsketch_check_fonts())
  expect_type(res, "logical")
  expect_named(res)
})

# ---- rough_frame roughens facet strips --------------------------------------

test_that("rough_frame gives facet strips a sketch background", {
  t <- theme_sketch(rough_frame = TRUE, seed = 1L)
  expect_s3_class(t$strip.background, "element_sketch_rect")
  # plain theme keeps the ordinary strip background
  expect_false(inherits(theme_sketch()$strip.background, "element_sketch_rect"))
})

test_that("a faceted plot renders with rough_frame strips", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(displ, hwy)) +
    geom_sketch_point(seed = 1L) +
    ggplot2::facet_wrap(~drv) +
    theme_sketch(rough_frame = TRUE, seed = 2L)
  expect_no_error(print(p))
})

# ---- rough_frame roughens the colourbar -------------------------------------

test_that("rough_frame roughens the colourbar frame and ticks", {
  t <- theme_sketch(rough_frame = TRUE, seed = 1L)
  expect_s3_class(t$legend.frame, "element_sketch_rect")
  expect_s3_class(t$legend.ticks, "element_sketch_line")
})

test_that("a continuous-fill plot renders with rough_frame colourbar", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  p <- ggplot2::ggplot(ggplot2::faithfuld,
                       ggplot2::aes(waiting, eruptions, fill = density)) +
    ggplot2::geom_raster() +
    theme_sketch(rough_frame = TRUE, seed = 1L)
  expect_no_error(print(p))
})
