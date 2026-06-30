# Layer 2/3 - paper ground theme element (v2)
# element_sketch_paper() is a panel-background element that paints a simulated
# paper ground (ruled / graph / dotted / aged / blueprint / chalkboard / kraft)
# behind the data. Like the other sketch elements it prepends an
# "element_sketch_*" S3 class and supplies an element_grob method; the ruling is
# spaced in physical inches measured from the live panel viewport.

#' Paper-ground theme element
#'
#' A panel-background element that paints a simulated paper texture behind the
#' data: ruled notebook lines, a graph grid, a dot grid, aged blotches, or a
#' blueprint / chalkboard / kraft ground. Use it as `panel.background` in
#' [ggplot2::theme()], or -- more simply -- via `theme_sketch(paper = )`.
#' Everything is drawn as vector primitives, so it reproduces on every device.
#'
#' @param kind A paper from [sketch_papers()].
#' @param ground Optional override for the ground (fill) colour.
#' @param seed Integer seed for the aged blotches.
#' @param ... Passed to [ggplot2::element_rect()].
#' @return A ggplot2 theme element carrying an `element_sketch_paper` subclass.
#' @family sketch-paper
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_sketch_point(seed = 1L) +
#'   theme_sketch() +
#'   theme(panel.background = element_sketch_paper("graph"))
element_sketch_paper <- function(kind = "notebook", ground = NULL,
                                 seed = NULL, ...) {
  check_paper(kind)
  base_ground <- ground %||% (paper_spec(kind)$ground %||% NA)
  el <- ggplot2::element_rect(fill = base_ground, colour = NA, ...)
  attr(el, "sk_paper_kind")   <- kind
  attr(el, "sk_paper_ground") <- ground
  attr(el, "sk_seed")         <- seed
  class(el) <- c("element_sketch_paper", class(el))
  el
}

#' @exportS3Method ggplot2::element_grob
element_grob.element_sketch_paper <- function(element, x = 0.5, y = 0.5,
                                              width = 1, height = 1,
                                              fill = NULL, colour = NULL,
                                              ...) {
  kind <- sk_get(element, "sk_paper_kind", "notebook")
  if (identical(kind, "none")) return(ggplot2::zeroGrob())

  # Couple watercolour wash feathering to this paper's tooth (C3). The panel
  # background draws before the data, so washes in the same panel read it.
  options(ggsketch.wash_grain = paper_grain(kind))

  # Physical panel size sets the ruling pitch.
  w_in <- tryCatch(as.numeric(convertWidth(unit(1, "npc"), "inches")),
                   error = function(e) 6)
  h_in <- tryCatch(as.numeric(convertHeight(unit(1, "npc"), "inches")),
                   error = function(e) 4)

  prim <- paper_primitives(kind, width_in = w_in, height_in = h_in,
                           seed = sk_get(element, "sk_seed", NULL))
  if (is.null(prim)) return(ggplot2::zeroGrob())

  ground <- sk_get(element, "sk_paper_ground", NULL) %||% prim$ground
  grobs  <- list()

  # Ground fill.
  if (!is.null(ground) && !is.na(ground)) {
    grobs[[length(grobs) + 1L]] <- rectGrob(gp = gpar(fill = ground, col = NA))
  }

  # Aged blotches (under the ruling).
  for (b in prim$blotches %||% list()) {
    grobs[[length(grobs) + 1L]] <- polygonGrob(
      x = unit(b$x, "npc"), y = unit(b$y, "npc"),
      gp = gpar(fill = b$fill, col = NA)
    )
  }

  # Ruling / grid line groups.
  for (s in prim$segs) {
    grobs[[length(grobs) + 1L]] <- segmentsGrob(
      x0 = unit(s$x0, "npc"), y0 = unit(s$y0, "npc"),
      x1 = unit(s$x1, "npc"), y1 = unit(s$y1, "npc"),
      gp = gpar(col = s$colour, lwd = s$lwd)
    )
  }

  # Dot grid.
  if (!is.null(prim$dots)) {
    d <- prim$dots
    grobs[[length(grobs) + 1L]] <- circleGrob(
      x = unit(d$x, "npc"), y = unit(d$y, "npc"),
      r = unit(d$r_in, "inches"),
      gp = gpar(fill = d$colour, col = NA)
    )
  }

  if (length(grobs) == 0L) return(ggplot2::zeroGrob())
  do.call(grid::grobTree, grobs)
}
