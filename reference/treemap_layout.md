# Squarified treemap layout

Lays out one rectangle per value inside the box
`[x, x + width] x [y, y + height]`, with area proportional to the value
and aspect ratios kept close to 1. Returns rectangles in the original
input order.

## Usage

``` r
treemap_layout(values, x = 0, y = 0, width = 1, height = 1)
```

## Arguments

- values:

  Non-negative numeric vector (one per tile). Zero / negative values
  produce zero-area tiles.

- x, y:

  Lower-left corner of the bounding box. Default 0.

- width, height:

  Bounding box size. Default 1.

## Value

A data frame with columns `xmin`, `xmax`, `ymin`, `ymax`, one row per
input value, in input order.

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
[`wash_bleed()`](https://orijitghosh.github.io/ggsketch/reference/wash_bleed.md),
[`watercolor_wash()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash.md),
[`watercolor_wash_multi()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash_multi.md)

## Examples

``` r
treemap_layout(c(6, 3, 2, 1))
#>        xmin      xmax ymin ymax
#> 1 0.0000000 0.5000000  0.0  1.0
#> 2 0.5000000 1.0000000  0.0  0.5
#> 3 0.5000000 0.8333333  0.5  1.0
#> 4 0.8333333 1.0000000  0.5  1.0
```
