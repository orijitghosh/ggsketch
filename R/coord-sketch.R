# Layer 3 - coord_sketch() (v2)
# A drop-in coordinate system that roughens the whole frame, under ANY theme.
# Rather than reimplement gridline/axis layout (fragile across ggplot2 versions),
# it subclasses CoordCartesian and, at render time, swaps the relevant theme
# elements for their element_sketch_* counterparts, then defers to the parent
# method -- so all of ggplot2's positioning logic is reused and only the *drawing*
# of gridlines and ticks changes. This is the global, theme-independent companion
# to theme_sketch(rough_frame = TRUE) (which only acts inside theme_sketch).

# Replace a line-valued theme element with a roughened element_sketch_line,
# copying the resolved colour/linewidth/linetype so the frame keeps its look.
#' @noRd
sketchify_line_element <- function(theme, name, sk, seed) {
  cur <- tryCatch(ggplot2::calc_element(name, theme), error = function(e) NULL)
  if (is.null(cur) || inherits(cur, "element_blank")) return(theme)
  theme[[name]] <- element_sketch_line(
    colour    = cur$colour,
    linewidth = cur$linewidth,
    linetype  = cur$linetype,
    roughness = sk$roughness,
    bowing    = sk$bowing,
    n_passes  = sk$n_passes,
    seed      = seed
  )
  theme
}

#' @rdname coord_sketch
#' @format NULL
#' @usage NULL
#' @export
CoordSketch <- ggplot2::ggproto(
  "CoordSketch", ggplot2::CoordCartesian,

  render_bg = function(self, panel_params, theme) {
    if (isTRUE(self$sketch$grid)) {
      base <- resolve_seed(self$sketch$seed)
      theme <- sketchify_line_element(theme, "panel.grid.major", self$sketch,
                                      seed_offset(base, 11L))
      theme <- sketchify_line_element(theme, "panel.grid.minor", self$sketch,
                                      seed_offset(base, 29L))
    }
    ggplot2::ggproto_parent(ggplot2::CoordCartesian, self)$render_bg(
      panel_params, theme
    )
  },

  render_axis_h = function(self, panel_params, theme) {
    if (isTRUE(self$sketch$ticks)) {
      theme <- sketchify_line_element(theme, "axis.ticks", self$sketch,
                                      seed_offset(resolve_seed(self$sketch$seed),
                                                  101L))
    }
    ggplot2::ggproto_parent(ggplot2::CoordCartesian, self)$render_axis_h(
      panel_params, theme
    )
  },

  render_axis_v = function(self, panel_params, theme) {
    if (isTRUE(self$sketch$ticks)) {
      theme <- sketchify_line_element(theme, "axis.ticks", self$sketch,
                                      seed_offset(resolve_seed(self$sketch$seed),
                                                  211L))
    }
    ggplot2::ggproto_parent(ggplot2::CoordCartesian, self)$render_axis_v(
      panel_params, theme
    )
  }
)

#' A hand-drawn coordinate system
#'
#' A drop-in replacement for [ggplot2::coord_cartesian()] that draws the *frame*
#' hand-drawn: the panel gridlines and axis ticks are rendered as roughened
#' sketch grobs, so the frame matches the marks -- under any theme, not only
#' [theme_sketch()]. It reuses ggplot2's own gridline and axis layout and only
#' swaps how those elements are drawn, so limits, expansion, and clipping behave
#' exactly like `coord_cartesian()`.
#'
#' The panel *border* is a plot-level theme element (not part of the coordinate
#' system), so to roughen it as well, combine `coord_sketch()` with
#' `theme_sketch(rough_frame = TRUE)` or set
#' `panel.border = element_sketch_rect(...)`.
#'
#' @param xlim,ylim Limits for the x and y axes (as in
#'   [ggplot2::coord_cartesian()]).
#' @param expand If `TRUE` (default), add the standard expansion around the data.
#' @param default Is this the default coordinate system? Default `FALSE`.
#' @param clip Should drawing be clipped to the panel (`"on"`, default) or not
#'   (`"off"`)?
#' @param roughness,bowing,n_passes Sketch parameters for the frame. Gentle
#'   defaults suited to gridlines (`0.5`, `0.5`, `2`).
#' @param seed Integer seed for reproducible wobble. `NULL` uses
#'   `getOption("ggsketch.seed", 1L)`.
#' @param rough_grid,rough_ticks Roughen the gridlines / axis ticks? Both default
#'   `TRUE`; set one to `FALSE` to leave that element crisp.
#' @return A `ggproto` Coord object to add to a plot.
#' @family sketch-theme
#' @export
#' @examples
#' library(ggplot2)
#' # A rough frame under a plain (non-sketch) theme:
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_sketch_point(seed = 1L) +
#'   coord_sketch(seed = 1L)
coord_sketch <- function(xlim        = NULL,
                         ylim        = NULL,
                         expand      = TRUE,
                         default     = FALSE,
                         clip        = "on",
                         roughness   = 0.5,
                         bowing      = 0.5,
                         n_passes    = 2L,
                         seed        = NULL,
                         rough_grid  = TRUE,
                         rough_ticks = TRUE) {
  ggplot2::ggproto(NULL, CoordSketch,
    limits  = list(x = xlim, y = ylim),
    expand  = expand,
    default = default,
    clip    = clip,
    sketch  = list(
      roughness = max(0, roughness),
      bowing    = max(0, bowing),
      n_passes  = as.integer(n_passes),
      seed      = seed,
      grid      = isTRUE(rough_grid),
      ticks     = isTRUE(rough_ticks)
    )
  )
}

# ---- coord_sketch_polar() ---------------------------------------------------

#' @rdname coord_sketch_polar
#' @format NULL
#' @usage NULL
#' @export
CoordSketchPolar <- ggplot2::ggproto(
  "CoordSketchPolar", ggplot2::CoordPolar,

  render_bg = function(self, panel_params, theme) {
    if (isTRUE(self$sketch$grid)) {
      base  <- resolve_seed(self$sketch$seed)
      theme <- sketchify_line_element(theme, "panel.grid.major", self$sketch,
                                      seed_offset(base, 11L))
      theme <- sketchify_line_element(theme, "panel.grid.minor", self$sketch,
                                      seed_offset(base, 29L))
    }
    ggplot2::ggproto_parent(ggplot2::CoordPolar, self)$render_bg(
      panel_params, theme
    )
  }
)

#' A hand-drawn polar coordinate system
#'
#' The polar companion to [coord_sketch()]: a drop-in replacement for
#' [ggplot2::coord_polar()] that draws the circular grid hand-drawn. The radial
#' and angular gridlines are rendered as roughened sketch grobs, so pie/rose
#' charts and circular bar plots get a frame that matches the marks -- under any
#' theme. It reuses all of ggplot2's polar layout and only swaps how the grid is
#' drawn.
#'
#' @param theta Variable mapped to angle (`"x"` or `"y"`). Default `"x"`.
#' @param start Offset of the starting point, in radians. Default 0.
#' @param direction `1` clockwise, `-1` anticlockwise. Default 1.
#' @param clip Should drawing be clipped to the panel (`"on"`, default) or not
#'   (`"off"`)?
#' @param roughness,bowing,n_passes Sketch parameters for the grid. Gentle
#'   defaults suited to gridlines (`0.5`, `0.5`, `2`).
#' @param seed Integer seed for reproducible wobble. `NULL` uses
#'   `getOption("ggsketch.seed", 1L)`.
#' @param rough_grid Roughen the gridlines? Default `TRUE`.
#' @return A `ggproto` Coord object to add to a plot.
#' @family sketch-theme
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(g = c("a", "b", "c", "d"), v = c(3, 5, 2, 4))
#' # A hand-drawn circular bar (rose) chart:
#' ggplot(df, aes(g, v, fill = g)) +
#'   geom_sketch_col(seed = 1L) +
#'   coord_sketch_polar(seed = 1L) +
#'   theme_sketch()
coord_sketch_polar <- function(theta      = "x",
                               start      = 0,
                               direction  = 1,
                               clip       = "on",
                               roughness  = 0.5,
                               bowing     = 0.5,
                               n_passes   = 2L,
                               seed       = NULL,
                               rough_grid = TRUE) {
  theta <- match.arg(theta, c("x", "y"))
  r     <- if (theta == "x") "y" else "x"
  ggplot2::ggproto(NULL, CoordSketchPolar,
    theta     = theta,
    r         = r,
    start     = start,
    direction = sign(direction),
    clip      = clip,
    sketch    = list(
      roughness = max(0, roughness),
      bowing    = max(0, bowing),
      n_passes  = as.integer(n_passes),
      seed      = seed,
      grid      = isTRUE(rough_grid)
    )
  )
}
