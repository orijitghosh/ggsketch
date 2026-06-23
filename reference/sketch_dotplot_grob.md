# Create a sketchy dot-plot grob (stacked circular dots)

Draws stacked roughened dots for a Wilkinson-style dot plot. The dot
diameter is taken from `dia` (an npc-x fraction = the bin width) and
converted to device inches at draw time, so every dot is a true circle
whatever the panel aspect, and stacks are built upward from `baseline`
by that diameter.

## Usage

``` r
sketch_dotplot_grob(
  x,
  stackpos,
  dia,
  baseline = 0,
  stackratio = 1,
  roughness = 0.5,
  n_passes = 2L,
  seed = NULL,
  fill_gp = gpar(),
  outline_gp = gpar(),
  name = NULL,
  vp = NULL
)
```

## Arguments

- x:

  Npc \[0,1\] x of each dot (its bin centre), one per dot.

- stackpos:

  Integer stack position of each dot within its bin (1 = first).

- dia:

  Dot diameter as an npc-x fraction (scalar; the bin width).

- baseline:

  Npc y the stacks grow from. Default 0.

- stackratio:

  Vertical spacing between stacked dots, as a fraction of the diameter.
  Default 1.

- roughness, n_passes, seed:

  Sketch parameters.

- fill_gp:

  `gpar()` for the solid dot fill (per-dot `col` recycled; `NA` leaves
  dots unfilled).

- outline_gp:

  `gpar()` for the roughened dot outline (per-dot `col`).

- name, vp:

  Passed to [`grid::gTree()`](https://rdrr.io/r/grid/grid.grob.html).

## Value

A `SketchDotplotGrob` grob subclass.

## See also

Other grob-layer:
[`sketch_arrow_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_arrow_grob.md),
[`sketch_band_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_band_grob.md),
[`sketch_callout_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_callout_grob.md),
[`sketch_ellipse_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_ellipse_grob.md),
[`sketch_path_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_path_grob.md),
[`sketch_polygon_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_polygon_grob.md),
[`sketch_wedge_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_wedge_grob.md)
