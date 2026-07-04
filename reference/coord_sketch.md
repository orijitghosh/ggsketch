# A hand-drawn coordinate system

A drop-in replacement for
[`ggplot2::coord_cartesian()`](https://ggplot2.tidyverse.org/reference/coord_cartesian.html)
that draws the *frame* hand-drawn: the panel gridlines and axis ticks
are rendered as roughened sketch grobs, so the frame matches the marks –
under any theme, not only
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md).
It reuses ggplot2's own gridline and axis layout and only swaps how
those elements are drawn, so limits, expansion, and clipping behave
exactly like
[`coord_cartesian()`](https://ggplot2.tidyverse.org/reference/coord_cartesian.html).

## Usage

``` r
coord_sketch(
  xlim = NULL,
  ylim = NULL,
  expand = TRUE,
  default = FALSE,
  clip = "on",
  roughness = 0.5,
  bowing = 0.5,
  n_passes = 2L,
  seed = NULL,
  rough_grid = TRUE,
  rough_ticks = TRUE
)
```

## Arguments

- xlim, ylim:

  Limits for the x and y axes (as in
  [`ggplot2::coord_cartesian()`](https://ggplot2.tidyverse.org/reference/coord_cartesian.html)).

- expand:

  If `TRUE` (default), add the standard expansion around the data.

- default:

  Is this the default coordinate system? Default `FALSE`.

- clip:

  Should drawing be clipped to the panel (`"on"`, default) or not
  (`"off"`)?

- roughness, bowing, n_passes:

  Sketch parameters for the frame. Gentle defaults suited to gridlines
  (`0.5`, `0.5`, `2`).

- seed:

  Integer seed for reproducible wobble. `NULL` uses
  `getOption("ggsketch.seed", 1L)`.

- rough_grid, rough_ticks:

  Roughen the gridlines / axis ticks? Both default `TRUE`; set one to
  `FALSE` to leave that element crisp.

## Value

A `ggproto` Coord object to add to a plot.

## Details

The panel *border* is a plot-level theme element (not part of the
coordinate system), so to roughen it as well, combine `coord_sketch()`
with `theme_sketch(rough_frame = TRUE)` or set
`panel.border = element_sketch_rect(...)`.

## See also

Other sketch-theme:
[`CoordSketchPolar`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch_polar.md),
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
# A rough frame under a plain (non-sketch) theme:
ggplot(mtcars, aes(wt, mpg)) +
  geom_sketch_point(seed = 1L) +
  coord_sketch(seed = 1L)
```
