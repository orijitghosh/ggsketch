# Layer 3 - geom_sketch_radar() (v2.0 breadth)
# A radar / spider chart: each series is a closed polygon over evenly-spaced
# angular axes. Like geom_sketch_pie(), the layout lives in its own cartesian
# space via custom `axis`/`value` aesthetics (so it never fights a discrete x
# scale). StatSketchRadar turns (axis, value) into polygon coordinates scaled to
# a unit radius; GeomSketchRadar draws the web (concentric rings + radial spokes
# + axis labels) once per panel, then a roughened, optionally hachure-filled
# polygon per series. No new dependencies (cf. ggradar / fmsb::radarchart()).

# ---- StatSketchRadar ---------------------------------------------------------

#' @rdname geom_sketch_radar
#' @export
StatSketchRadar <- ggplot2::ggproto(
  "StatSketchRadar", ggplot2::Stat,

  required_aes = c("axis", "value"),

  compute_panel = function(data, scales, rmax = NULL, na.rm = FALSE) {
    if (nrow(data) == 0L) return(data)

    ax   <- data$axis
    levs <- if (is.factor(ax)) levels(droplevels(ax)) else sort(unique(ax))
    n    <- length(levs)
    if (n < 3L) {
      cli::cli_abort("{.fn geom_sketch_radar} needs at least 3 axes, not {n}.")
    }
    # Angles run clockwise from due north (0 at top), like a compass.
    ang  <- 2 * pi * (seq_len(n) - 1L) / n
    names(ang) <- levs

    vmax <- rmax %||% max(data$value, na.rm = TRUE)
    if (!is.finite(vmax) || vmax <= 0) vmax <- 1

    grp <- if (!is.null(data$group)) data$group else rep(1L, nrow(data))

    series <- do.call(rbind, lapply(split(seq_len(nrow(data)), grp), function(ix) {
      d <- data[ix, , drop = FALSE]
      # order/complete to the full axis set so every series is a full polygon
      d <- d[match(levs, as.character(d$axis)), , drop = FALSE]
      r <- d$value / vmax
      r[is.na(r)] <- 0
      proto <- data[ix[1L], , drop = FALSE][rep(1L, n), , drop = FALSE]
      proto$x           <- r * sin(ang)
      proto$y           <- r * cos(ang)
      proto$group       <- grp[ix][1L]
      proto$.role       <- "series"
      proto$.angle      <- as.numeric(ang)
      proto$.axis_label <- levs
      proto
    }))

    # One anchor row per axis: carries the angle/label for the web, and trains
    # the x/y scales past the unit circle (radius 1.22) so the outer ring sits
    # inside the panel with headroom for the axis labels. The anchors are never
    # drawn; the geom recomputes the web from the angles at radius 1.
    anchors <- series[seq_len(n), , drop = FALSE]
    anchors$x           <- 1.22 * sin(ang)
    anchors$y           <- 1.22 * cos(ang)
    anchors$group       <- -1L
    anchors$.role       <- "axis"
    anchors$.angle      <- as.numeric(ang)
    anchors$.axis_label <- levs
    # Keep the copied fill/colour values: the anchors are never drawn, and an
    # NA here would train the discrete fill scale with an extra "NA" legend
    # key (and stop the colour and fill legends merging into one).

    out <- rbind(series, anchors)
    out$.vmax <- vmax
    out
  }
)

# ---- GeomSketchRadar ---------------------------------------------------------

#' @rdname geom_sketch_radar
#' @export
GeomSketchRadar <- ggplot2::ggproto(
  "GeomSketchRadar", ggplot2::Geom,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    colour    = "grey30",
    fill      = NA,
    linewidth = 0.6,
    linetype  = 1,
    alpha     = NA
  ),

  draw_key = draw_key_sketch_polygon,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "rmax",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight",
      "n_rings", "grid_colour", "label_size", "label_colour", "label_family",
      "na.rm")
  },

  draw_panel = function(data, panel_params, coord,
                         roughness     = 1,
                         bowing        = 1,
                         n_passes      = 2L,
                         seed          = NULL,
                         fill_style    = "hachure",
                         hachure_angle = 45,
                         hachure_gap   = NULL,
                         fill_weight   = 0.5,
                         n_rings       = 4L,
                         grid_colour   = "grey75",
                         label_size    = 3.2,
                         label_colour  = "grey30",
                         label_family  = NULL,
                         ...) {
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    # radar-cartesian -> npc, vertex by vertex (so it is correct under any coord)
    tx <- function(px, py) {
      d <- coord$transform(data.frame(x = px, y = py), panel_params)
      list(x = d$x, y = d$y)
    }

    axis_rows <- data[data$.role == "axis", , drop = FALSE]
    series    <- data[data$.role == "series", , drop = FALSE]
    angles    <- axis_rows$.angle
    labels    <- axis_rows$.axis_label
    n_axes    <- nrow(axis_rows)

    grobs <- list()

    # --- web: concentric rings -------------------------------------------------
    n_rings <- max(as.integer(n_rings), 1L)
    tt <- seq(0, 2 * pi, length.out = 73L)
    for (k in seq_len(n_rings)) {
      f  <- k / n_rings
      pp <- tx(f * sin(tt), f * cos(tt))
      grobs[[length(grobs) + 1L]] <- sketch_path_grob(
        x = pp$x, y = pp$y, roughness = sp$roughness * 0.5, bowing = sp$bowing,
        n_passes = 1L, seed = seed_offset(sp$seed, 500L + k),
        gp = gpar(col = grid_colour, lwd = 0.5 * ggplot2::.pt, lineend = "round")
      )
    }

    # --- web: radial spokes ----------------------------------------------------
    sp_x <- sp_y <- numeric(0); sp_id <- integer(0)
    for (j in seq_len(n_axes)) {
      pp <- tx(c(0, sin(angles[j])), c(0, cos(angles[j])))
      sp_x <- c(sp_x, pp$x); sp_y <- c(sp_y, pp$y); sp_id <- c(sp_id, rep(j, 2L))
    }
    grobs[[length(grobs) + 1L]] <- sketch_path_grob(
      x = sp_x, y = sp_y, id = sp_id,
      roughness = sp$roughness * 0.5, bowing = sp$bowing, n_passes = 1L,
      seed = seed_offset(sp$seed, 700L),
      gp = gpar(col = grid_colour, lwd = 0.5 * ggplot2::.pt, lineend = "round")
    )

    # --- axis labels -----------------------------------------------------------
    fam <- resolve_label_family(label_family)
    lp  <- tx(sin(angles), cos(angles))
    # grow text outward: hjust from the x-component, vjust from the y-component
    hj  <- 0.5 - 0.5 * sin(angles)
    vj  <- 0.5 - 0.5 * cos(angles)
    grobs[[length(grobs) + 1L]] <- grid::textGrob(
      label = labels, x = lp$x, y = lp$y,
      hjust = hj, vjust = vj, default.units = "npc",
      gp = gpar(col = label_colour, fontsize = label_size * ggplot2::.pt,
                fontfamily = fam)
    )

    # --- series polygons (back-to-front: first group drawn last, on top) -------
    gs <- split(seq_len(nrow(series)), series$group)
    for (gi in rev(seq_along(gs))) {
      idx   <- gs[[gi]]
      d     <- series[idx, , drop = FALSE]
      first <- d[1L, , drop = FALSE]
      pp    <- tx(d$x, d$y)

      diag <- sqrt(diff(range(pp$x))^2 + diff(range(pp$y))^2)
      gap  <- (hachure_gap %||% (0.09 * diag))
      gap  <- max(gap, 1e-3)

      grobs[[length(grobs) + 1L]] <- sketch_polygon_grob(
        x = pp$x, y = pp$y,
        roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, gi * 53L),
        fill_style = fill_style, hachure_angle = hachure_angle,
        hachure_gap = gap, fill_weight = fill_weight,
        fill_gp = gpar(col = scales::alpha(first$fill, first$alpha),
                       lineend = "round"),
        outline_gp = gpar(
          col = scales::alpha(first$colour, first$alpha),
          lwd = first$linewidth * ggplot2::.pt,
          lty = first$linetype, lineend = "round", linejoin = "round"
        )
      )
    }

    grid::gTree(children = do.call(grid::gList, grobs))
  }
)

# ---- geom_sketch_radar -------------------------------------------------------

#' Sketchy radar (spider) chart
#'
#' Draws a hand-drawn radar chart: each series is a closed polygon over evenly
#' spaced angular axes, with a roughened web (concentric rings, radial spokes,
#' and axis labels) drawn behind. Map `axis` (the variable that becomes each
#' spoke, usually a factor), `value` (its magnitude), and `group` (the series);
#' map `colour`/`fill` to the series too. Values are scaled to a common unit
#' radius (`rmax`), and each polygon takes any `fill_style` (including
#' `"watercolor"`). No new dependencies (cf. `ggradar`, `fmsb::radarchart()`).
#'
#' Like [geom_sketch_pie()], the chart lives in its own square coordinate space,
#' so pair it with `coord_equal()` and `theme_void()` (or `theme_sketch()`).
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires
#'   `axis` and `value`; usually also map `group` (and `colour`/`fill`) to the
#'   series.
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"sketch_radar"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param rmax Value mapped to the outer ring (`NULL` = the data maximum).
#' @param fill_style Polygon fill style; see [geom_sketch_polygon()]. Default
#'   `"hachure"`.
#' @param hachure_angle,hachure_gap,fill_weight Fill controls; see
#'   [geom_sketch_polygon()].
#' @param n_rings Number of concentric grid rings. Default 4.
#' @param grid_colour Colour of the web (rings + spokes). Default `"grey75"`.
#' @param label_size,label_colour,label_family Axis-label text controls.
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend?
#' @param inherit.aes Override default aesthetics?
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' skills <- data.frame(
#'   axis = rep(c("Speed", "Power", "Range", "Control", "Stamina"), 2),
#'   value = c(8, 6, 9, 5, 7, 5, 9, 4, 8, 6),
#'   who = rep(c("A", "B"), each = 5)
#' )
#' ggplot(skills, aes(axis = axis, value = value, group = who,
#'                    colour = who, fill = who)) +
#'   geom_sketch_radar(alpha = 0.3, seed = 1L) +
#'   coord_equal() +
#'   theme_void()
geom_sketch_radar <- function(mapping       = NULL,
                              data          = NULL,
                              stat          = "sketch_radar",
                              position      = "identity",
                              ...,
                              rmax          = NULL,
                              fill_style    = "hachure",
                              hachure_angle = 45,
                              hachure_gap   = NULL,
                              fill_weight   = 0.5,
                              n_rings       = 4L,
                              grid_colour   = "grey75",
                              label_size    = 3.2,
                              label_colour  = "grey30",
                              label_family  = NULL,
                              roughness     = 1,
                              bowing        = 1,
                              n_passes      = 2L,
                              seed          = NULL,
                              na.rm         = FALSE,
                              show.legend   = NA,
                              inherit.aes   = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchRadar,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      rmax = rmax, fill_style = fill_style, hachure_angle = hachure_angle,
      hachure_gap = hachure_gap, fill_weight = fill_weight,
      n_rings = as.integer(n_rings), grid_colour = grid_colour,
      label_size = label_size, label_colour = label_colour,
      label_family = label_family,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
