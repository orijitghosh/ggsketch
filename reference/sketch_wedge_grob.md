# Create a sketchy pie/donut-wedge grob

Draws one or more annular sectors (pie or donut slices) sharing a
centre, guaranteed circular regardless of panel shape: radii are taken
as a fraction of the smaller panel dimension and the geometry is
assembled in device inches inside `makeContent()`, then roughened. Each
slice's roughened boundary is also reused as the fill region so the
hand-drawn edge is kept.

## Usage

``` r
sketch_wedge_grob(
  x0,
  y0,
  r,
  r0 = 0,
  start,
  end,
  roughness = 1,
  bowing = 0.4,
  n_passes = 2L,
  seed = NULL,
  fill_style = "solid",
  hachure_angle = 45,
  hachure_gap = 0.07,
  fill_weight = 0.5,
  fill_gp = gpar(),
  outline_gp = gpar(),
  name = NULL,
  vp = NULL
)
```

## Arguments

- x0, y0:

  Centre in npc \[0,1\] (scalars).

- r, r0:

  Outer and inner radius as a fraction of the smaller panel dimension
  (`r0 = 0` gives a pie, `r0 > 0` a donut).

- start, end:

  Per-slice start/end angles in radians.

- roughness, bowing, n_passes, seed:

  Sketch parameters for the outline.

- fill_style:

  `"solid"` (default) paints each slice in its fill colour; any other
  style (`"hachure"`, ...) hatches it instead.

- hachure_angle, hachure_gap, fill_weight:

  Fill parameters (`hachure_gap` is a fraction of the smaller panel
  dimension).

- fill_gp:

  `gpar()` for the fill (per-slice `col` recycled).

- outline_gp:

  `gpar()` for the rough outline (per-slice `col` recycled).

- name, vp:

  Passed to [`grid::gTree()`](https://rdrr.io/r/grid/grid.grob.html).

## Value

A `SketchWedgeGrob` grob subclass.

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
[`sketch_spray_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_spray_grob.md),
[`sketch_stroke_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_stroke_grob.md)
