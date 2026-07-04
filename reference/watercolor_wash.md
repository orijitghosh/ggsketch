# Build a watercolour wash for a polygon region

Returns a stack of translucent boundary copies plus optional granulation
specks; the grob layer paints the copies at a low alpha so overlap
accumulates tone. The look the line-based fill styles cannot give: soft,
pooled, bleeding colour.

## Usage

``` r
watercolor_wash(
  px,
  py,
  n_layers = 6L,
  bleed = NULL,
  granulation = 0,
  grain = 0,
  seed = NULL
)
```

## Arguments

- px, py:

  Polygon vertices (inch space).

- n_layers:

  Number of wash copies. More = smoother, deeper, slower. Default 6.

- bleed:

  Edge irregularity in inches. `NULL` (default) scales to ~2% of the
  shape's bounding diagonal.

- granulation:

  Fraction in `[0, 1]`: density of pigment specks (0 = none). Default 0.

- grain:

  Paper-grain coupling in `[0, ~1]`: how strongly the edge feathers
  along the paper tooth. 0 (default) is the historical pure-uniform
  jitter; higher values wick the edge in coherent capillary channels
  (see
  [`paper_grain()`](https://orijitghosh.github.io/ggsketch/reference/paper_grain.md)).
  0 draws no extra randomness, so existing seeds reproduce.

- seed:

  Integer seed.

## Value

A list with `washes` (a list of 2-column `(x, y)` polygon matrices,
outermost/lightest first) and `granules` (`list(x, y, r)` in inches, or
`NULL`).

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
[`watercolor_wash_multi()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash_multi.md)
