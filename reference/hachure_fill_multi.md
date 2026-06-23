# Fill a multi-ring region with hachure lines (hole-aware)

Like
[`hachure_fill()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill.md)
but takes a list of rings sharing one Active Edge Table, so the even-odd
scan-line parity excludes holes and skips the gaps between disjoint
pieces automatically. This is what powers the filled contour / 2-D
density band geoms, whose regions have holes.

## Usage

``` r
hachure_fill_multi(
  rings,
  hachure_gap = 0.1,
  hachure_angle = 45,
  roughness = 0,
  bowing = 0,
  seed = NULL
)
```

## Arguments

- rings:

  A list of rings, each a list with numeric `x` and `y` vertex vectors
  (inch space). The first ring is typically the outer boundary and the
  rest holes, but any even-odd arrangement of outer pieces and holes is
  handled.

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

A list of 2-column (x, y) fill-line matrices (same structure as
[`hachure_fill()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill.md)).

## See also

Other sketch-core:
[`curve_fill()`](https://orijitghosh.github.io/ggsketch/reference/curve_fill.md),
[`hachure_fill()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill.md),
[`rough_arc()`](https://orijitghosh.github.io/ggsketch/reference/rough_arc.md),
[`rough_bezier()`](https://orijitghosh.github.io/ggsketch/reference/rough_bezier.md),
[`rough_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/rough_ellipse.md),
[`roughen_polyline()`](https://orijitghosh.github.io/ggsketch/reference/roughen_polyline.md),
[`sketch_fill()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill.md),
[`sketch_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill_multi.md)
