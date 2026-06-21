# Continuous scale for the sketch `roughness` aesthetic

[`geom_sketch_point()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_point.md)
lets you map a variable to `roughness` (`aes(roughness = z)`). This
scale rescales that variable's observed range to a legible band of
roughness values, just as
[`scale_size()`](https://ggplot2.tidyverse.org/reference/scale_size.html)
rescales to a size range. It is applied automatically whenever
`roughness` is mapped to a continuous variable, so you only call it
directly to change `range`. To use values as raw roughness with no
rescaling, wrap them in [`base::I()`](https://rdrr.io/r/base/AsIs.html)
(`aes(roughness = I(z))`).

## Usage

``` r
scale_roughness_continuous(..., range = c(0.01, 0.75), guide = "none")

scale_roughness(..., range = c(0.01, 0.75), guide = "none")
```

## Arguments

- ...:

  Other arguments passed to
  [`ggplot2::continuous_scale()`](https://ggplot2.tidyverse.org/reference/continuous_scale.html).

- range:

  Output roughness range. Default `c(0.01, 0.75)`: `0.01` is effectively
  clean and `0.75` is clearly hand-drawn without becoming noise. Values
  above roughly `1` start to look scribbled.

- guide:

  Legend guide. Defaults to `"none"` because the legend keys do not
  reflect roughness; set to `"legend"` to show one anyway.

## Value

A ggplot2 scale object.

## See also

Other sketch-theme:
[`element_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md),
[`ggsketch_check_fonts()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_check_fonts.md),
[`register_sketch_font()`](https://orijitghosh.github.io/ggsketch/reference/register_sketch_font.md),
[`scale_sketch`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md),
[`sketch_palette()`](https://orijitghosh.github.io/ggsketch/reference/sketch_palette.md),
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)

## Examples

``` r
library(ggplot2)

# Mapped roughness is rescaled to c(0.01, 0.75) automatically.
ggplot(mtcars, aes(wt, mpg, roughness = hp)) +
  geom_sketch_point(size = 3, seed = 1L)


# Widen the band so the wobble difference is more dramatic.
ggplot(mtcars, aes(wt, mpg, roughness = hp)) +
  geom_sketch_point(size = 3, seed = 1L) +
  scale_roughness_continuous(range = c(0, 1.2))
```
