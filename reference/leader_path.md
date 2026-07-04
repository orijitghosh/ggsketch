# Route a leader line from a box edge to a target

The un-roughened path a callout / annotation leader takes from its start
`(sx, sy)` (a box edge) to the target `(xe, ye)`: a `"straight"` line,
an `"elbow"` (horizontal then vertical, flowchart style) or a `"curved"`
quadratic-Bezier bow. Also reports the end tangent so the arrowhead can
orient to it. Pure geometry; the grob roughens the result.

## Usage

``` r
leader_path(sx, sy, xe, ye, style = "straight", curvature = 0.3)
```

## Arguments

- sx, sy:

  Leader start (inch space).

- xe, ye:

  Target point (inch space).

- style:

  One of `"straight"`, `"elbow"`, `"curved"`.

- curvature:

  Bow size for `"curved"` (signed). Default 0.3.

## Value

A list with `x`, `y` (the path vertices) and `angle` (end tangent, in
radians).

## See also

Other sketch-core:
[`arrowhead()`](https://orijitghosh.github.io/ggsketch/reference/arrowhead.md),
[`curve_fill()`](https://orijitghosh.github.io/ggsketch/reference/curve_fill.md),
[`engrave_fill()`](https://orijitghosh.github.io/ggsketch/reference/engrave_fill.md),
[`engrave_ladder()`](https://orijitghosh.github.io/ggsketch/reference/engrave_ladder.md),
[`hachure_fill()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill.md),
[`hachure_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill_multi.md),
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
leader_path(0, 0, 1, 1, style = "elbow")
#> $x
#> [1] 0 1 1
#> 
#> $y
#> [1] 0 0 1
#> 
#> $angle
#> [1] 1.570796
#> 
```
