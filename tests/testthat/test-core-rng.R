# T-CORE-06, T-CORE-07: RNG hygiene and determinism

test_that("within_seed() restores global .Random.seed (T-CORE-06)", {
  set.seed(99L)
  seed_before <- .Random.seed

  within_seed(42L, {
    runif(100)
  })

  seed_after <- .Random.seed
  expect_identical(seed_before, seed_after)
})

test_that("within_seed() is deterministic for same seed (T-CORE-07)", {
  r1 <- within_seed(123L, runif(10))
  r2 <- within_seed(123L, runif(10))
  expect_identical(r1, r2)
})

test_that("within_seed() differs for different seeds", {
  r1 <- within_seed(1L, runif(10))
  r2 <- within_seed(2L, runif(10))
  expect_false(identical(r1, r2))
})

test_that("resolve_seed() returns integer", {
  expect_type(resolve_seed(42),   "integer")
  expect_type(resolve_seed(42L),  "integer")
  expect_type(resolve_seed(NULL), "integer")
  expect_type(resolve_seed(NA),   "integer")
})

test_that("resolve_seed() falls back to option", {
  withr::with_options(list(ggsketch.seed = 999L), {
    expect_equal(resolve_seed(NULL), 999L)
  })
})

test_that("seed_offset() stays within safe integer range", {
  s <- seed_offset(2147483640L, 100L)
  expect_true(s >= 0L && s <= 2147483647L)
})
