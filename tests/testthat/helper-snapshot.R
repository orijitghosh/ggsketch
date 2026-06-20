# Geometry snapshot helpers (T-ARCH-01, ADR-0009)
# Primary regression gate: deterministic Layer-1 numeric output.
# Uses testthat snapshot infrastructure with a canonical serialisation.

#' Serialise Layer-1 geometry output for snapshot comparison
#'
#' Converts a list of matrices (x/y columns) to a stable string: each segment
#' is rendered as "x,y" lines, rounded to 6 significant figures.
#'
#' @param geom_output List of 2-column matrices with columns `x` and `y`.
#' @return Single character string for `testthat::expect_snapshot()`.
#' @noRd
serialise_geometry <- function(geom_output) {
  stopifnot(is.list(geom_output))
  parts <- lapply(seq_along(geom_output), function(i) {
    seg <- geom_output[[i]]
    if (is.data.frame(seg)) seg <- as.matrix(seg[, c("x", "y")])
    stopifnot(is.matrix(seg), ncol(seg) == 2L)
    seg   <- signif(seg, 6)
    lines <- paste0(seg[, "x"], ",", seg[, "y"])
    paste0("[[", i, "]]\n", paste(lines, collapse = "\n"))
  })
  paste(parts, collapse = "\n\n")
}

#' Assert Layer-1 geometry matches a stored snapshot
#'
#' Each call should live in its own `test_that()` block so the snapshot file
#' name is unique (testthat 3 derives the name from the test label).
#'
#' @param geom_output Geometry list to snapshot.
#' @noRd
expect_snapshot_geometry <- function(geom_output) {
  serialised <- serialise_geometry(geom_output)
  testthat::expect_snapshot(cat(serialised))
}

#' vdiffr wrapper with fixed seed for deterministic image snapshots (VD gate)
#' @noRd
expect_doppelganger_sketch <- function(title, fig, ...) {
  withr::with_seed(42L, {
    vdiffr::expect_doppelganger(title, fig, ...)
  })
}
