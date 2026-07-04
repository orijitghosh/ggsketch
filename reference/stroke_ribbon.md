# Build a variable-width stroke as a closed polygon ribbon

Offsets a centreline left and right by a per-vertex half-width and
closes the loop into a single polygon, so a hand-drawn stroke can taper,
swell with pressure, or vary like a broad calligraphic nib – effects
`grid` cannot do with a constant-`lwd` polyline. The centreline is used
as supplied (roughen it first with
[`roughen_polyline()`](https://orijitghosh.github.io/ggsketch/reference/roughen_polyline.md)
for a sketchy edge); this routine only offsets, so it is deterministic
apart from `jitter_w`.

## Usage

``` r
stroke_ribbon(
  x,
  y,
  width,
  taper = c("none", "both", "start", "end"),
  taper_frac = 0,
  pressure = NULL,
  nib_angle = NULL,
  nib_floor = 0.15,
  jitter_w = 0,
  cap = c("round", "butt"),
  miter_limit = 3,
  seed = NULL
)
```

## Arguments

- x, y:

  Numeric vectors of centreline vertices in inch space (same length).

- width:

  Full stroke width in inches: a scalar, or a per-vertex vector.

- taper:

  Where the stroke narrows to a tip: `"none"` (default), `"both"`,
  `"start"`, or `"end"`.

- taper_frac:

  Tip width as a fraction of `width` (`0` = sharp point, `1` = no
  narrowing). Default `0`.

- pressure:

  Optional vectorised function `f(t)` over normalised arc-length `t` in
  `[0, 1]` returning a width multiplier (see
  [`stroke_profile()`](https://orijitghosh.github.io/ggsketch/reference/stroke_profile.md)).
  `NULL` (default) is constant pressure.

- nib_angle:

  Optional broad-nib angle in degrees for a calligraphic stroke: the
  half-width is scaled by `|sin(segment_dir - nib_angle)|` (with a small
  floor), so the line is thick across the nib and thin along it. `NULL`
  (default) disables it.

- nib_floor:

  Minimum nib multiplier in `[0, 1]`, so a calligraphic stroke never
  fully vanishes. Default `0.15`.

- jitter_w:

  Width roughening in `[0, 1]`: random per-vertex modulation of the
  half-width, for a dry / inky edge. Default `0`.

- cap:

  End-cap style: `"round"` (default) or `"butt"`.

- miter_limit:

  Clamp on the joint miter factor, capping how far an outside corner
  extends at a sharp turn. Default `3`.

- seed:

  Integer seed for `jitter_w` (ADR-0004).

## Value

A 2-column `(x, y)` matrix giving the closed ribbon polygon (right side
forward, end cap, left side back, start cap). Fill it with the stroke
colour and no border for a solid variable-width stroke.

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
[`treemap_layout()`](https://orijitghosh.github.io/ggsketch/reference/treemap_layout.md),
[`wash_bleed()`](https://orijitghosh.github.io/ggsketch/reference/wash_bleed.md),
[`watercolor_wash()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash.md),
[`watercolor_wash_multi()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash_multi.md)
