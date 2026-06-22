# Layer 1 - seeded RNG stream (ADR-0004, R5, T-CORE-06)
# All randomised Layer-1 functions call within_seed() rather than bare runif/rnorm.
# The user's global .Random.seed is NEVER mutated.

#' Execute `expr` inside a local, seeded RNG context
#'
#' Uses `withr::with_seed()` so the caller's `.Random.seed` is restored on
#' exit.  Every Layer-1 function that needs randomness must call this.
#'
#' @param seed Integer seed.
#' @param expr Expression to evaluate.
#' @return Value of `expr`.
#' @noRd
within_seed <- function(seed, expr) {
  withr::with_seed(as.integer(seed), expr)
}

#' Resolve a user-facing seed to a concrete integer
#'
#' If `seed` is `NULL` or `NA`, falls back to `getOption("ggsketch.seed", 1L)`.
#'
#' @param seed User-supplied seed (NULL, NA, or integer-ish).
#' @return A single integer.
#' @noRd
resolve_seed <- function(seed) {
  if (is.null(seed) || (length(seed) == 1L && is.na(seed))) {
    seed <- getOption("ggsketch.seed", default = 1L)
  }
  as.integer(seed[[1L]])
}

#' Combine a base seed with an offset for per-pass or per-element RNG streams
#' @noRd
seed_offset <- function(base_seed, offset) {
  # Use double arithmetic to avoid integer overflow before modulo
  as.integer((as.double(base_seed) + as.double(offset)) %% 2147483647)
}
