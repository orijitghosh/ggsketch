# T-v2: paper / canvas system (paper_spec / paper_primitives /
# element_sketch_paper / theme_sketch(paper=)).

# ---- registry & spec --------------------------------------------------------

test_that("sketch_papers lists the grounds with none first", {
  p <- sketch_papers()
  expect_identical(p[1L], "none")
  expect_true(all(c("notebook", "graph", "dotted", "aged",
                    "blueprint", "chalkboard", "kraft") %in% p))
})

test_that("check_paper rejects unknown grounds", {
  expect_error(check_paper("vellum"), "must be one of")
  expect_silent(check_paper("kraft"))
})

test_that("paper_spec is NULL for none and carries a ground otherwise", {
  expect_null(paper_spec("none"))
  for (k in setdiff(sketch_papers(), "none")) {
    s <- paper_spec(k)
    expect_true(!is.null(s$ground), info = k)
    expect_true(is.logical(s$dark_ground), info = k)
  }
  expect_true(paper_spec("blueprint")$dark_ground)
  expect_false(paper_spec("notebook")$dark_ground)
})

# ---- ruling_positions -------------------------------------------------------

test_that("ruling_positions spaces lines by physical inches inside (0,1)", {
  pos <- ruling_positions(span_in = 4, spacing_in = 1)
  expect_equal(pos, c(0.25, 0.5, 0.75))           # 3 interior lines
  expect_length(ruling_positions(0, 1), 0L)
  expect_length(ruling_positions(4, 0), 0L)
})

# ---- paper_primitives -------------------------------------------------------

test_that("paper_primitives returns the right primitives per kind", {
  expect_null(paper_primitives("none"))

  nb <- paper_primitives("notebook", 6, 4, seed = 1L)
  expect_true(length(nb$segs) >= 2L)              # ruling + margin
  expect_equal(nb$ground, paper_spec("notebook")$ground)

  gr <- paper_primitives("graph", 6, 4, seed = 1L)
  expect_true(length(gr$segs) >= 2L)              # minor + major groups

  dt <- paper_primitives("dotted", 6, 4, seed = 1L)
  expect_true(!is.null(dt$dots))
  expect_true(length(dt$dots$x) > 0L)

  ag <- paper_primitives("aged", 6, 4, seed = 1L)
  expect_length(ag$blotches, paper_spec("aged")$aged$blotches)
})

test_that("paper_primitives is reproducible and leaves .Random.seed alone", {
  set.seed(3L); before <- .Random.seed
  a <- paper_primitives("aged", 6, 4, seed = 9L)
  b <- paper_primitives("aged", 6, 4, seed = 9L)
  expect_identical(a, b)
  expect_identical(.Random.seed, before)
})

# ---- element_sketch_paper ---------------------------------------------------

test_that("element_sketch_paper builds an element and draws a grob tree", {
  el <- element_sketch_paper("graph", seed = 1L)
  expect_s3_class(el, "element_sketch_paper")

  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  grid::pushViewport(grid::viewport(width = grid::unit(5, "in"),
                                    height = grid::unit(4, "in")))
  g <- ggplot2::element_grob(el)
  expect_true(length(grid::childNames(g)) > 0L)
  grid::popViewport()
})

# ---- theme_sketch(paper=) ---------------------------------------------------

test_that("theme_sketch(paper='none') keeps a plain panel background", {
  th <- theme_sketch()
  expect_false(inherits(th$panel.background, "element_sketch_paper"))
})

test_that("theme_sketch(paper=) installs the paper element and renders", {
  grDevices::pdf(NULL); on.exit(grDevices::dev.off())
  for (k in setdiff(sketch_papers(), "none")) {
    th <- theme_sketch(paper = k)
    expect_s3_class(th$panel.background, "element_sketch_paper")
    p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
      geom_sketch_point(seed = 1L) +
      th
    expect_no_error(print(p))
  }
})

test_that("a dark-ground paper flips text colour light", {
  th <- theme_sketch(paper = "blueprint")
  expect_identical(th$axis.title$colour, paper_spec("blueprint")$ink)
})
