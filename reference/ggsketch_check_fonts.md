# Check for optional handwriting fonts

Diagnoses whether a handwriting-style font is available on this device.
The sketch *look* in ggsketch comes from geometry, not fonts, so this is
purely cosmetic (ADR-0005).

## Usage

``` r
ggsketch_check_fonts(fonts = sketch_font_candidates())
```

## Arguments

- fonts:

  Character vector of font families to check. Defaults to the same
  candidate list
  [`geom_sketch_text()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text.md)
  resolves against - preferred handwriting faces first, then fonts
  preinstalled on Windows / macOS.

## Value

Invisibly returns a logical vector (font available?); prints a formatted
report.

## See also

Other sketch-theme:
[`element_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md),
[`register_sketch_font()`](https://orijitghosh.github.io/ggsketch/reference/register_sketch_font.md),
[`scale_roughness_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_roughness_continuous.md),
[`scale_sketch`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md),
[`sketch_palette()`](https://orijitghosh.github.io/ggsketch/reference/sketch_palette.md),
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)
