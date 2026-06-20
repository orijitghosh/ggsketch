# Shared sketch aesthetic parameter helpers

#' Resolve sketch layer parameters from data and explicit args
#'
#' Used by `draw_group`/`draw_panel` to merge data-column values with
#' explicit parameter overrides.  Sketch parameters are layer-level only (not
#' mappable via `aes()` in v1); this function just sanitises and defaults them.
#'
#' @param roughness,bowing,n_passes,seed User-supplied values (from the layer).
#' @return A named list with sanitised values.
#' @noRd
resolve_sketch_params <- function(roughness = 1, bowing = 1,
                                   n_passes = 2L, seed = NULL) {
  list(
    roughness = max(0, as.double(roughness[[1L]])),
    bowing    = max(0, as.double(bowing[[1L]])),
    n_passes  = max(1L, as.integer(n_passes[[1L]])),
    seed      = resolve_seed(seed)
  )
}

#' Build a fill gpar from data row
#' @noRd
fill_gpar <- function(colour, alpha = NA, fill_weight = 0.5) {
  gpar(col = scales::alpha(colour, alpha),
       lwd = fill_weight * ggplot2::.pt,
       lineend = "round")
}

#' Build an outline gpar from data row
#' @noRd
outline_gpar <- function(colour, linewidth = 0.5, linetype = 1, alpha = NA) {
  gpar(col = scales::alpha(colour, alpha),
       lwd = linewidth * ggplot2::.pt,
       lty = linetype,
       lineend = "round",
       linejoin = "round")
}
