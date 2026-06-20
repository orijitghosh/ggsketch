# Check for optional handwriting fonts

Diagnoses whether a handwriting-style font is available on this device.
The sketch *look* in ggsketch comes from geometry, not fonts, so this is
purely cosmetic (ADR-0005).

## Usage

``` r
ggsketch_check_fonts(
  fonts = c("xkcd", "Humor Sans", "Permanent Marker", "Caveat", "Indie Flower")
)
```

## Arguments

- fonts:

  Character vector of font families to check. Defaults to common
  handwriting fonts.

## Value

Invisibly returns a logical vector (font available?); prints a formatted
report.

## See also

Other sketch-theme:
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)
