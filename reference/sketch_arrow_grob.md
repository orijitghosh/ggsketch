# Create a sketchy arrow grob

Draws one or more hand-drawn arrows. The shaft is a quadratic Bezier (so
it can curve) and the arrowhead is roughened and oriented to the curve's
end tangent, both assembled in device inches so the head stays crisp and
correctly angled on any panel shape. The arrowhead size can adapt to the
shaft length.

## Usage

``` r
sketch_arrow_grob(
  x0,
  y0,
  cx,
  cy,
  x1,
  y1,
  roughness = 1,
  bowing = 1,
  n_passes = 2L,
  seed = NULL,
  arrow_length = NULL,
  arrow_angle = 25,
  arrow_type = "open",
  arrow_head = NULL,
  ends = "last",
  gp = gpar(),
  name = NULL,
  vp = NULL
)
```

## Arguments

- x0, y0:

  Shaft start in npc \[0,1\] (vectors, one per arrow).

- cx, cy:

  Quadratic-Bezier control point in npc (vectors). For a straight arrow
  pass the chord midpoint.

- x1, y1:

  Shaft end / arrow tip in npc (vectors).

- roughness, bowing, n_passes, seed:

  Sketch parameters.

- arrow_length:

  Arrowhead length in inches. `NULL` (default) adapts it to the shaft
  length.

- arrow_angle:

  Half-angle of the arrowhead in degrees. Default 25.

- arrow_type:

  `"open"` (default) draws a two-stroke V; `"closed"` draws a filled
  rough triangle. Superseded by `arrow_head`; kept for back-compat.

- arrow_head:

  Head style, one of
  [`sketch_arrowheads()`](https://orijitghosh.github.io/ggsketch/reference/sketch_arrowheads.md)
  (`"triangle_open"`, `"triangle_filled"`, `"barb"`, `"fishtail"`,
  `"dot"`, `"bar"`). `NULL` (default) derives it from `arrow_type`.

- ends:

  Which end(s) carry a head: `"last"` (default), `"first"`, or `"both"`.

- gp:

  A [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html) for the strokes
  (per-arrow `col` recycled).

- name, vp:

  Passed to [`grid::gTree()`](https://rdrr.io/r/grid/grid.grob.html).

## Value

A `SketchArrowGrob` grob subclass.

## See also

Other grob-layer:
[`sketch_band_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_band_grob.md),
[`sketch_callout_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_callout_grob.md),
[`sketch_dotplot_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_dotplot_grob.md),
[`sketch_ellipse_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_ellipse_grob.md),
[`sketch_engrave_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_engrave_grob.md),
[`sketch_path_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_path_grob.md),
[`sketch_polygon_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_polygon_grob.md),
[`sketch_repel_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_repel_grob.md),
[`sketch_spray_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_spray_grob.md),
[`sketch_stroke_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_stroke_grob.md),
[`sketch_wedge_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_wedge_grob.md)
