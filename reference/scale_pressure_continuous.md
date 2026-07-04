# Continuous scale for the sketch `pressure` aesthetic

[`geom_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_line.md)
and
[`geom_sketch_path()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_path.md)
let you map a variable to `pressure` (`aes(pressure = z)`) so the stroke
swells and thins **along** the line, like a real pen pressed harder in
places. This scale rescales that variable's observed range to a band of
width multipliers, just as
[`scale_size()`](https://ggplot2.tidyverse.org/reference/scale_size.html)
rescales to a size range. It is applied automatically whenever
`pressure` is mapped to a continuous variable, so you only call it
directly to change `range`. To use values as raw width multipliers with
no rescaling, wrap them in
[`base::I()`](https://rdrr.io/r/base/AsIs.html)
(`aes(pressure = I(z))`).

## Usage

``` r
scale_pressure_continuous(..., range = c(0.2, 1.6), guide = "none")

scale_pressure(..., range = c(0.2, 1.6), guide = "none")
```

## Arguments

- ...:

  Other arguments passed to
  [`ggplot2::continuous_scale()`](https://ggplot2.tidyverse.org/reference/continuous_scale.html).

- range:

  Output width-multiplier range. Default `c(0.2, 1.6)`: the lightest
  pressure draws the stroke at `0.2x` its base width, the heaviest at
  `1.6x`.

- guide:

  Legend guide. Defaults to `"none"` because the legend keys do not
  reflect pressure; set to `"legend"` to show one anyway.

## Value

A ggplot2 scale object.

## Details

Mapping `pressure` renders the line through the variable-width
[`stroke_ribbon()`](https://orijitghosh.github.io/ggsketch/reference/stroke_ribbon.md)
engine even under the default `medium = "pen"`, and combines with a
non-`pen` `medium` (the medium's own width profile is multiplied by the
mapped pressure).

## See also

Other sketch-theme:
[`CoordSketch`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch.md),
[`CoordSketchPolar`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch_polar.md),
[`element_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md),
[`ggsketch_check_fonts()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_check_fonts.md),
[`ggsketch_save()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_save.md),
[`register_sketch_font()`](https://orijitghosh.github.io/ggsketch/reference/register_sketch_font.md),
[`scale_roughness_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_roughness_continuous.md),
[`scale_sketch`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md),
[`scale_tone_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_tone_continuous.md),
[`sketch_palette()`](https://orijitghosh.github.io/ggsketch/reference/sketch_palette.md),
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)

## Examples

``` r
library(ggplot2)

# A line whose width tracks a variable, rescaled to c(0.2, 1.6) automatically.
ggplot(economics[1:120, ], aes(date, unemploy, pressure = unemploy)) +
  geom_sketch_line(linewidth = 1, seed = 1L)


# Widen the band for a more dramatic swell.
ggplot(economics[1:120, ], aes(date, unemploy, pressure = unemploy)) +
  geom_sketch_line(linewidth = 1, seed = 1L) +
  scale_pressure_continuous(range = c(0.05, 2.5))
```
