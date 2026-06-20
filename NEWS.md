# ggsketch 1.3.0

New geoms (Tier 3, first batch — 2-D density and text):

* `geom_sketch_contour()` — hand-drawn contour lines of a surface (via
  `stat_contour`).
* `geom_sketch_density2d()` / `geom_sketch_density_2d()` — 2-D kernel-density
  contour lines (via `stat_density_2d`).
* `geom_sketch_hex()` — hexagonal binning heatmap (needs the optional `hexbin`
  package).
* `geom_sketch_text()` and `geom_sketch_label()` — text in a handwriting font
  (the sketch of text is the font, not roughened glyphs).

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
