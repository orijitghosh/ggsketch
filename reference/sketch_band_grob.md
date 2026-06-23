# Create a sketchy filled-band grob (hole-aware region)

Draws one filled region made of several rings (outer pieces and holes) -
the building block for filled contour / 2-D density bands. The whole
region is filled with a single hole-aware scan-line (so holes stay
empty), and every ring is stroked with a roughened outline. A `"solid"`
fill paints the rings with an even-odd rule.

## Usage

``` r
sketch_band_grob(
  rings,
  roughness = 0.7,
  bowing = 0.5,
  n_passes = 2L,
  seed = NULL,
  fill_style = "solid",
  hachure_angle = 45,
  hachure_gap = 0.05,
  fill_weight = 0.5,
  fill_col = NA,
  outline_gp = gpar(),
  name = NULL,
  vp = NULL
)
```

## Arguments

- rings:

  A list of rings, each a list with npc \[0,1\] `x` and `y` vertex
  vectors. The even-odd arrangement of outer pieces and holes is
  honoured.

- roughness, bowing, n_passes, seed:

  Sketch parameters for the outlines.

- fill_style:

  `"solid"` (default), `"hachure"`, or `"cross_hatch"`.

- hachure_angle, hachure_gap, fill_weight:

  Fill parameters (`hachure_gap` is an npc fraction).

- fill_col:

  Fill colour (`NA` leaves the region empty).

- outline_gp:

  `gpar()` for the roughened ring outlines.

- name, vp:

  Passed to [`grid::gTree()`](https://rdrr.io/r/grid/grid.grob.html).

## Value

A `SketchBandGrob` grob subclass.

## See also

Other grob-layer:
[`sketch_arrow_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_arrow_grob.md),
[`sketch_callout_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_callout_grob.md),
[`sketch_dotplot_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_dotplot_grob.md),
[`sketch_ellipse_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_ellipse_grob.md),
[`sketch_path_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_path_grob.md),
[`sketch_polygon_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_polygon_grob.md),
[`sketch_wedge_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_wedge_grob.md)
