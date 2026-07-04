# Create a sketchy engraving grob (tonal cross-hatch by line density)

Fills a region with
[`engrave_fill()`](https://orijitghosh.github.io/ggsketch/reference/engrave_fill.md):
a ladder of hatch layers whose accumulated density follows a tone field,
so the region shades continuously from blank paper (light) to dense
cross-hatch (dark) the way an etching does. The hatch geometry is
computed in device inches (so angles and wobble are device-consistent);
the `field` is supplied in npc \[0,1\] and sampled through an
inch-to-npc affine at draw time.

## Usage

``` r
sketch_engrave_grob(
  rings,
  field,
  ladder = NULL,
  ladder_levels = 5L,
  ladder_base_gap = 0.08,
  ladder_gap_ratio = 0.62,
  ladder_base_angle = 45,
  ladder_cross_after = 3L,
  roughness = 0.5,
  bowing = 0.3,
  seed = NULL,
  min_gap_in = 0.012,
  gp = gpar(),
  name = NULL,
  vp = NULL
)
```

## Arguments

- rings:

  A list of rings, each a list with npc \[0,1\] `x` and `y` vertex
  vectors bounding the region to engrave (even-odd holes honoured).

- field:

  A vectorised tone function `function(x, y)` taking npc \[0,1\]
  coordinates and returning tone in `[0, 1]` (0 = paper, 1 = darkest).

- ladder:

  A ladder from
  [`engrave_ladder()`](https://orijitghosh.github.io/ggsketch/reference/engrave_ladder.md);
  `NULL` builds a default from the `ladder_*` parameters.

- ladder_levels, ladder_base_gap, ladder_gap_ratio, ladder_base_angle,
  ladder_cross_after:

  Ladder controls used when `ladder` is `NULL`. `ladder_base_gap` is an
  npc-x fraction (converted to inches at draw time).

- roughness, bowing, seed:

  Sketch parameters for the engraving strokes.

- min_gap_in:

  Hard pitch floor in inches: ladder layers finer than this are dropped,
  so the darkest tones cannot explode into a runaway number of strokes.
  Default 0.012.

- gp:

  `gpar()` for the engraving strokes (`col`, `lwd`).

- name, vp:

  Passed to [`grid::gTree()`](https://rdrr.io/r/grid/grid.grob.html).

## Value

A `SketchEngraveGrob` grob subclass.

## See also

Other grob-layer:
[`sketch_arrow_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_arrow_grob.md),
[`sketch_band_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_band_grob.md),
[`sketch_callout_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_callout_grob.md),
[`sketch_dotplot_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_dotplot_grob.md),
[`sketch_ellipse_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_ellipse_grob.md),
[`sketch_path_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_path_grob.md),
[`sketch_polygon_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_polygon_grob.md),
[`sketch_repel_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_repel_grob.md),
[`sketch_spray_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_spray_grob.md),
[`sketch_stroke_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_stroke_grob.md),
[`sketch_wedge_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_wedge_grob.md)
