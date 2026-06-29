# ggsketch 2.0.0 (development)

The 2.0 series turns ggsketch from a *line style* into a *drawing-medium*
simulator. This first piece is the engine that makes it possible.

* **Variable-width strokes (Layer 1 + Layer 2).** `stroke_ribbon()` builds a
  hand-drawn stroke as a filled polygon ribbon offset around a centreline, so a
  line can taper to a point, swell with pressure, or vary like a broad
  calligraphic nib -- effects `grid` cannot produce with a constant-`lwd`
  polyline. `stroke_profile()` supplies ready-made width profiles (`"taper_in"`,
  `"taper_out"`, `"belly"`, `"flat"`), and `sketch_stroke_grob()` renders a path
  as variable-width ribbons, re-roughening the centreline at device resolution
  (with round or butt caps, optional width jitter for a dry edge, and a
  `nib_angle` for calligraphy). This is the foundation the forthcoming media
  (ink, brush, pencil, charcoal, calligraphy) are built on.
* **Drawing media on the path geoms.** A new `medium` argument selects how a line
  is laid down: `"pen"` (the default -- the classic constant-width double stroke,
  unchanged), or `"ink"`, `"brush"`, `"pencil"`, `"charcoal"`, `"marker"`,
  `"crayon"`, which render through the variable-width engine -- tapered ink,
  brushy belly swells, grainy multi-pass pencil/charcoal, translucent marker,
  waxy crayon. Available on `geom_sketch_line()`, `geom_sketch_path()`,
  `geom_sketch_segment()`, and `geom_sketch_step()`; `sketch_media()` lists the
  options. Existing plots are unaffected (the default stays `"pen"`).
* **Paper / canvas grounds.** `theme_sketch(paper = )` paints a simulated paper
  texture behind the data: `"notebook"` (blue rules + red margin), `"graph"`,
  `"dotted"`, `"aged"` (warm ground with soft blotches), `"blueprint"` and
  `"chalkboard"` (dark grounds that flip the text light), and `"kraft"`. The
  ruling is spaced in physical inches so it looks right on any panel aspect, and
  everything is drawn as vector primitives, so it reproduces on every device.
  `element_sketch_paper()` is the underlying panel-background element (usable
  directly in `theme()`), and `sketch_papers()` lists the grounds. The default
  `"none"` leaves the theme unchanged.
* **Watercolour fill.** A new `fill_style = "watercolor"` paints a region with
  stacked translucent washes instead of stroked fill lines: where the jittered
  boundary copies overlap the colour deepens toward the interior, the irregular
  edges feather like pigment bleeding into wet paper, and a scatter of darker
  specks reads as pigment granulation. Overlapping shapes blend wet-on-wet. It
  works on every polygon-fill geom (`geom_sketch_polygon()`, `geom_sketch_area()`,
  `geom_sketch_col()` / `bar()`, `geom_sketch_rect()` / `tile()`,
  `geom_sketch_violin()`, `geom_sketch_boxplot()`, `geom_sketch_ridgeline()`,
  ...), on the ellipse/circle geoms (`geom_sketch_circle()`, the `mark_circle` /
  `mark_ellipse` family), and on the hole-aware band geoms
  (`geom_sketch_contour_filled()`, `geom_sketch_density_2d_filled()`) where the
  washes respect holes via a new Layer-1 `watercolor_wash_multi()`. Powered by a
  new Layer-1 `watercolor_wash()`. Everything is vector, so it reproduces on
  every device.
* **`medium` is now a mappable aesthetic.** On the path-like geoms
  (`geom_sketch_line()`, `geom_sketch_path()`, `geom_sketch_segment()`,
  `geom_sketch_step()`) you can map a discrete variable with `aes(medium = )` to
  draw each group (or each segment) in a different medium, and
  `scale_medium_discrete()` chooses which media the levels map to. The legend
  keys render in their own medium. Setting `medium` as a constant still works
  exactly as before, and the default is unchanged (`"pen"`).
* **`coord_sketch()`.** A drop-in replacement for `coord_cartesian()` that draws
  the *frame* hand-drawn -- the panel gridlines and axis ticks become roughened
  sketch grobs -- under *any* theme, not only `theme_sketch()`. It reuses
  ggplot2's own gridline and axis layout and only swaps how those elements are
  drawn, so limits, expansion, and clipping behave exactly like
  `coord_cartesian()`. `rough_grid` / `rough_ticks` toggle each element; combine
  with `theme_sketch(rough_frame = TRUE)` to roughen the panel border too.
* **`coord_sketch_polar()`.** The polar companion to `coord_sketch()` -- a
  drop-in replacement for `coord_polar()` that draws the circular grid
  hand-drawn (wobbly concentric rings and radial spokes), so rose / circular bar
  charts get a frame that matches the marks under any theme. Like
  `coord_sketch()` it reuses ggplot2's polar layout and only swaps how the grid
  is drawn (`theta`, `start`, `direction` behave as in `coord_polar()`).
* **New chart families: `geom_sketch_dumbbell()` and `geom_sketch_slope()`.** Two
  hand-drawn comparison charts. `geom_sketch_dumbbell()` draws a roughened
  connector from `x` to `xend` on a shared `y`, capped with a sketch dot at each
  end (separate `colour_x` / `colour_xend`), for showing the gap between two
  paired values per category. `geom_sketch_slope()` draws one roughened line per
  `group` across an ordered x with a dot at each vertex -- a sketch slopegraph
  for before/after rank changes. Both reuse the existing stroke and point grobs,
  so they need no new dependencies.
* **New chart family: `geom_sketch_beeswarm()`.** A hand-drawn beeswarm
  (dot-strip) plot -- at each categorical `x` the points are nudged sideways so
  they no longer overlap, so the width of the swarm reads as the local density of
  `y`. The offset is computed deterministically in data space (no device metrics,
  fully reproducible) and the dots are drawn with `geom_sketch_point()`, so they
  keep the usual wobble. `width` widens the swarm; `binwidth` / `nbins` control
  the `y` rows. No new dependencies (cf. `ggbeeswarm::geom_beeswarm()`).
* **New chart family: `geom_sketch_ridgeline()`.** A hand-drawn ridgeline
  (joyplot) -- a kernel density of `x` for each category on a discrete `y`,
  raised to its own baseline so the ridges overlap and the changing shape of the
  distribution is easy to compare. `scale` sets how far the tallest ridge rises
  (values above 1 overlap), `rel_min_height` trims the tails, and the fill
  honours every `fill_style` including `"watercolor"`. Ridges are drawn
  back-to-front so nearer ones sit on top. Powered by a new
  `StatSketchDensityRidges`; no new dependencies (cf.
  `ggridges::geom_density_ridges()`).
* **New chart family: `geom_sketch_waffle()`.** A hand-drawn waffle chart -- a
  square grid (default 10x10 = 100 cells) where the number of cells of each
  colour reads as that category's share of the whole. Map the category to `fill`
  and (for summarised data) a count to `weight`; cells are tallied by a new
  `StatSketchWaffle` (largest-remainder rounding) and drawn with
  `geom_sketch_tile()`, so they take the roughened outline and any `fill_style`
  (including `"watercolor"`). No new dependencies (cf. `waffle::geom_waffle()`).
* **New chart family: `geom_sketch_treemap()`.** A hand-drawn treemap -- nested
  rectangles tiling a square, each with area proportional to a value, so the
  biggest categories take the most space. Map the value to `area`, the category
  to `fill`, and optionally `label` to write a name in each tile. Rectangles are
  placed by a new Layer-1 squarified algorithm (`treemap_layout()`, exported) and
  drawn with the roughened rect look, so they take any `fill_style`. No new
  dependencies (cf. `treemapify::geom_treemap()`).
* **New chart family: `geom_sketch_streamgraph()`.** A hand-drawn streamgraph
  (ThemeRiver) -- a stacked area whose baseline floats so the coloured bands flow
  around a moving centre. Map `x`, `y`, and `fill`; a new `StatSketchStream`
  stacks the values and offsets the baseline (`offset = "silhouette"` centred,
  `"zero"` for a normal stacked area, or `"wiggle"` to minimise the slope), and
  each band is drawn as a roughened ribbon (any `fill_style`, including
  `"watercolor"`). No new dependencies (cf. `ggstream::geom_stream()`).
* **New chart family: `geom_sketch_calendar()`.** A hand-drawn calendar heatmap
  in the GitHub-contributions style -- one roughened tile per day, laid out as
  weeks (columns) and weekdays (rows), coloured by a value. Map `date` and
  `fill`; a new `StatSketchCalendar` builds the week/weekday grid (`week_start`
  chooses Sunday or Monday on top), and tiles are drawn with `geom_sketch_tile()`
  (default `fill_style = "solid"` so the gradient reads). Facet on a year column
  for multiple years. No new dependencies.
* **Flagship: hand-drawn networks.** `geom_sketch_node()` and
  `geom_sketch_edge()` draw a graph the sketch way -- roughened node markers with
  optional handwriting labels, and roughened (optionally curved, via `curvature`)
  edges. `sketch_graph()` is the bridge: give it a two-column edge data frame (or
  an `igraph` object) and it returns ready-to-plot `nodes` and `edges` frames,
  positioning nodes with `force_layout()`, a from-scratch pure-R
  Fruchterman-Reingold force-directed layout -- so the whole flagship needs **no
  graph dependency**. `igraph` is an optional, guarded convenience for ingestion
  only; extra edge/node columns are carried through as attributes you can map.
  The layout is seeded and reproducible and never disturbs the global RNG.
* **Flagship: hand-drawn maps (`sf`).** `geom_sketch_sf()` is a sketch take on
  `ggplot2::geom_sf()`: it roughens the boundaries of simple-features geometry in
  one call -- `(MULTI)POLYGON` features get a hole-aware hachure (or any
  `fill_style`), `(MULTI)LINESTRING` features become sketch paths, and
  `(MULTI)POINT` features become sketch points. It extracts coordinates from the
  `sf` object up front and draws ordinary sketch layers, so it sidesteps
  `coord_sf()`/`stat_sf()` and plots in **planar coordinates** -- pre-project
  lon/lat data with `sf::st_transform()` for a faithful map. `sf` is an optional,
  guarded dependency (Suggests); it is only needed when you call this geom.
* **Radar / spider charts.** `geom_sketch_radar()` draws each series as a closed
  roughened polygon over evenly spaced angular axes, behind a hand-drawn web of
  concentric rings, radial spokes and axis labels. Map `axis`, `value` and
  `group` (plus `colour`/`fill`); values are scaled to a common outer ring
  (`rmax`) and each polygon takes any `fill_style`, including `"watercolor"`.
  Like the pie geoms it lives in its own square space -- pair with
  `coord_equal()`. No new dependencies (cf. `ggradar`, `fmsb::radarchart()`).
* **Chord diagrams.** `geom_sketch_chord()` lays nodes on a circle, each given a
  rim arc proportional to its total flow, and draws every weighted relation as a
  ribbon whose ends are sub-arcs joined by curves through the centre. Give it an
  edge table and the `from`, `to` and `value` columns; ribbons are coloured by
  source node (add [scale_fill_sketch()] or any fill scale), take any
  `fill_style`, and self-loops are dropped. Pair with `coord_equal()`. No new
  dependencies (cf. `circlize::chordDiagram()`).
* **Alluvial / Sankey diagrams.** `geom_sketch_alluvial()` draws two or more
  categorical axes as stacks of strata, joined by flows whose thickness is the
  frequency of each category combination. Give it a wide data frame, the `axes`
  columns (in order), an optional `value` weight, and an optional `fill` column
  (default: the first axis); flows get raised-cosine edges and any `fill_style`.
  It draws in ordinary x/y space -- pair with `theme_void()`. No new
  dependencies (cf. `ggalluvial`, `ggsankey`).

# ggsketch 1.8.0 (development)

* **Engraving: tonal shading by line density.** A new module shades by the
  *density* of hand-drawn hatch lines, the way an etcher or banknote engraver
  builds a gradient -- light areas stay near-blank, shadows accumulate dense
  cross-hatch. Unlike the fill-pattern packages (which tile a motif), the tone
  is *computed* from geometry. `geom_sketch_engrave()` shades an `x`/`y`/`z`
  surface (high `z` = dark); `geom_sketch_shade()` shades each polygon region
  with a uniform density set by a `tone` aesthetic, so a mapped value reads as
  darkness. Powered by a new Layer-1 engine (`engrave_fill()` /
  `engrave_ladder()`, exposed at Layer 1) that lays down a ladder of hatch
  layers and keeps each only where the tone reaches its threshold, reusing the
  hole-aware scan-line. A pitch floor (`min_gap_in`) keeps the darkest tones
  from exploding into a runaway number of strokes.
  * `scale_tone_continuous()` (alias `scale_engrave()`) rescales a mapped
    variable to a legible tone band, so `aes(tone = z)` works the way
    `scale_size()` does for size; wrap in `I()` to use raw tone.
  * `geom_sketch_engrave()` takes an `x`/`y`/`z` grid directly, or shades raw
    points through a density stat, e.g.
    `geom_sketch_engrave(stat = "density_2d", contour = FALSE, aes(z = after_stat(density)))`.

# ggsketch 1.7.0 (development)

* **Dot plots.** `geom_sketch_dotplot()` draws a hand-drawn Wilkinson-style dot
  plot: the data are binned along `x` and one roughened circular dot per
  observation is stacked upward in each bin. Dots stay round on any panel
  aspect (the diameter is taken from the bin width and converted to device
  inches at draw time). The sketch analogue of `ggplot2::geom_dotplot()`.
* **Filled contour and 2-D density bands.** `geom_sketch_contour_filled()` and
  `geom_sketch_density_2d_filled()` fill the *bands* between contour levels (not
  just the lines). Each band is a region that may contain holes (the next level
  up, cut out); a new hole-aware scan-line filler (`hachure_fill_multi()` /
  `sketch_fill_multi()`, exposed at Layer 1) keeps the holes empty, so
  `fill_style = "hachure"` and `"cross_hatch"` work on multi-ring regions as
  well as `"solid"`. This completes the filled `*_filled` family planned since
  1.3.0.
* **Bounding marks.** `geom_sketch_mark_circle()`, `geom_sketch_mark_ellipse()`,
  and `geom_sketch_mark_rect()` draw a roughened bounding shape around each
  group of points -- the sketch analogues of `ggforce::geom_mark_circle()` /
  `geom_mark_ellipse()` / `geom_mark_rect()`, completing the mark family started
  by `geom_sketch_mark_hull()`. Shade them with a mapped `fill` or leave them
  outline-only.
* **Lollipop charts.** `geom_sketch_lollipop()` draws a roughened stem from a
  `baseline` to each value, capped with a sketch point -- a tidy alternative to
  bars for ranked or sparse values (cf. `ggalt::geom_lollipop()`). Set
  `horizontal = TRUE` for horizontal stems.
* **Empirical CDF.** `geom_sketch_ecdf()` draws the empirical cumulative
  distribution as a hand-drawn stairstep (the sketch analogue of
  `ggplot2::stat_ecdf()`).
* **Content-aware arrows.** `geom_sketch_arrow()` (and the one-off
  `annotate_sketch_arrow()`) draw a hand-drawn arrow from `(x, y)` to
  `(xend, yend)` with an optional handwriting label. They are "content-aware":
  the shaft curvature defaults to an automatic, pleasing bow whose side follows
  the direction of travel; the roughened arrowhead orients itself to the curve's
  *end tangent*, so it always points at the target however the shaft bends; and
  the label justifies itself away from the target so it never sits under the
  shaft. `arrow_type = "closed"` gives a filled rough arrowhead.
* **Callouts.** `geom_sketch_callout()` (and `annotate_sketch_callout()`) draw a
  handwriting label in a roughened rounded box, optionally with a leader arrow to
  a target. The box auto-sizes to the label and the leader leaves from the box
  edge nearest the target -- a sketch speech-bubble / callout.
* **Hull marks.** `geom_sketch_mark_hull()` draws a roughened convex hull around
  each group of points (the sketch analogue of `ggforce::geom_mark_hull()`), for
  circling or grouping clusters; shade it with a `fill` or leave it outline-only.
* **Hand-drawn pie and donut charts.** `geom_sketch_pie()` draws a sketchy pie
  (one slice per row, sized by the `amount` aesthetic and coloured by `fill`);
  `geom_sketch_donut()` is the same with a hole. Slices stay circular on any
  panel shape (radii are taken from the smaller panel dimension and assembled in
  device space), so they look right without `coord_fixed()`. Slices are solid by
  default, with a rough edge; pass any `fill_style` (`"hachure"`, ...) to hatch
  them instead.
* **Arc geometry (Layer 1).** New `rough_arc()` roughens an elliptical arc into
  open hand-drawn strokes (the open-arc sibling of `rough_ellipse()`), and a new
  `sketch_wedge_grob()` draws roughened pie/donut sectors. These are the arc
  sampler that powers the pie/donut geoms.
* **Rounded rectangles and bars.** `geom_sketch_rect()`, `geom_sketch_tile()`,
  and `geom_sketch_col()` / `geom_sketch_bar()` gain a `corner_radius` argument
  (a fraction `[0, 1]` of each half-side) for rounded corners. Default `0`
  keeps sharp corners, so existing plots render identically.

# ggsketch 1.6.0

* **`roughness` is now a mappable aesthetic on the per-shape geoms.** Following
  `geom_sketch_point()`, you can map `roughness` per shape with
  `aes(roughness = )` (rescaled by `scale_roughness_continuous()`) or set a
  constant on: `geom_sketch_col()` / `geom_sketch_bar()`, `geom_sketch_rect()` /
  `geom_sketch_tile()`, `geom_sketch_circle()` / `geom_sketch_ellipse()`,
  `geom_sketch_segment()` / `geom_sketch_spoke()`, and the point-based
  `geom_sketch_jitter()` / `geom_sketch_count()`. `sketch_ellipse_grob()` now
  takes a per-shape roughness vector. Defaults are unchanged, so existing plots
  render identically. Path-like geoms (line, path, area, density, smooth, step,
  reference lines, ...) keep `roughness` as a layer parameter, since per-row
  roughness is ill-defined for a single path.
* **Independent fill roughness and seed.** Every fill-bearing geom now accepts
  `fill_roughness` and `fill_seed`, so the fill texture can be controlled
  separately from the outline. Previously the fill roughness was hardwired to a
  fraction of the outline's (`roughness * 0.5` for polygons, `* 0.4` for
  ellipses) and shared the outline's seed. The defaults are unchanged
  (`NULL` keeps the historical coupling), so existing plots render identically;
  set the values for a scratchier fill under a clean edge, or to reshuffle the
  fill pattern without moving the outline. Exposed on `sketch_polygon_grob()` /
  `sketch_ellipse_grob()` and threaded through `geom_sketch_col()`/`bar()`,
  `rect()`/`tile()`, `polygon()`, `area()`/`ribbon()`, `density()`, `violin()`,
  `circle()`/`ellipse()`, `crossbar()`, `boxplot()`, `hex()`, and `smooth()`.

# ggsketch 1.5.0

Annotation toolkit (first piece), roughness-as-an-aesthetic, and a real solid
fill.

* **`geom_sketch_bracket()`** draws a hand-drawn significance / comparison
  bracket spanning `xmin` to `xmax` at height `y`, with short end tips and an
  optional handwriting `label` (e.g. a p-value or "n.s.") centred above. The
  sketch counterpart of a `ggsignif` bracket, for marking pairwise comparisons
  on boxplots, bars, and violins.
* **`roughness` is now a mappable aesthetic on `geom_sketch_point()`.** Map it to
  a variable (`aes(roughness = z)`) so each point wobbles more or less, or set a
  constant. A mapped variable is rescaled to a legible roughness band by the new
  **`scale_roughness_continuous()`** (default range `c(0.01, 0.75)`), applied
  automatically just like `scale_size()`; wrap values in `I()` to use them as raw
  roughness. Rolling the mappable treatment out to the other geoms is planned.

### Bug fixes

* `fill_style = "solid"` now actually paints the shape with its fill colour
  instead of leaving the interior empty. Previously "solid" drew the outline
  only, so the fill colour was computed and then never used and the shape stayed
  transparent (most visible on solid bars/columns). The fill follows the
  roughened boundary so the hand-drawn edge is kept. Shapes with no fill
  (`fill = NA`) stay outline-only as before.
* `geom_sketch_boxplot()` now defaults to `fill = NA`, so the box stays
  outline-only (as it effectively was before solid fill started painting). Pass a
  `fill` for a solid box, or `fill_style = "hachure"` with a `fill` for a shaded
  one.
* `theme_sketch(base_family = )` now defaults to
  `getOption("ggsketch.base_family", "")`, so `options(ggsketch.base_family =
  "auto")` makes every sketch plot's text (titles, axes, legend) use a
  handwriting font, not only the labels drawn by `geom_sketch_text()` /
  `geom_sketch_bracket()`.

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
