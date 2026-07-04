# Create a sketchy repelled-label grob

Places `label`s near their anchors `(x, y)` but nudged apart so they do
not overlap each other or sit on the points, via
[`repel_layout()`](https://orijitghosh.github.io/ggsketch/reference/repel_layout.md)
(run in device inches at draw time). Each displaced label is tied back
to its anchor with a roughened leader line. With `boxed = TRUE` the
labels sit in roughened rounded boxes (the
[`geom_sketch_label_repel()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text_repel.md)
look); otherwise they are bare text (the
[`geom_sketch_text_repel()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text_repel.md)
look).

## Usage

``` r
sketch_repel_grob(
  x,
  y,
  label,
  boxed = FALSE,
  padding = 0.07,
  corner_radius = 0.3,
  box_padding = 0.1,
  point_padding = 0.05,
  min_segment = 0.06,
  max_iter = 2000L,
  roughness = 1,
  bowing = 0.6,
  n_passes = 2L,
  seed = NULL,
  text_gp = gpar(),
  box_gp = gpar(),
  seg_gp = gpar(),
  name = NULL,
  vp = NULL
)
```

## Arguments

- x, y:

  Anchor points in npc \[0,1\] (vectors).

- label:

  Character labels (recycled to the anchors).

- boxed:

  Draw each label in a rounded box? Default `FALSE`.

- padding:

  Text-to-edge / text clearance, in inches. Default 0.07.

- corner_radius:

  Box corner rounding (fraction of half-side). Default 0.3.

- box_padding, point_padding:

  Extra clearance between boxes and around anchor points, in inches.

- min_segment:

  Shortest leader drawn, in inches (shorter = no leader).

- max_iter:

  Solver iteration cap. Default 2000.

- roughness, bowing, n_passes, seed:

  Sketch parameters.

- text_gp, box_gp, seg_gp:

  `gpar()`s for the text, the box, and the leader.

- name, vp:

  Passed to [`grid::gTree()`](https://rdrr.io/r/grid/grid.grob.html).

## Value

A `SketchRepelGrob` grob subclass.

## See also

Other grob-layer:
[`sketch_arrow_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_arrow_grob.md),
[`sketch_band_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_band_grob.md),
[`sketch_callout_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_callout_grob.md),
[`sketch_dotplot_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_dotplot_grob.md),
[`sketch_ellipse_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_ellipse_grob.md),
[`sketch_engrave_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_engrave_grob.md),
[`sketch_path_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_path_grob.md),
[`sketch_polygon_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_polygon_grob.md),
[`sketch_spray_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_spray_grob.md),
[`sketch_stroke_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_stroke_grob.md),
[`sketch_wedge_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_wedge_grob.md)
