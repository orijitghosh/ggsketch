# Scatter a cloud of dots along a path (airbrush / spray)

Samples points along a centreline and offsets each one perpendicular to
the path by a Gaussian random amount, producing a soft-edged spray of
dots with no hard outline – the airbrush / spray-can look. The dot
density falls off from the centreline (the Gaussian offset), and dots
near the edge are drawn smaller so the cloud feathers out. Pure
number-to-number (no `grid`/`ggplot2`); deterministic apart from the
seeded RNG (ADR-0004).

## Usage

``` r
spray_scatter(x, y, spread = 0.04, density = 140, dot_r = 0.004, seed = NULL)
```

## Arguments

- x, y:

  Numeric vectors of centreline vertices (same length, any units –
  `spread`, `dot_r` and `density` are interpreted in those units).

- spread:

  Standard deviation of the perpendicular offset (cloud half-width).

- density:

  Mean number of dots per unit of path arc-length.

- dot_r:

  Base dot radius. Edge dots shrink toward `0.4 * dot_r`.

- seed:

  Integer seed for the scatter (ADR-0004).

## Value

A 4-column matrix with columns `x`, `y` (dot centres), `r` (dot radii)
and `a` (a 0-1 weight that fades with distance from the centreline, for
the caller to fold into per-dot alpha if desired). Zero rows for a
degenerate path.

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
[`rough_bezier()`](https://orijitghosh.github.io/ggsketch/reference/rough_bezier.md),
[`rough_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/rough_ellipse.md),
[`roughen_polyline()`](https://orijitghosh.github.io/ggsketch/reference/roughen_polyline.md),
[`sketch_arrowheads()`](https://orijitghosh.github.io/ggsketch/reference/sketch_arrowheads.md),
[`sketch_fill()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill.md),
[`sketch_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill_multi.md),
[`stroke_profile()`](https://orijitghosh.github.io/ggsketch/reference/stroke_profile.md),
[`stroke_ribbon()`](https://orijitghosh.github.io/ggsketch/reference/stroke_ribbon.md),
[`treemap_layout()`](https://orijitghosh.github.io/ggsketch/reference/treemap_layout.md),
[`wash_bleed()`](https://orijitghosh.github.io/ggsketch/reference/wash_bleed.md),
[`watercolor_wash()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash.md),
[`watercolor_wash_multi()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash_multi.md)
