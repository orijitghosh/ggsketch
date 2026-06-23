# Layer 3 - geom_sketch_lollipop() (v1.7)
# A lollipop chart: a roughened stem from a baseline to each value, capped with
# a sketch point. Composes the existing stem (sketch_path_grob) and head
# (sketch_point_grob) grobs, so no new geometry. The sketch take on the
# common stem-and-dot chart (cf. ggalt::geom_lollipop()).

# ---- GeomSketchLollipop -----------------------------------------------------

#' @rdname geom_sketch_lollipop
#' @export
GeomSketchLollipop <- ggplot2::ggproto(
  "GeomSketchLollipop", ggplot2::Geom,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    colour    = "black",
    linewidth = 0.5,
    linetype  = 1,
    size      = 2.5,
    alpha     = NA
  ),

  draw_key = draw_key_sketch_point,

  parameters = function(self, extra = FALSE) {
    c("baseline", "horizontal", "roughness", "point_roughness",
      "bowing", "n_passes", "seed", "na.rm")
  },

  # Expand the value axis to include the baseline, so each full stem is visible
  # (otherwise the stems run off the panel toward an off-screen baseline).
  setup_data = function(data, params) {
    base <- params$baseline %||% 0
    if (isTRUE(params$horizontal)) {
      data$xmin <- pmin(data$x, base)
      data$xmax <- pmax(data$x, base)
    } else {
      data$ymin <- pmin(data$y, base)
      data$ymax <- pmax(data$y, base)
    }
    data
  },

  draw_panel = function(data, panel_params, coord,
                         baseline        = 0,
                         horizontal      = FALSE,
                         roughness       = 0.8,
                         point_roughness = 0.4,
                         bowing          = 0.4,
                         n_passes        = 2L,
                         seed            = NULL,
                         ...) {
    if (nrow(data) == 0L) return(nullGrob())
    sp <- resolve_sketch_params(roughness, bowing, n_passes, seed)

    base_df <- data.frame(
      x = if (horizontal) baseline else data$x,
      y = if (horizontal) data$y   else baseline
    )
    basep <- coord$transform(base_df, panel_params)
    tipp  <- coord$transform(data.frame(x = data$x, y = data$y), panel_params)

    # --- stems (one roughened path per row) ---
    stems <- lapply(seq_len(nrow(data)), function(i) {
      sketch_path_grob(
        x = c(basep$x[i], tipp$x[i]), y = c(basep$y[i], tipp$y[i]),
        roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, i * 53L),
        gp = outline_gpar(
          colour = data$colour[i], linewidth = data$linewidth[i],
          linetype = data$linetype[i], alpha = data$alpha[i]
        )
      )
    })

    # --- heads (sketch points at the tips) ---
    head <- sketch_point_grob(
      x = tipp$x, y = tipp$y, size = data$size,
      roughness = point_roughness, n_passes = sp$n_passes,
      seed = seed_offset(sp$seed, 7000L),
      gp = gpar(
        col = scales::alpha(data$colour, data$alpha),
        lwd = data$linewidth * ggplot2::.pt, lineend = "round"
      )
    )

    do.call(gList, c(stems, list(head)))
  }
)

# ---- geom_sketch_lollipop ---------------------------------------------------

#' Sketchy lollipop chart
#'
#' Draws a hand-drawn lollipop: a roughened stem from a `baseline` to each
#' value, capped with a sketch point. A tidy alternative to bars for ranked or
#' sparse values (cf. `ggalt::geom_lollipop()`).
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires `x`
#'   and `y`.
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param baseline Value the stems grow from. Default `0`.
#' @param horizontal If `TRUE`, stems run horizontally from `baseline` on the
#'   x-axis (pair with a discrete `y`). Default `FALSE`.
#' @param roughness Stem roughness (0 = straight). Default 0.8.
#' @param point_roughness Roughness of the head points. Default 0.4.
#' @param bowing Non-negative bowing multiplier. Default 0.4 (kept low so tall
#'   stems read straight).
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend?
#' @param inherit.aes Override default aesthetics?
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(g = c("Alpha", "Bravo", "Charlie", "Delta"),
#'                  v = c(34, 51, 22, 47))
#' ggplot(df, aes(g, v)) +
#'   geom_sketch_lollipop(colour = "#7B241C", seed = 1L) +
#'   theme_sketch()
geom_sketch_lollipop <- function(mapping         = NULL,
                                 data            = NULL,
                                 stat            = "identity",
                                 position        = "identity",
                                 ...,
                                 baseline        = 0,
                                 horizontal      = FALSE,
                                 roughness       = 0.8,
                                 point_roughness = 0.4,
                                 bowing          = 0.4,
                                 n_passes        = 2L,
                                 seed            = NULL,
                                 na.rm           = FALSE,
                                 show.legend     = NA,
                                 inherit.aes     = TRUE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchLollipop,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      baseline = baseline, horizontal = horizontal,
      roughness = roughness, point_roughness = point_roughness,
      bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
