# T-FILL-roughness: independent stroke vs fill roughness/seed

# Children coordinates of a resolved grob, flattened. Names are dropped because
# grid auto-numbers grob names from a global counter (so they differ between two
# otherwise-identical grobs built at different times).
all_xy <- function(grob) {
  ch <- grid::makeContent(grob)$children
  unname(lapply(ch, function(g) {
    list(x = if (is.null(g$x)) numeric(0) else as.numeric(g$x),
         y = if (is.null(g$y)) numeric(0) else as.numeric(g$y))
  }))
}
nverts <- function(grob) sum(vapply(all_xy(grob), function(p) length(p$x), integer(1)))

base_poly <- function(...) {
  sketch_polygon_grob(
    x = c(0.1, 0.9, 0.9, 0.1), y = c(0.1, 0.1, 0.9, 0.9),
    roughness = 1, seed = 1L, fill_style = "hachure", hachure_gap = 0.08,
    fill_gp = grid::gpar(col = "grey50"), outline_gp = grid::gpar(col = "black"),
    ...
  )
}

test_that("fill_roughness = NULL keeps the historical coupling (roughness * 0.5)", {
  a <- base_poly()                       # NULL -> roughness * 0.5 = 0.5
  b <- base_poly(fill_roughness = 0.5)   # explicit, same value
  expect_identical(all_xy(a), all_xy(b))
})

test_that("fill_roughness controls fill texture independently", {
  clean  <- base_poly(fill_roughness = 0)
  wobbly <- base_poly(fill_roughness = 3)
  # Rougher fill lines carry more vertices than dead-straight ones.
  expect_gt(nverts(wobbly), nverts(clean))
})

test_that("fill_seed moves the fill pattern but not the outline", {
  a <- base_poly()
  c <- base_poly(fill_seed = 99L)
  xa <- all_xy(a); xc <- all_xy(c)
  # Overall they differ (fill repositioned)...
  expect_false(isTRUE(all.equal(xa, xc)))
  # ...but the outline (last n_passes = 2 children) is unchanged.
  expect_identical(tail(xa, 2L), tail(xc, 2L))
})

test_that("ellipse grob honours fill_roughness / fill_seed", {
  e0 <- sketch_ellipse_grob(0.5, 0.5, 0.4, 0.4, roughness = 1, seed = 1L,
                            fill_style = "hachure",
                            fill_gp = grid::gpar(col = "grey50"),
                            outline_gp = grid::gpar(col = "black"),
                            fill_roughness = 0)
  e3 <- sketch_ellipse_grob(0.5, 0.5, 0.4, 0.4, roughness = 1, seed = 1L,
                            fill_style = "hachure",
                            fill_gp = grid::gpar(col = "grey50"),
                            outline_gp = grid::gpar(col = "black"),
                            fill_roughness = 3)
  expect_gt(nverts(e3), nverts(e0))
})

test_that("fill_roughness threads through a geom layer (col)", {
  df <- data.frame(g = c("a", "b", "c"), y = c(3, 5, 2))
  p <- ggplot2::ggplot(df, ggplot2::aes(g, y)) +
    geom_sketch_col(fill = "steelblue", fill_roughness = 0, fill_seed = 7L,
                    seed = 1L)
  tmp <- tempfile(fileext = ".png")
  expect_no_error({
    png(tmp, width = 4, height = 3, units = "in", res = 72); print(p); dev.off()
  })
  unlink(tmp)
})
