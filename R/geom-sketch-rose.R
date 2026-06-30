# Layer 3 - geom_sketch_rose() (v2.0 breadth)
# A coxcomb / Nightingale rose: categories occupy equal angular wedges, with
# radius encoding value (optionally area-true, as in Nightingale's original
# mortality roses). An optional second category stacks radially within each
# wedge. Like geom_sketch_chord(), a constructor that computes annular-sector
# geometry up front (reusing chord_arc()) and returns ordinary sketch layers
# (roughened sectors + labels). Pair with coord_equal() + theme_void(). No new
# dependencies (cf. coord_polar() bar charts).

# ---- layout (pure trig) -----------------------------------------------------

# Build rose sectors. `cat` sets the angular wedges (equal width); within a wedge
# `seg` (NULL = one segment) stacks radially by `value`. `area_true = TRUE` makes
# sector *area* proportional to value (radius ~ sqrt of cumulative value), as in
# Nightingale's roses; FALSE makes radius proportional to cumulative value.
rose_layout <- function(cat, value, seg = NULL, area_true = FALSE) {
  cat <- if (is.factor(cat)) droplevels(cat) else factor(cat)
  cl  <- levels(cat)
  k   <- length(cl)
  if (k < 1L) cli::cli_abort("{.fn geom_sketch_rose} needs at least one category.")
  dtheta <- 2 * pi / k

  if (is.null(seg)) seg <- rep("", length(value))
  seg <- as.character(seg)
  sl  <- sort(unique(seg))

  # cumulative raw radii per wedge, plus the global max for scaling
  rmap <- function(v) if (area_true) sqrt(v) else v
  sectors <- list()
  rmax_raw <- 0
  built <- list()
  for (i in seq_len(k)) {
    inx  <- cat == cl[i]
    vals <- vapply(sl, function(s) sum(value[inx & seg == s]), numeric(1))
    cum  <- cumsum(vals)
    r_out_raw <- rmap(cum)
    r_in_raw  <- c(0, r_out_raw[-length(r_out_raw)])
    rmax_raw  <- max(rmax_raw, r_out_raw)
    built[[i]] <- list(vals = vals, r_in = r_in_raw, r_out = r_out_raw)
  }
  scale <- if (rmax_raw > 0) 1 / rmax_raw else 1

  for (i in seq_len(k)) {
    a0 <- (i - 1L) * dtheta; a1 <- i * dtheta
    n  <- max(6L, ceiling(dtheta / (2 * pi) * 160))
    b  <- built[[i]]
    for (j in seq_along(sl)) {
      if (b$vals[j] <= 0) next
      r_in  <- b$r_in[j]  * scale
      r_out <- b$r_out[j] * scale
      outer <- chord_arc(a0, a1, r_out, n)
      inner <- chord_arc(a1, a0, r_in,  n)
      ring  <- rbind(outer, inner)
      sectors[[length(sectors) + 1L]] <- data.frame(
        x = ring[, 1], y = ring[, 2],
        sector = paste(cl[i], sl[j], sep = ""),
        cat = cl[i], seg = sl[j], value = unname(b$vals[j]),
        stringsAsFactors = FALSE
      )
    }
  }
  sectors <- do.call(rbind, sectors)

  labels <- do.call(rbind, lapply(seq_len(k), function(i) {
    amid <- (i - 0.5) * dtheta
    data.frame(x = 1.12 * sin(amid), y = 1.12 * cos(amid),
               cat = cl[i], stringsAsFactors = FALSE)
  }))

  list(sectors = sectors, labels = labels, cats = cl, segs = sl)
}

# ---- geom_sketch_rose -------------------------------------------------------

#' Sketchy coxcomb / Nightingale rose chart
#'
#' Draws a hand-drawn coxcomb (polar area) chart: each category of `x` occupies
#' an equal angular wedge and its `value` sets the radius, so the wedges fan out
#' like a rose. With `area_true = TRUE` the sector *area* (not radius) encodes
#' value, as in Florence Nightingale's original mortality roses. An optional
#' `fill` category stacks radially within each wedge. Like [geom_sketch_chord()]
#' it is a constructor returning a list of ordinary sketch layers (roughened
#' annular sectors + labels), so it composes with `+`; pair it with
#' `coord_equal()` and `theme_void()`, and add [scale_fill_sketch()].
#'
#' @param data A data frame.
#' @param x Unquoted column name of the category that sets the angular wedges.
#' @param value Unquoted column name giving the magnitude (radius / area).
#' @param fill Optional unquoted column name of a second category to stack
#'   radially within each wedge (`NULL` = one segment per wedge, coloured by `x`).
#' @param area_true If `TRUE`, sector area is proportional to value (radius is the
#'   square root) - Nightingale's convention. Default `FALSE` (radius ∝ value).
#' @param fill_style Sector fill style; see [geom_sketch_polygon()]. Default
#'   `"solid"`.
#' @param alpha Sector opacity. Default 0.9.
#' @param colour Sector outline colour. Default `"grey30"`.
#' @param label Draw category labels around the rim? Default `TRUE`.
#' @param label_size,label_colour Label text controls.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param ... Other arguments passed on to the sector layer.
#' @return A list of `ggplot2` layers.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' deaths <- data.frame(
#'   month = month.abb,
#'   n     = c(12, 18, 25, 30, 22, 15, 10, 14, 20, 28, 24, 16)
#' )
#' ggplot() +
#'   geom_sketch_rose(deaths, month, n, area_true = TRUE, seed = 1L) +
#'   scale_fill_sketch() +
#'   coord_equal() +
#'   theme_void()
geom_sketch_rose <- function(data,
                             x, value,
                             fill         = NULL,
                             ...,
                             area_true    = FALSE,
                             fill_style   = "solid",
                             alpha        = 0.9,
                             colour       = "grey30",
                             label        = TRUE,
                             label_size   = 3.2,
                             label_colour = "grey20",
                             roughness    = 1,
                             bowing       = 1,
                             n_passes     = 2L,
                             seed         = NULL) {
  if (missing(data) || !is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame.")
  }
  xcol     <- rlang::as_name(rlang::ensym(x))
  valcol   <- rlang::as_name(rlang::ensym(value))
  fillexpr <- rlang::enquo(fill)
  fillcol  <- if (rlang::quo_is_null(fillexpr)) NULL
              else rlang::as_name(rlang::ensym(fill))

  seg <- if (is.null(fillcol)) NULL else as.character(data[[fillcol]])
  lay <- rose_layout(cat = data[[xcol]], value = as.numeric(data[[valcol]]),
                     seg = seg, area_true = area_true)

  # colour by the stack segment when given, else by the wedge category
  lay$sectors$fill <- if (is.null(fillcol)) lay$sectors$cat else lay$sectors$seg

  layers <- list(
    geom_sketch_polygon(
      data = lay$sectors,
      mapping = ggplot2::aes(x = .data$x, y = .data$y,
                             group = .data$sector, fill = .data$fill),
      fill_style = fill_style, alpha = alpha, colour = colour,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, inherit.aes = FALSE,
      show.legend = !is.null(fillcol), ...
    )
  )

  if (isTRUE(label)) {
    layers <- c(layers, list(geom_sketch_text(
      data = lay$labels,
      mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$cat),
      size = label_size, colour = label_colour,
      family = resolve_label_family(), inherit.aes = FALSE
    )))
  }

  layers
}
