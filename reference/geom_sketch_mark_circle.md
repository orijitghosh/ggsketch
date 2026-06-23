# Sketchy bounding marks around point groups

Draw a hand-drawn bounding shape around each group of points - the
sketch analogues of `ggforce::geom_mark_circle()` /
`geom_mark_ellipse()` / `geom_mark_rect()`, completing the family
started by
[`geom_sketch_mark_hull()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_mark_hull.md).
Group the points with an aesthetic such as `group`, `colour`, or `fill`;
each group gets its own mark. With `fill` mapped the mark is shaded
(using `fill_style`); otherwise it is outline-only. The position scales
expand to contain the marks, so they are not clipped.

## Usage

``` r
GeomSketchMarkCircle

GeomSketchMarkEllipse

GeomSketchMarkRect

geom_sketch_mark_circle(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  expand = 0.05,
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

geom_sketch_mark_ellipse(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  expand = 0.05,
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

geom_sketch_mark_rect(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  expand = 0.05,
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

An object of class `GeomSketchMarkCircle` (inherits from `Geom`,
`ggproto`, `gg`) of length 7.

An object of class `GeomSketchMarkEllipse` (inherits from
`GeomSketchMarkCircle`, `Geom`, `ggproto`, `gg`) of length 3.

An object of class `GeomSketchMarkRect` (inherits from
`GeomSketchMarkCircle`, `Geom`, `ggproto`, `gg`) of length 3.

## Arguments

- mapping:

  Aesthetic mappings created by
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html).
  Requires `x` and `y`; map `group`/`colour`/`fill` to separate the
  clusters.

- data:

  Data to display.

- stat:

  Statistical transformation. Default `"identity"`.

- position:

  Position adjustment. Default `"identity"`.

- ...:

  Other arguments passed on to the layer.

- expand:

  Fractional outward inflation of the mark, so it sits around the points
  rather than through them. Default `0.05`.

- roughness:

  Non-negative roughness (0 = clean). Default 1.

- bowing:

  Non-negative bowing multiplier. Default 1.

- n_passes:

  Number of stroke passes. Default 2.

- seed:

  Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.

- fill_style:

  Fill style when `fill` is mapped: `"hachure"`, `"cross_hatch"`,
  `"zigzag"`, `"scribble"`, `"dots"`, `"dashed"`, or `"solid"`. Default
  `"hachure"`.

- hachure_angle:

  Fill line angle in degrees. Default 45.

- hachure_gap:

  Fill line gap (npc fraction). Default 0.07.

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

## Details

The boundary is computed in data units, so a `geom_sketch_mark_circle()`
is a true circle only under
[`ggplot2::coord_equal()`](https://ggplot2.tidyverse.org/reference/coord_fixed.html)
(as for
[`geom_sketch_circle()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md));
on a non-square panel prefer `geom_sketch_mark_ellipse()`.

## See also

Other sketch-geoms:
[`GeomSketchAbline`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_abline.md),
[`GeomSketchArrow`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_arrow.md),
[`GeomSketchBoxplot`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_boxplot.md),
[`GeomSketchBracket`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bracket.md),
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
ggplot(iris, aes(Sepal.Length, Sepal.Width, colour = Species)) +
  geom_sketch_mark_ellipse(aes(fill = Species), seed = 1L) +
  geom_sketch_point(seed = 2L) +
  theme_sketch()
```
