# Layer 3 - geom_sketch_smooth() (P4-T4)
# A sketchy fitted line plus an optional roughened confidence band.
# stat_smooth supplies x, y (fit) and ymin/ymax (CI when se = TRUE).

# ---- GeomSketchSmooth -------------------------------------------------------

#' @rdname geom_sketch_smooth
#' @export
GeomSketchSmooth <- ggplot2::ggproto(
  "GeomSketchSmooth", ggplot2::Geom,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    colour    = "#3366FF",
    fill      = "grey60",
    linewidth = 1,
    linetype  = 1,
    weight    = 1,
    alpha     = 0.4
  ),

  draw_key = draw_key_sketch_path,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight",
      "se", "na.rm")
  },

  draw_group = function(data, panel_params, coord,
                         roughness     = 1,
                         bowing        = 1,
                         n_passes      = 2L,
                         seed          = NULL,
                         fill_style    = "hachure",
                         hachure_angle = 45,
                         hachure_gap   = NULL,
                         fill_weight   = 0.5,
                         se            = TRUE,
                         ...) {
    if (nrow(data) < 2L) return(nullGrob())

    data <- data[order(data$x), , drop = FALSE]
    sp   <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    first <- data[1L, , drop = FALSE]

    grobs <- list()

    # --- confidence band (drawn first, under the line) ---
    has_ci <- se && all(c("ymin", "ymax") %in% names(data)) &&
      !any(is.na(data$ymin)) && !any(is.na(data$ymax))
    if (has_ci) {
      poly <- data.frame(
        x = c(data$x, rev(data$x)),
        y = c(data$ymax, rev(data$ymin))
      )
      pc  <- coord$transform(poly, panel_params)
      gap <- hachure_gap %||%
        (0.06 * sqrt(diff(range(pc$x))^2 + diff(range(pc$y))^2))
      gap <- max(gap, 1e-3)

      grobs[[length(grobs) + 1L]] <- sketch_polygon_grob(
        x             = pc$x,
        y             = pc$y,
        roughness     = sp$roughness * 0.6,
        bowing        = sp$bowing,
        n_passes      = 1L,
        seed          = seed_offset(sp$seed, 11L),
        fill_style    = fill_style,
        hachure_angle = hachure_angle,
        hachure_gap   = gap,
        fill_weight   = fill_weight,
        fill_gp       = gpar(
          col = scales::alpha(first$fill, first$alpha),
          lineend = "round"
        ),
        outline_gp    = gpar(
          col = scales::alpha(first$fill, first$alpha),
          lwd = 0.5 * ggplot2::.pt, lineend = "round"
        )
      )
    }

    # --- fitted line (on top) ---
    lc <- coord$transform(data[, c("x", "y")], panel_params)
    grobs[[length(grobs) + 1L]] <- sketch_path_grob(
      x         = lc$x,
      y         = lc$y,
      roughness = sp$roughness,
      bowing    = sp$bowing,
      n_passes  = sp$n_passes,
      seed      = seed_offset(sp$seed, 22L),
      gp        = outline_gpar(
        colour    = first$colour,
        linewidth = first$linewidth,
        linetype  = first$linetype,
        alpha     = NA
      )
    )

    do.call(gList, grobs)
  }
)

# ---- geom_sketch_smooth -----------------------------------------------------

#' Sketchy smoothed conditional mean
#'
#' Draws a hand-drawn fitted line with an optional roughened confidence band - 
#' the sketch analogue of [ggplot2::geom_smooth()].  The fit is computed by
#' [ggplot2::stat_smooth()] (`method`, `formula`, `se`, etc. pass through).
#'
#' @inheritParams geom_sketch_ribbon
#' @param method,formula,se Passed to [ggplot2::stat_smooth()]. `se = TRUE`
#'   draws the roughened confidence band.
#' @param fill_style Fill style for the confidence band. Default `"hachure"`.
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_sketch_point(seed = 1L) +
#'   geom_sketch_smooth(method = "lm", formula = y ~ x, seed = 2L) +
#'   theme_sketch()
geom_sketch_smooth <- function(mapping       = NULL,
                                data          = NULL,
                                stat          = "smooth",
                                position      = "identity",
                                ...,
                                method        = NULL,
                                formula       = NULL,
                                se            = TRUE,
                                roughness     = 1,
                                bowing        = 1,
                                n_passes      = 2L,
                                seed          = NULL,
                                fill_style    = "hachure",
                                hachure_angle = 45,
                                hachure_gap   = NULL,
                                fill_weight   = 0.5,
                                na.rm         = FALSE,
                                show.legend   = NA,
                                inherit.aes   = TRUE) {
  params <- list(
    roughness     = roughness,
    bowing        = bowing,
    n_passes      = as.integer(n_passes),
    seed          = seed,
    fill_style    = fill_style,
    hachure_angle = hachure_angle,
    hachure_gap   = hachure_gap,
    fill_weight   = fill_weight,
    se            = se,
    na.rm         = na.rm,
    ...
  )
  if (!is.null(method))  params$method  <- method
  if (!is.null(formula)) params$formula <- formula

  ggplot2::layer(
    data        = data,
    mapping     = mapping,
    stat        = stat,
    geom        = GeomSketchSmooth,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = params
  )
}
