# Layer 3 - geom_sketch_sunburst() (v2.0 breadth)
# A sunburst: a hierarchy drawn as nested rings of annular sectors. The root ring
# fills the circle; each deeper ring splits its parent's angular span by the
# children's summed weight, so a child sector always nests inside its parent.
# Like geom_sketch_chord(), this is a constructor that computes the geometry up
# front in unit-circle space and returns ordinary sketch layers (roughened
# annular-sector polygons plus optional handwriting labels), so it composes with
# `+` and needs `coord_equal()` + `theme_void()`. Reuses chord_arc(); no new
# dependencies (cf. sunburstR, plotly).

# ---- layout (pure trig, no grid/ggplot2) ------------------------------------

# Build the sunburst layout from a hierarchy described by the `levels` columns
# (outermost-to-innermost order: levels[1] is the root ring). `value` weights the
# leaves; NULL counts each row as 1. Returns a list of nodes, each an annular
# sector: list(depth, label, root, a0, a1, r_in, r_out) in radians (0 = north,
# clockwise, matching chord_arc()).
sunburst_layout <- function(data, levels, value = NULL,
                            r0 = 0.15, ring_width = NULL) {
  D <- length(levels)
  if (D < 1L) {
    cli::cli_abort("{.fn geom_sketch_sunburst} needs at least one level.")
  }
  miss <- setdiff(levels, names(data))
  if (length(miss)) {
    cli::cli_abort("Column{?s} {.val {miss}} not found in {.arg data}.")
  }

  keys <- lapply(levels, function(l) as.character(data[[l]]))
  w    <- if (is.null(value)) rep(1, nrow(data)) else as.numeric(data[[value]])

  # Keep only rows with a complete path and a finite weight.
  ok <- is.finite(w) & Reduce(`&`, lapply(keys, function(k) !is.na(k)))
  keys <- lapply(keys, function(k) k[ok]); w <- w[ok]
  if (length(w) == 0L) {
    cli::cli_abort("{.fn geom_sketch_sunburst}: no complete rows to draw.")
  }

  # Aggregate weight per full (deepest) path, then sort leaves lexicographically
  # so every node's descendant leaves are contiguous.
  sep      <- ""
  leaf_key <- do.call(paste, c(keys, sep = sep))
  agg      <- stats::aggregate(list(w = w), by = list(k = leaf_key), FUN = sum)
  parts    <- strsplit(agg$k, sep, fixed = TRUE)
  lvl      <- do.call(rbind, parts)                 # n_leaves x D character matrix
  ord      <- do.call(order, as.data.frame(lvl, stringsAsFactors = FALSE))
  lvl      <- lvl[ord, , drop = FALSE]
  lw       <- agg$w[ord]

  # Cumulative angular interval per leaf.
  total <- sum(lw)
  a_hi  <- cumsum(lw) / total * 2 * pi
  a_lo  <- c(0, a_hi[-length(a_hi)])

  rw <- ring_width %||% ((1 - r0) / D)

  # One node per (depth, prefix); span = union of its leaves' intervals.
  nodes <- list()
  for (d in seq_len(D)) {
    prefix <- apply(lvl[, seq_len(d), drop = FALSE], 1L, paste, collapse = sep)
    for (p in unique(prefix)) {
      ix    <- which(prefix == p)
      r_in  <- r0 + (d - 1L) * rw
      nodes[[length(nodes) + 1L]] <- list(
        depth = d,
        label = lvl[ix[1L], d],
        root  = lvl[ix[1L], 1L],
        a0    = min(a_lo[ix]), a1 = max(a_hi[ix]),
        r_in  = r_in, r_out = r_in + rw
      )
    }
  }
  nodes
}

# ---- geom_sketch_sunburst ---------------------------------------------------

#' Sketchy sunburst (hierarchy) chart
#'
#' Draws a hand-drawn sunburst: a hierarchy rendered as nested rings of annular
#' sectors. The columns named in `levels` define the hierarchy outermost-to-
#' innermost (`levels[1]` is the inner root ring); each deeper ring splits its
#' parent's angular span by the children's summed `value`, so a child always
#' nests inside its parent. Like [geom_sketch_chord()] it is a constructor
#' returning a list of ordinary sketch layers (roughened annular sectors plus
#' optional labels), so it composes with `+`; pair it with `coord_equal()` and
#' `theme_void()`, and add [scale_fill_sketch()] (or any fill scale) to colour
#' it. Reuses no new dependencies (cf. `sunburstR`, `plotly`).
#'
#' @param data A data frame, one row per observation (or per leaf).
#' @param levels Character vector of column names giving the hierarchy, from the
#'   inner root ring outward (at least one).
#' @param value Optional column name giving the leaf weight (`NULL` = every row
#'   counts as 1).
#' @param r0 Radius of the central hole, in the unit circle. Default 0.15.
#' @param ring_width Radial width of each ring. `NULL` (default) divides the
#'   space `r0..1` evenly across the levels.
#' @param fill_by What the sector fill encodes: `"root"` (default, the top-level
#'   ancestor - the classic sunburst look), `"self"` (each node's own label), or
#'   `"depth"` (the ring number).
#' @param fill_style Sector fill style; see [geom_sketch_polygon()]. Default
#'   `"solid"`.
#' @param alpha Sector fill opacity. Default 0.9.
#' @param colour Sector outline colour. Default `"grey30"`.
#' @param label Draw a label on each sector? Default `FALSE` (sunbursts get busy;
#'   only sectors with a wide enough angle are labelled).
#' @param label_size,label_colour Label text controls.
#' @param min_label_angle Minimum angular span (radians) a sector needs before it
#'   is labelled. Default 0.15.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param ... Other arguments passed on to the sector layer.
#' @return A list of `ggplot2` layers.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(
#'   region = c("West", "West", "West", "East", "East", "East"),
#'   dept   = c("Sales", "Sales", "Eng", "Sales", "Eng", "Eng"),
#'   team   = c("A", "B", "C", "D", "E", "F"),
#'   n      = c(4, 2, 6, 3, 5, 1)
#' )
#' ggplot() +
#'   geom_sketch_sunburst(df, levels = c("region", "dept", "team"),
#'                        value = "n", seed = 1L) +
#'   scale_fill_sketch() +
#'   coord_equal() +
#'   theme_void()
geom_sketch_sunburst <- function(data,
                                 levels,
                                 value           = NULL,
                                 ...,
                                 r0              = 0.15,
                                 ring_width      = NULL,
                                 fill_by         = c("root", "self", "depth"),
                                 fill_style      = "solid",
                                 alpha           = 0.9,
                                 colour          = "grey30",
                                 label           = FALSE,
                                 label_size      = 3,
                                 label_colour    = "grey20",
                                 min_label_angle = 0.15,
                                 roughness       = 1,
                                 bowing          = 1,
                                 n_passes        = 2L,
                                 seed            = NULL) {
  if (missing(data) || !is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame.")
  }
  fill_by <- match.arg(fill_by)
  if (!is.null(value) && !value %in% names(data)) {
    cli::cli_abort("Value column {.val {value}} not found in {.arg data}.")
  }

  nodes <- sunburst_layout(data, levels = levels, value = value,
                           r0 = r0, ring_width = ring_width)

  # Annular-sector polygons: outer arc forward + inner arc reversed -> closed.
  secs <- lapply(seq_along(nodes), function(i) {
    nd   <- nodes[[i]]
    span <- nd$a1 - nd$a0
    n    <- max(8L, ceiling(span / (2 * pi) * 160))
    outer <- chord_arc(nd$a0, nd$a1, nd$r_out, n)
    inner <- chord_arc(nd$a1, nd$a0, nd$r_in,  n)
    ring  <- rbind(outer, inner)
    fillv <- switch(fill_by,
                    root  = nd$root,
                    self  = nd$label,
                    depth = paste0("ring ", nd$depth))
    data.frame(x = ring[, 1], y = ring[, 2],
               sector = i, depth = nd$depth, fill = fillv,
               stringsAsFactors = FALSE)
  })
  sec_df <- do.call(rbind, secs)

  layers <- list(
    geom_sketch_polygon(
      data = sec_df,
      mapping = ggplot2::aes(x = .data$x, y = .data$y,
                             group = .data$sector, fill = .data$fill),
      fill_style = fill_style, alpha = alpha, colour = colour,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, inherit.aes = FALSE, ...
    )
  )

  if (isTRUE(label)) {
    labs <- do.call(rbind, lapply(nodes, function(nd) {
      if (nd$a1 - nd$a0 < min_label_angle) return(NULL)
      amid <- (nd$a0 + nd$a1) / 2
      rmid <- (nd$r_in + nd$r_out) / 2
      data.frame(x = rmid * sin(amid), y = rmid * cos(amid),
                 label = nd$label, stringsAsFactors = FALSE)
    }))
    if (!is.null(labs) && nrow(labs) > 0L) {
      layers <- c(layers, list(geom_sketch_text(
        data = labs,
        mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$label),
        size = label_size, colour = label_colour, inherit.aes = FALSE
      )))
    }
  }

  layers
}
