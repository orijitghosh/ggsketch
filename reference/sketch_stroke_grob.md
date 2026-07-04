# Create a variable-width sketch stroke grob

A `grid` grob that draws its path as a tapered / pressure-varying
hand-drawn stroke. Unlike
[`sketch_path_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_path_grob.md)
(constant-`lwd` polylines), the line is built from
[`stroke_ribbon()`](https://orijitghosh.github.io/ggsketch/reference/stroke_ribbon.md)
polygons, so it can taper to a point, swell with pressure, or vary like
a broad calligraphic nib. Coordinates are npc \[0,1\]; roughening and
offsetting happen in device inches inside `makeContent()`.

## Usage

``` r
sketch_stroke_grob(
  x,
  y,
  id = NULL,
  width = 0.03,
  roughness = 1,
  bowing = 1,
  n_passes = 2L,
  seed = NULL,
  taper = "none",
  taper_frac = 0,
  pressure = NULL,
  nib_angle = NULL,
  jitter_w = 0,
  cap = "round",
  gp = gpar(),
  name = NULL,
  vp = NULL
)
```

## Arguments

- x, y:

  Numeric vectors of npc \[0,1\] coordinates.

- id:

  Integer vector grouping coordinates into separate strokes (same
  semantics as
  [`sketch_path_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_path_grob.md)).
  `NULL` treats all points as one stroke.

- width:

  Full stroke width in **inches**. Default `0.03`.

- roughness, bowing, n_passes, seed:

  Sketch parameters for the centreline.

- taper, taper_frac, pressure, nib_angle, jitter_w, cap:

  Passed to
  [`stroke_ribbon()`](https://orijitghosh.github.io/ggsketch/reference/stroke_ribbon.md).

- gp:

  A [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html); its `col`
  becomes the ribbon fill (the ribbon is painted, not stroked), `alpha`
  is honoured.

- name, vp:

  Passed to [`grid::gTree()`](https://rdrr.io/r/grid/grid.grob.html).

## Value

A `SketchStrokeGrob` (a grid grob subclass).

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
[`sketch_wedge_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_wedge_grob.md)
