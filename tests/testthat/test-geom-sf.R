# geom_sketch_sf() - hand-drawn simple-features maps. sf is a guarded Suggests,
# so every test that needs geometry is skipped when sf is absent. The geometry
# walk helpers (sfg_*) are pure and exercised through small hand-built sfg
# objects; the geom itself is checked for "builds without error".

test_that("geom_sketch_sf errors without a data argument", {
  skip_if_not_installed("sf")
  expect_error(geom_sketch_sf(), class = "rlang_error")
  expect_error(geom_sketch_sf(data = mtcars), class = "rlang_error")
})

test_that("sfg geometry walkers pull the right pieces", {
  skip_if_not_installed("sf")
  poly <- sf::st_polygon(list(
    rbind(c(0, 0), c(4, 0), c(4, 4), c(0, 4), c(0, 0)),
    rbind(c(1, 1), c(1, 3), c(3, 3), c(3, 1), c(1, 1))
  ))
  expect_equal(ggsketch:::sfg_type(poly), "POLYGON")
  expect_length(ggsketch:::sfg_rings(poly), 2L)        # exterior + hole
  expect_length(ggsketch:::sfg_lines(poly), 0L)
  expect_equal(nrow(ggsketch:::sfg_points(poly)), 0L)

  mp <- sf::st_multipolygon(list(
    list(rbind(c(0, 0), c(1, 0), c(1, 1), c(0, 0))),
    list(rbind(c(2, 2), c(3, 2), c(3, 3), c(2, 2)))
  ))
  expect_length(ggsketch:::sfg_rings(mp), 2L)          # one ring per part, flattened

  ls <- sf::st_linestring(rbind(c(0, 0), c(1, 1), c(2, 0)))
  expect_length(ggsketch:::sfg_lines(ls), 1L)
  expect_length(ggsketch:::sfg_rings(ls), 0L)

  mls <- sf::st_multilinestring(list(
    rbind(c(0, 0), c(1, 1)), rbind(c(2, 2), c(3, 3))
  ))
  expect_length(ggsketch:::sfg_lines(mls), 2L)

  pt <- sf::st_point(c(1, 2))
  expect_equal(nrow(ggsketch:::sfg_points(pt)), 1L)
  mpt <- sf::st_multipoint(rbind(c(0, 0), c(1, 1), c(2, 2)))
  expect_equal(nrow(ggsketch:::sfg_points(mpt)), 3L)
})

test_that("bind_pieces tags features, pieces and recycles attributes", {
  pieces <- list(rbind(c(0, 0), c(1, 1)), rbind(c(2, 2), c(3, 3), c(4, 4)))
  ar <- data.frame(name = "A", val = 7)
  df <- ggsketch:::bind_pieces(pieces, feature_id = 2L, piece_offset = 0L, attr_row = ar)
  expect_equal(nrow(df), 5L)
  expect_true(all(df$feature_id == 2L))
  expect_equal(sort(unique(df$piece_id)), c(1L, 2L))
  expect_true(all(df$name == "A"))
  expect_true(all(df$val == 7))
  expect_null(ggsketch:::bind_pieces(list(), 1L, 0L, NULL))
})

test_that("geom_sketch_sf returns a layer list for polygons and builds", {
  skip_if_not_installed("sf")
  nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
  layers <- geom_sketch_sf(data = nc, ggplot2::aes(fill = AREA), seed = 1L)
  expect_type(layers, "list")
  expect_true(all(vapply(layers, ggplot2::is.ggproto, logical(1L)) |
                  vapply(layers, function(l) inherits(l, "LayerInstance"),
                         logical(1L))))
  p <- ggplot2::ggplot() + layers + ggplot2::scale_fill_viridis_c()
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("geom_sketch_sf handles a polygon with a hole", {
  skip_if_not_installed("sf")
  ext  <- rbind(c(0, 0), c(4, 0), c(4, 4), c(0, 4), c(0, 0))
  hole <- rbind(c(1, 1), c(1, 3), c(3, 3), c(3, 1), c(1, 1))
  donut <- sf::st_sf(id = 1, geometry = sf::st_sfc(sf::st_polygon(list(ext, hole))))
  p <- ggplot2::ggplot() + geom_sketch_sf(data = donut, seed = 2L)
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("geom_sketch_sf handles mixed line and point geometry", {
  skip_if_not_installed("sf")
  ls <- sf::st_sf(g = c("a", "b"), geometry = sf::st_sfc(
    sf::st_linestring(rbind(c(0, 0), c(1, 1), c(2, 0))),
    sf::st_linestring(rbind(c(0, 1), c(2, 1)))
  ))
  pt <- sf::st_sf(geometry = sf::st_sfc(
    sf::st_point(c(0, 0)), sf::st_multipoint(rbind(c(1, 1), c(2, 2)))
  ))
  p <- ggplot2::ggplot() +
    geom_sketch_sf(data = ls, ggplot2::aes(colour = g), seed = 3L) +
    geom_sketch_sf(data = pt, seed = 4L)
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("geom_sketch_sf accepts a bare sfc object", {
  skip_if_not_installed("sf")
  sfc <- sf::st_sfc(sf::st_linestring(rbind(c(0, 0), c(1, 1))))
  expect_silent(ggplot2::ggplot_build(
    ggplot2::ggplot() + geom_sketch_sf(data = sfc, seed = 5L)
  ))
})
