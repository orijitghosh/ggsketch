# A hand-drawn polar coordinate system

The polar companion to
[`coord_sketch()`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch.md):
a drop-in replacement for
[`ggplot2::coord_polar()`](https://ggplot2.tidyverse.org/reference/coord_radial.html)
that draws the circular grid hand-drawn. The radial and angular
gridlines are rendered as roughened sketch grobs, so pie/rose charts and
circular bar plots get a frame that matches the marks – under any theme.
It reuses all of ggplot2's polar layout and only swaps how the grid is
drawn.

## Usage

``` r
coord_sketch_polar(
  theta = "x",
  start = 0,
  direction = 1,
  clip = "on",
  roughness = 0.5,
  bowing = 0.5,
  n_passes = 2L,
  seed = NULL,
  rough_grid = TRUE
)
```

## Arguments

- theta:

  Variable mapped to angle (`"x"` or `"y"`). Default `"x"`.

- start:

  Offset of the starting point, in radians. Default 0.

- direction:

  `1` clockwise, `-1` anticlockwise. Default 1.

- clip:

  Should drawing be clipped to the panel (`"on"`, default) or not
  (`"off"`)?

- roughness, bowing, n_passes:

  Sketch parameters for the grid. Gentle defaults suited to gridlines
  (`0.5`, `0.5`, `2`).

- seed:

  Integer seed for reproducible wobble. `NULL` uses
  `getOption("ggsketch.seed", 1L)`.

- rough_grid:

  Roughen the gridlines? Default `TRUE`.

## Value

A `ggproto` Coord object to add to a plot.

## See also

Other sketch-theme:
[`CoordSketch`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch.md),
[`element_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md),
[`ggsketch_check_fonts()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_check_fonts.md),
[`ggsketch_save()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_save.md),
[`register_sketch_font()`](https://orijitghosh.github.io/ggsketch/reference/register_sketch_font.md),
[`scale_pressure_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_pressure_continuous.md),
[`scale_roughness_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_roughness_continuous.md),
[`scale_sketch`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md),
[`scale_tone_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_tone_continuous.md),
[`sketch_palette()`](https://orijitghosh.github.io/ggsketch/reference/sketch_palette.md),
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)

## Examples

``` r
library(ggplot2)
df <- data.frame(g = c("a", "b", "c", "d"), v = c(3, 5, 2, 4))
# A hand-drawn circular bar (rose) chart:
ggplot(df, aes(g, v, fill = g)) +
  geom_sketch_col(seed = 1L) +
  coord_sketch_polar(seed = 1L) +
  theme_sketch()
```
