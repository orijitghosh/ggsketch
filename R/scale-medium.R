# Layer 3 - scale_medium_discrete() (v2)
# A discrete scale for the mappable `medium` aesthetic on the path-like sketch
# geoms. Named `scale_medium_discrete` so ggplot2 finds it automatically when a
# discrete variable is mapped to `medium` (the scale_<aes>_<type> convention).
# The palette maps factor levels to drawing media from sketch_media().

#' Discrete scale for the drawing `medium` aesthetic
#'
#' Maps a discrete variable to drawing media (see [sketch_media()]) when it is
#' mapped with `aes(medium = )` on a path-like sketch geom
#' ([geom_sketch_line()], [geom_sketch_path()], [geom_sketch_segment()],
#' [geom_sketch_step()]). Because of its name, ggplot2 picks it up automatically;
#' you only need to call it directly to choose which media to use or to set
#' legend options.
#'
#' Each group is drawn in a single medium, so map `medium` to the same variable
#' you group by (often `colour` or `group`).
#'
#' @param ... Passed to [ggplot2::discrete_scale()] (e.g. `name`, `labels`,
#'   `guide`).
#' @param media Character vector of media to cycle through, each one of
#'   [sketch_media()]. Defaults to every medium except `"pen"` (so mapped levels
#'   look distinct); recycled with a warning if there are more levels than media.
#' @return A `ggplot2` scale object.
#' @family sketch-media
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(
#'   x = rep(1:10, 3),
#'   y = c(1:10, (1:10) + 4, (1:10) + 8),
#'   g = rep(c("a", "b", "c"), each = 10)
#' )
#' ggplot(df, aes(x, y, group = g, medium = g, colour = g)) +
#'   geom_sketch_line(linewidth = 1, seed = 1L) +
#'   scale_medium_discrete() +
#'   theme_sketch()
scale_medium_discrete <- function(..., media = NULL) {
  media <- media %||% setdiff(sketch_media(), "pen")
  bad <- setdiff(media, sketch_media())
  if (length(bad)) {
    cli::cli_abort(
      "{.arg media} must contain only {.fn sketch_media} values; bad: {.val {bad}}."
    )
  }

  pal <- function(n) {
    if (n > length(media)) {
      cli::cli_warn(c(
        "More levels ({n}) than media ({length(media)}); media will be recycled.",
        i = "Pass {.arg media} a longer vector to avoid repeats."
      ))
    }
    media[((seq_len(n) - 1L) %% length(media)) + 1L]
  }

  # discrete_scale() dropped the `scale_name` argument in ggplot2 4.0; pass it
  # only when the installed version still expects it (3.5 compatibility).
  args <- list(aesthetics = "medium", palette = pal, ...)
  if ("scale_name" %in% names(formals(ggplot2::discrete_scale))) {
    args$scale_name <- "medium"
  }
  do.call(ggplot2::discrete_scale, args)
}
