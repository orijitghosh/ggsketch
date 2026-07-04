# Dispatch fill-style to the appropriate Layer-1 fill function

Dispatch fill-style to the appropriate Layer-1 fill function

## Usage

``` r
sketch_fill(
  px,
  py,
  fill_style = "hachure",
  hachure_gap = 0.1,
  hachure_angle = 45,
  fill_weight = 1,
  roughness = 0.5,
  bowing = 0,
  seed = NULL
)
```

## Arguments

- px, py:

  Polygon vertices (inch space).

- fill_style:

  Character: one of `"hachure"`, `"cross_hatch"`, `"zigzag"`,
  `"zigzag_line"`, `"dots"`, `"dashed"`, `"solid"`.

- hachure_gap:

  Gap between fill lines (inches). Default 0.1.

- hachure_angle:

  Base fill angle (degrees). Default 45.

- fill_weight:

  Thickness weight (passed to caller for gpar). Default 1.

- roughness, bowing:

  Sketch params for fill lines. Defaults 0.5, 0.

- seed:

  Integer seed.

## Value

List of 2-column (x,y) matrices representing fill stroke segments, OR
`NULL` for `"solid"` (solid fill handled by polygon fill colour).

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
[`sketch_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill_multi.md),
[`spray_scatter()`](https://orijitghosh.github.io/ggsketch/reference/spray_scatter.md),
[`stroke_profile()`](https://orijitghosh.github.io/ggsketch/reference/stroke_profile.md),
[`stroke_ribbon()`](https://orijitghosh.github.io/ggsketch/reference/stroke_ribbon.md),
[`treemap_layout()`](https://orijitghosh.github.io/ggsketch/reference/treemap_layout.md),
[`wash_bleed()`](https://orijitghosh.github.io/ggsketch/reference/wash_bleed.md),
[`watercolor_wash()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash.md),
[`watercolor_wash_multi()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash_multi.md)
