# A hand-drawn theme for ggplot2

A sketch-style theme based on
[`ggplot2::theme_bw()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
with a paper-and-ink palette that complements the rough geoms. Light
(default) and dark presets are available via `dark`. The sketchiness of
the *marks* comes from the geoms themselves; this theme styles the
surrounding frame, typography, and background.

## Usage

``` r
theme_sketch(
  base_size = 11,
  base_family = "",
  base_line_size = base_size/22,
  base_rect_size = base_size/22,
  dark = FALSE
)
```

## Arguments

- base_size:

  Base font size (default 11).

- base_family:

  Base font family. `""` (default) uses the device default. `"auto"`
  picks the first installed handwriting font (see
  [`ggsketch_check_fonts()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_check_fonts.md)),
  falling back to the device default. Or pass an explicit family name.

- base_line_size:

  Line size (default `base_size / 22`).

- base_rect_size:

  Rect size (default `base_size / 22`).

- dark:

  If `TRUE`, use the dark "chalkboard" preset. Default `FALSE` (light
  "paper" preset).

## Value

A [`ggplot2::theme`](https://ggplot2.tidyverse.org/reference/theme.html)
object.

## See also

Other sketch-theme:
[`ggsketch_check_fonts()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_check_fonts.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(mtcars, aes(wt, mpg)) + geom_sketch_point(seed = 1L)
p + theme_sketch()

p + theme_sketch(dark = TRUE)
```
