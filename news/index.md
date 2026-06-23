# Changelog

## ggsketch 1.7.0 (development)

- **Dot plots.**
  [`geom_sketch_dotplot()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_dotplot.md)
  draws a hand-drawn Wilkinson-style dot plot: the data are binned along
  `x` and one roughened circular dot per observation is stacked upward
  in each bin. Dots stay round on any panel aspect (the diameter is
  taken from the bin width and converted to device inches at draw time).
  The sketch analogue of
  [`ggplot2::geom_dotplot()`](https://ggplot2.tidyverse.org/reference/geom_dotplot.html).
- **Filled contour and 2-D density bands.**
  [`geom_sketch_contour_filled()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_contour_filled.md)
  and
  [`geom_sketch_density_2d_filled()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_contour_filled.md)
  fill the *bands* between contour levels (not just the lines). Each
  band is a region that may contain holes (the next level up, cut out);
  a new hole-aware scan-line filler
  ([`hachure_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill_multi.md)
  /
  [`sketch_fill_multi()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill_multi.md),
  exposed at Layer 1) keeps the holes empty, so `fill_style = "hachure"`
  and `"cross_hatch"` work on multi-ring regions as well as `"solid"`.
  This completes the filled `*_filled` family planned since 1.3.0.
- **Bounding marks.**
  [`geom_sketch_mark_circle()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_mark_circle.md),
  [`geom_sketch_mark_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_mark_circle.md),
  and
  [`geom_sketch_mark_rect()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_mark_circle.md)
  draw a roughened bounding shape around each group of points – the
  sketch analogues of `ggforce::geom_mark_circle()` /
  `geom_mark_ellipse()` / `geom_mark_rect()`, completing the mark family
  started by
  [`geom_sketch_mark_hull()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_mark_hull.md).
  Shade them with a mapped `fill` or leave them outline-only.
- **Lollipop charts.**
  [`geom_sketch_lollipop()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_lollipop.md)
  draws a roughened stem from a `baseline` to each value, capped with a
  sketch point – a tidy alternative to bars for ranked or sparse values
  (cf. `ggalt::geom_lollipop()`). Set `horizontal = TRUE` for horizontal
  stems.
- **Empirical CDF.**
  [`geom_sketch_ecdf()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ecdf.md)
  draws the empirical cumulative distribution as a hand-drawn stairstep
  (the sketch analogue of
  [`ggplot2::stat_ecdf()`](https://ggplot2.tidyverse.org/reference/stat_ecdf.html)).
- **Content-aware arrows.**
  [`geom_sketch_arrow()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_arrow.md)
  (and the one-off
  [`annotate_sketch_arrow()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch_arrow.md))
  draw a hand-drawn arrow from `(x, y)` to `(xend, yend)` with an
  optional handwriting label. They are “content-aware”: the shaft
  curvature defaults to an automatic, pleasing bow whose side follows
  the direction of travel; the roughened arrowhead orients itself to the
  curve’s *end tangent*, so it always points at the target however the
  shaft bends; and the label justifies itself away from the target so it
  never sits under the shaft. `arrow_type = "closed"` gives a filled
  rough arrowhead.
- **Callouts.**
  [`geom_sketch_callout()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_callout.md)
  (and
  [`annotate_sketch_callout()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch_callout.md))
  draw a handwriting label in a roughened rounded box, optionally with a
  leader arrow to a target. The box auto-sizes to the label and the
  leader leaves from the box edge nearest the target – a sketch
  speech-bubble / callout.
- **Hull marks.**
  [`geom_sketch_mark_hull()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_mark_hull.md)
  draws a roughened convex hull around each group of points (the sketch
  analogue of `ggforce::geom_mark_hull()`), for circling or grouping
  clusters; shade it with a `fill` or leave it outline-only.
- **Hand-drawn pie and donut charts.**
  [`geom_sketch_pie()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_pie.md)
  draws a sketchy pie (one slice per row, sized by the `amount`
  aesthetic and coloured by `fill`);
  [`geom_sketch_donut()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_pie.md)
  is the same with a hole. Slices stay circular on any panel shape
  (radii are taken from the smaller panel dimension and assembled in
  device space), so they look right without
  [`coord_fixed()`](https://ggplot2.tidyverse.org/reference/coord_fixed.html).
  Slices are solid by default, with a rough edge; pass any `fill_style`
  (`"hachure"`, …) to hatch them instead.
- **Arc geometry (Layer 1).** New
  [`rough_arc()`](https://orijitghosh.github.io/ggsketch/reference/rough_arc.md)
  roughens an elliptical arc into open hand-drawn strokes (the open-arc
  sibling of
  [`rough_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/rough_ellipse.md)),
  and a new
  [`sketch_wedge_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_wedge_grob.md)
  draws roughened pie/donut sectors. These are the arc sampler that
  powers the pie/donut geoms.
- **Rounded rectangles and bars.**
  [`geom_sketch_rect()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md),
  [`geom_sketch_tile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md),
  and
  [`geom_sketch_col()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md)
  /
  [`geom_sketch_bar()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md)
  gain a `corner_radius` argument (a fraction `[0, 1]` of each
  half-side) for rounded corners. Default `0` keeps sharp corners, so
  existing plots render identically.

## ggsketch 1.6.0

- **`roughness` is now a mappable aesthetic on the per-shape geoms.**
  Following
  [`geom_sketch_point()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_point.md),
  you can map `roughness` per shape with `aes(roughness = )` (rescaled
  by
  [`scale_roughness_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_roughness_continuous.md))
  or set a constant on:
  [`geom_sketch_col()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md)
  /
  [`geom_sketch_bar()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md),
  [`geom_sketch_rect()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md)
  /
  [`geom_sketch_tile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md),
  [`geom_sketch_circle()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md)
  /
  [`geom_sketch_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md),
  [`geom_sketch_segment()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_segment.md)
  /
  [`geom_sketch_spoke()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_spoke.md),
  and the point-based
  [`geom_sketch_jitter()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_jitter.md)
  /
  [`geom_sketch_count()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_count.md).
  [`sketch_ellipse_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_ellipse_grob.md)
  now takes a per-shape roughness vector. Defaults are unchanged, so
  existing plots render identically. Path-like geoms (line, path, area,
  density, smooth, step, reference lines, …) keep `roughness` as a layer
  parameter, since per-row roughness is ill-defined for a single path.
- **Independent fill roughness and seed.** Every fill-bearing geom now
  accepts `fill_roughness` and `fill_seed`, so the fill texture can be
  controlled separately from the outline. Previously the fill roughness
  was hardwired to a fraction of the outline’s (`roughness * 0.5` for
  polygons, `* 0.4` for ellipses) and shared the outline’s seed. The
  defaults are unchanged (`NULL` keeps the historical coupling), so
  existing plots render identically; set the values for a scratchier
  fill under a clean edge, or to reshuffle the fill pattern without
  moving the outline. Exposed on
  [`sketch_polygon_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_polygon_grob.md)
  /
  [`sketch_ellipse_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_ellipse_grob.md)
  and threaded through
  [`geom_sketch_col()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md)/`bar()`,
  [`rect()`](https://rdrr.io/r/graphics/rect.html)/`tile()`,
  [`polygon()`](https://rdrr.io/r/graphics/polygon.html),
  `area()`/`ribbon()`,
  [`density()`](https://rdrr.io/r/stats/density.html), `violin()`,
  `circle()`/`ellipse()`, `crossbar()`,
  [`boxplot()`](https://rdrr.io/r/graphics/boxplot.html), `hex()`, and
  [`smooth()`](https://rdrr.io/r/stats/smooth.html).

## ggsketch 1.5.0

Annotation toolkit (first piece), roughness-as-an-aesthetic, and a real
solid fill.

- **[`geom_sketch_bracket()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bracket.md)**
  draws a hand-drawn significance / comparison bracket spanning `xmin`
  to `xmax` at height `y`, with short end tips and an optional
  handwriting `label` (e.g. a p-value or “n.s.”) centred above. The
  sketch counterpart of a `ggsignif` bracket, for marking pairwise
  comparisons on boxplots, bars, and violins.
- **`roughness` is now a mappable aesthetic on
  [`geom_sketch_point()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_point.md).**
  Map it to a variable (`aes(roughness = z)`) so each point wobbles more
  or less, or set a constant. A mapped variable is rescaled to a legible
  roughness band by the new
  **[`scale_roughness_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_roughness_continuous.md)**
  (default range `c(0.01, 0.75)`), applied automatically just like
  [`scale_size()`](https://ggplot2.tidyverse.org/reference/scale_size.html);
  wrap values in [`I()`](https://rdrr.io/r/base/AsIs.html) to use them
  as raw roughness. Rolling the mappable treatment out to the other
  geoms is planned.

#### Bug fixes

- `fill_style = "solid"` now actually paints the shape with its fill
  colour instead of leaving the interior empty. Previously “solid” drew
  the outline only, so the fill colour was computed and then never used
  and the shape stayed transparent (most visible on solid bars/columns).
  The fill follows the roughened boundary so the hand-drawn edge is
  kept. Shapes with no fill (`fill = NA`) stay outline-only as before.
- [`geom_sketch_boxplot()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_boxplot.md)
  now defaults to `fill = NA`, so the box stays outline-only (as it
  effectively was before solid fill started painting). Pass a `fill` for
  a solid box, or `fill_style = "hachure"` with a `fill` for a shaded
  one.
- `theme_sketch(base_family = )` now defaults to
  `getOption("ggsketch.base_family", "")`, so
  `options(ggsketch.base_family = "auto")` makes every sketch plot’s
  text (titles, axes, legend) use a handwriting font, not only the
  labels drawn by
  [`geom_sketch_text()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text.md)
  /
  [`geom_sketch_bracket()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bracket.md).

## ggsketch 1.4.0

The frame can now be roughened too, plus a matching colour palette, a
new fill style, and reproducible fonts.

- **Rough theme elements.**
  [`element_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md)
  and
  [`element_sketch_rect()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md)
  render gridlines, panel borders, and axis ticks as roughened sketch
  grobs. `theme_sketch(rough_frame = TRUE)` turns them on so the frame
  matches the marks. Works on ggplot2 3.5 and 4.0 (S3 `element_grob`
  methods; sketch params stored as attributes that survive theme
  merging).
- **Sketch colour scales.**
  [`scale_colour_sketch()`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md)
  /
  [`scale_fill_sketch()`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md)
  use a qualitative palette
  ([`sketch_palette()`](https://orijitghosh.github.io/ggsketch/reference/sketch_palette.md))
  chosen to suit the hand-drawn look; the `*_sketch_c()` variants give a
  continuous blue gradient.
- **New fill style `"scribble"`** — one continuous winding stroke that
  overshoots the boundary, like scribbling to fill a shape. Available
  everywhere a `fill_style` is accepted.
- **Reproducible fonts.**
  [`register_sketch_font()`](https://orijitghosh.github.io/ggsketch/reference/register_sketch_font.md)
  registers a handwriting font file (via systemfonts) so the result
  reproduces on any machine or CI runner without a system install; the
  font resolver now also finds registered fonts.

#### Bug fixes

- [`geom_sketch_point()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_point.md)
  (and
  [`geom_sketch_circle()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md)
  /
  [`geom_sketch_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md))
  now draw each mark in its own colour when the colour/fill aesthetic
  varies within a single group — e.g. a continuous scale such as
  [`scale_colour_sketch_c()`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md).
  Previously every mark took the first point’s colour, so a gradient
  looked flat.
- The double-stroke outline now shares its vertices across passes, so it
  reads as one hand-drawn line gone over twice rather than two parallel
  lines. Previously each pass jittered the vertices independently and
  the strokes could drift apart on short or flat edges (most visible on
  outlines like violins).
- [`geom_sketch_boxplot()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_boxplot.md)
  draws the median with much less bowing so the thick median line reads
  as one firm line rather than a bowed lens.
- The handwriting-font resolver (`base_family = "auto"`,
  [`geom_sketch_text()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text.md))
  now handles variable fonts. A face such as Caveat that ships as a
  variable font cannot be drawn by name on ragg/svglite (the device
  falls back to the default), so the resolver pins a renderable instance
  automatically. This is why a handwriting face now shows up out of the
  box, with no manual
  [`register_sketch_font()`](https://orijitghosh.github.io/ggsketch/reference/register_sketch_font.md)
  call needed.

## ggsketch 1.3.0

New geoms (Tier 3, first batch — 2-D density and text):

- [`geom_sketch_contour()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_contour.md)
  — hand-drawn contour lines of a surface (via `stat_contour`).
- [`geom_sketch_density2d()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_density2d.md)
  /
  [`geom_sketch_density_2d()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_density2d.md)
  — 2-D kernel-density contour lines (via `stat_density_2d`).
- [`geom_sketch_hex()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_hex.md)
  — hexagonal binning heatmap (needs the optional `hexbin` package).
- [`geom_sketch_text()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text.md)
  and
  [`geom_sketch_label()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text.md)
  — text in a handwriting font (the sketch of text is the font, not
  roughened glyphs). They now honour `nudge_x`/`nudge_y` like
  [`ggplot2::geom_text()`](https://ggplot2.tidyverse.org/reference/geom_text.html),
  and the font resolver falls back to handwriting faces preinstalled on
  Windows/macOS (Segoe Print, Ink Free, Bradley Hand, Chalkboard, Comic
  Sans MS, …) so a sketchy face is found even when Caveat is not
  installed. Use a font-aware device (ragg, svglite, cairo) to render
  the handwriting font; the base GDI
  [`png()`](https://rdrr.io/r/grDevices/png.html) device may fall back
  to the default family.

Still to come in Tier 3: filled contour / 2-D density bands (`*_filled`,
which need multi-ring hole-aware hachure) and
[`geom_sketch_dotplot()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_dotplot.md).

## ggsketch 1.2.0

New geoms (Tier 2 coverage — more stats and connectors; reuse existing
grobs, one new optional dependency):

- [`geom_sketch_count()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_count.md)
  — points sized by overplot count (via `stat_sum`).
- [`geom_sketch_function()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_function.md)
  — sketch a function curve (via `stat_function`).
- [`geom_sketch_qq()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_qq.md)
  and
  [`geom_sketch_qq_line()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_qq.md)
  — quantile-quantile points and reference line.
- [`geom_sketch_quantile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_quantile.md)
  — quantile regression lines (needs the optional `quantreg` package).
- [`geom_sketch_rug()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rug.md)
  — marginal ticks along the panel edges (`sides`).
- [`geom_sketch_spoke()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_spoke.md)
  — segments from `(x, y)` by `angle` + `radius`.
- [`geom_sketch_curve()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_curve.md)
  — hand-drawn curved connector (quadratic Bezier).
- [`geom_sketch_bin2d()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bin2d.md)
  /
  [`geom_sketch_bin_2d()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bin2d.md)
  — rectangular 2-D bin heatmap.

## ggsketch 1.1.0

New geoms (Tier 1 coverage — all reuse the existing grobs and base
ggplot2 stats; no new hard dependencies):

- [`geom_sketch_histogram()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_histogram.md)
  and
  [`geom_sketch_freqpoly()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_histogram.md)
  — binned distributions (via `stat_bin`).
- [`geom_sketch_jitter()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_jitter.md)
  —
  [`geom_sketch_point()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_point.md)
  with a jitter position.
- [`geom_sketch_violin()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_violin.md)
  — mirrored kernel density with hachure fill (via `stat_ydensity`).
- Interval family:
  [`geom_sketch_linerange()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_linerange.md),
  [`geom_sketch_pointrange()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_linerange.md),
  [`geom_sketch_errorbar()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_linerange.md),
  [`geom_sketch_crossbar()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_linerange.md).
- Reference lines:
  [`geom_sketch_abline()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_abline.md),
  [`geom_sketch_hline()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_abline.md),
  [`geom_sketch_vline()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_abline.md).

## ggsketch 1.0.0

First public release. A grammar-native, pure-R implementation of the
rough.js hand-drawn aesthetic for ggplot2 — no JavaScript, works on
every graphics device.

#### Geoms

- Lines & points:
  [`geom_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_line.md),
  [`geom_sketch_path()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_path.md),
  [`geom_sketch_point()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_point.md).
- Bars & tiles:
  [`geom_sketch_col()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md),
  [`geom_sketch_bar()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md),
  [`geom_sketch_rect()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md),
  [`geom_sketch_tile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md).
- Areas & curves:
  [`geom_sketch_polygon()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_polygon.md)
  (concave-safe fill),
  [`geom_sketch_ribbon()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ribbon.md),
  [`geom_sketch_area()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ribbon.md),
  [`geom_sketch_density()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_density.md),
  [`geom_sketch_smooth()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_smooth.md).
- Circular & composed:
  [`geom_sketch_circle()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md),
  [`geom_sketch_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md),
  [`geom_sketch_segment()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_segment.md),
  [`geom_sketch_step()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_segment.md),
  [`geom_sketch_boxplot()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_boxplot.md).
- Helpers:
  [`annotate_sketch()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch.md)
  and
  [`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)
  (light + dark presets).

#### Fill styles

- `hachure`, `cross_hatch`, `zigzag`, `zigzag_line`, `dots`, `dashed`,
  `solid`, via a full Active-Edge-Table scan-line filler that handles
  concave polygons.

#### Design

- Three strict layers: pure geometry (Layer 1), grid grobs with
  `makeContent()` (Layer 2), ggproto geoms (Layer 3). Roughening happens
  in device-inch space.
- Reproducible: every randomized routine draws from a seeded local RNG
  stream and never mutates the user’s global `.Random.seed`. Set
  `options(ggsketch.seed=)`.
- Sketchy legend keys for every geom.

#### Notes

- Algorithms reimplemented in original R from published descriptions; no
  rough.js source is included (see `inst/NOTICE`). Independent of, and
  not affiliated with, rough.js or ggrough.

#### Development history (internal milestones)

- 0.0.1 — Layer 1 sketch core (roughen, ellipse, Bézier, hachure, fill
  styles).
- 0.1.0 — Layer 2 grobs + first geoms (line/path/point) +
  [`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md).
- 0.2.0 — Filled rectangular geoms (col/bar/rect/tile) + fill-style
  coverage.
- 0.3.0 — Polygons, areas, ribbons, density, smooth.
- 1.0.0 — Circular & composed geoms, annotations, theming, docs,
  release.
