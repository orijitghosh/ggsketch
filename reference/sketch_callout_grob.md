# Create a sketchy callout grob (boxed label + leader arrow)

Draws a handwriting label inside a roughened rounded box and a leader
arrow from the box to a target point. The box auto-sizes to the label at
draw time (device-space text metrics) and the leader leaves from the box
edge nearest the target.

## Usage

``` r
sketch_callout_grob(
  x,
  y,
  xend,
  yend,
  label,
  padding = 0.06,
  corner_radius = 0.3,
  roughness = 1,
  bowing = 0.6,
  n_passes = 2L,
  seed = NULL,
  arrow_length = NULL,
  arrow_angle = 25,
  text_gp = gpar(),
  box_gp = gpar(),
  arrow_gp = gpar(),
  name = NULL,
  vp = NULL
)
```

## Arguments

- x, y:

  Box centre in npc \[0,1\] (scalars).

- xend, yend:

  Target point in npc the leader points at (scalars). Pass `NA` for both
  to draw a boxed label with no leader.

- label:

  Label text.

- padding:

  Box padding around the text, in inches. Default 0.06.

- corner_radius:

  Box corner rounding (fraction of half-side). Default 0.3.

- roughness, bowing, n_passes, seed:

  Sketch parameters.

- arrow_length, arrow_angle:

  Leader arrowhead size (see
  [`sketch_arrow_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_arrow_grob.md)).

- text_gp, box_gp, arrow_gp:

  `gpar()`s for the label, the box (outline; its `fill` paints the box),
  and the leader.

- name, vp:

  Passed to [`grid::gTree()`](https://rdrr.io/r/grid/grid.grob.html).

## Value

A `SketchCalloutGrob` grob subclass.

## See also

Other grob-layer:
[`sketch_arrow_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_arrow_grob.md),
[`sketch_ellipse_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_ellipse_grob.md),
[`sketch_path_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_path_grob.md),
[`sketch_polygon_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_polygon_grob.md),
[`sketch_wedge_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_wedge_grob.md)
