# Fill a region with tonal engraving (line density follows a tone field)

The engraving counterpart of
[`hachure_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill_multi.md):
instead of one uniform hatch, it lays down a
[`engrave_ladder()`](https://orijitghosh.github.io/ggsketch/reference/engrave_ladder.md)
of hatch layers and keeps each layer only where the `field` tone reaches
that layer's threshold, so line density (and cross-hatching) tracks the
tone continuously across the region. Holes are handled exactly as in
[`hachure_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill_multi.md)
(shared even-odd scan-line).

## Usage

``` r
engrave_fill(
  rings,
  field,
  ladder = NULL,
  roughness = 0.5,
  bowing = 0,
  sample_step = NULL,
  seed = NULL,
  ...
)
```

## Arguments

- rings:

  A list of rings, each `list(x, y)` of vertex coordinates in inch/data
  space (see
  [`hachure_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill_multi.md)).

- field:

  A vectorised tone function `function(x, y)` returning a value in
  `[0, 1]` per point (0 = lightest/paper, 1 = darkest/solid).

- ladder:

  A hatch ladder from
  [`engrave_ladder()`](https://orijitghosh.github.io/ggsketch/reference/engrave_ladder.md);
  if `NULL`, a default ladder is built from `...`.

- roughness, bowing:

  Sketch params applied to each surviving stroke. Defaults 0.5 and 0.

- sample_step:

  Tone-sampling step along each scan line (inches). `NULL` (default)
  uses a fraction of the finest ladder pitch.

- seed:

  Integer seed.

- ...:

  Passed to
  [`engrave_ladder()`](https://orijitghosh.github.io/ggsketch/reference/engrave_ladder.md)
  when `ladder` is `NULL`.

## Value

A list of 2-column (x, y) stroke matrices (same structure as
[`hachure_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill_multi.md)),
densest where the field is darkest.

## See also

Other sketch-core:
[`arrowhead()`](https://orijitghosh.github.io/ggsketch/reference/arrowhead.md),
[`curve_fill()`](https://orijitghosh.github.io/ggsketch/reference/curve_fill.md),
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
