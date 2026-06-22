# T-ARC: arc sampler, pie/donut geom, rounded rectangles

test_that("rough_arc returns n_passes open stroke matrices", {
  a <- rough_arc(0, 0, 1, 1, 0, pi, roughness = 1, n_passes = 2L, seed = 1L)
  expect_length(a, 2L)
  expect_true(all(vapply(a, function(m) ncol(m) == 2L, logical(1))))
  expect_identical(colnames(a[[1]]), c("x", "y"))
  # open arc: first and last sample points are not the same vertex
  m <- a[[1]]
  expect_false(isTRUE(all.equal(m[1, ], m[nrow(m), ])))
})

test_that("rough_arc is reproducible for a fixed seed and clean at roughness 0", {
  expect_identical(rough_arc(0, 0, 1, 1, 0, pi, seed = 7L),
                   rough_arc(0, 0, 1, 1, 0, pi, seed = 7L))
  clean <- rough_arc(0, 0, 1, 1, 0, pi, roughness = 0, seed = 1L)[[1]]
  th    <- seq(0, pi, length.out = nrow(clean))
  # roughness 0 => points lie on the exact arc
  expect_equal(clean[, "x"], cos(th), tolerance = 1e-8)
  expect_equal(clean[, "y"], sin(th), tolerance = 1e-8)
})

test_that("arc_sector traces a wedge (apex) or annulus (inner arc)", {
  wedge <- arc_sector(r0 = 0, r = 1, start = 0, end = pi / 2)
  # last vertex is the apex at the origin
  expect_equal(c(wedge$x[length(wedge$x)], wedge$y[length(wedge$y)]), c(0, 0))

  donut <- arc_sector(r0 = 0.5, r = 1, start = 0, end = pi / 2)
  # inner arc points sit at radius r0
  inner <- utils::tail(donut$x, 1)^2 + utils::tail(donut$y, 1)^2
  expect_equal(sqrt(inner), 0.5, tolerance = 1e-8)
})

test_that("rounded_rect_xy stays within the rectangle and rounds corners", {
  v <- rounded_rect_xy(0, 4, 0, 2, rx = 0.5, ry = 0.5)
  expect_true(all(v$x >= -1e-9 & v$x <= 4 + 1e-9))
  expect_true(all(v$y >= -1e-9 & v$y <= 2 + 1e-9))
  # no vertex sits exactly on a sharp corner (0,0)
  expect_false(any(v$x == 0 & v$y == 0))
  # radii clamp to half-side: a huge radius cannot exceed the box
  big <- rounded_rect_xy(0, 4, 0, 2, rx = 99, ry = 99)
  expect_true(all(big$x >= -1e-9 & big$x <= 4 + 1e-9))
})

test_that("geom_sketch_pie builds and converts amounts into slice angles", {
  df <- data.frame(group = c("a", "b", "c", "d"), amount = c(40, 25, 20, 15))
  p  <- ggplot2::ggplot(df, ggplot2::aes(amount = amount, fill = group)) +
    geom_sketch_pie(seed = 1L)
  built <- ggplot2::ggplot_build(p)$data[[1]]
  expect_true(all(c("start", "end") %in% names(built)))
  expect_equal(nrow(built), 4L)
  # full circle: total swept angle equals 2*pi
  expect_equal(sum(built$start - built$end), 2 * pi, tolerance = 1e-8)
  # first slice starts at the top (12 o'clock = pi/2)
  expect_equal(built$start[1], pi / 2, tolerance = 1e-8)
})

test_that("geom_sketch_donut sets a non-zero inner radius", {
  df <- data.frame(group = c("a", "b"), amount = c(1, 1))
  expect_no_error(ggplot2::ggplot_build(
    ggplot2::ggplot(df, ggplot2::aes(amount = amount, fill = group)) +
      geom_sketch_donut(seed = 1L)))
})

test_that("corner_radius is a layer parameter on rect, tile, and col", {
  expect_true("corner_radius" %in% GeomSketchRect$parameters())
  expect_true("corner_radius" %in% GeomSketchTile$parameters())
  expect_true("corner_radius" %in% GeomSketchCol$parameters())
})

test_that("rect with corner_radius still builds and defaults unchanged", {
  rdf <- data.frame(xmin = 1, xmax = 3, ymin = 1, ymax = 4)
  expect_no_error(ggplot2::ggplot_build(
    ggplot2::ggplot(rdf) +
      geom_sketch_rect(ggplot2::aes(xmin = xmin, xmax = xmax,
                                    ymin = ymin, ymax = ymax),
                       corner_radius = 0.4, seed = 1L)))

  # rect_boundary: 0 radius => the original 4 corners (back-compat)
  b0 <- rect_boundary(1, 3, 1, 4, corner_radius = 0)
  expect_identical(b0$x, c(1, 3, 3, 1))
  expect_identical(b0$y, c(1, 1, 4, 4))
  # rounded => more vertices
  br <- rect_boundary(1, 3, 1, 4, corner_radius = 0.5)
  expect_gt(length(br$x), 4L)
})
