# Sketchy dumbbell chart

Draws a hand-drawn dumbbell: a roughened connector from `x` to `xend` on
a shared `y`, capped with a sketch point at each end. Ideal for showing
the change or gap between two paired values per category (cf.
`ggalt::geom_dumbbell()`).

## Usage

``` r
GeomSketchDumbbell

geom_sketch_dumbbell(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  colour_x = NULL,
  colour_xend = NULL,
  roughness = 0.6,
  point_roughness = 0.4,
  bowing = 0.4,
  n_passes = 2L,
  seed = NULL,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)
```

## Arguments

- mapping:

  Aesthetic mappings created by
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html).
  Requires `x`, `xend` and `y`.

- data:

  Data to display.

- stat:

  Statistical transformation. Default `"identity"`.

- position:

  Position adjustment. Default `"identity"`.

- ...:

  Other arguments passed on to the layer.

- colour_x:

  Colour of the dot at `x`. Default `NULL` (uses `colour`).

- colour_xend:

  Colour of the dot at `xend`. Default `NULL` (uses `colour`).

- roughness:

  Connector roughness (0 = straight). Default 0.6.

- point_roughness:

  Roughness of the end dots. Default 0.4.

- bowing:

  Non-negative bowing multiplier. Default 0.4.

- n_passes:

  Number of stroke passes. Default 2.

- seed:

  Integer seed. `NULL` uses `getOption("ggsketch.seed", 1L)`.

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
[`GeomSketchEdge`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_edge.md),
[`GeomSketchEllipse`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md),
[`GeomSketchEngrave`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_engrave.md),
[`GeomSketchGantt`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_gantt.md),
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
[`GeomSketchSfPolygon`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_sf.md),
[`GeomSketchSlope`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_slope.md),
[`GeomSketchSmooth`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_smooth.md),
[`GeomSketchSpoke`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_spoke.md),
[`GeomSketchTextRepel`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text_repel.md),
[`GeomSketchViolin`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_violin.md),
[`StatSketchBeeswarm`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_beeswarm.md),
[`StatSketchCalendar`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_calendar.md),
[`StatSketchDensityRidges`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ridgeline.md),
[`StatSketchFunnel`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_funnel.md),
[`StatSketchPie`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_pie.md),
[`StatSketchPyramid`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_pyramid.md),
[`StatSketchRadar`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_radar.md),
[`StatSketchStream`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_streamgraph.md),
[`StatSketchTreemap`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_treemap.md),
[`StatSketchWaffle`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_waffle.md),
[`StatSketchWaterfall`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_waterfall.md),
[`annotate_sketch()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch.md),
[`annotate_sketch_arrow()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch_arrow.md),
[`annotate_sketch_callout()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch_callout.md),
[`annotate_sketch_highlight()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch_highlight.md),
[`geom_sketch_alluvial()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_alluvial.md),
[`geom_sketch_arc_diagram()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_arc_diagram.md),
[`geom_sketch_bin2d()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bin2d.md),
[`geom_sketch_bump()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bump.md),
[`geom_sketch_chord()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_chord.md),
[`geom_sketch_contour()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_contour.md),
[`geom_sketch_count()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_count.md),
[`geom_sketch_dendrogram()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_dendrogram.md),
[`geom_sketch_density()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_density.md),
[`geom_sketch_density2d()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_density2d.md),
[`geom_sketch_ecdf()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ecdf.md),
[`geom_sketch_function()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_function.md),
[`geom_sketch_histogram()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_histogram.md),
[`geom_sketch_jitter()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_jitter.md),
[`geom_sketch_marimekko()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_marimekko.md),
[`geom_sketch_mosaic()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_mosaic.md),
[`geom_sketch_parallel()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_parallel.md),
[`geom_sketch_qq()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_qq.md),
[`geom_sketch_quantile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_quantile.md),
[`geom_sketch_rose()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rose.md),
[`geom_sketch_sunburst()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_sunburst.md),
[`geom_sketch_text()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text.md),
[`sketch_graph()`](https://orijitghosh.github.io/ggsketch/reference/sketch_graph.md)

## Examples

``` r
library(ggplot2)
df <- data.frame(g = c("Alpha", "Bravo", "Charlie", "Delta"),
                 before = c(20, 35, 28, 42),
                 after  = c(34, 51, 22, 47))
ggplot(df, aes(x = before, xend = after, y = g)) +
  geom_sketch_dumbbell(colour_x = "#B03A2E", colour_xend = "#1F618D",
                       seed = 1L) +
  theme_sketch()
```
