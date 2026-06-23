# Sketchy filled contour and 2-D density bands

`geom_sketch_contour_filled()` draws hand-drawn *filled* contour bands
of a surface (the sketch analogue of
[`ggplot2::geom_contour_filled()`](https://ggplot2.tidyverse.org/reference/geom_contour.html));
it needs `x`, `y`, and `z`. `geom_sketch_density_2d_filled()` fills the
bands of a 2-D kernel density estimate
([`ggplot2::geom_density_2d_filled()`](https://ggplot2.tidyverse.org/reference/geom_density_2d.html));
it needs `x` and `y` and uses MASS.

## Usage

``` r
GeomSketchContourFilled

geom_sketch_contour_filled(
  mapping = NULL,
  data = NULL,
  stat = "contour_filled",
  position = "identity",
  ...,
  bins = NULL,
  binwidth = NULL,
  breaks = NULL,
  roughness = 0.7,
  bowing = 0.5,
  n_passes = 2L,
  seed = NULL,
  fill_style = "solid",
  hachure_angle = 45,
  hachure_gap = 0.04,
  fill_weight = 0.5,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

geom_sketch_density_2d_filled(
  mapping = NULL,
  data = NULL,
  stat = "density_2d_filled",
  position = "identity",
  ...,
  roughness = 0.7,
  bowing = 0.5,
  n_passes = 2L,
  seed = NULL,
  fill_style = "solid",
  hachure_angle = 45,
  hachure_gap = 0.04,
  fill_weight = 0.5,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

geom_sketch_density2d_filled(
  mapping = NULL,
  data = NULL,
  stat = "density_2d_filled",
  position = "identity",
  ...,
  roughness = 0.7,
  bowing = 0.5,
  n_passes = 2L,
  seed = NULL,
  fill_style = "solid",
  hachure_angle = 45,
  hachure_gap = 0.04,
  fill_weight = 0.5,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)
```

## Format

An object of class `GeomSketchContourFilled` (inherits from `Geom`,
`ggproto`, `gg`) of length 6.

## Arguments

- mapping:

  Set of aesthetic mappings created by
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html).

- data:

  Data to display.

- stat:

  Statistical transformation (default `"identity"`).

- position:

  Position adjustment (default `"identity"`).

- ...:

  Other arguments passed on to the layer.

- bins:

  Number of contour bins. Overridden by `binwidth` or `breaks`.

- binwidth:

  Distance between contour bins.

- breaks:

  Explicit numeric contour breaks; overrides `bins`/`binwidth`.

- roughness:

  Non-negative roughness parameter (0 = straight). Default 1.

- bowing:

  Non-negative bowing multiplier. Default 1.

- n_passes:

  Number of stroke passes for the double-stroke effect. Default 2.

- seed:

  Integer seed for reproducibility. `NULL` uses
  `getOption("ggsketch.seed", 1L)`.

- fill_style:

  Band fill: `"solid"` (default), `"hachure"`, or `"cross_hatch"`. Other
  styles degrade to `"hachure"`.

- hachure_angle:

  Fill line angle in degrees. Default 45.

- hachure_gap:

  Fill line gap (npc fraction). Default 0.04.

- fill_weight:

  Stroke weight for fill lines. Default 0.5.

- na.rm:

  If `FALSE` (default), missing values are removed with a warning.

- show.legend:

  Logical. Should this layer be included in the legend?

- inherit.aes:

  If `FALSE`, override the default aesthetics.

## Value

A `ggplot2` layer object.

## Details

Unlike the contour *line* geoms, each band is a region that may contain
holes (the next level up, cut out). The fill is painted with a
hole-aware scan-line so the holes stay empty, even for
`fill_style = "hachure"`.

## See also

Other sketch-geoms:
[`GeomSketchAbline`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_abline.md),
[`GeomSketchArrow`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_arrow.md),
[`GeomSketchBoxplot`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_boxplot.md),
[`GeomSketchBracket`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bracket.md),
[`GeomSketchCallout`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_callout.md),
[`GeomSketchCol`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md),
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
ggplot(faithfuld, aes(waiting, eruptions, z = density)) +
  geom_sketch_contour_filled(seed = 1L) +
  theme_sketch()
```
