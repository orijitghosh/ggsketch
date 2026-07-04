# Sketchy waffle chart

Draws a hand-drawn waffle: a square grid (default 10x10 = 100 cells)
where each cell is coloured by category, so the number of cells of a
colour reads as that category's share of the whole. Map the category to
`fill`; map a count to `weight` if the data is already summarised
(otherwise each row counts as one). Cells are drawn with
[`geom_sketch_tile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md),
so they take the usual roughened outline and `fill_style` (including
`"watercolor"`). Add
[`ggplot2::coord_equal()`](https://ggplot2.tidyverse.org/reference/coord_fixed.html)
to keep the cells square. (cf. `waffle::geom_waffle()`).

## Usage

``` r
StatSketchWaffle

geom_sketch_waffle(
  mapping = NULL,
  data = NULL,
  stat = "sketch_waffle",
  position = "identity",
  ...,
  n_rows = 10L,
  cells = 100L,
  flip = FALSE,
  width = 0.9,
  height = 0.9,
  colour = "grey35",
  fill_style = "hachure",
  roughness = 1,
  bowing = 1,
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
  Requires `fill`; optionally `weight` (a per-row count).

- data:

  Data to display.

- stat:

  Statistical transformation. Default `"sketch_waffle"`.

- position:

  Position adjustment. Default `"identity"`.

- ...:

  Other arguments passed on to the layer.

- n_rows:

  Number of rows in the grid. Default 10.

- cells:

  Total number of cells (the grid resolution). Default 100, i.e. a
  percentage waffle.

- flip:

  Fill columns top-down instead of bottom-up? Default `FALSE`.

- width, height:

  Cell size in grid units (gaps appear below 1). Default 0.9.

- colour:

  Outline colour for each cell. Default `"grey35"`.

- fill_style:

  Cell fill style; see
  [`geom_sketch_rect()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md).
  Default `"hachure"`.

- roughness, bowing, n_passes, seed:

  Sketch parameters.

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
[`GeomSketchDumbbell`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_dumbbell.md),
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
df <- data.frame(grp = c("Rent", "Food", "Travel", "Other"),
                 spend = c(45, 25, 20, 10))
ggplot(df, aes(fill = grp, weight = spend)) +
  geom_sketch_waffle(seed = 1L) +
  coord_equal() +
  theme_sketch()
```
