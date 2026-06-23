# Dispatch fill-style for a multi-ring (hole-aware) region

The band counterpart of
[`sketch_fill()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill.md):
fills a region described by several rings (outer pieces and holes) with
one shared scan-line so holes are excluded. Supports the line-based
styles `"hachure"` and `"cross_hatch"`; `"solid"` returns `NULL`
(painted by an even-odd polygon fill in the grob). Any other style
degrades to `"hachure"`, since the scribble/dots/dashed styles are
defined per single ring.

## Usage

``` r
sketch_fill_multi(
  rings,
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

- rings:

  A list of rings (see
  [`hachure_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill_multi.md)).

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

List of fill-line segments, or `NULL` for `"solid"`.

## See also

Other sketch-core:
[`curve_fill()`](https://orijitghosh.github.io/ggsketch/reference/curve_fill.md),
[`hachure_fill()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill.md),
[`hachure_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill_multi.md),
[`rough_arc()`](https://orijitghosh.github.io/ggsketch/reference/rough_arc.md),
[`rough_bezier()`](https://orijitghosh.github.io/ggsketch/reference/rough_bezier.md),
[`rough_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/rough_ellipse.md),
[`roughen_polyline()`](https://orijitghosh.github.io/ggsketch/reference/roughen_polyline.md),
[`sketch_fill()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill.md)
