# Sketchy interval geoms

Hand-drawn uncertainty intervals at each `x`: `geom_sketch_linerange()`
draws a vertical range from `ymin` to `ymax`; `geom_sketch_pointrange()`
adds a point at `y`; `geom_sketch_errorbar()` adds end caps;
`geom_sketch_crossbar()` draws a rough box with a line at `y`. Sketch
analogues of
[`ggplot2::geom_linerange()`](https://ggplot2.tidyverse.org/reference/geom_linerange.html)
and friends. Vertical orientation only in this release.

## Usage

``` r
GeomSketchLinerange

GeomSketchPointrange

GeomSketchErrorbar

GeomSketchCrossbar

geom_sketch_linerange(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  roughness = 0.7,
  bowing = 1,
  n_passes = 2L,
  seed = NULL,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

geom_sketch_pointrange(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  fatten = 4,
  roughness = 0.7,
  bowing = 1,
  n_passes = 2L,
  seed = NULL,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

geom_sketch_errorbar(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  width = 0.5,
  roughness = 0.7,
  bowing = 1,
  n_passes = 2L,
  seed = NULL,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

geom_sketch_crossbar(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  width = 0.5,
  roughness = 0.7,
  bowing = 1,
  n_passes = 2L,
  seed = NULL,
  fill_style = "solid",
  hachure_angle = 45,
  hachure_gap = NULL,
  fill_weight = 0.5,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)
```

## Format

An object of class `GeomSketchLinerange` (inherits from `Geom`,
`ggproto`, `gg`) of length 6.

An object of class `GeomSketchPointrange` (inherits from `Geom`,
`ggproto`, `gg`) of length 6.

An object of class `GeomSketchErrorbar` (inherits from `Geom`,
`ggproto`, `gg`) of length 7.

An object of class `GeomSketchCrossbar` (inherits from `Geom`,
`ggproto`, `gg`) of length 7.

## Arguments

- mapping, data, stat, position, na.rm, show.legend, inherit.aes, ...:

  Standard layer arguments.

- roughness, bowing, n_passes, seed:

  Sketch parameters.

- fatten:

  For `pointrange`, multiply the point `size` by this factor.

- width:

  For `errorbar`/`crossbar`, the cap/box width in data units.

- fill_style, hachure_angle, hachure_gap, fill_weight:

  Fill parameters for the `crossbar` box.

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
[`geom_sketch_quantile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_quantile.md),
[`geom_sketch_text()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text.md)

## Examples

``` r
library(ggplot2)
df <- data.frame(x = c("a", "b", "c"), y = c(2, 5, 4),
                 lo = c(1, 4, 2.5), hi = c(3, 6, 5.5))
ggplot(df, aes(x, y)) +
  geom_sketch_pointrange(aes(ymin = lo, ymax = hi), seed = 1L) +
  theme_sketch()
```
