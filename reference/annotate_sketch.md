# Sketchy annotations

The sketch analogue of
[`ggplot2::annotate()`](https://ggplot2.tidyverse.org/reference/annotate.html).
Creates a one-off layer of fixed, hand-drawn marks that do not inherit
the plot's aesthetics - useful for highlighting, callouts, and reference
shapes.

## Usage

``` r
annotate_sketch(
  geom,
  x = NULL,
  y = NULL,
  xmin = NULL,
  xmax = NULL,
  ymin = NULL,
  ymax = NULL,
  xend = NULL,
  yend = NULL,
  r = NULL,
  a = NULL,
  b = NULL,
  seed = NULL,
  na.rm = FALSE,
  ...
)
```

## Arguments

- geom:

  Name of the sketch geom to draw. One of `"point"`, `"line"`, `"path"`,
  `"segment"`, `"rect"`, `"polygon"`, `"circle"`, `"ellipse"`.

- x, y, xmin, xmax, ymin, ymax, xend, yend:

  Positioning aesthetics (numeric vectors, recycled to a common length).
  Supply the ones the chosen geom needs (e.g. `xmin/xmax/ymin/ymax` for
  `"rect"`, `xend/yend` for `"segment"`).

- r, a, b:

  Radius (`"circle"`) or semi-axes (`"ellipse"`).

- seed:

  Integer seed for reproducible wobble.

- na.rm:

  If `FALSE` (default), missing values trigger a warning.

- ...:

  Other arguments passed to the underlying `geom_sketch_*()` layer (e.g.
  `colour`, `fill`, `roughness`, `fill_style`).

## Value

A `ggplot2` layer object.

## See also

Other sketch-geoms:
[`GeomSketchAbline`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_abline.md),
[`GeomSketchBoxplot`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_boxplot.md),
[`GeomSketchBracket`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bracket.md),
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
ggplot(mtcars, aes(wt, mpg)) +
  geom_sketch_point(seed = 1L) +
  annotate_sketch("rect", xmin = 3, xmax = 4, ymin = 15, ymax = 22,
                  fill = NA, colour = "red", seed = 2L) +
  annotate_sketch("segment", x = 2, y = 30, xend = 3.5, yend = 20,
                  colour = "blue", seed = 3L) +
  theme_sketch()
```
