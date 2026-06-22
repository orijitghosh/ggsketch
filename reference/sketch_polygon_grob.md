# Create a sketchy polygon grob with optional hachure fill

Create a sketchy polygon grob with optional hachure fill

## Usage

``` r
sketch_polygon_grob(
  x,
  y,
  id = NULL,
  roughness = 1,
  bowing = 1,
  n_passes = 2L,
  seed = NULL,
  fill_gp = gpar(),
  outline_gp = gpar(),
  fill_style = "hachure",
  hachure_angle = 45,
  hachure_gap = 0.07,
  fill_weight = 0.5,
  fill_roughness = NULL,
  fill_seed = NULL,
  name = NULL,
  vp = NULL
)
```

## Arguments

- x, y:

  Numeric npc \[0,1\] coordinates.

- id:

  Group IDs (same semantics as
  [`grid::polygonGrob`](https://rdrr.io/r/grid/grid.polygon.html)).

- roughness, bowing, n_passes, seed:

  Sketch parameters for the outline.

- fill_gp:

  `gpar()` for fill lines (`col` sets fill-line colour).

- outline_gp:

  `gpar()` for the rough outline stroke.

- fill_style, hachure_angle, hachure_gap, fill_weight:

  Fill parameters.

- fill_roughness:

  Roughness of the fill strokes. `NULL` (default) ties it to the outline
  as `roughness * 0.5`; set a number to control the fill texture
  independently of the outline.

- fill_seed:

  Seed for the fill strokes. `NULL` (default) derives it from `seed`;
  set an integer to vary the fill pattern without moving the outline.

- name, vp:

  Passed to [`grid::grob()`](https://rdrr.io/r/grid/grid.grob.html).

## Value

A `SketchPolygonGrob` grob subclass.

## See also

Other grob-layer:
[`sketch_ellipse_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_ellipse_grob.md),
[`sketch_path_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_path_grob.md)
