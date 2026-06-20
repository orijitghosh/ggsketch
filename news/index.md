# Changelog

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
which need multi-ring hole-aware hachure) and `geom_sketch_dotplot()`.

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
