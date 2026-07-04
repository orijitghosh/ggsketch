# Roughen a cubic Bezier curve

Applies roughness to all four control points, then flattens and reduces
the curve. Returns `n_passes` roughened polyline paths.

## Usage

``` r
rough_bezier(
  P0,
  P1,
  P2,
  P3,
  roughness = 1,
  bowing = 1,
  n_passes = 2L,
  seed = NULL,
  tol = NULL,
  rdp_eps = NULL
)
```

## Arguments

- P0, P1, P2, P3:

  Control points as length-2 numeric vectors c(x, y) in inch space.

- roughness:

  Non-negative roughness radius (inches). Default 1.

- bowing:

  Bowing multiplier (currently not applied to Bezier control points
  separately; roughness serves the role). Default 1.

- n_passes:

  Number of stroke passes. Default 2.

- seed:

  Integer seed for reproducibility.

- tol:

  Flatness tolerance. Default `max(roughness * 0.01, 1e-4)`.

- rdp_eps:

  RDP epsilon. Default `max(roughness * 0.005, 1e-5)`.

## Value

List of `n_passes` 2-column (x, y) matrices.

## See also

Other sketch-core:
[`arrowhead()`](https://orijitghosh.github.io/ggsketch/reference/arrowhead.md),
[`curve_fill()`](https://orijitghosh.github.io/ggsketch/reference/curve_fill.md),
[`engrave_fill()`](https://orijitghosh.github.io/ggsketch/reference/engrave_fill.md),
[`engrave_ladder()`](https://orijitghosh.github.io/ggsketch/reference/engrave_ladder.md),
[`hachure_fill()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill.md),
[`hachure_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill_multi.md),
[`leader_path()`](https://orijitghosh.github.io/ggsketch/reference/leader_path.md),
[`repel_layout()`](https://orijitghosh.github.io/ggsketch/reference/repel_layout.md),
[`rough_arc()`](https://orijitghosh.github.io/ggsketch/reference/rough_arc.md),
[`rough_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/rough_ellipse.md),
[`roughen_polyline()`](https://orijitghosh.github.io/ggsketch/reference/roughen_polyline.md),
[`sketch_arrowheads()`](https://orijitghosh.github.io/ggsketch/reference/sketch_arrowheads.md),
[`sketch_fill()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill.md),
[`sketch_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill_multi.md),
[`spray_scatter()`](https://orijitghosh.github.io/ggsketch/reference/spray_scatter.md),
[`stroke_profile()`](https://orijitghosh.github.io/ggsketch/reference/stroke_profile.md),
[`stroke_ribbon()`](https://orijitghosh.github.io/ggsketch/reference/stroke_ribbon.md),
[`treemap_layout()`](https://orijitghosh.github.io/ggsketch/reference/treemap_layout.md),
[`wash_bleed()`](https://orijitghosh.github.io/ggsketch/reference/wash_bleed.md),
[`watercolor_wash()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash.md),
[`watercolor_wash_multi()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash_multi.md)
