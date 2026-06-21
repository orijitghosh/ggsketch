# Sketchy ribbon and area geoms

`geom_sketch_ribbon()` draws a hand-drawn band between `ymin` and
`ymax`. `geom_sketch_area()` is the special case anchored at zero
(`ymin = 0`, `ymax = y`). Both use a roughened outline and a
hachure-style fill, the sketch analogues of
[`ggplot2::geom_ribbon()`](https://ggplot2.tidyverse.org/reference/geom_ribbon.html)
/
[`ggplot2::geom_area()`](https://ggplot2.tidyverse.org/reference/geom_ribbon.html).

## Usage

``` r
GeomSketchRibbon

geom_sketch_ribbon(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  roughness = 1,
  bowing = 1,
  n_passes = 2L,
  seed = NULL,
  fill_style = "hachure",
  hachure_angle = 45,
  hachure_gap = NULL,
  fill_weight = 0.5,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

GeomSketchArea

geom_sketch_area(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  roughness = 1,
  bowing = 1,
  n_passes = 2L,
  seed = NULL,
  fill_style = "hachure",
  hachure_angle = 45,
  hachure_gap = NULL,
  fill_weight = 0.5,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)
```

## Format

An object of class `GeomSketchRibbon` (inherits from `Geom`, `ggproto`,
`gg`) of length 6.

An object of class `GeomSketchArea` (inherits from `GeomSketchRibbon`,
`Geom`, `ggproto`, `gg`) of length 4.

## Arguments

- mapping:

  Set of aesthetic mappings created by
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html).

- data:

  Data to display.

- stat:

  Statistical transformation. Default `"identity"`.

- position:

  Position adjustment. Default `"identity"`.

- ...:

  Other arguments passed on to the layer.

- roughness:

  Non-negative roughness (0 = straight). Default 1.

- bowing:

  Non-negative bowing multiplier. Default 1.

- n_passes:

  Number of stroke passes. Default 2.

- seed:

  Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.

- fill_style:

  One of `"hachure"`, `"cross_hatch"`, `"zigzag"`, `"zigzag_line"`,
  `"scribble"`, `"dots"`, `"dashed"`, or `"solid"`. Default `"hachure"`.

- hachure_angle:

  Fill line angle in degrees. Default 45.

- hachure_gap:

  Fill line gap in npc units (`NULL` = 6% of diagonal).

- fill_weight:

  Stroke weight for fill lines. Default 0.5.

- na.rm:

  Remove missing values silently? Default `FALSE`.

- show.legend:

  Logical; include in legend?

- inherit.aes:

  Override default aesthetics?

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
df <- data.frame(x = 1:10, lo = (1:10) - 2, hi = (1:10) + 2)
ggplot(df, aes(x)) +
  geom_sketch_ribbon(aes(ymin = lo, ymax = hi), fill = "plum", seed = 1L) +
  theme_sketch()
```
