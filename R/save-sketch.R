# Layer 3 - ggsketch_save() (v2.0)
# A font-aware ggsave() wrapper. Handwriting families and paper textures only
# render right on font-aware devices; the base grDevices raster/pdf devices on
# some platforms miss registered fonts (systemfonts) entirely. This picks the
# right device per format so the common "my handwriting font disappeared in the
# saved file" support footgun goes away.

#' Save a sketch plot with a font-aware device
#'
#' A drop-in [ggplot2::ggsave()] wrapper that picks a device which can see
#' fonts registered with [register_sketch_font()] / \pkg{systemfonts}:
#'
#' * `.png` / `.jpeg` / `.jpg` / `.tiff` -- \pkg{ragg} when installed (falls
#'   back to the ggsave default with a hint).
#' * `.svg` -- \pkg{svglite} when installed.
#' * `.pdf` -- `cairo_pdf` (embeds registered fonts; the base `pdf` device
#'   does not).
#' * `.eps` / `.ps` -- `cairo_ps`, with a warning: PostScript cannot embed
#'   handwriting faces reliably, so prefer PDF.
#'
#' @param filename File to write; the extension picks the device.
#' @param plot Plot to save. Default [ggplot2::last_plot()].
#' @param width,height Size in inches. Defaults 8 x 5.
#' @param dpi Resolution for raster formats. Default 300.
#' @param device Override the chosen device (a function or name); passed
#'   through to [ggplot2::ggsave()] untouched when supplied.
#' @param ... Other arguments passed on to [ggplot2::ggsave()].
#' @return Invisibly, `filename`.
#' @family sketch-theme
#' @export
#' @examples
#' \donttest{
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(wt, mpg)) + geom_sketch_point(seed = 1L) +
#'   theme_sketch()
#' out <- file.path(tempdir(), "sketch.png")
#' ggsketch_save(out, p)
#' unlink(out)
#' }
ggsketch_save <- function(filename,
                          plot   = ggplot2::last_plot(),
                          width  = 8,
                          height = 5,
                          dpi    = 300,
                          device = NULL,
                          ...) {
  if (is.null(device)) {
    ext <- tolower(tools::file_ext(filename))
    device <- switch(ext,
      png  = if (requireNamespace("ragg", quietly = TRUE)) ragg::agg_png,
      jpg  = ,
      jpeg = if (requireNamespace("ragg", quietly = TRUE)) ragg::agg_jpeg,
      tiff = if (requireNamespace("ragg", quietly = TRUE)) ragg::agg_tiff,
      svg  = if (requireNamespace("svglite", quietly = TRUE)) svglite::svglite,
      pdf  = grDevices::cairo_pdf,
      eps  = ,
      ps   = {
        cli::cli_warn(c(
          "PostScript cannot embed handwriting faces reliably.",
          "i" = "Prefer {.code ggsketch_save(\"plot.pdf\")}."
        ))
        grDevices::cairo_ps
      },
      NULL
    )
    if (is.null(device) && ext %in% c("png", "jpg", "jpeg", "tiff", "svg")) {
      cli::cli_inform(c(
        "i" = "Falling back to the default {.fn ggplot2::ggsave} device.",
        " " = "Install {.pkg {if (ext == 'svg') 'svglite' else 'ragg'}} so
               registered handwriting fonts render in {.val {ext}} output."
      ))
    }
  }
  ggplot2::ggsave(filename, plot = plot, device = device,
                  width = width, height = height, dpi = dpi, ...)
  invisible(filename)
}
