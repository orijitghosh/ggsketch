# A hand-drawn theme for ggplot2

A sketch-style theme based on
[`ggplot2::theme_bw()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
with a muted palette to match the rough geoms. Light (default) and dark
presets are available via `dark`. The sketchiness of the *marks* comes
from the geoms themselves; this theme styles the surrounding frame,
typography, and background.

## Usage

``` r
theme_sketch(
  base_size = 11,
  base_family = getOption("ggsketch.base_family", ""),
  base_line_size = base_size/22,
  base_rect_size = base_size/22,
  dark = FALSE,
  rough_frame = FALSE,
  roughness = 0.5,
  paper = "none",
  seed = NULL
)
```

## Arguments

- base_size:

  Base font size (default 11).

- base_family:

  Base font family. Defaults to `getOption("ggsketch.base_family", "")`;
  `""` uses the device default. `"auto"` picks the first installed
  handwriting font (see
  [`ggsketch_check_fonts()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_check_fonts.md)),
  falling back to the device default. Set
  `options(ggsketch.base_family = "auto")` to make every sketch plot's
  text (titles, axes, legend) use handwriting, not just the labels drawn
  by
  [`geom_sketch_text()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text.md)
  /
  [`geom_sketch_bracket()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bracket.md).
  Or pass an explicit family name.

- base_line_size:

  Line size (default `base_size / 22`).

- base_rect_size:

  Rect size (default `base_size / 22`).

- dark:

  If `TRUE`, use the dark "chalkboard" preset. Default `FALSE` (light
  "paper" preset).

- rough_frame:

  If `TRUE`, draw the *frame* itself hand-drawn: the major gridlines,
  panel border, axis ticks, facet strip backgrounds, and the
  continuous-scale colourbar frame and ticks become roughened sketch
  grobs (via
  [`element_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md)
  /
  [`element_sketch_rect()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md))
  so the whole frame matches the marks. Default `FALSE`.

- roughness:

  Roughness for the rough frame (only used when `rough_frame = TRUE`).
  Default 0.5.

- paper:

  Paper ground drawn behind the data: one of
  [`sketch_papers()`](https://orijitghosh.github.io/ggsketch/reference/sketch_papers.md)
  (`"none"` (default), `"notebook"`, `"graph"`, `"dotted"`, `"aged"`,
  `"blueprint"`, `"chalkboard"`, `"kraft"`). A non-`"none"` paper paints
  a simulated texture as the panel background, recolours the plot ground
  and text to suit it (light text on the dark blueprint / chalkboard
  grounds), and suppresses the default gridlines where the paper
  supplies its own ruling.

- seed:

  Integer seed for the rough frame, for reproducible wobble. `NULL` uses
  `getOption("ggsketch.seed", 1L)`.

## Value

A [`ggplot2::theme`](https://ggplot2.tidyverse.org/reference/theme.html)
object.

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
[`sketch_palette()`](https://orijitghosh.github.io/ggsketch/reference/sketch_palette.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(mtcars, aes(wt, mpg)) + geom_sketch_point(seed = 1L)
p + theme_sketch()

p + theme_sketch(dark = TRUE)

p + theme_sketch(rough_frame = TRUE)

p + theme_sketch(paper = "notebook")
```
