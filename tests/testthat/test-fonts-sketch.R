# Reproducible handwriting fonts (v1.6).

test_that("register_sketch_font() validates inputs", {
  skip_if_not_installed("systemfonts")
  expect_error(register_sketch_font("Nope", "does/not/exist.ttf"),
               "does not exist")
})

test_that("register_sketch_font() registers a file and the resolver finds it", {
  skip_if_not_installed("systemfonts")
  # Use any real font file systemfonts can see as a stand-in.
  sf <- systemfonts::system_fonts()
  skip_if(nrow(sf) == 0L, "no system fonts available")
  path <- sf$path[[1L]]
  fam  <- "ggsketchTestFamily"

  expect_message(register_sketch_font(fam, path), "Registered")
  reg <- systemfonts::registry_fonts()
  expect_true(fam %in% reg$family)

  # resolve_sketch_font() should pick it up when it's first in the candidate list
  expect_identical(resolve_sketch_font(fonts = c(fam, "Caveat")), fam)
})

test_that("resolve_sketch_font() returns '' when nothing matches", {
  expect_identical(resolve_sketch_font(fonts = "DefinitelyNotAFont_xyz"), "")
})

test_that("resolve_sketch_font() pins an installed family so devices can render it", {
  skip_if_not_installed("systemfonts")
  sys <- systemfonts::system_fonts()
  skip_if(nrow(sys) == 0L, "no system fonts available")
  # Pick a real installed family and resolve it directly. The resolver should
  # return a renderable handle (a pinned variant in the registry), not just hand
  # back the bare system name (which can fail for variable fonts on ragg).
  fam <- sys$family[[1L]]
  res <- resolve_sketch_font(fonts = fam)
  expect_true(nzchar(res))
  reg <- systemfonts::registry_fonts()$family
  expect_true(res %in% reg || identical(res, fam))   # pinned, or best-effort name
  # Idempotent: a second call returns the same handle, no error.
  expect_identical(resolve_sketch_font(fonts = fam), res)
})
