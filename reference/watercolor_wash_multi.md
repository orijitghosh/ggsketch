# Build a hole-aware watercolour wash for a multi-ring region

The multi-ring analogue of
[`watercolor_wash()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash.md):
each wash layer is a jittered, resized copy of *every* ring, so the grob
can paint a layer as one even-odd path and keep holes empty (rings
shrink/grow about their own centroid). Used by the band / multi-ring
grobs (filled contours, density bands).

## Usage

``` r
watercolor_wash_multi(
  rings,
  n_layers = 6L,
  bleed = NULL,
  granulation = 0,
  grain = 0,
  seed = NULL
)
```

## Arguments

- rings:

  A list of rings, each a list with inch-space `x` and `y` vertex
  vectors. Even-odd nesting defines holes.

- n_layers:

  Number of wash copies. Default 6.

- bleed:

  Edge irregularity in inches. `NULL` (default) scales to ~2% of the
  combined bounding diagonal.

- granulation:

  Fraction in `[0, 1]`: density of pigment specks (0 = none). Default 0.
  Specks land inside the even-odd region (never in holes).

- grain:

  Paper-grain coupling in `[0, ~1]`: how strongly each ring's edge
  feathers along the paper tooth. 0 (default) is the historical
  pure-uniform jitter and draws no extra randomness. See
  [`paper_grain()`](https://orijitghosh.github.io/ggsketch/reference/paper_grain.md).

- seed:

  Integer seed.

## Value

A list with `washes` (a list of layers; each layer is a list of 2-column
`(x, y)` ring matrices, outermost/lightest first) and `granules`
(`list(x, y, r)` in inches, or `NULL`).

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
[`spray_scatter()`](https://orijitghosh.github.io/ggsketch/reference/spray_scatter.md),
[`stroke_profile()`](https://orijitghosh.github.io/ggsketch/reference/stroke_profile.md),
[`stroke_ribbon()`](https://orijitghosh.github.io/ggsketch/reference/stroke_ribbon.md),
[`treemap_layout()`](https://orijitghosh.github.io/ggsketch/reference/treemap_layout.md),
[`wash_bleed()`](https://orijitghosh.github.io/ggsketch/reference/wash_bleed.md),
[`watercolor_wash()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash.md)
