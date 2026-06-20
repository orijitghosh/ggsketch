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
  resolves against — preferred handwriting faces first, then fonts
  preinstalled on Windows / macOS.

## Value

Invisibly returns a logical vector (font available?); prints a formatted
report.

## See also

Other sketch-theme:
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)
