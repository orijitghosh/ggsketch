# Sketchy engraving: tonal shading by hatch-line density

`geom_sketch_engrave()` shades a surface the way an etcher or banknote
engraver does: continuous tone is built from the *density* of hand-drawn
hatch lines, with cross-hatching deepening the shadows. It takes a
regular grid of `x`, `y`, and `z` (like
[`ggplot2::geom_raster()`](https://ggplot2.tidyverse.org/reference/geom_tile.html));
`z` is mapped to tone (high = dark by default). Unlike the fill-pattern
packages, the tone is *computed* from geometry (a
[`engrave_fill()`](https://orijitghosh.github.io/ggsketch/reference/engrave_fill.md)
ladder), not tiled from a motif.

## Usage

``` r
GeomSketchEngrave

GeomSketchShade

geom_sketch_engrave(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  levels = 5L,
  base_gap = 0.08,
  gap_ratio = 0.62,
  base_angle = 45,
  cross_after = 3L,
  reverse = FALSE,
  roughness = 0.5,
  bowing = 0.3,
  min_gap_in = 0.012,
  seed = NULL,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

geom_sketch_shade(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  levels = 5L,
  base_gap = 0.08,
  gap_ratio = 0.62,
  base_angle = 45,
  cross_after = 3L,
  roughness = 0.5,
  bowing = 0.3,
  min_gap_in = 0.012,
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
  `geom_sketch_engrave()` needs `x`, `y`, `z`; `geom_sketch_shade()`
  needs `x`, `y` and uses the `tone` aesthetic (default 0.6).

- data:

  Data to display.

- stat:

  Statistical transformation. Default `"identity"`.

- position:

  Position adjustment. Default `"identity"`.

- ...:

  Other arguments passed on to the layer.

- levels:

  Number of hatch layers in the ladder. Default 5.

- base_gap:

  Pitch of the sparsest layer (npc-x fraction). Default 0.08.

- gap_ratio:

  Multiplicative pitch shrink per layer (smaller = densens faster).
  Default 0.62.

- base_angle:

  Angle of the first hatch layer (degrees). Default 45.

- cross_after:

  Layer index at which cross-hatching begins. Default 3.

- reverse:

  (`geom_sketch_engrave()` only) Invert the tone mapping so low `z` is
  dark. Default `FALSE`.

- roughness:

  Non-negative stroke roughness. Default 0.5.

- bowing:

  Non-negative bowing multiplier. Default 0.3.

- min_gap_in:

  Pitch floor in inches; finer ladder layers are dropped. Default 0.012.

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

## Details

`geom_sketch_shade()` shades each polygon region with a *uniform*
density set by a `tone` aesthetic in `[0, 1]`, so a mapped value reads
directly as darkness – a hand-drawn alternative to a solid fill scale.

The hatch ladder is a stack of layers of increasing density and rotating
angle (`levels`, `base_gap`, `gap_ratio`, `base_angle`, `cross_after`);
each layer is drawn only where the tone reaches its threshold, so light
areas keep the sparse base layer and shadows accumulate every layer.
`min_gap_in` is a pitch floor (inches) that keeps the darkest tones from
exploding into a runaway number of strokes.

## See also

Other sketch-geoms:
[`GeomSketchAbline`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_abline.md),
[`GeomSketchArrow`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_arrow.md),
[`GeomSketchBoxplot`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_boxplot.md),
[`GeomSketchBracket`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bracket.md),
[`GeomSketchCallout`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_callout.md),
[`GeomSketchChicklet`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_chicklet.md),
[`GeomSketchCol`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md),
[`GeomSketchContourFilled`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_contour_filled.md),
[`GeomSketchCurve`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_curve.md),
[`GeomSketchDotplot`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_dotplot.md),
[`GeomSketchDumbbell`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_dumbbell.md),
[`GeomSketchEdge`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_edge.md),
[`GeomSketchEllipse`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md),
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
ggplot(faithfuld, aes(waiting, eruptions, z = density)) +
  geom_sketch_engrave(seed = 1L) +
  theme_sketch()


# A real surface: an engraved relief map of Maungawhau (Mt Eden),
# the way a 19th-century atlas shades elevation by hatch density.
volcano_df <- expand.grid(
  easting  = seq_len(nrow(volcano)),
  northing = seq_len(ncol(volcano))
)
volcano_df$height <- as.vector(volcano)

ggplot(volcano_df, aes(easting, northing, z = height)) +
  geom_sketch_engrave(
    levels = 8L, base_gap = 0.04, gap_ratio = 0.72,
    roughness = 0.35, bowing = 0.2, seed = 1L
  ) +
  coord_equal() +
  labs(title = "Maungawhau", subtitle = "engraved by elevation") +
  theme_sketch()
```
