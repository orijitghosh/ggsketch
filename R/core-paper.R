# Layer 1 - paper / canvas textures (v2)
# Vector primitives for simulated paper grounds: ruled notebook lines, graph
# grids, dot grids, aged blotches, blueprint / chalkboard / kraft. Everything is
# plain geometry (no raster), so it reproduces on every device. Ruling is spaced
# in PHYSICAL inches (the caller passes the panel size) so it looks right on any
# panel aspect. No grid:: or ggplot2:: (T-ARCH-01).

#' The available paper grounds
#'
#' The valid values for the `paper` argument of [theme_sketch()] and the `kind`
#' of [element_sketch_paper()].
#'
#' @return A character vector of paper names (`"none"` first).
#' @family sketch-paper
#' @export
#' @examples
#' sketch_papers()
sketch_papers <- function() {
  c("none", "notebook", "graph", "dotted", "aged",
    "blueprint", "chalkboard", "kraft")
}

#' Validate a paper choice
#' @noRd
check_paper <- function(x, arg = rlang::caller_arg(x),
                        call = rlang::caller_env()) {
  choices <- sketch_papers()
  if (!is.character(x) || length(x) != 1L || !x %in% choices) {
    cli::cli_abort(
      "{.arg {arg}} must be one of {.or {choices}}, not {.val {x}}.",
      call = call
    )
  }
  invisible(x)
}

#' Palette + layout spec for a paper ground
#'
#' Pure data: the ground colour, a suggested ink colour, whether the ground is
#' dark (so text should flip light), and the ruling/grid/dot layout.
#'
#' @param kind A value from [sketch_papers()].
#' @return A named list describing the paper, or `NULL` for `"none"`.
#' @family sketch-paper
#' @export
paper_spec <- function(kind) {
  switch(kind,
    none = NULL,
    notebook = list(
      ground = "#FCFBF7", ink = "grey20", dark_ground = FALSE,
      rule   = list(colour = "#AEC8E2", spacing_in = 0.28, lwd = 0.5),
      margin = list(colour = "#E2A9A9", x = 0.08, lwd = 0.7)
    ),
    graph = list(
      ground = "#FCFBF7", ink = "grey20", dark_ground = FALSE,
      grid = list(colour = "#D2E2D2", major = "#A9C9A9",
                  spacing_in = 0.12, major_every = 5L, lwd = 0.4)
    ),
    dotted = list(
      ground = "#FCFBF7", ink = "grey20", dark_ground = FALSE,
      dots = list(colour = "grey72", spacing_in = 0.18, r_in = 0.007)
    ),
    aged = list(
      ground = "#F2E7CE", ink = "#4A3F2E", dark_ground = FALSE,
      aged = list(blotches = 7L)
    ),
    blueprint = list(
      ground = "#16324F", ink = "#EAF2FB", dark_ground = TRUE,
      grid = list(colour = "#3E6286", major = "#82A3C5",
                  spacing_in = 0.16, major_every = 5L, lwd = 0.4)
    ),
    chalkboard = list(
      ground = "#28332C", ink = "#EDEAE0", dark_ground = TRUE,
      grid = list(colour = "#46564A", major = "#5F7363",
                  spacing_in = 0.18, major_every = 5L, lwd = 0.4)
    ),
    kraft = list(
      ground = "#B49A73", ink = "#3A2E1E", dark_ground = FALSE
    )
  )
}

#' Wash-feathering grain factor for a paper ground
#'
#' How toothy a [sketch_papers()] ground is, as a number a watercolour wash uses
#' to feather its edges (the `grain` argument of [watercolor_wash()]). Smooth
#' grounds wick little; rough grounds (aged, kraft) wick a lot. Smooth, machine
#' papers (notebook / graph / dotted) sit low; the textured grounds climb toward
#' 1. `theme_sketch(paper = )` reads this so washes drawn on a paper pick up its
#' tooth automatically.
#'
#' @param kind A value from [sketch_papers()].
#' @return A numeric grain factor in `[0, 1]` (0 for `"none"`).
#' @family sketch-paper
#' @export
#' @examples
#' paper_grain("kraft")
#' paper_grain("graph")
paper_grain <- function(kind) {
  check_paper(kind)
  switch(kind,
    none       = 0,
    notebook   = 0.15,
    graph      = 0.15,
    dotted     = 0.15,
    blueprint  = 0.2,
    chalkboard = 0.5,
    aged       = 0.8,
    kraft      = 1
  )
}

# Evenly spaced positions in [0, 1] at `spacing_in` physical inches over a span
# of `span_in` inches, excluding the two edges.
#' @noRd
ruling_positions <- function(span_in, spacing_in) {
  if (!is.finite(span_in) || span_in <= 0 || spacing_in <= 0) return(numeric(0))
  n <- floor(span_in / spacing_in)
  if (n < 1L) return(numeric(0))
  pos <- (seq_len(n) * spacing_in) / span_in
  pos[pos < 1 - 1e-9]   # exclude a line landing exactly on the far edge
}

#' Build the vector primitives for a paper ground
#'
#' Turns a [paper_spec()] into draw-ready primitives in npc coordinates, spaced
#' for the given physical panel size. The grob layer (`element_sketch_paper()`)
#' renders the result; this function stays free of any `grid` dependency.
#'
#' @param kind A value from [sketch_papers()].
#' @param width_in,height_in Panel size in inches (sets the ruling pitch).
#' @param seed Integer seed (for aged blotches).
#' @return A list with `ground` (fill colour) and zero or more of `segs` (a list
#'   of homogeneous line groups, each `list(x0, y0, x1, y1, colour, lwd)`),
#'   `dots` (`list(x, y, r_in, colour)`), and `blotches` (a list of
#'   `list(x, y, fill)` polygons), or `NULL` for `"none"`.
#' @family sketch-paper
#' @export
paper_primitives <- function(kind, width_in = 6, height_in = 4, seed = NULL) {
  spec <- paper_spec(kind)
  if (is.null(spec)) return(NULL)

  out <- list(ground = spec$ground, segs = list(), dots = NULL,
              blotches = NULL)

  # Ruled notebook lines (+ optional margin rule).
  if (!is.null(spec$rule)) {
    ys <- 1 - ruling_positions(height_in, spec$rule$spacing_in)
    if (length(ys)) {
      out$segs <- c(out$segs, list(list(
        x0 = rep(0, length(ys)), y0 = ys,
        x1 = rep(1, length(ys)), y1 = ys,
        colour = spec$rule$colour, lwd = spec$rule$lwd
      )))
    }
    if (!is.null(spec$margin)) {
      out$segs <- c(out$segs, list(list(
        x0 = spec$margin$x, y0 = 0, x1 = spec$margin$x, y1 = 1,
        colour = spec$margin$colour, lwd = spec$margin$lwd
      )))
    }
  }

  # Graph / blueprint / chalkboard grid (minor + major).
  if (!is.null(spec$grid)) {
    g  <- spec$grid
    xs <- ruling_positions(width_in,  g$spacing_in)
    ys <- ruling_positions(height_in, g$spacing_in)
    is_major <- function(i) (i %% g$major_every) == 0L
    add_lines <- function(pos, vertical, major) {
      idx <- which(vapply(seq_along(pos), function(i) is_major(i) == major,
                          logical(1L)))
      if (!length(idx)) return(NULL)
      p <- pos[idx]
      if (vertical) {
        list(x0 = p, y0 = rep(0, length(p)), x1 = p, y1 = rep(1, length(p)),
             colour = if (major) g$major else g$colour,
             lwd = if (major) g$lwd * 1.6 else g$lwd)
      } else {
        list(x0 = rep(0, length(p)), y0 = p, x1 = rep(1, length(p)), y1 = p,
             colour = if (major) g$major else g$colour,
             lwd = if (major) g$lwd * 1.6 else g$lwd)
      }
    }
    for (major in c(FALSE, TRUE)) {
      lv <- add_lines(xs, TRUE,  major); if (!is.null(lv)) out$segs <- c(out$segs, list(lv))
      lh <- add_lines(ys, FALSE, major); if (!is.null(lh)) out$segs <- c(out$segs, list(lh))
    }
  }

  # Dot grid.
  if (!is.null(spec$dots)) {
    d  <- spec$dots
    xs <- ruling_positions(width_in,  d$spacing_in)
    ys <- ruling_positions(height_in, d$spacing_in)
    if (length(xs) && length(ys)) {
      grid_xy <- expand.grid(x = xs, y = ys)
      out$dots <- list(x = grid_xy$x, y = grid_xy$y,
                       r_in = d$r_in, colour = d$colour)
    }
  }

  # Aged blotches: a few soft irregular translucent stains.
  if (!is.null(spec$aged)) {
    seed <- resolve_seed(seed)
    out$blotches <- within_seed(seed_offset(seed, 71L), {
      nb <- spec$aged$blotches
      lapply(seq_len(nb), function(k) {
        cx <- stats::runif(1L, 0.05, 0.95)
        cy <- stats::runif(1L, 0.05, 0.95)
        rr <- stats::runif(1L, 0.04, 0.11)
        m  <- 14L
        a  <- seq(0, 2 * pi, length.out = m + 1L)[-(m + 1L)]
        rad <- rr * stats::runif(m, 0.7, 1.3)
        list(x = cx + rad * cos(a), y = cy + rad * sin(a),
             fill = scales::alpha("#6B5836", stats::runif(1L, 0.05, 0.12)))
      })
    })
  }

  out
}
