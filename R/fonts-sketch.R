# Layer 3 — reproducible handwriting fonts (v1.6)
# The sketch look of text comes from a handwriting *font* (ADR-0005). Relying on
# an OS-installed face is not reproducible across machines/CI. These helpers let
# a user register a font file once (via systemfonts) so the same family is
# available to font-aware devices (ragg, svglite, cairo) everywhere — no system
# install required. systemfonts is an optional dependency (Suggests).

#' Register a handwriting font for reproducible sketch text
#'
#' Registers a font file under a family name with \pkg{systemfonts} so that
#' [geom_sketch_text()], [theme_sketch()] (`base_family = "auto"`), and the
#' font resolver can find it on font-aware devices (ragg, svglite, cairo)
#' without installing the font system-wide. Call it once per session (e.g. in a
#' script or `.Rprofile`); ship the `.ttf`/`.otf` alongside your project for
#' fully reproducible output.
#'
#' @param family Family name to register the font under (e.g. `"Caveat"`). This
#'   is the name you then pass to `family =` or `base_family =`.
#' @param plain Path to the regular/plain font file (`.ttf` or `.otf`).
#' @param bold,italic,bolditalic Optional paths to the bold/italic faces;
#'   default to `plain`.
#' @param ... Passed to [systemfonts::register_font()].
#' @return Invisibly, the registered `family` name.
#' @family sketch-theme
#' @export
#' @examples
#' \dontrun{
#' # Download Caveat from Google Fonts, then:
#' register_sketch_font("Caveat", "fonts/Caveat-Regular.ttf")
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_sketch_point(seed = 1L) +
#'   theme_sketch(base_family = "Caveat")
#' }
register_sketch_font <- function(family, plain,
                                 bold       = plain,
                                 italic     = plain,
                                 bolditalic = plain,
                                 ...) {
  if (!requireNamespace("systemfonts", quietly = TRUE)) {
    cli::cli_abort(c(
      "{.pkg systemfonts} is required to register fonts.",
      "i" = "Install it with {.code install.packages(\"systemfonts\")}."
    ))
  }
  if (!file.exists(plain)) {
    cli::cli_abort("Font file {.path {plain}} does not exist.")
  }
  systemfonts::register_font(
    name = family, plain = plain, bold = bold,
    italic = italic, bolditalic = bolditalic, ...
  )
  cli::cli_inform(c("v" = "Registered font family {.val {family}}."))
  invisible(family)
}
