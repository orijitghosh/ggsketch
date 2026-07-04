# Save a sketch plot with a font-aware device

A drop-in
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html)
wrapper that picks a device which can see fonts registered with
[`register_sketch_font()`](https://orijitghosh.github.io/ggsketch/reference/register_sketch_font.md)
/ systemfonts:

## Usage

``` r
ggsketch_save(
  filename,
  plot = ggplot2::last_plot(),
  width = 8,
  height = 5,
  dpi = 300,
  device = NULL,
  ...
)
```

## Arguments

- filename:

  File to write; the extension picks the device.

- plot:

  Plot to save. Default
  [`ggplot2::last_plot()`](https://ggplot2.tidyverse.org/reference/get_last_plot.html).

- width, height:

  Size in inches. Defaults 8 x 5.

- dpi:

  Resolution for raster formats. Default 300.

- device:

  Override the chosen device (a function or name); passed through to
  [`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html)
  untouched when supplied.

- ...:

  Other arguments passed on to
  [`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html).

## Value

Invisibly, `filename`.

## Details

- `.png` / `.jpeg` / `.jpg` / `.tiff` – ragg when installed (falls back
  to the ggsave default with a hint).

- `.svg` – svglite when installed.

- `.pdf` – `cairo_pdf` (embeds registered fonts; the base `pdf` device
  does not).

- `.eps` / `.ps` – `cairo_ps`, with a warning: PostScript cannot embed
  handwriting faces reliably, so prefer PDF.

## See also

Other sketch-theme:
[`CoordSketch`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch.md),
[`CoordSketchPolar`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch_polar.md),
[`element_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md),
[`ggsketch_check_fonts()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_check_fonts.md),
[`register_sketch_font()`](https://orijitghosh.github.io/ggsketch/reference/register_sketch_font.md),
[`scale_pressure_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_pressure_continuous.md),
[`scale_roughness_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_roughness_continuous.md),
[`scale_sketch`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md),
[`scale_tone_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_tone_continuous.md),
[`sketch_palette()`](https://orijitghosh.github.io/ggsketch/reference/sketch_palette.md),
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)

## Examples

``` r
# \donttest{
library(ggplot2)
p <- ggplot(mtcars, aes(wt, mpg)) + geom_sketch_point(seed = 1L) +
  theme_sketch()
out <- file.path(tempdir(), "sketch.png")
ggsketch_save(out, p)
unlink(out)
# }
```
