# Create an airbrush / spray stroke grob

A `grid` grob that draws its path as a soft cloud of dots instead of a
stroked line: it re-roughens the centreline at device resolution, then
scatters dots around it with
[`spray_scatter()`](https://orijitghosh.github.io/ggsketch/reference/spray_scatter.md),
for the airbrush / spray-can medium (no hard outline). Coordinates are
npc \[0,1\]; the scatter happens in device inches inside
`makeContent()`.

## Usage

``` r
sketch_spray_grob(
  x,
  y,
  id = NULL,
  spread = 0.05,
  density = 150,
  dot_r = 0.004,
  roughness = 1,
  bowing = 1,
  n_passes = 1L,
  seed = NULL,
  gp = gpar(),
  name = NULL,
  vp = NULL
)
```

## Arguments

- x, y:

  Numeric vectors of npc \[0,1\] coordinates.

- id:

  Integer vector grouping coordinates into separate strokes (`NULL`
  treats all points as one).

- spread, density, dot_r:

  Passed to
  [`spray_scatter()`](https://orijitghosh.github.io/ggsketch/reference/spray_scatter.md)
  (in **inches**).

- roughness, bowing, n_passes, seed:

  Sketch parameters for the centreline.

- gp:

  A [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html); its `col`
  becomes the dot fill, `alpha` is honoured.

- name, vp:

  Passed to [`grid::gTree()`](https://rdrr.io/r/grid/grid.grob.html).

## Value

A `SketchSprayGrob` (a grid grob subclass).

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
[`sketch_repel_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_repel_grob.md),
[`sketch_stroke_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_stroke_grob.md),
[`sketch_wedge_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_wedge_grob.md)
