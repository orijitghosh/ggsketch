# Hand-drawn theme elements

Sketch counterparts of
[`ggplot2::element_line()`](https://ggplot2.tidyverse.org/reference/element.html)
and
[`ggplot2::element_rect()`](https://ggplot2.tidyverse.org/reference/element.html).
Use them in
[`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html)
(or via `theme_sketch(rough_frame = TRUE)`) to render gridlines, panel
borders, and axis ticks with the same wobbly, double-stroke look as the
geoms. They accept the usual element arguments plus the shared sketch
parameters (`roughness`, `bowing`, `n_passes`, `seed`).

## Usage

``` r
element_sketch_line(
  colour = NULL,
  linewidth = NULL,
  linetype = NULL,
  lineend = NULL,
  color = NULL,
  roughness = 0.5,
  bowing = 0.5,
  n_passes = 2L,
  seed = NULL,
  ...
)

element_sketch_rect(
  fill = NULL,
  colour = NULL,
  linewidth = NULL,
  linetype = NULL,
  color = NULL,
  roughness = 0.6,
  bowing = 0.4,
  n_passes = 2L,
  seed = NULL,
  ...
)
```

## Arguments

- colour, color:

  Line/border colour.

- linewidth:

  Line width.

- linetype:

  Line type.

- lineend:

  Line end style.

- roughness, bowing, n_passes, seed:

  Sketch parameters (see
  [`geom_sketch_path()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_path.md)).
  Defaults are gentle, suited to a frame.

- ...:

  Passed to the underlying ggplot2 element constructor.

- fill:

  Fill colour (`element_sketch_rect()` only). `NA` draws the outline
  only — the usual choice for a panel border.

## Value

A ggplot2 theme element carrying an `element_sketch_*` subclass.

## See also

Other sketch-theme:
[`ggsketch_check_fonts()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_check_fonts.md),
[`register_sketch_font()`](https://orijitghosh.github.io/ggsketch/reference/register_sketch_font.md),
[`scale_roughness_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_roughness_continuous.md),
[`scale_sketch`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md),
[`sketch_palette()`](https://orijitghosh.github.io/ggsketch/reference/sketch_palette.md),
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_sketch_point(seed = 1L) +
  theme_sketch() +
  theme(panel.grid.major = element_sketch_line(colour = "grey80", seed = 7L))
```
