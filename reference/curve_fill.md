# Flatten a closed Bezier boundary to a polygon, then fill

For area/ribbon/density geoms: converts a curved boundary (list of
Bezier control-point sets) into a polygon approximation, then applies
`sketch_fill`.

## Usage

``` r
curve_fill(bezier_list, tol = 0.001, rdp_eps = 1e-04, ...)
```

## Arguments

- bezier_list:

  List of 4-element lists, each with `P0`, `P1`, `P2`, `P3` (each a
  length-2 c(x,y) vector in inch space). The list describes a closed
  path.

- tol:

  Flatness tolerance for flattening. Default 1e-3.

- rdp_eps:

  RDP epsilon. Default 1e-4.

- ...:

  Passed to `sketch_fill`.

## Value

List of fill-line segments (same structure as `sketch_fill`).

## See also

Other sketch-core:
[`hachure_fill()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill.md),
[`hachure_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill_multi.md),
[`rough_arc()`](https://orijitghosh.github.io/ggsketch/reference/rough_arc.md),
[`rough_bezier()`](https://orijitghosh.github.io/ggsketch/reference/rough_bezier.md),
[`rough_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/rough_ellipse.md),
[`roughen_polyline()`](https://orijitghosh.github.io/ggsketch/reference/roughen_polyline.md),
[`sketch_fill()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill.md),
[`sketch_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill_multi.md)
