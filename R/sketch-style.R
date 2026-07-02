# One-call style presets: paper + palette + matching defaults in a single `+`.
# A style bundles theme_sketch(paper =), a qualitative colour/fill palette tuned
# to that ground and (on ggplot2 >= 4.0) the default geom ink, so
# `p + sketch_style("chalkboard")` restyles the whole plot at once.

#' The available style presets
#'
#' The valid values for [sketch_style()].
#'
#' @return A character vector of style names.
#' @family sketch-style
#' @export
#' @examples
#' sketch_styles()
sketch_styles <- function() {
  c("notebook", "chalkboard", "blueprint", "field_notes", "graphite")
}

# Recipe for each style: the paper ground, a qualitative palette tuned to it,
# and the default ink (stroke colour) that reads on that ground.
#' @noRd
style_spec <- function(style) {
  switch(style,
    # Blue-ruled school notebook, written in ink.
    notebook = list(
      paper = "notebook", ink = "#2b2b2b",
      palette = c("#1d3f8f", "#2b2b2b", "#c0392b", "#1e7d32",
                  "#6a3d9a", "#b15928")
    ),
    # Dark board, chalky pastels. Pair with medium = "chalk".
    chalkboard = list(
      paper = "chalkboard", ink = "#f5f5ef",
      palette = c("#f5f5ef", "#ffd166", "#a8dadc", "#f4a3b5",
                  "#b8e0a0", "#e0c3fc")
    ),
    # Cyanotype draughting: pale monoline strokes with one warm accent.
    blueprint = list(
      paper = "blueprint", ink = "#eef4f8",
      palette = c("#eef4f8", "#9fd0e8", "#ffd166", "#f4a3b5", "#b8e0a0")
    ),
    # Kraft / expedition journal, sepia and olive inks.
    field_notes = list(
      paper = "kraft", ink = "#4a3728",
      palette = c("#4a3728", "#8c3b2e", "#4d5d43", "#7a5c3d",
                  "#3f5566", "#9c7a2f")
    ),
    # Plain paper, greys only - an unfinished pencil study.
    graphite = list(
      paper = "none", ink = "#3a3a3a",
      palette = c("#3a3a3a", "#6f6f6f", "#545454", "#8f8f8f", "#262626")
    )
  )
}

#' Apply a complete hand-drawn style in one call
#'
#' Bundles a [theme_sketch()] paper ground, a qualitative colour + fill palette
#' tuned to that ground and (on ggplot2 >= 4.0) matching default geom ink into a
#' single object to add to a plot: `p + sketch_style("chalkboard")`. Styles:
#'
#' * `"notebook"` -- blue-ruled paper written in ballpoint/fountain-pen inks.
#' * `"chalkboard"` -- dark board with chalky pastels; pair the line geoms with
#'   `medium = "chalk"`.
#' * `"blueprint"` -- cyanotype draughting: pale monoline strokes, warm accent.
#' * `"field_notes"` -- kraft expedition journal in sepia and olive.
#' * `"graphite"` -- plain ground, grey pencil tones; pair with
#'   `medium = "pencil"`.
#'
#' @param style One of [sketch_styles()].
#' @param palette If `TRUE` (default), include discrete colour and fill scales
#'   using the style's palette. Set `FALSE` when a mapped colour/fill variable
#'   is continuous (a discrete scale would error) or you want your own scale.
#' @param ... Passed on to [theme_sketch()] (e.g. `base_size`, `rough_frame`,
#'   `seed`). `paper` is fixed by the style and cannot be overridden here.
#' @return A list of plot components (theme + optional scales) to add with `+`.
#' @family sketch-style
#' @export
#' @examples
#' library(ggplot2)
#' p <- ggplot(mpg, aes(displ, hwy, colour = drv)) +
#'   geom_sketch_point(seed = 1L)
#' p + sketch_style("field_notes")
#' p + sketch_style("chalkboard")
sketch_style <- function(style, palette = TRUE, ...) {
  if (!is.character(style) || length(style) != 1L ||
      !style %in% sketch_styles()) {
    cli::cli_abort(
      "{.arg style} must be one of {.or {sketch_styles()}}, not {.val {style}}."
    )
  }
  dots <- list(...)
  if ("paper" %in% names(dots)) {
    cli::cli_abort(
      "{.arg paper} is fixed by the style; pick a different {.arg style} instead."
    )
  }
  spec <- style_spec(style)

  out <- list(do.call(theme_sketch, c(list(paper = spec$paper), dots)))

  # ggplot2 >= 4.0 can retheme the default geom ink, so unmapped strokes read
  # on a dark ground too; earlier versions silently keep their defaults.
  if (utils::packageVersion("ggplot2") >= "4.0.0") {
    out <- c(out, list(ggplot2::theme(
      geom = ggplot2::element_geom(ink = spec$ink)
    )))
  }

  if (isTRUE(palette)) {
    pal  <- spec$palette
    palf <- function(n) {
      if (n <= length(pal)) pal[seq_len(n)]
      else grDevices::colorRampPalette(pal)(n)
    }
    out <- c(out, list(
      ggplot2::discrete_scale("colour", palette = palf),
      ggplot2::discrete_scale("fill",   palette = palf)
    ))
  }
  out
}
