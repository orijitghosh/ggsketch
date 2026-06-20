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
