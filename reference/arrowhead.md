# Build the ideal paths for one arrowhead

Returns the un-roughened geometry of an arrowhead whose tip is at
`(tipx, tipy)` and which points along `angle`. The grob layer roughens
and paints it, so this stays pure geometry and reproduces on every
device. Styles: `"triangle_open"` (a two-stroke V), `"triangle_filled"`
(a solid triangle), `"barb"` (swept-back harpoon barbs), `"fishtail"` (a
forked swallowtail), `"dot"` (a blob at the tip) and `"bar"` (a
perpendicular tick).

## Usage

``` r
arrowhead(
  tipx,
  tipy,
  angle,
  length,
  half_angle = 25 * pi/180,
  style = "triangle_open"
)
```

## Arguments

- tipx, tipy:

  Tip position (inch space).

- angle:

  Direction the arrow points, in radians (the end tangent).

- length:

  Head length in inches.

- half_angle:

  Half-angle of the wings, in radians. Default ~25 degrees.

- style:

  One of
  [`sketch_arrowheads()`](https://orijitghosh.github.io/ggsketch/reference/sketch_arrowheads.md).

## Value

A list with `strokes` (a list of 2-column `(x, y)` polylines to stroke),
`polygons` (a list of `(x, y)` rings to fill) and `dots`
(`list(x, y, r)` or `NULL`).

## See also

Other sketch-core:
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
[`watercolor_wash()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash.md),
[`watercolor_wash_multi()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash_multi.md)

## Examples

``` r
arrowhead(1, 1, angle = 0, length = 0.2, style = "barb")
#> $strokes
#> list()
#> 
#> $polygons
#> $polygons[[1]]
#>              x         y
#> [1,] 1.0000000 1.0000000
#> [2,] 0.8187384 1.0845237
#> [3,] 0.7500000 1.0000000
#> [4,] 0.8187384 0.9154763
#> [5,] 1.0000000 1.0000000
#> 
#> 
#> $dots
#> NULL
#> 
```
