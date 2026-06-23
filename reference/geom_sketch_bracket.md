# Sketchy significance / comparison brackets

Draws a hand-drawn bracket spanning `xmin` to `xmax` at height `y`, with
short tips dropping toward the data and an optional `label` (e.g. a
p-value or "n.s.") centred above. It is the sketch counterpart of a
`ggsignif` bracket: useful for marking pairwise comparisons on boxplots,
bars, or violins.

## Usage

``` r
GeomSketchBracket

geom_sketch_bracket(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  tip_length = 0.02,
  family = NULL,
  label_vjust = -0.35,
  roughness = 0.8,
  bowing = 0.4,
  n_passes = 2L,
  seed = NULL,
  na.rm = FALSE,
  show.legend = FALSE,
  inherit.aes = FALSE
)
```

## Format

An object of class `GeomSketchBracket` (inherits from `Geom`, `ggproto`,
`gg`) of length 6.

## Arguments

- mapping:

  Aesthetic mappings created by
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html).
  Requires `xmin`, `xmax`, and `y`; `label` is optional.

- data:

  Data with one row per bracket.

- stat:

  Statistical transformation. Default `"identity"`.

- position:

  Position adjustment. Default `"identity"`.

- ...:

  Other arguments passed on to the layer.

- tip_length:

  Length of the downward end tips, as a fraction of panel height.
  Default `0.02`. Use `0` for a plain bar.

- family:

  Font family for the label. Defaults to the same family as
  [`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)
  (`getOption("ggsketch.base_family", "")`, i.e. the device default), so
  the label matches the plot's other text; set
  `options(ggsketch.base_family = "auto")` for a handwriting face, or
  pass an explicit family here.

- label_vjust:

  Vertical justification of the label relative to the bar (negative
  nudges it above). Default `-0.35`.

- roughness:

  Non-negative roughness (0 = straight). Default 0.8.

- bowing:

  Non-negative bowing multiplier. Default 0.4 (kept low so the bar stays
  readable).

- n_passes:

  Number of stroke passes. Default 2.

- seed:

  Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.

- na.rm:

  Remove missing values silently? Default `FALSE`.

- show.legend:

  Logical; include in legend? Default `FALSE`.

- inherit.aes:

  Inherit aesthetics from the plot? Default `FALSE`.

## Value

A `ggplot2` layer object.

## Details

Brackets are usually one-off annotations, so supply them with their own
`data` and `inherit.aes = FALSE` rather than inheriting the plot's
mapping.

## See also

Other sketch-geoms:
[`GeomSketchAbline`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_abline.md),
[`GeomSketchArrow`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_arrow.md),
[`GeomSketchBoxplot`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_boxplot.md),
[`GeomSketchCallout`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_callout.md),
[`GeomSketchCol`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md),
[`GeomSketchContourFilled`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_contour_filled.md),
[`GeomSketchCurve`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_curve.md),
[`GeomSketchDotplot`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_dotplot.md),
[`GeomSketchEllipse`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md),
[`GeomSketchHex`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_hex.md),
[`GeomSketchLine`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_line.md),
[`GeomSketchLinerange`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_linerange.md),
[`GeomSketchLollipop`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_lollipop.md),
[`GeomSketchMarkCircle`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_mark_circle.md),
[`GeomSketchMarkHull`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_mark_hull.md),
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
[`StatSketchPie`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_pie.md),
[`annotate_sketch()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch.md),
[`annotate_sketch_arrow()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch_arrow.md),
[`annotate_sketch_callout()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch_callout.md),
[`geom_sketch_bin2d()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bin2d.md),
[`geom_sketch_contour()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_contour.md),
[`geom_sketch_count()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_count.md),
[`geom_sketch_density()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_density.md),
[`geom_sketch_density2d()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_density2d.md),
[`geom_sketch_ecdf()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ecdf.md),
[`geom_sketch_function()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_function.md),
[`geom_sketch_histogram()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_histogram.md),
[`geom_sketch_jitter()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_jitter.md),
[`geom_sketch_qq()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_qq.md),
[`geom_sketch_quantile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_quantile.md),
[`geom_sketch_text()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text.md)

## Examples

``` r
library(ggplot2)
brackets <- data.frame(xmin = 1, xmax = 2, y = 45, label = "p = 0.01")
ggplot(mpg, aes(drv, hwy)) +
  geom_sketch_boxplot(seed = 1L) +
  geom_sketch_bracket(
    data = brackets,
    aes(xmin = xmin, xmax = xmax, y = y, label = label),
    family = "", seed = 2L
  ) +
  theme_sketch()
```
