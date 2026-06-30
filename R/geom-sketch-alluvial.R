# Layer 3 - geom_sketch_alluvial() (v2.0 breadth)
# An alluvial / Sankey-style diagram: two or more categorical axes, each drawn
# as a stack of strata (boxes), with flows (ribbons) between adjacent axes whose
# thickness is the frequency of each category combination. Like
# geom_sketch_chord(), this is a constructor that computes the geometry up front
# (pure arithmetic, no grid/ggplot2) and returns ordinary sketch layers: strata
# as roughened rectangles, flows as roughened polygons with raised-cosine edges,
# plus stratum labels. It draws in ordinary x/y space. No new dependencies
# (cf. ggalluvial, ggsankey).

# ---- layout (pure arithmetic) -----------------------------------------------

# Raised-cosine S-curve between two heights across an x-span: smooth, monotone,
# flat at both ends so ribbons leave/meet the strata horizontally.
alluvial_scurve <- function(x0, x1, y0, y1, n = 40L) {
  t  <- seq(0, 1, length.out = max(n, 2L))
  s  <- 0.5 - 0.5 * cos(pi * t)
  cbind(x0 + t * (x1 - x0), y0 + (y1 - y0) * s)
}

# Build the alluvial layout from a wide data frame: `axes` are the category
# columns in order, `value` an optional weight column (NULL = one per row), and
# `fill_var` the column whose category colours each flow (NULL = first axis).
alluvial_layout <- function(data, axes, value = NULL, fill_var = NULL,
                            box_width = 0.18) {
  if (length(axes) < 2L) {
    cli::cli_abort("{.fn geom_sketch_alluvial} needs at least 2 axes.")
  }
  miss <- setdiff(c(axes, value, fill_var), names(data))
  if (length(miss)) {
    cli::cli_abort("Column{?s} {.val {miss}} not found in {.arg data}.")
  }

  K   <- length(axes)
  w   <- if (is.null(value)) rep(1, nrow(data)) else as.numeric(data[[value]])
  fillv <- if (is.null(fill_var)) as.character(data[[axes[1L]]])
           else as.character(data[[fill_var]])

  # Aggregate identical alluvia (same category at every axis + same fill).
  key <- do.call(paste, c(lapply(axes, function(a) as.character(data[[a]])),
                          list(fillv), sep = "\r"))
  ord0 <- !duplicated(key)
  uk   <- key[ord0]
  cats <- lapply(axes, function(a) {
    col <- data[[a]]
    levs <- if (is.factor(col)) levels(droplevels(col)) else sort(unique(as.character(col)))
    list(levs = levs, val = as.character(col))
  })
  agg_w <- tapply(w, key, sum)[uk]
  amat  <- do.call(cbind, lapply(seq_len(K), function(k) cats[[k]]$val[ord0]))
  fillc <- fillv[ord0]
  A     <- length(uk)

  # Global alluvium order: lexicographic by category index across all axes, so
  # ribbons stay as untangled as a single pass allows.
  idxmat <- vapply(seq_len(K), function(k) match(amat[, k], cats[[k]]$levs),
                   integer(A))
  if (A == 1L) idxmat <- matrix(idxmat, nrow = 1L)
  gorder <- do.call(order, lapply(seq_len(K), function(k) idxmat[, k]))

  # Stratum extents per axis, and per-alluvium sub-bands within each stratum.
  yk_low  <- matrix(NA_real_, A, K)
  yk_high <- matrix(NA_real_, A, K)
  strata  <- list()
  for (k in seq_len(K)) {
    levs <- cats[[k]]$levs
    hgt  <- vapply(levs, function(L) sum(agg_w[amat[, k] == L]), numeric(1))
    ystart <- c(0, cumsum(hgt)[-length(hgt)])
    names(ystart) <- levs
    for (si in seq_along(levs)) {
      L  <- levs[si]
      strata[[length(strata) + 1L]] <- data.frame(
        xmin = k - box_width / 2, xmax = k + box_width / 2,
        ymin = ystart[L], ymax = ystart[L] + hgt[si],
        axis = axes[k], stratum = L,
        ycen = ystart[L] + hgt[si] / 2
      )
      # alluvia in this stratum, in global order, stacked upward
      in_s <- which(amat[, k] == L)
      in_s <- in_s[order(match(in_s, gorder))]
      cur  <- ystart[L]
      for (a in in_s) {
        yk_low[a, k]  <- cur
        yk_high[a, k] <- cur + agg_w[a]
        cur <- yk_high[a, k]
      }
    }
  }
  strata <- do.call(rbind, strata)

  # Flow polygons: one per alluvium per adjacent-axis gap.
  flows <- list(); fid <- 0L
  bh <- box_width / 2
  for (k in seq_len(K - 1L)) {
    xL <- k + bh; xR <- (k + 1L) - bh
    for (a in seq_len(A)) {
      top <- alluvial_scurve(xL, xR, yk_high[a, k], yk_high[a, k + 1L])
      bot <- alluvial_scurve(xR, xL, yk_low[a, k + 1L], yk_low[a, k])
      poly <- rbind(top, bot)
      fid <- fid + 1L
      flows[[fid]] <- data.frame(x = poly[, 1], y = poly[, 2],
                                 flow = fid, fill = fillc[a])
    }
  }
  flows <- do.call(rbind, flows)

  list(strata = strata, flows = flows, labels = strata,
       axes = axes)
}

# ---- geom_sketch_alluvial ---------------------------------------------------

#' Sketchy alluvial / Sankey diagram
#'
#' Draws a hand-drawn alluvial diagram: two or more categorical axes, each a
#' stack of strata (boxes), connected by flows (ribbons) whose thickness is the
#' frequency of each category combination. Like [geom_sketch_chord()] it is a
#' constructor that returns a list of ordinary sketch layers (roughened strata,
#' roughened flow ribbons with smooth S-curved edges, and stratum labels), so it
#' composes with `+` and any fill scale. It draws in ordinary x/y space; pair it
#' with `theme_void()` or `theme_sketch()`. No new dependencies
#' (cf. `ggalluvial`, `ggsankey`).
#'
#' @param data A wide data frame: one column per axis, one row per observation
#'   (or per group, with a `value` weight).
#' @param axes Character vector of column names to use as axes, in order
#'   (at least two).
#' @param value Optional column name giving each row's weight (`NULL` = 1 each).
#' @param fill Optional column name whose category colours each flow (`NULL` =
#'   the first axis). Add [scale_fill_sketch()] or any fill scale to style it.
#' @param box_width Width of the stratum boxes in x units. Default 0.18.
#' @param fill_style Flow fill style; see [geom_sketch_polygon()]. Default
#'   `"solid"`.
#' @param alpha Flow opacity. Default 0.7.
#' @param strata_fill Fill colour of the stratum boxes. Default `"grey85"`.
#' @param label Draw stratum labels? Default `TRUE`.
#' @param label_size,label_colour Label text controls.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param ... Other arguments passed on to the flow layer.
#' @return A list of `ggplot2` layers.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- as.data.frame(Titanic)
#' ggplot() +
#'   geom_sketch_alluvial(df, axes = c("Class", "Sex", "Survived"),
#'                        value = "Freq", seed = 1L) +
#'   scale_fill_sketch() +
#'   theme_void()
geom_sketch_alluvial <- function(data,
                                 axes,
                                 value        = NULL,
                                 fill         = NULL,
                                 ...,
                                 box_width    = 0.18,
                                 fill_style   = "solid",
                                 alpha        = 0.7,
                                 strata_fill  = "grey85",
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
  lay <- alluvial_layout(data, axes = axes, value = value, fill_var = fill,
                         box_width = box_width)

  layers <- list(
    # flows first, so the strata boxes sit on top of the ribbon ends
    geom_sketch_polygon(
      data = lay$flows,
      mapping = ggplot2::aes(x = .data$x, y = .data$y,
                             group = .data$flow, fill = .data$fill),
      fill_style = fill_style, alpha = alpha, colour = NA,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, inherit.aes = FALSE, ...
    ),
    geom_sketch_rect(
      data = lay$strata,
      mapping = ggplot2::aes(xmin = .data$xmin, xmax = .data$xmax,
                             ymin = .data$ymin, ymax = .data$ymax,
                             group = interaction(.data$axis, .data$stratum)),
      fill = strata_fill, fill_style = "solid", colour = "grey30",
      roughness = roughness * 0.7, bowing = bowing,
      n_passes = as.integer(n_passes), seed = seed,
      show.legend = FALSE, inherit.aes = FALSE
    )
  )

  if (isTRUE(label)) {
    layers <- c(layers, list(geom_sketch_text(
      data = lay$labels,
      mapping = ggplot2::aes(x = .data$xmax, y = .data$ycen,
                             label = .data$stratum),
      hjust = -0.1, size = label_size, colour = label_colour,
      family = resolve_label_family(), inherit.aes = FALSE
    )))
  }

  layers
}
