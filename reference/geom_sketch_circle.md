# Sketchy circle and ellipse geoms

`geom_sketch_circle()` draws roughened circles of radius `r` (data
units); `geom_sketch_ellipse()` draws ellipses with semi-axes `a` (x)
and `b` (y). Radii are in data units, so on a non-square panel a circle
appears elliptical - use
[`ggplot2::coord_equal()`](https://ggplot2.tidyverse.org/reference/coord_fixed.html)
for true circles. These are annotation-style geoms (cf.
`ggforce::geom_circle()`).

## Usage

``` r
GeomSketchEllipse

GeomSketchCircle

geom_sketch_circle(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  roughness = NULL,
  bowing = 1,
  n_passes = 2L,
  seed = NULL,
  fill_style = "hachure",
  hachure_angle = 45,
  hachure_gap = 0.07,
  fill_weight = 0.5,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

geom_sketch_ellipse(
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
  hachure_gap = 0.07,
  fill_weight = 0.5,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)
```

## Format

An object of class `GeomSketchEllipse` (inherits from `Geom`, `ggproto`,
`gg`) of length 7.

An object of class `GeomSketchCircle` (inherits from
`GeomSketchEllipse`, `Geom`, `ggproto`, `gg`) of length 3.

## Arguments

- mapping:

  Set of aesthetic mappings created by
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html).
  `geom_sketch_circle()` needs `x`, `y`, `r`; `geom_sketch_ellipse()`
  needs `x`, `y`, `a`, `b`.

- data:

  Data to display.

- stat:

  Statistical transformation. Default `"identity"`.

- position:

  Position adjustment. Default `"identity"`.

- ...:

  Other arguments passed on to the layer.

- roughness:

  Non-negative roughness (0 = clean). A mappable aesthetic (default 1):
  pass a constant, or map it per shape with `aes(roughness = )`
  (rescaled by
  [`scale_roughness_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_roughness_continuous.md)).

- bowing:

  Non-negative bowing multiplier. Default 1.

- n_passes:

  Number of stroke passes. Default 2.

- seed:

  Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.

- fill_style:

  Fill style when `fill` is mapped: `"hachure"`, `"cross_hatch"`,
  `"zigzag"`, `"scribble"`, `"dots"`, `"dashed"`. Default `"hachure"`.

- hachure_angle:

  Fill line angle in degrees. Default 45.

- hachure_gap:

  Fill line gap (npc fraction, scaled by radius). Default 0.07.

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
[`geom_sketch_quantile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_quantile.md),
[`geom_sketch_text()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text.md)

## Examples

``` r
library(ggplot2)
df <- data.frame(x = c(1, 3), y = c(1, 2), r = c(0.5, 1))
ggplot(df, aes(x, y, r = r)) +
  geom_sketch_circle(fill = "gold", seed = 1L) +
  coord_equal() + theme_sketch()
```
