# Discrete scale for the drawing `medium` aesthetic

Maps a discrete variable to drawing media (see
[`sketch_media()`](https://orijitghosh.github.io/ggsketch/reference/sketch_media.md))
when it is mapped with `aes(medium = )` on a path-like sketch geom
([`geom_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_line.md),
[`geom_sketch_path()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_path.md),
[`geom_sketch_segment()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_segment.md),
[`geom_sketch_step()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_segment.md)).
Because of its name, ggplot2 picks it up automatically; you only need to
call it directly to choose which media to use or to set legend options.

## Usage

``` r
scale_medium_discrete(..., media = NULL)
```

## Arguments

- ...:

  Passed to
  [`ggplot2::discrete_scale()`](https://ggplot2.tidyverse.org/reference/discrete_scale.html)
  (e.g. `name`, `labels`, `guide`).

- media:

  Character vector of media to cycle through, each one of
  [`sketch_media()`](https://orijitghosh.github.io/ggsketch/reference/sketch_media.md).
  Defaults to every medium except `"pen"` (so mapped levels look
  distinct); recycled with a warning if there are more levels than
  media.

## Value

A `ggplot2` scale object.

## Details

Each group is drawn in a single medium, so map `medium` to the same
variable you group by (often `colour` or `group`).

## See also

Other sketch-media:
[`sketch_media()`](https://orijitghosh.github.io/ggsketch/reference/sketch_media.md)

## Examples

``` r
library(ggplot2)
df <- data.frame(
  x = rep(1:10, 3),
  y = c(1:10, (1:10) + 4, (1:10) + 8),
  g = rep(c("a", "b", "c"), each = 10)
)
ggplot(df, aes(x, y, group = g, medium = g, colour = g)) +
  geom_sketch_line(linewidth = 1, seed = 1L) +
  scale_medium_discrete() +
  theme_sketch()
```
