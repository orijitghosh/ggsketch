# Repel overlapping label boxes away from each other and their anchors

A small physical solver behind
[`geom_sketch_text_repel()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text_repel.md)
/
[`geom_sketch_label_repel()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text_repel.md).
Each label starts near its anchor and is pushed by three forces,
iterated to rest: boxes that overlap shove each other apart along their
axis of least penetration (preferring an axis with room left inside the
bounds, so pairs pressed into a panel corner escape along the edge
instead of staying stuck); a box covering any anchor point slides off
it; and a weak spring pulls each box back toward its own anchor so
labels stay close to what they name. Positions are clamped to `xlim` /
`ylim`.

## Usage

``` r
repel_layout(
  ax,
  ay,
  w,
  h,
  xlim = c(-Inf, Inf),
  ylim = c(-Inf, Inf),
  box_padding = 0.1,
  point_padding = 0.05,
  max_iter = 2000L,
  seed = NULL
)
```

## Arguments

- ax, ay:

  Anchor points (one per label), in a single isotropic space (e.g.
  device inches).

- w, h:

  Label box width and height (same units), recycled to the anchors.

- xlim, ylim:

  Length-2 bounds the box centres are kept within.

- box_padding, point_padding:

  Extra clearance around boxes and around anchor points, in the same
  units.

- max_iter:

  Maximum solver iterations. Default 2000.

- seed:

  Integer seed (for the tiny start jitter that separates labels sharing
  an anchor).

## Value

A list with `x`, `y` (the resolved box centres) and `iter` (iterations
actually run).

## See also

Other sketch-core:
[`arrowhead()`](https://orijitghosh.github.io/ggsketch/reference/arrowhead.md),
[`curve_fill()`](https://orijitghosh.github.io/ggsketch/reference/curve_fill.md),
[`engrave_fill()`](https://orijitghosh.github.io/ggsketch/reference/engrave_fill.md),
[`engrave_ladder()`](https://orijitghosh.github.io/ggsketch/reference/engrave_ladder.md),
[`hachure_fill()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill.md),
[`hachure_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill_multi.md),
[`leader_path()`](https://orijitghosh.github.io/ggsketch/reference/leader_path.md),
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
repel_layout(c(0, 0.1, 0.1), c(0, 0, 0.05), w = 0.4, h = 0.2, seed = 1L)
#> $x
#> [1] 3.197873e-05 1.000208e-01 4.491272e-01
#> 
#> $y
#> [1] -0.6580096 -0.2480149  0.1619851
#> 
#> $iter
#> [1] 2000
#> 
```
