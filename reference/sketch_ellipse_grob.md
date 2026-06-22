# Create a sketchy ellipse / circle grob

Draws one or more roughened ellipses whose centres are in npc \[0,1\]
and whose radii are npc fractions of the viewport (converted to device
inches in `makeContent()`, so a "circle" in data units may appear
elliptical on a non-square panel - matching ggplot2's coordinate
semantics).

## Usage

``` r
sketch_ellipse_grob(
  x,
  y,
  rx,
  ry,
  roughness = 1,
  n_passes = 2L,
  seed = NULL,
  fill_style = NULL,
  hachure_angle = 45,
  hachure_gap = 0.07,
  fill_weight = 0.5,
  fill_roughness = NULL,
  fill_seed = NULL,
  fill_gp = gpar(),
  outline_gp = gpar(),
  name = NULL,
  vp = NULL
)
```

## Arguments

- x, y:

  Numeric npc centre coordinates (vectors).

- rx, ry:

  Numeric npc radii (vectors, recycled to `x`).

- roughness, n_passes, seed:

  Sketch parameters.

- fill_style, hachure_angle, hachure_gap, fill_weight:

  Fill parameters; set `fill_style = NULL` or `"solid"` for outline
  only.

- fill_roughness:

  Roughness of the fill strokes. `NULL` (default) ties it to the outline
  as `roughness * 0.4`; set a number to control the fill texture
  independently of the outline.

- fill_seed:

  Seed for the fill strokes. `NULL` (default) derives it from `seed`;
  set an integer to vary the fill pattern without moving the outline.

- fill_gp:

  `gpar()` for the fill lines.

- outline_gp:

  `gpar()` for the rough outline stroke.

- name, vp:

  Passed to [`grid::gTree()`](https://rdrr.io/r/grid/grid.grob.html).

## Value

A `SketchEllipseGrob` grob subclass.

## See also

Other grob-layer:
[`sketch_path_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_path_grob.md),
[`sketch_polygon_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_polygon_grob.md)
