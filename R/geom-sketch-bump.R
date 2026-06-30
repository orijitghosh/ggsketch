# Layer 3 - geom_sketch_bump() (v2.0 breadth)
# A bump / ranking chart: each series' rank at every time point, with smooth
# roughened curves connecting a series' rank across adjacent times so crossings
# read as overtakes. Like geom_sketch_alluvial(), a constructor that computes the
# layout up front (reusing alluvial_scurve()) and returns ordinary sketch layers
# (roughened ribbons, rank points, end labels) in plain x/y space. No new deps
# (cf. ggbump).

# ---- layout (pure arithmetic) -----------------------------------------------

# Build the bump layout from a long data frame. `x` is the (ordinal) time, `group`
# the series, `value` ranked within each x. `direction` = "desc" ranks the
# highest value as rank 1 (drawn at the top). Returns connector segments (one per
# group per adjacent pair), rank points, and left/right end labels.
bump_layout <- function(data, x, group, value,
                        direction = c("desc", "asc"), n = 40L) {
  direction <- match.arg(direction)
  miss <- setdiff(c(x, group, value), names(data))
  if (length(miss)) {
    cli::cli_abort("Column{?s} {.val {miss}} not found in {.arg data}.")
  }

  xv <- data[[x]]
  gv <- as.character(data[[group]])
  vv <- as.numeric(data[[value]])

  xlev <- sort(unique(xv))
  if (length(xlev) < 2L) {
    cli::cli_abort("{.fn geom_sketch_bump} needs at least 2 distinct {.arg x} values.")
  }
  xpos <- match(xv, xlev)                      # 1..T
  glev <- sort(unique(gv))
  nG   <- length(glev)

  # Rank within each time point; rank 1 placed at the top (y = nG).
  rank <- numeric(length(vv))
  for (t in seq_along(xlev)) {
    ix <- which(xpos == t)
    sgn <- if (direction == "desc") -1 else 1
    rank[ix] <- rank(sgn * vv[ix], ties.method = "first")
  }
  y <- nG - rank + 1

  pts <- data.frame(x = xpos, y = y, group = gv, rank = rank, value = vv,
                    stringsAsFactors = FALSE)
  pts <- pts[order(pts$group, pts$x), , drop = FALSE]

  # Connector ribbons: per group, join consecutive time points with an S-curve.
  segs <- list()
  for (g in glev) {
    gp <- pts[pts$group == g, , drop = FALSE]
    if (nrow(gp) < 2L) next
    for (i in seq_len(nrow(gp) - 1L)) {
      cv <- alluvial_scurve(gp$x[i], gp$x[i + 1L], gp$y[i], gp$y[i + 1L], n = n)
      segs[[length(segs) + 1L]] <- data.frame(
        x = cv[, 1], y = cv[, 2],
        seg = paste(g, i, sep = "."), group = g,
        stringsAsFactors = FALSE
      )
    }
  }
  segments <- do.call(rbind, segs)

  left  <- pts[pts$x == 1L, , drop = FALSE]
  right <- pts[pts$x == length(xlev), , drop = FALSE]

  list(
    segments = segments,
    points   = pts,
    left     = data.frame(x = left$x  - 0.06, y = left$y,  group = left$group),
    right    = data.frame(x = right$x + 0.06, y = right$y, group = right$group),
    xlevels  = xlev, groups = glev
  )
}

# ---- geom_sketch_bump -------------------------------------------------------

#' Sketchy bump (ranking) chart
#'
#' Draws a hand-drawn bump chart: each series' rank at every time point, joined
#' across adjacent times by smooth roughened curves so a crossing reads as one
#' series overtaking another. Like [geom_sketch_alluvial()] it is a constructor
#' returning a list of ordinary sketch layers (connector ribbons, rank points and
#' end labels), so it composes with `+`; map a colour scale over the series and
#' pair with `theme_void()` or `theme_sketch()`. No new dependencies
#' (cf. `ggbump`).
#'
#' @param data A long data frame (one row per series per time point).
#' @param x,group,value Unquoted column names: the (ordinal) time, the series,
#'   and the value ranked within each time.
#' @param direction `"desc"` (default) ranks the highest `value` as rank 1, drawn
#'   at the top; `"asc"` flips it.
#' @param point_size Size of the rank points. Default 3.
#' @param line_width Connector line width. Default 1.2.
#' @param alpha Connector opacity. Default 0.9.
#' @param label Draw series labels at the first and last time point? Default
#'   `TRUE`.
#' @param label_size,label_colour Label text controls.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param ... Other arguments passed on to the connector layer.
#' @return A list of `ggplot2` layers.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(
#'   year = rep(2018:2021, each = 4),
#'   team = rep(c("A", "B", "C", "D"), times = 4),
#'   pts  = c(10, 8, 6, 4,  6, 10, 8, 4,  8, 6, 10, 5,  4, 8, 6, 12)
#' )
#' ggplot() +
#'   geom_sketch_bump(df, year, team, pts, seed = 1L) +
#'   scale_colour_sketch() +
#'   theme_void()
geom_sketch_bump <- function(data,
                             x, group, value,
                             ...,
                             direction    = c("desc", "asc"),
                             point_size   = 3,
                             line_width   = 1.2,
                             alpha        = 0.9,
                             label        = TRUE,
                             label_size   = 3.5,
                             label_colour = "grey20",
                             roughness    = 1,
                             bowing       = 1,
                             n_passes     = 2L,
                             seed         = NULL) {
  if (missing(data) || !is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame.")
  }
  direction <- match.arg(direction)
  x_col     <- rlang::as_name(rlang::ensym(x))
  group_col <- rlang::as_name(rlang::ensym(group))
  value_col <- rlang::as_name(rlang::ensym(value))

  lay <- bump_layout(data, x = x_col, group = group_col, value = value_col,
                     direction = direction)

  layers <- list(
    geom_sketch_path(
      data = lay$segments,
      mapping = ggplot2::aes(x = .data$x, y = .data$y, group = .data$seg,
                             colour = .data$group),
      linewidth = line_width, alpha = alpha,
      roughness = roughness, bowing = bowing,
      n_passes = as.integer(n_passes), seed = seed, inherit.aes = FALSE, ...
    ),
    geom_sketch_point(
      data = lay$points,
      mapping = ggplot2::aes(x = .data$x, y = .data$y, colour = .data$group),
      size = point_size, seed = seed, inherit.aes = FALSE, show.legend = FALSE
    )
  )

  if (isTRUE(label)) {
    layers <- c(layers, list(
      geom_sketch_text(
        data = lay$left,
        mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$group),
        size = label_size, colour = label_colour, hjust = 1,
        family = resolve_label_family(), inherit.aes = FALSE
      ),
      geom_sketch_text(
        data = lay$right,
        mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$group),
        size = label_size, colour = label_colour, hjust = 0,
        family = resolve_label_family(), inherit.aes = FALSE
      )
    ))
  }

  layers
}
