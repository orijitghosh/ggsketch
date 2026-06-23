# Roughen an elliptical arc into one or more sketch stroke paths

The open-arc sibling of
[`rough_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/rough_ellipse.md).
Samples the arc by arc length, displaces each point slightly, and
returns `n_passes` overlaid strokes for the double-stroke hand-drawn
look. Unlike a full ellipse the path is left open (the ends are not
joined).

## Usage

``` r
rough_arc(
  cx,
  cy,
  rx,
  ry,
  start,
  end,
  roughness = 1,
  n_passes = 2L,
  seed = NULL
)
```

## Arguments

- cx, cy:

  Centre coordinates in inch space.

- rx, ry:

  Semi-axis radii in inches.

- start, end:

  Start/end angle in radians (counter-clockwise from the positive
  x-axis; `end` may be less than `start`).

- roughness:

  Non-negative roughness parameter. Default 1.

- n_passes:

  Number of stroke overlays. Default 2.

- seed:

  Integer seed for reproducibility.

## Value

List of `n_passes` 2-column (x, y) matrices of stroke points.

## See also

Other sketch-core:
[`curve_fill()`](https://orijitghosh.github.io/ggsketch/reference/curve_fill.md),
[`hachure_fill()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill.md),
[`hachure_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill_multi.md),
[`rough_bezier()`](https://orijitghosh.github.io/ggsketch/reference/rough_bezier.md),
[`rough_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/rough_ellipse.md),
[`roughen_polyline()`](https://orijitghosh.github.io/ggsketch/reference/roughen_polyline.md),
[`sketch_fill()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill.md),
[`sketch_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill_multi.md)
