# Sketch colour and fill scales

Discrete scales (`scale_colour_sketch()`, `scale_fill_sketch()`) use
[`sketch_palette()`](https://orijitghosh.github.io/ggsketch/reference/sketch_palette.md);
the continuous variants (`*_sketch_c()`) use a paper-to-ink blue
gradient. They pair with
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)
and the sketch geoms but work with any ggplot2 layer.

## Usage

``` r
scale_colour_sketch(..., aesthetics = "colour")

scale_color_sketch(..., aesthetics = "colour")

scale_fill_sketch(..., aesthetics = "fill")

scale_colour_sketch_c(..., aesthetics = "colour")

scale_color_sketch_c(..., aesthetics = "colour")

scale_fill_sketch_c(..., aesthetics = "fill")
```

## Arguments

- ...:

  Passed to
  [`ggplot2::discrete_scale()`](https://ggplot2.tidyverse.org/reference/discrete_scale.html)
  (discrete) or
  [`ggplot2::scale_colour_gradientn()`](https://ggplot2.tidyverse.org/reference/scale_gradient.html)
  (continuous).

- aesthetics:

  Character vector of aesthetics this scale works with.

## Value

A ggplot2 scale object.

## See also

Other sketch-theme:
[`element_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md),
[`ggsketch_check_fonts()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_check_fonts.md),
[`register_sketch_font()`](https://orijitghosh.github.io/ggsketch/reference/register_sketch_font.md),
[`sketch_palette()`](https://orijitghosh.github.io/ggsketch/reference/sketch_palette.md),
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)

## Examples

``` r
library(ggplot2)
ggplot(mpg, aes(displ, hwy, colour = drv)) +
  geom_sketch_point(seed = 1L) +
  scale_colour_sketch() +
  theme_sketch()
```
