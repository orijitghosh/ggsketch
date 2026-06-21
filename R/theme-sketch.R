# Layer 3 — theme_sketch() (P2-T5, P6-T1)
# Typography + panel aesthetics with light and dark presets. The sketch *look*
# of the marks comes from the geoms (Layer 2 rough grobs); the theme provides a
# matching muted palette.

#' Pick the first available handwriting font, or fall back to the device default
#'
#' Cosmetic only (ADR-0005): the sketch look comes from geometry, not fonts.
#' Returns `""` (device default) when none of `fonts` are installed, or when
#' `systemfonts` is not available - never errors. The default list tries the
#' preferred (brand) handwriting faces first, then falls back to handwriting
#' fonts that ship with Windows / macOS so a sketchy face is usually found
#' without the user installing anything.
#'
#' Variable fonts (e.g. Caveat ships as `Caveat-VariableFont_wght.ttf`) cannot be
#' rendered by name on ragg/svglite - the device silently falls back to the
#' default family, which is why a handwriting face often "does not show up".
#' systemfonts does not reliably flag variable fonts, so we pin the matched
#' family to a renderable instance under a derived name and return that. The pin
#' is idempotent (cached in the registry) and a no-op alias for plain fonts.
#' @param fonts Candidate families, tried in order.
#' @return A single font family string (`""` = device default).
#' @noRd
resolve_sketch_font <- function(fonts = sketch_font_candidates()) {
  if (!requireNamespace("systemfonts", quietly = TRUE)) return("")
  sys <- systemfonts::system_fonts()
  # Fonts registered via register_sketch_font() (or a previous pin below) live
  # in the systemfonts registry, not system_fonts(); honour both.
  reg <- tryCatch(systemfonts::registry_fonts(), error = function(e) NULL)
  registered <- unique(reg$family)

  for (f in fonts) {
    if (f %in% registered) return(f)              # already renderable by name
    if (!(f %in% sys$family)) next
    pinned <- paste0(f, " (ggsketch)")
    if (pinned %in% registered) return(pinned)
    if (pin_sketch_font(f, sys, pinned)) return(pinned)
    return(f)                                     # best effort if the pin fails
  }
  ""
}

#' Pin an installed family to a renderable instance under `name`
#'
#' Works around devices not rendering some installed faces (notably variable
#' fonts) by name. Prefers `systemfonts::register_variant()` (handles variable
#' axes), falling back to `register_font()` with the regular face's file path.
#' Returns `TRUE` on success.
#' @noRd
pin_sketch_font <- function(family, sys, name) {
  if ("register_variant" %in% getNamespaceExports("systemfonts")) {
    ok <- tryCatch({
      systemfonts::register_variant(name = name, family = family)
      TRUE
    }, error = function(e) FALSE)
    if (ok) return(TRUE)
  }
  rows  <- sys[sys$family == family, , drop = FALSE]
  plain <- rows[grepl("regular|book|normal", tolower(rows$style)), , drop = FALSE]
  if (nrow(plain) == 0L) plain <- rows[1L, , drop = FALSE]
  tryCatch({
    systemfonts::register_font(name = name, plain = plain$path[[1L]])
    TRUE
  }, error = function(e) FALSE)
}

#' Default handwriting-font candidates, most preferred first
#'
#' Preferred (brand) faces lead, then handwriting fonts preinstalled on Windows
#' and macOS so the resolver usually finds one without the user installing
#' anything. `Comic Sans MS` is the last resort (near-universal).
#' @return Character vector of font families.
#' @noRd
sketch_font_candidates <- function() {
  c(
    # preferred / brand (best match for the pkgdown theme)
    "Caveat", "xkcd", "Humor Sans", "Permanent Marker", "Indie Flower",
    # macOS preinstalled
    "Chalkboard", "Chalkboard SE", "Bradley Hand",
    # Windows preinstalled
    "Segoe Print", "Ink Free", "Bradley Hand ITC", "Segoe Script",
    # near-universal last resort
    "Comic Sans MS"
  )
}

#' A hand-drawn theme for ggplot2
#'
#' A sketch-style theme based on [ggplot2::theme_bw()] with a muted palette to
#' match the rough geoms.  Light (default) and dark presets
#' are available via `dark`.  The sketchiness of the *marks* comes from the
#' geoms themselves; this theme styles the surrounding frame, typography, and
#' background.
#'
#' @param base_size Base font size (default 11).
#' @param base_family Base font family. Defaults to
#'   `getOption("ggsketch.base_family", "")`; `""` uses the device default.
#'   `"auto"` picks the first installed handwriting font (see
#'   [ggsketch_check_fonts()]), falling back to the device default. Set
#'   `options(ggsketch.base_family = "auto")` to make every sketch plot's text
#'   (titles, axes, legend) use handwriting, not just the labels drawn by
#'   [geom_sketch_text()] / [geom_sketch_bracket()]. Or pass an explicit family
#'   name.
#' @param base_line_size Line size (default `base_size / 22`).
#' @param base_rect_size Rect size (default `base_size / 22`).
#' @param dark If `TRUE`, use the dark "chalkboard" preset. Default `FALSE`
#'   (light "paper" preset).
#' @param rough_frame If `TRUE`, draw the *frame* itself hand-drawn: the major
#'   gridlines, panel border, and axis ticks become roughened sketch grobs (via
#'   [element_sketch_line()] / [element_sketch_rect()]) so the frame matches the
#'   marks. Default `FALSE`.
#' @param roughness Roughness for the rough frame (only used when
#'   `rough_frame = TRUE`). Default 0.5.
#' @param seed Integer seed for the rough frame, for reproducible wobble. `NULL`
#'   uses `getOption("ggsketch.seed", 1L)`.
#' @return A `ggplot2::theme` object.
#' @family sketch-theme
#' @export
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(wt, mpg)) + geom_sketch_point(seed = 1L)
#' p + theme_sketch()
#' p + theme_sketch(dark = TRUE)
#' p + theme_sketch(rough_frame = TRUE)
theme_sketch <- function(base_size      = 11,
                          base_family    = getOption("ggsketch.base_family", ""),
                          base_line_size = base_size / 22,
                          base_rect_size = base_size / 22,
                          dark           = FALSE,
                          rough_frame    = FALSE,
                          roughness      = 0.5,
                          seed           = NULL) {
  if (identical(base_family, "auto")) base_family <- resolve_sketch_font()

  pal <- if (dark) {
    list(paper = "#1E1E24", ink = "#E8E6DF", ink_soft = "#B8B6AF",
         grid_major = "#3A3A44", grid_minor = "#2C2C34", border = "#9A9AA2")
  } else {
    list(paper = "#FFFEF5", ink = "grey20", ink_soft = "grey40",
         grid_major = "grey85", grid_minor = "grey92", border = "grey40")
  }

  t <- ggplot2::theme_bw(
    base_size      = base_size,
    base_family    = base_family,
    base_line_size = base_line_size,
    base_rect_size = base_rect_size
  ) %+replace%
    ggplot2::theme(
      panel.grid.major  = ggplot2::element_line(colour = pal$grid_major,
                                                linewidth = 0.3),
      panel.grid.minor  = ggplot2::element_line(colour = pal$grid_minor,
                                                linewidth = 0.2),
      panel.border      = ggplot2::element_rect(colour = pal$border, fill = NA,
                                                linewidth = 0.8),
      panel.background  = ggplot2::element_rect(fill = pal$paper, colour = NA),
      plot.background   = ggplot2::element_rect(fill = pal$paper, colour = NA),
      axis.ticks        = ggplot2::element_line(colour = pal$border,
                                                linewidth = 0.4),
      axis.text         = ggplot2::element_text(colour = pal$ink_soft,
                                                size = base_size * 0.8),
      axis.title        = ggplot2::element_text(colour = pal$ink,
                                                size = base_size),
      plot.title        = ggplot2::element_text(colour = pal$ink, face = "bold",
                                                size = base_size * 1.2,
                                                hjust = 0,
                                                margin = ggplot2::margin(b = 8)),
      plot.subtitle     = ggplot2::element_text(colour = pal$ink_soft,
                                                size = base_size * 0.9,
                                                hjust = 0,
                                                margin = ggplot2::margin(b = 8)),
      plot.caption      = ggplot2::element_text(colour = pal$ink_soft,
                                                size = base_size * 0.7,
                                                hjust = 1),
      legend.background = ggplot2::element_rect(fill = pal$paper, colour = NA),
      legend.key        = ggplot2::element_rect(fill = pal$paper, colour = NA),
      legend.text       = ggplot2::element_text(colour = pal$ink_soft),
      legend.title      = ggplot2::element_text(colour = pal$ink),
      complete          = TRUE
    )

  if (isTRUE(rough_frame)) {
    t <- t %+replace% ggplot2::theme(
      panel.grid.major = element_sketch_line(
        colour = pal$grid_major, linewidth = 0.3,
        roughness = roughness * 0.8, bowing = roughness, seed = seed
      ),
      panel.border = element_sketch_rect(
        colour = pal$border, fill = NA, linewidth = 0.8,
        roughness = roughness, bowing = roughness * 0.6,
        seed = seed_offset(resolve_seed(seed), 9001L)
      ),
      axis.ticks = element_sketch_line(
        colour = pal$border, linewidth = 0.4,
        roughness = roughness, bowing = roughness,
        seed = seed_offset(resolve_seed(seed), 4242L)
      )
    )
  }

  t
}

#' Check for optional handwriting fonts
#'
#' Diagnoses whether a handwriting-style font is available on this device.
#' The sketch *look* in ggsketch comes from geometry, not fonts, so this is
#' purely cosmetic (ADR-0005).
#'
#' @param fonts Character vector of font families to check. Defaults to the
#'   same candidate list [geom_sketch_text()] resolves against — preferred
#'   handwriting faces first, then fonts preinstalled on Windows / macOS.
#' @return Invisibly returns a logical vector (font available?); prints a
#'   formatted report.
#' @family sketch-theme
#' @export
ggsketch_check_fonts <- function(fonts = sketch_font_candidates()) {
  if (!requireNamespace("systemfonts", quietly = TRUE)) {
    cli::cli_inform(c(
      "!" = "Install {.pkg systemfonts} to detect system fonts.",
      "i" = "ggsketch works fine without a handwriting font."
    ))
    return(invisible(stats::setNames(rep(NA, length(fonts)), fonts)))
  }

  sys_fonts <- systemfonts::system_fonts()
  available <- stats::setNames(
    vapply(fonts, function(f) any(sys_fonts$family == f), logical(1L)),
    fonts
  )

  if (any(available)) {
    cli::cli_inform(c(
      "v" = "Available handwriting fonts:",
      " " = paste(" ", names(available)[available], collapse = "\n")
    ))
  } else {
    cli::cli_inform(c(
      "!" = "No handwriting fonts found. ggsketch will use the default device font.",
      "i" = "The sketch look comes from geometry, not fonts."
    ))
  }
  invisible(available)
}
