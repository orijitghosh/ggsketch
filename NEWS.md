# ggsketch 1.4.0

The frame can now be roughened too, plus a matching colour palette, a new fill
style, and reproducible fonts.

* **Rough theme elements.** `element_sketch_line()` and `element_sketch_rect()`
  render gridlines, panel borders, and axis ticks as roughened sketch grobs.
  `theme_sketch(rough_frame = TRUE)` turns them on so the frame matches the marks.
  Works on ggplot2 3.5 and 4.0 (S3 `element_grob` methods; sketch params stored as
  attributes that survive theme merging).
* **Sketch colour scales.** `scale_colour_sketch()` / `scale_fill_sketch()` use a
  qualitative palette (`sketch_palette()`) chosen to suit the hand-drawn look; the
  `*_sketch_c()` variants give a continuous blue gradient.
* **New fill style `"scribble"`** — one continuous winding stroke that overshoots
  the boundary, like scribbling to fill a shape. Available everywhere a
  `fill_style` is accepted.
* **Reproducible fonts.** `register_sketch_font()` registers a handwriting font
  file (via systemfonts) so the result reproduces on any machine or CI runner
  without a system install; the font resolver now also finds registered fonts.

### Bug fixes

* `geom_sketch_point()` (and `geom_sketch_circle()` / `geom_sketch_ellipse()`)
  now draw each mark in its own colour when the colour/fill aesthetic varies
  within a single group — e.g. a continuous scale such as `scale_colour_sketch_c()`.
  Previously every mark took the first point's colour, so a gradient looked flat.
* The double-stroke outline now shares its vertices across passes, so it reads as
  one hand-drawn line gone over twice rather than two parallel lines. Previously
  each pass jittered the vertices independently and the strokes could drift apart
  on short or flat edges (most visible on outlines like violins).
* `geom_sketch_boxplot()` draws the median with much less bowing so the thick
  median line reads as one firm line rather than a bowed lens.
* The handwriting-font resolver (`base_family = "auto"`, `geom_sketch_text()`)
  now handles variable fonts. A face such as Caveat that ships as a variable font
  cannot be drawn by name on ragg/svglite (the device falls back to the default),
  so the resolver pins a renderable instance automatically. This is why a
  handwriting face now shows up out of the box, with no manual
  `register_sketch_font()` call needed.

# ggsketch 1.3.0

New geoms (Tier 3, first batch — 2-D density and text):

* `geom_sketch_contour()` — hand-drawn contour lines of a surface (via
  `stat_contour`).
* `geom_sketch_density2d()` / `geom_sketch_density_2d()` — 2-D kernel-density
  contour lines (via `stat_density_2d`).
* `geom_sketch_hex()` — hexagonal binning heatmap (needs the optional `hexbin`
  package).
* `geom_sketch_text()` and `geom_sketch_label()` — text in a handwriting font
  (the sketch of text is the font, not roughened glyphs). They now honour
  `nudge_x`/`nudge_y` like `ggplot2::geom_text()`, and the font resolver falls
  back to handwriting faces preinstalled on Windows/macOS (Segoe Print, Ink
  Free, Bradley Hand, Chalkboard, Comic Sans MS, …) so a sketchy face is found
  even when Caveat is not installed. Use a font-aware device
  (ragg, svglite, cairo) to render the handwriting font; the base GDI `png()`
  device may fall back to the default family.

Still to come in Tier 3: filled contour / 2-D density bands
(`*_filled`, which need multi-ring hole-aware hachure) and `geom_sketch_dotplot()`.

# ggsketch 1.2.0

New geoms (Tier 2 coverage — more stats and connectors; reuse existing grobs,
one new optional dependency):

* `geom_sketch_count()` — points sized by overplot count (via `stat_sum`).
* `geom_sketch_function()` — sketch a function curve (via `stat_function`).
* `geom_sketch_qq()` and `geom_sketch_qq_line()` — quantile-quantile points and
  reference line.
* `geom_sketch_quantile()` — quantile regression lines (needs the optional
  `quantreg` package).
* `geom_sketch_rug()` — marginal ticks along the panel edges (`sides`).
* `geom_sketch_spoke()` — segments from `(x, y)` by `angle` + `radius`.
* `geom_sketch_curve()` — hand-drawn curved connector (quadratic Bezier).
* `geom_sketch_bin2d()` / `geom_sketch_bin_2d()` — rectangular 2-D bin heatmap.

# ggsketch 1.1.0

New geoms (Tier 1 coverage — all reuse the existing grobs and base ggplot2
stats; no new hard dependencies):

* `geom_sketch_histogram()` and `geom_sketch_freqpoly()` — binned distributions
  (via `stat_bin`).
* `geom_sketch_jitter()` — `geom_sketch_point()` with a jitter position.
* `geom_sketch_violin()` — mirrored kernel density with hachure fill (via
  `stat_ydensity`).
* Interval family: `geom_sketch_linerange()`, `geom_sketch_pointrange()`,
  `geom_sketch_errorbar()`, `geom_sketch_crossbar()`.
* Reference lines: `geom_sketch_abline()`, `geom_sketch_hline()`,
  `geom_sketch_vline()`.

# ggsketch 1.0.0

First public release. A grammar-native, pure-R implementation of the rough.js
hand-drawn aesthetic for ggplot2 — no JavaScript, works on every graphics device.

### Geoms

* Lines & points: `geom_sketch_line()`, `geom_sketch_path()`,
  `geom_sketch_point()`.
* Bars & tiles: `geom_sketch_col()`, `geom_sketch_bar()`, `geom_sketch_rect()`,
  `geom_sketch_tile()`.
* Areas & curves: `geom_sketch_polygon()` (concave-safe fill),
  `geom_sketch_ribbon()`, `geom_sketch_area()`, `geom_sketch_density()`,
  `geom_sketch_smooth()`.
* Circular & composed: `geom_sketch_circle()`, `geom_sketch_ellipse()`,
  `geom_sketch_segment()`, `geom_sketch_step()`, `geom_sketch_boxplot()`.
* Helpers: `annotate_sketch()` and `theme_sketch()` (light + dark presets).

### Fill styles

* `hachure`, `cross_hatch`, `zigzag`, `zigzag_line`, `dots`, `dashed`, `solid`,
  via a full Active-Edge-Table scan-line filler that handles concave polygons.

### Design

* Three strict layers: pure geometry (Layer 1), grid grobs with `makeContent()`
  (Layer 2), ggproto geoms (Layer 3). Roughening happens in device-inch space.
* Reproducible: every randomized routine draws from a seeded local RNG stream and
  never mutates the user's global `.Random.seed`. Set `options(ggsketch.seed=)`.
* Sketchy legend keys for every geom.

### Notes

* Algorithms reimplemented in original R from published descriptions; no rough.js
  source is included (see `inst/NOTICE`). Independent of, and not affiliated with,
  rough.js or ggrough.

### Development history (internal milestones)

* 0.0.1 — Layer 1 sketch core (roughen, ellipse, Bézier, hachure, fill styles).
* 0.1.0 — Layer 2 grobs + first geoms (line/path/point) + `theme_sketch()`.
* 0.2.0 — Filled rectangular geoms (col/bar/rect/tile) + fill-style coverage.
* 0.3.0 — Polygons, areas, ribbons, density, smooth.
* 1.0.0 — Circular & composed geoms, annotations, theming, docs, release.
