# The ggsketch qualitative colour palette

Eight muted ink-on-paper colours led by the package primary (Carolina
blue, `#7BAFD4`), ordered for maximal separation.

## Usage

``` r
sketch_palette(n = NULL, interpolate = TRUE)
```

## Arguments

- n:

  Number of colours to return. If `NULL`, the eight anchor colours are
  returned. Up to eight are taken verbatim; beyond that they are
  interpolated (or recycled, if `interpolate = FALSE`).

- interpolate:

  When `n > 8`, interpolate the eight anchors into `n` colours (the
  default). `FALSE` recycles the anchors with a warning.

## Value

A character vector of hex colours.

## Details

The first eight colours are returned exactly, so small categorical plots
keep their recognisable hues. Ask for **more than eight** and the
palette is *interpolated*: a smooth
[`colorRampPalette()`](https://rdrr.io/r/grDevices/colorRamp.html) ramp
through all eight anchors yields `n` distinct ink tones, so the discrete
sketch scales keep working for large factors and for quasi-continuous
use. Set `interpolate = FALSE` to fall back to the old recycling
behaviour instead.

## See also

Other sketch-theme:
[`CoordSketch`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch.md),
[`CoordSketchPolar`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch_polar.md),
[`element_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md),
[`ggsketch_check_fonts()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_check_fonts.md),
[`ggsketch_save()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_save.md),
[`register_sketch_font()`](https://orijitghosh.github.io/ggsketch/reference/register_sketch_font.md),
[`scale_pressure_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_pressure_continuous.md),
[`scale_roughness_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_roughness_continuous.md),
[`scale_sketch`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md),
[`scale_tone_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_tone_continuous.md),
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)

## Examples

``` r
sketch_palette(4)
#> [1] "#7BAFD4" "#C8553D" "#88B398" "#9B6FB0"
sketch_palette(20)             # interpolated ramp through all eight anchors
#>  [1] "#7AAED3" "#AA909A" "#C06F63" "#C46146" "#B48566" "#99A588" "#8EA59D"
#>  [8] "#968CA6" "#9A72AE" "#B57E96" "#CE9276" "#D9A059" "#AB8B65" "#7A766E"
#> [15] "#6B6974" "#8A6576" "#A75E79" "#9B6B7A" "#7B7D7B" "#4D8C7D"
```
