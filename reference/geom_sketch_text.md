# Sketchy text and labels

`geom_sketch_text()` and `geom_sketch_label()` add text in a handwriting
font, the sketch counterparts of
[`ggplot2::geom_text()`](https://ggplot2.tidyverse.org/reference/geom_text.html)
and
[`ggplot2::geom_label()`](https://ggplot2.tidyverse.org/reference/geom_text.html).
Unlike the other geoms the strokes are not geometrically roughened — the
hand-drawn feel comes from the font (see
[`ggsketch_check_fonts()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_check_fonts.md)
for which faces are available). If no handwriting font is installed they
render with the device default family.

## Usage

``` r
geom_sketch_text(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  family = NULL,
  nudge_x = 0,
  nudge_y = 0,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

geom_sketch_label(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  family = NULL,
  nudge_x = 0,
  nudge_y = 0,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)
```

## Arguments

- mapping:

  Set of aesthetic mappings created by
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html).
  Requires a `label` aesthetic.

- data:

  Data to display.

- stat:

  Statistical transformation (default `"identity"`).

- position:

  Position adjustment (default `"identity"`).

- ...:

  Other arguments passed on to
  [`ggplot2::layer()`](https://ggplot2.tidyverse.org/reference/layer.html),
  such as `size`, `colour`, `angle`, or `hjust`.

- family:

  Font family. By default the first installed handwriting face is used;
  pass an explicit family to override, or `""` for the device default.

- nudge_x, nudge_y:

  Horizontal and vertical adjustment to nudge labels by. Useful for
  offsetting text from points. Cannot be used together with an explicit
  `position`.

- na.rm:

  If `FALSE` (default), missing values are removed with a warning.

- show.legend:

  Logical. Should this layer be included in the legend?

- inherit.aes:

  If `FALSE`, override the default aesthetics.

## Value

A `ggplot2` layer object.

## See also

Other sketch-geoms:
[`GeomSketchAbline`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_abline.md),
[`GeomSketchBoxplot`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_boxplot.md),
[`GeomSketchCol`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md),
[`GeomSketchCurve`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_curve.md),
[`GeomSketchEllipse`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md),
[`GeomSketchHex`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_hex.md),
[`GeomSketchLine`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_line.md),
[`GeomSketchLinerange`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_linerange.md),
[`GeomSketchPath`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_path.md),
[`GeomSketchPoint`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_point.md),
[`GeomSketchPolygon`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_polygon.md),
[`GeomSketchRect`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md),
[`GeomSketchRibbon`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ribbon.md),
[`GeomSketchRug`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rug.md),
[`GeomSketchSegment`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_segment.md),
[`GeomSketchSmooth`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_smooth.md),
[`GeomSketchSpoke`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_spoke.md),
[`GeomSketchViolin`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_violin.md),
[`annotate_sketch()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch.md),
[`geom_sketch_bin2d()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bin2d.md),
[`geom_sketch_contour()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_contour.md),
[`geom_sketch_count()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_count.md),
[`geom_sketch_density()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_density.md),
[`geom_sketch_density2d()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_density2d.md),
[`geom_sketch_function()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_function.md),
[`geom_sketch_histogram()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_histogram.md),
[`geom_sketch_jitter()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_jitter.md),
[`geom_sketch_qq()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_qq.md),
[`geom_sketch_quantile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_quantile.md)

## Examples

``` r
library(ggplot2)
df <- data.frame(x = c(1, 2, 3), y = c(2, 3, 1),
                 lab = c("alpha", "bravo", "charlie"))

# `family = ""` uses the device default, so this runs on any device.
ggplot(df, aes(x, y, label = lab)) +
  geom_sketch_text(size = 6, family = "") +
  theme_sketch()


# With no `family`, the first installed handwriting font is used. Render with
# a font-capable device (ragg, svglite, cairo) to see it — the base pdf() /
# postscript() devices cannot use unregistered system fonts.
if (FALSE) { # \dontrun{
ggplot(df, aes(x, y, label = lab)) +
  geom_sketch_text(size = 6) +
  theme_sketch()
} # }
```
