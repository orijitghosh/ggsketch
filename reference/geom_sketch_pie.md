# Sketchy pie and donut charts

`geom_sketch_pie()` draws a hand-drawn pie chart: one slice per row,
sized by the `amount` aesthetic and coloured by `fill`.
`geom_sketch_donut()` is the same with a hole in the middle. Slices are
kept circular regardless of the panel's shape, so they look right
without
[`coord_fixed()`](https://ggplot2.tidyverse.org/reference/coord_fixed.html).
The chart is drawn in the centre of the panel; pair it with
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)
or
[`ggplot2::theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
to hide the (unused) axes.

## Usage

``` r
GeomSketchPie

geom_sketch_pie(
  mapping = NULL,
  data = NULL,
  stat = StatSketchPie,
  position = "identity",
  ...,
  x0 = 0.5,
  y0 = 0.5,
  r = 0.45,
  r0 = 0,
  roughness = 1,
  bowing = 0.4,
  n_passes = 2L,
  seed = NULL,
  fill_style = "solid",
  hachure_angle = 45,
  hachure_gap = 0.02,
  fill_weight = 0.5,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

geom_sketch_donut(..., r0 = 0.25)
```

## Format

An object of class `GeomSketchPie` (inherits from `Geom`, `ggproto`,
`gg`) of length 7.

## Arguments

- mapping:

  Aesthetic mappings created by
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html).
  Requires `amount`; map `fill` to colour the slices.

- data:

  Data with one row per slice.

- stat:

  The statistic; defaults to `StatSketchPie`, which converts `amount`
  into slice angles.

- position:

  Position adjustment. Default `"identity"`.

- ...:

  Other arguments passed on to the layer.

- x0, y0:

  Pie centre in npc \[0,1\]. Default `0.5` (panel centre).

- r:

  Outer radius as a fraction of the smaller panel dimension. Default
  `0.45`.

- r0:

  Inner radius (hole) as a fraction of the smaller panel dimension. `0`
  (default) is a full pie; `geom_sketch_donut()` defaults it to `0.25`
  (a ring between `r0` and `r`).

- roughness:

  Non-negative roughness of the slice edges (0 = clean). Default 1.

- bowing:

  Non-negative bowing multiplier. Default 0.4 (kept low so the radial
  edges stay straight-ish).

- n_passes:

  Number of stroke passes. Default 2.

- seed:

  Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.

- fill_style:

  `"solid"` (default) paints each slice in its `fill` colour with a
  rough edge; any other style (`"hachure"`, `"cross_hatch"`, `"zigzag"`,
  `"scribble"`, `"dots"`, `"dashed"`) hatches it instead.

- hachure_angle:

  Fill line angle in degrees. Default 45.

- hachure_gap:

  Spacing between fill lines, as a fraction of the smaller panel
  dimension – this is the hatch *density* knob: smaller is denser.
  Default 0.02.

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
df <- data.frame(
  group  = c("Sketch", "Polish", "Coffee", "Doubt"),
  amount = c(40, 25, 20, 15)
)
ggplot(df, aes(amount = amount, fill = group)) +
  geom_sketch_pie(seed = 1L) +
  scale_fill_sketch() +
  coord_fixed() +
  theme_void()


# A donut:
ggplot(df, aes(amount = amount, fill = group)) +
  geom_sketch_donut(seed = 2L) +
  theme_void()
```
