# Create a sketchy path grob

A `grid` grob that re-roughens its path at actual render resolution in
`makeContent()`. Coordinates are in npc \[0,1\]; roughening is performed
in device inches.

## Usage

``` r
sketch_path_grob(
  x,
  y,
  id = NULL,
  roughness = 1,
  bowing = 1,
  n_passes = 2L,
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

  Integer vector grouping coordinates into separate polylines (same
  semantics as
  [`grid::polylineGrob`](https://rdrr.io/r/grid/grid.lines.html)).
  `NULL` treats all points as one path.

- roughness, bowing, n_passes, seed:

  Sketch parameters.

- gp:

  A [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html) object
  controlling line aesthetics.

- name, vp:

  Passed to [`grid::grob()`](https://rdrr.io/r/grid/grid.grob.html).

## Value

A `SketchPathGrob` (a grid grob subclass).

## See also

Other grob-layer:
[`sketch_ellipse_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_ellipse_grob.md),
[`sketch_polygon_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_polygon_grob.md)
