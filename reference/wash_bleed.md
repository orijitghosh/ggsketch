# Pigment bleed between two overlapping wash regions

Where two wet watercolour washes overlap the pigments diffuse and the
colours mix - the "wet-on-wet" bleed. This approximates it without
polygon clipping: it samples points lying inside *both* polygons (the
overlap region) and returns soft translucent specks tinted with the
blended colour. The grob layer paints the specks at low alpha over the
two washes, so the shared area reads as mingled pigment. Pure geometry +
colour math; reproduces on every device.

## Usage

``` r
wash_bleed(
  ax,
  ay,
  bx,
  by,
  col_a,
  col_b,
  density = 0.5,
  bleed = NULL,
  seed = NULL
)
```

## Arguments

- ax, ay, bx, by:

  Vertices (inch space) of the two wash polygons.

- col_a, col_b:

  The two wash colours (any R colour spec).

- density:

  Fraction in `[0, 1]`: speck density in the overlap. Default 0.5.

- bleed:

  Speck radius scale in inches. `NULL` (default) scales to ~2.5% of the
  overlap's bounding diagonal.

- seed:

  Integer seed.

## Value

A `list(x, y, r, fill)` of bleed specks (inch space), or `NULL` when the
polygons' bounding boxes - or the sampled overlap - do not meet.

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
[`watercolor_wash()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash.md),
[`watercolor_wash_multi()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash_multi.md)
