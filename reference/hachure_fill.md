# Fill a polygon with hachure lines using the AET scan-line algorithm

Fill a polygon with hachure lines using the AET scan-line algorithm

## Usage

``` r
hachure_fill(
  px,
  py,
  hachure_gap = 0.1,
  hachure_angle = 45,
  roughness = 0,
  bowing = 0,
  seed = NULL
)
```

## Arguments

- px, py:

  Polygon vertex coordinates in inch space. May be open or closed.

- hachure_gap:

  Spacing between fill lines (inches). Default 0.1.

- hachure_angle:

  Fill angle (degrees). Default 45.

- roughness:

  Roughness applied to each fill line. Default 0 (straight).

- bowing:

  Bowing applied to each fill line. Default 0.

- seed:

  Integer seed.

## Value

A list of 2-column (x, y) matrices, one per fill line (roughened if
roughness \> 0, otherwise two-point straight segments).

## See also

Other sketch-core:
[`curve_fill()`](https://orijitghosh.github.io/ggsketch/reference/curve_fill.md),
[`rough_arc()`](https://orijitghosh.github.io/ggsketch/reference/rough_arc.md),
[`rough_bezier()`](https://orijitghosh.github.io/ggsketch/reference/rough_bezier.md),
[`rough_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/rough_ellipse.md),
[`roughen_polyline()`](https://orijitghosh.github.io/ggsketch/reference/roughen_polyline.md),
[`sketch_fill()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill.md)
