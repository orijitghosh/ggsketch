# Roughen an ellipse into one or more sketch stroke paths

Generates points around the ellipse, roughens them, and connects them
with a smooth path (sampled cubic Bézier between consecutive
point-pairs). Deliberately leaves a small gap at the close point ("ends
don't meet" hand-drawn effect).

## Usage

``` r
rough_ellipse(cx, cy, rx, ry, roughness = 1, n_passes = 2L, seed = NULL)
```

## Arguments

- cx, cy:

  Centre coordinates in inch space.

- rx, ry:

  Semi-axis radii in inches (rx = horizontal, ry = vertical).

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
[`rough_bezier()`](https://orijitghosh.github.io/ggsketch/reference/rough_bezier.md),
[`roughen_polyline()`](https://orijitghosh.github.io/ggsketch/reference/roughen_polyline.md),
[`sketch_fill()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill.md)
