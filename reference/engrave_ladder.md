# Build a tonal hatch ladder for engraving fills

An engraving ladder is an ordered list of hatch layers; each is applied
only where the tone field is at least its `threshold`, so darker regions
accumulate more (and finer, cross-hatched) layers. Defaults trace the
classic etching progression: a sparse base layer, then denser same-angle
lines, then a second angle (cross-hatch), then the fine angles that read
as black.

## Usage

``` r
engrave_ladder(
  n_levels = 5L,
  base_gap = 0.1,
  gap_ratio = 0.62,
  base_angle = 45,
  cross_after = 3L,
  cross_angle = 90,
  tone_floor = 0.12,
  tone_ceiling = 0.92
)
```

## Arguments

- n_levels:

  Number of hatch layers. Default 5.

- base_gap:

  Pitch (inches) of the sparsest layer. Each subsequent layer tightens
  geometrically toward `base_gap * gap_ratio^(n_levels - 1)`. Default
  0.10.

- gap_ratio:

  Multiplicative pitch shrink per layer (0 \< r \<= 1; smaller = faster
  densening). Default 0.62.

- base_angle:

  Angle (degrees) of the first layer. Default 45.

- cross_after:

  Layer index (1-based) at which cross-hatching begins; from this layer
  on, angles alternate by `cross_angle`. Default 3.

- cross_angle:

  Angular offset (degrees) of the cross direction. Default 90.

- tone_floor, tone_ceiling:

  Tone thresholds of the first and last layers; the layers' thresholds
  are spread evenly between them. A region with tone below `tone_floor`
  is left blank (paper); tone at or above `tone_ceiling` gets every
  layer. Defaults 0.12 and 0.92.

## Value

A list of layers, each `list(gap, angle, threshold)`.

## See also

Other sketch-core:
[`arrowhead()`](https://orijitghosh.github.io/ggsketch/reference/arrowhead.md),
[`curve_fill()`](https://orijitghosh.github.io/ggsketch/reference/curve_fill.md),
[`engrave_fill()`](https://orijitghosh.github.io/ggsketch/reference/engrave_fill.md),
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
[`watercolor_wash()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash.md),
[`watercolor_wash_multi()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash_multi.md)
