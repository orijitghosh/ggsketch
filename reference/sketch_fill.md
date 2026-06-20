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
[`curve_fill()`](https://orijitghosh.github.io/ggsketch/reference/curve_fill.md),
[`hachure_fill()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill.md),
[`rough_bezier()`](https://orijitghosh.github.io/ggsketch/reference/rough_bezier.md),
[`rough_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/rough_ellipse.md),
[`roughen_polyline()`](https://orijitghosh.github.io/ggsketch/reference/roughen_polyline.md)
