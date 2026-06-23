# Layer 3 - geom_sketch_bracket() (v1.5 annotation toolkit)
# A hand-drawn significance / comparison bracket: a horizontal bar spanning
# xmin..xmax at height y, with short tips dropping toward the data, and an
# optional label centred above. The sketch counterpart of a ggsignif bracket.

# ---- GeomSketchBracket ------------------------------------------------------

#' @rdname geom_sketch_bracket
#' @export
GeomSketchBracket <- ggplot2::ggproto(
  "GeomSketchBracket", ggplot2::Geom,

  required_aes = c("xmin", "xmax", "y"),

  default_aes = ggplot2::aes(
    label     = NA,
    colour    = "black",
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA,
    size      = 3.88
  ),

  draw_key = draw_key_sketch_path,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed", "tip_length", "family",
      "label_vjust", "na.rm")
  },

  draw_panel = function(data, panel_params, coord,
                         roughness = 0.8, bowing = 0.4, n_passes = 2L,
                         seed = NULL, tip_length = 0.02, family = NULL,
                         label_vjust = -0.35, ...) {
    if (nrow(data) == 0L) return(nullGrob())

    sp  <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    fam <- resolve_label_family(family)

    grobs <- list()
    for (i in seq_len(nrow(data))) {
      row <- data[i, , drop = FALSE]
      # Transform the bracket corners to npc; the tips drop by tip_length (a
      # fraction of panel height) toward the data.
      pts <- coord$transform(
        data.frame(x = c(row$xmin, row$xmin, row$xmax, row$xmax),
                   y = rep(row$y, 4L)),
        panel_params
      )
      bx <- pts$x
      by <- c(pts$y[1L] - tip_length, pts$y[2L], pts$y[3L],
              pts$y[4L] - tip_length)

      grobs[[length(grobs) + 1L]] <- sketch_path_grob(
        x = bx, y = by,
        roughness = sp$roughness, bowing = sp$bowing, n_passes = sp$n_passes,
        seed = seed_offset(sp$seed, i * 53L),
        gp = outline_gpar(colour = row$colour, linewidth = row$linewidth,
                          linetype = row$linetype, alpha = row$alpha)
      )

      lab <- row$label
      if (!is.null(lab) && !is.na(lab) && nzchar(as.character(lab))) {
        grobs[[length(grobs) + 1L]] <- grid::textGrob(
          label = as.character(lab),
          x = grid::unit((bx[2L] + bx[3L]) / 2, "npc"),
          y = grid::unit(pts$y[2L], "npc"),
          vjust = label_vjust,
          gp = grid::gpar(
            col = scales::alpha(row$colour, row$alpha),
            fontfamily = fam,
            fontsize = row$size * ggplot2::.pt
          )
        )
      }
    }
    do.call(gList, grobs)
  }
)

# ---- geom_sketch_bracket ----------------------------------------------------

#' Sketchy significance / comparison brackets
#'
#' Draws a hand-drawn bracket spanning `xmin` to `xmax` at height `y`, with short
#' tips dropping toward the data and an optional `label` (e.g. a p-value or
#' "n.s.") centred above. It is the sketch counterpart of a `ggsignif` bracket:
#' useful for marking pairwise comparisons on boxplots, bars, or violins.
#'
#' Brackets are usually one-off annotations, so supply them with their own
#' `data` and `inherit.aes = FALSE` rather than inheriting the plot's mapping.
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires
#'   `xmin`, `xmax`, and `y`; `label` is optional.
#' @param data Data with one row per bracket.
#' @param stat Statistical transformation. Default `"identity"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param tip_length Length of the downward end tips, as a fraction of panel
#'   height. Default `0.02`. Use `0` for a plain bar.
#' @param family Font family for the label. Defaults to the same family as
#'   [theme_sketch()] (`getOption("ggsketch.base_family", "")`, i.e. the device
#'   default), so the label matches the plot's other text; set
#'   `options(ggsketch.base_family = "auto")` for a handwriting face, or pass an
#'   explicit family here.
#' @param label_vjust Vertical justification of the label relative to the bar
#'   (negative nudges it above). Default `-0.35`.
#' @param roughness Non-negative roughness (0 = straight). Default 0.8.
#' @param bowing Non-negative bowing multiplier. Default 0.4 (kept low so the bar
#'   stays readable).
#' @param n_passes Number of stroke passes. Default 2.
#' @param seed Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend? Default `FALSE`.
#' @param inherit.aes Inherit aesthetics from the plot? Default `FALSE`.
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' brackets <- data.frame(xmin = 1, xmax = 2, y = 45, label = "p = 0.01")
#' ggplot(mpg, aes(drv, hwy)) +
#'   geom_sketch_boxplot(seed = 1L) +
#'   geom_sketch_bracket(
#'     data = brackets,
#'     aes(xmin = xmin, xmax = xmax, y = y, label = label),
#'     family = "", seed = 2L
#'   ) +
#'   theme_sketch()
geom_sketch_bracket <- function(mapping     = NULL,
                                 data        = NULL,
                                 stat        = "identity",
                                 position    = "identity",
                                 ...,
                                 tip_length  = 0.02,
                                 family      = NULL,
                                 label_vjust = -0.35,
                                 roughness   = 0.8,
                                 bowing      = 0.4,
                                 n_passes    = 2L,
                                 seed        = NULL,
                                 na.rm       = FALSE,
                                 show.legend = FALSE,
                                 inherit.aes = FALSE) {
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchBracket,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(
      tip_length = tip_length, family = family, label_vjust = label_vjust,
      roughness = roughness, bowing = bowing, n_passes = as.integer(n_passes),
      seed = seed, na.rm = na.rm, ...
    )
  )
}
