# Changelog

## ggsketch 2.0.0

The 2.0 series turns ggsketch from a *line style* into a
*drawing-medium* simulator. This first piece is the engine that makes it
possible.

- **Chicklet charts.** New
  [`geom_sketch_chicklet()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_chicklet.md)
  – a hand-drawn take on `ggchicklet::geom_chicklet()`. It stacks
  rounded “pill” segments with a small `segment_gap` between them and a
  solid fill by default; add
  [`coord_flip()`](https://ggplot2.tidyverse.org/reference/coord_flip.html)
  for the classic horizontal layout. Built on
  [`geom_sketch_col()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md),
  so it inherits every fill style, drawing medium, and sketch parameter.

- **Repelled labels escape panel corners.** The
  [`repel_layout()`](https://orijitghosh.github.io/ggsketch/reference/repel_layout.md)
  solver now picks its separation axis by the room left inside the panel
  bounds, so labels pressed into a corner fan out along the edge instead
  of being clamped back on top of each other (previously e.g. three
  overlapping boxes in a scatter’s corner).

- **Calendar axes read as calendars.**
  [`geom_sketch_calendar()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_calendar.md)
  now labels the y axis with weekday names (honouring `week_start`) and
  the x axis with month names instead of raw grid numbers; set
  `labels = FALSE` to supply your own scales.

- **Saner default hachure pitch.** When `hachure_gap` is `NULL`,
  [`sketch_polygon_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_polygon_grob.md)
  now picks the gap at draw time in device inches – 15% of the shape’s
  smaller drawn extent, clamped to \[0.04, 0.4\] – instead of geoms
  guessing in data units. Wide flat rectangles (Gantt/funnel/pyramid
  bars, long tiles) no longer degenerate into a few huge strokes
  escaping the outline, and
  [`geom_sketch_gantt()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_gantt.md)/`funnel()`/`pyramid()`
  drop their fixed 0.12 workaround pitch. An explicit `hachure_gap` is
  honoured unchanged, but default-gap output shifts slightly.

- **Rect geoms bend under nonlinear coords.**
  [`geom_sketch_rect()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md),
  [`geom_sketch_tile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md),
  and
  [`geom_sketch_col()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md)/`bar()`
  now densify their boundaries before the coordinate transform, so bars
  under
  [`coord_polar()`](https://ggplot2.tidyverse.org/reference/coord_radial.html)
  /
  [`coord_sketch_polar()`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch_polar.md)
  curve into proper wedges and rings instead of straight-edged quads.

- **Radar legend fix.**
  [`geom_sketch_radar()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_radar.md)
  no longer leaks an `NA` key into a mapped discrete `fill` scale, so
  its colour and fill legends merge into one (previously two legends,
  one with a spurious `NA` entry).

- **Edge labels are never clipped.**
  [`geom_sketch_bump()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bump.md),
  [`geom_sketch_arc_diagram()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_arc_diagram.md),
  [`geom_sketch_parallel()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_parallel.md),
  and
  [`geom_sketch_dendrogram()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_dendrogram.md)
  now reserve panel room for their end/leaf/axis labels (and the
  dendrogram’s rotated labels hang cleanly away from the tree), so
  nothing is cut off at the plot edge under
  [`theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html).

- **The lightest engraved region always draws.**
  [`scale_tone_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_tone_continuous.md)’s
  default band is now `c(0.15, 0.95)` (was `c(0.1, 0.95)`), keeping the
  faintest mapped tone above the engraving ladder’s blank-paper
  threshold – previously the lightest
  [`geom_sketch_shade()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_engrave.md)
  region could disappear entirely.

- **Alluvial strata gaps.**
  [`geom_sketch_alluvial()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_alluvial.md)
  gains `stratum_gap` (default 0.02): a small vertical gap between
  adjacent strata so roughened boxes never overlap at their shared edge;
  `0` restores flush stacking.

- **Variable-width strokes (Layer 1 + Layer 2).**
  [`stroke_ribbon()`](https://orijitghosh.github.io/ggsketch/reference/stroke_ribbon.md)
  builds a hand-drawn stroke as a filled polygon ribbon offset around a
  centreline, so a line can taper to a point, swell with pressure, or
  vary like a broad calligraphic nib – effects `grid` cannot produce
  with a constant-`lwd` polyline.
  [`stroke_profile()`](https://orijitghosh.github.io/ggsketch/reference/stroke_profile.md)
  supplies ready-made width profiles (`"taper_in"`, `"taper_out"`,
  `"belly"`, `"flat"`), and
  [`sketch_stroke_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_stroke_grob.md)
  renders a path as variable-width ribbons, re-roughening the centreline
  at device resolution (with round or butt caps, optional width jitter
  for a dry edge, and a `nib_angle` for calligraphy). This is the
  foundation the forthcoming media (ink, brush, pencil, charcoal,
  calligraphy) are built on.

- **Drawing media on the path geoms.** A new `medium` argument selects
  how a line is laid down: `"pen"` (the default – the classic
  constant-width double stroke, unchanged), or `"ink"`, `"brush"`,
  `"pencil"`, `"charcoal"`, `"marker"`, `"crayon"`, which render through
  the variable-width engine – tapered ink, brushy belly swells, grainy
  multi-pass pencil/charcoal, translucent marker, waxy crayon. Available
  on
  [`geom_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_line.md),
  [`geom_sketch_path()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_path.md),
  [`geom_sketch_segment()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_segment.md),
  and
  [`geom_sketch_step()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_segment.md);
  [`sketch_media()`](https://orijitghosh.github.io/ggsketch/reference/sketch_media.md)
  lists the options. Existing plots are unaffected (the default stays
  `"pen"`).

- **Three more drawing media.** `"fountain_pen"` (a crisp, wet line that
  pools slightly at the ends), `"ballpoint"` (a thin, even, faintly
  skipping stroke), and `"pastel"` (a broad, soft, grainy and
  translucent mark, lighter than charcoal) join the `medium` family and
  the
  [`scale_medium_discrete()`](https://orijitghosh.github.io/ggsketch/reference/scale_medium_discrete.md)
  palette.

- **Waterfall charts.**
  [`geom_sketch_waterfall()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_waterfall.md)
  floats each step’s delta (`y`) from the running total before it to the
  running total after it across the categories (`x`), with dotted
  hand-drawn connectors carrying the level over the gaps. Bars colour by
  direction (`fill_increase` / `fill_decrease` / `fill_total`, or map
  `fill` to `after_stat(change)` yourself), an optional
  `measure = "total"` aesthetic draws closing-total bars from zero, and
  any `fill_style` works (including `"watercolor"`).

- **Gantt / timeline charts.**
  [`geom_sketch_gantt()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_gantt.md)
  draws one roughened bar per task from `x` (start) to `xend` (end) on a
  discrete `y` – the whiteboard project-planning look. An optional
  `progress` aesthetic (0-1) overlays a slimmer, darker solid bar over
  the completed fraction; bars take rounded corners (`corner_radius`),
  dates on x and any `fill_style`.

- **Funnel and population-pyramid charts.**
  [`geom_sketch_funnel()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_funnel.md)
  centres one bar per stage on zero with width equal to the stage’s
  value, so the shrinking bars read as drop-off, with translucent
  trapezoid connectors carrying each stage into the next.
  [`geom_sketch_pyramid()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_pyramid.md)
  draws back-to-back bars mirrored about zero by a two-level `side`
  aesthetic – the population pyramid. Both take every `fill_style`.

- **Font-aware export helper.**
  [`ggsketch_save()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_save.md)
  is a drop-in
  [`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html)
  wrapper that picks a device able to see fonts registered with
  [`register_sketch_font()`](https://orijitghosh.github.io/ggsketch/reference/register_sketch_font.md):
  ragg for raster formats, svglite for SVG, `cairo_pdf` for PDF (the
  base `pdf` device misses registered fonts), and it warns PostScript
  users towards PDF – ending the “my handwriting font disappeared in the
  saved file” footgun.

- **One-call style presets.**
  [`sketch_style()`](https://orijitghosh.github.io/ggsketch/reference/sketch_style.md)
  bundles a paper ground, a qualitative colour/fill palette tuned to it
  and (on ggplot2 \>= 4.0) matching default geom ink into a single
  `+`-able object: `p + sketch_style("chalkboard")`. Presets:
  `"notebook"`, `"chalkboard"`, `"blueprint"`, `"field_notes"` and
  `"graphite"`;
  [`sketch_styles()`](https://orijitghosh.github.io/ggsketch/reference/sketch_styles.md)
  lists them, and `palette = FALSE` keeps your own scales.

- **Highlighter swipes and hand-drawn underlines.**
  [`annotate_sketch_highlight()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch_highlight.md)
  lays a wide translucent chisel-tip band (the new highlighter medium)
  over a region of interest in one call, and
  [`annotate_sketch_underline()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch_highlight.md)
  draws a quick wobbly underline (`strokes > 1` re-draws it for an
  emphatic scrawl).

- **Chalk and highlighter media.** `medium = "chalk"` draws a broad,
  dry, flat-ended stroke with a faint halo of settled dust either side
  of the line – made for `theme_sketch(paper = "chalkboard")` with a
  light stroke colour. `medium = "highlighter"` lays a single very
  translucent chisel-tip band with crisp edges, so a swipe drawn under
  (or over) a pen line reads as a fluorescent emphasis rather than a
  line of its own.

- **Airbrush / spray medium.** A new `medium = "spray"` renders a line
  as a soft cloud of dots scattered around the centreline with no hard
  outline – the spray-can / airbrush look. Powered by a new Layer-1
  sampler
  [`spray_scatter()`](https://orijitghosh.github.io/ggsketch/reference/spray_scatter.md)
  (Gaussian perpendicular offset, density falloff and feathered edges)
  and a Layer-2
  [`sketch_spray_grob()`](https://orijitghosh.github.io/ggsketch/reference/sketch_spray_grob.md)
  that re-roughens and scatters at device resolution. Selectable per
  group via `aes(medium = )` like the other media.

- **Paper / canvas grounds.** `theme_sketch(paper = )` paints a
  simulated paper texture behind the data: `"notebook"` (blue rules +
  red margin), `"graph"`, `"dotted"`, `"aged"` (warm ground with soft
  blotches), `"blueprint"` and `"chalkboard"` (dark grounds that flip
  the text light), and `"kraft"`. The ruling is spaced in physical
  inches so it looks right on any panel aspect, and everything is drawn
  as vector primitives, so it reproduces on every device.
  [`element_sketch_paper()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_paper.md)
  is the underlying panel-background element (usable directly in
  [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html)), and
  [`sketch_papers()`](https://orijitghosh.github.io/ggsketch/reference/sketch_papers.md)
  lists the grounds. The default `"none"` leaves the theme unchanged.

- **Watercolour fill.** A new `fill_style = "watercolor"` paints a
  region with stacked translucent washes instead of stroked fill lines:
  where the jittered boundary copies overlap the colour deepens toward
  the interior, the irregular edges feather like pigment bleeding into
  wet paper, and a scatter of darker specks reads as pigment
  granulation. Overlapping shapes blend wet-on-wet. It works on every
  polygon-fill geom
  ([`geom_sketch_polygon()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_polygon.md),
  [`geom_sketch_area()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ribbon.md),
  [`geom_sketch_col()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md)
  / `bar()`,
  [`geom_sketch_rect()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md)
  / `tile()`,
  [`geom_sketch_violin()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_violin.md),
  [`geom_sketch_boxplot()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_boxplot.md),
  [`geom_sketch_ridgeline()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ridgeline.md),
  …), on the ellipse/circle geoms
  ([`geom_sketch_circle()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md),
  the `mark_circle` / `mark_ellipse` family), and on the hole-aware band
  geoms
  ([`geom_sketch_contour_filled()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_contour_filled.md),
  [`geom_sketch_density_2d_filled()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_contour_filled.md))
  where the washes respect holes via a new Layer-1
  [`watercolor_wash_multi()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash_multi.md).
  Powered by a new Layer-1
  [`watercolor_wash()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash.md).
  Everything is vector, so it reproduces on every device.

- **Watercolour media physics: wet-on-wet bleed and ink-into-paper
  grain.** Two couplings make the washes behave more like real pigment.
  Where two watercolour regions overlap, the pigments now mingle: a new
  Layer-1
  [`wash_bleed()`](https://orijitghosh.github.io/ggsketch/reference/wash_bleed.md)
  samples the shared area and lays down soft specks tinted with the
  *blended* colour, so the overlap reads as mixed paint (toggle with
  `options(ggsketch.wash_bleed =)`). And the wash edge now feathers
  along the paper tooth:
  [`watercolor_wash()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash.md)
  gains a `grain` argument that wicks the boundary in coherent capillary
  channels, and `theme_sketch(paper = )` couples it automatically
  through a new
  [`paper_grain()`](https://orijitghosh.github.io/ggsketch/reference/paper_grain.md)
  (smooth notebook/graph grounds wick little; aged and kraft wick a
  lot). `grain = 0` is the historical look and draws no extra
  randomness, so existing seeds reproduce exactly.

- **`medium` is now a mappable aesthetic.** On the path-like geoms
  ([`geom_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_line.md),
  [`geom_sketch_path()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_path.md),
  [`geom_sketch_segment()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_segment.md),
  [`geom_sketch_step()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_segment.md))
  you can map a discrete variable with `aes(medium = )` to draw each
  group (or each segment) in a different medium, and
  [`scale_medium_discrete()`](https://orijitghosh.github.io/ggsketch/reference/scale_medium_discrete.md)
  chooses which media the levels map to. The legend keys render in their
  own medium. Setting `medium` as a constant still works exactly as
  before, and the default is unchanged (`"pen"`).

- **`pressure` is a mappable aesthetic.** On
  [`geom_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_line.md)
  /
  [`geom_sketch_path()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_path.md),
  map `aes(pressure = )` to a variable to make the stroke swell and thin
  *along* the line, like a pen pressed harder in places. The line then
  renders through the variable-width
  [`stroke_ribbon()`](https://orijitghosh.github.io/ggsketch/reference/stroke_ribbon.md)
  engine even under the default `medium = "pen"`, and combines with any
  non-`pen` medium (the width profiles multiply). Values are rescaled by
  the new
  [`scale_pressure_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_pressure_continuous.md)
  (default band `c(0.2, 1.6)`); wrap in
  [`I()`](https://rdrr.io/r/base/AsIs.html) for raw multipliers.
  Per-vertex pressure is carried as an interpolated arc-length profile,
  so it stays correct when the centreline is re-roughened at device
  resolution.

- **The sketch colour palette now interpolates.**
  [`scale_colour_sketch()`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md)
  /
  [`scale_fill_sketch()`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md)
  (and
  [`sketch_palette()`](https://orijitghosh.github.io/ggsketch/reference/sketch_palette.md))
  used to recycle once a factor had more than eight levels. They now
  interpolate the eight ink-on-paper anchors into one distinct colour
  per level via a
  [`colorRampPalette()`](https://rdrr.io/r/grDevices/colorRamp.html)
  ramp, so the discrete scales keep working for large factors and
  quasi-continuous use. The first eight colours are unchanged, so small
  plots look identical; pass `interpolate = FALSE` for the old recycling
  behaviour.

- **[`coord_sketch()`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch.md).**
  A drop-in replacement for
  [`coord_cartesian()`](https://ggplot2.tidyverse.org/reference/coord_cartesian.html)
  that draws the *frame* hand-drawn – the panel gridlines and axis ticks
  become roughened sketch grobs – under *any* theme, not only
  [`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md).
  It reuses ggplot2’s own gridline and axis layout and only swaps how
  those elements are drawn, so limits, expansion, and clipping behave
  exactly like
  [`coord_cartesian()`](https://ggplot2.tidyverse.org/reference/coord_cartesian.html).
  `rough_grid` / `rough_ticks` toggle each element; combine with
  `theme_sketch(rough_frame = TRUE)` to roughen the panel border too.

- **[`coord_sketch_polar()`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch_polar.md).**
  The polar companion to
  [`coord_sketch()`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch.md)
  – a drop-in replacement for
  [`coord_polar()`](https://ggplot2.tidyverse.org/reference/coord_radial.html)
  that draws the circular grid hand-drawn (wobbly concentric rings and
  radial spokes), so rose / circular bar charts get a frame that matches
  the marks under any theme. Like
  [`coord_sketch()`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch.md)
  it reuses ggplot2’s polar layout and only swaps how the grid is drawn
  (`theta`, `start`, `direction` behave as in
  [`coord_polar()`](https://ggplot2.tidyverse.org/reference/coord_radial.html)).

- **New chart families:
  [`geom_sketch_dumbbell()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_dumbbell.md)
  and
  [`geom_sketch_slope()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_slope.md).**
  Two hand-drawn comparison charts.
  [`geom_sketch_dumbbell()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_dumbbell.md)
  draws a roughened connector from `x` to `xend` on a shared `y`, capped
  with a sketch dot at each end (separate `colour_x` / `colour_xend`),
  for showing the gap between two paired values per category.
  [`geom_sketch_slope()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_slope.md)
  draws one roughened line per `group` across an ordered x with a dot at
  each vertex – a sketch slopegraph for before/after rank changes. Both
  reuse the existing stroke and point grobs, so they need no new
  dependencies.

- **New chart family:
  [`geom_sketch_beeswarm()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_beeswarm.md).**
  A hand-drawn beeswarm (dot-strip) plot – at each categorical `x` the
  points are nudged sideways so they no longer overlap, so the width of
  the swarm reads as the local density of `y`. The offset is computed
  deterministically in data space (no device metrics, fully
  reproducible) and the dots are drawn with
  [`geom_sketch_point()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_point.md),
  so they keep the usual wobble. `width` widens the swarm; `binwidth` /
  `nbins` control the `y` rows. No new dependencies
  (cf. `ggbeeswarm::geom_beeswarm()`).

- **New chart family:
  [`geom_sketch_ridgeline()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ridgeline.md).**
  A hand-drawn ridgeline (joyplot) – a kernel density of `x` for each
  category on a discrete `y`, raised to its own baseline so the ridges
  overlap and the changing shape of the distribution is easy to compare.
  `scale` sets how far the tallest ridge rises (values above 1 overlap),
  `rel_min_height` trims the tails, and the fill honours every
  `fill_style` including `"watercolor"`. Ridges are drawn back-to-front
  so nearer ones sit on top. Powered by a new `StatSketchDensityRidges`;
  no new dependencies (cf. `ggridges::geom_density_ridges()`).

- **New chart family:
  [`geom_sketch_waffle()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_waffle.md).**
  A hand-drawn waffle chart – a square grid (default 10x10 = 100 cells)
  where the number of cells of each colour reads as that category’s
  share of the whole. Map the category to `fill` and (for summarised
  data) a count to `weight`; cells are tallied by a new
  `StatSketchWaffle` (largest-remainder rounding) and drawn with
  [`geom_sketch_tile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md),
  so they take the roughened outline and any `fill_style` (including
  `"watercolor"`). No new dependencies (cf. `waffle::geom_waffle()`).

- **New chart family:
  [`geom_sketch_treemap()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_treemap.md).**
  A hand-drawn treemap – nested rectangles tiling a square, each with
  area proportional to a value, so the biggest categories take the most
  space. Map the value to `area`, the category to `fill`, and optionally
  `label` to write a name in each tile. Rectangles are placed by a new
  Layer-1 squarified algorithm
  ([`treemap_layout()`](https://orijitghosh.github.io/ggsketch/reference/treemap_layout.md),
  exported) and drawn with the roughened rect look, so they take any
  `fill_style`. No new dependencies (cf. `treemapify::geom_treemap()`).

- **New chart family:
  [`geom_sketch_streamgraph()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_streamgraph.md).**
  A hand-drawn streamgraph (ThemeRiver) – a stacked area whose baseline
  floats so the coloured bands flow around a moving centre. Map `x`,
  `y`, and `fill`; a new `StatSketchStream` stacks the values and
  offsets the baseline (`offset = "silhouette"` centred, `"zero"` for a
  normal stacked area, or `"wiggle"` to minimise the slope), and each
  band is drawn as a roughened ribbon (any `fill_style`, including
  `"watercolor"`). No new dependencies (cf. `ggstream::geom_stream()`).

- **New chart family:
  [`geom_sketch_calendar()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_calendar.md).**
  A hand-drawn calendar heatmap in the GitHub-contributions style – one
  roughened tile per day, laid out as weeks (columns) and weekdays
  (rows), coloured by a value. Map `date` and `fill`; a new
  `StatSketchCalendar` builds the week/weekday grid (`week_start`
  chooses Sunday or Monday on top), and tiles are drawn with
  [`geom_sketch_tile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md)
  (default `fill_style = "solid"` so the gradient reads). Facet on a
  year column for multiple years. No new dependencies.

- **Flagship: hand-drawn networks.**
  [`geom_sketch_node()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_edge.md)
  and
  [`geom_sketch_edge()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_edge.md)
  draw a graph the sketch way – roughened node markers with optional
  handwriting labels, and roughened (optionally curved, via `curvature`)
  edges.
  [`sketch_graph()`](https://orijitghosh.github.io/ggsketch/reference/sketch_graph.md)
  is the bridge: give it a two-column edge data frame (or an `igraph`
  object) and it returns ready-to-plot `nodes` and `edges` frames,
  positioning nodes with
  [`force_layout()`](https://orijitghosh.github.io/ggsketch/reference/force_layout.md),
  a from-scratch pure-R Fruchterman-Reingold force-directed layout – so
  the whole flagship needs **no graph dependency**. `igraph` is an
  optional, guarded convenience for ingestion only; extra edge/node
  columns are carried through as attributes you can map. The layout is
  seeded and reproducible and never disturbs the global RNG.

- **Flagship: hand-drawn maps (`sf`).**
  [`geom_sketch_sf()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_sf.md)
  is a sketch take on
  [`ggplot2::geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html):
  it roughens the boundaries of simple-features geometry in one call –
  `(MULTI)POLYGON` features get a hole-aware hachure (or any
  `fill_style`), `(MULTI)LINESTRING` features become sketch paths, and
  `(MULTI)POINT` features become sketch points. It extracts coordinates
  from the `sf` object up front and draws ordinary sketch layers, so it
  sidesteps
  [`coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)/[`stat_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
  and plots in **planar coordinates** – pre-project lon/lat data with
  [`sf::st_transform()`](https://r-spatial.github.io/sf/reference/st_transform.html)
  for a faithful map. `sf` is an optional, guarded dependency
  (Suggests); it is only needed when you call this geom.

- **Radar / spider charts.**
  [`geom_sketch_radar()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_radar.md)
  draws each series as a closed roughened polygon over evenly spaced
  angular axes, behind a hand-drawn web of concentric rings, radial
  spokes and axis labels. Map `axis`, `value` and `group` (plus
  `colour`/`fill`); values are scaled to a common outer ring (`rmax`)
  and each polygon takes any `fill_style`, including `"watercolor"`.
  Like the pie geoms it lives in its own square space – pair with
  [`coord_equal()`](https://ggplot2.tidyverse.org/reference/coord_fixed.html).
  No new dependencies (cf. `ggradar`, `fmsb::radarchart()`).

- **Chord diagrams.**
  [`geom_sketch_chord()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_chord.md)
  lays nodes on a circle, each given a rim arc proportional to its total
  flow, and draws every weighted relation as a ribbon whose ends are
  sub-arcs joined by curves through the centre. Give it an edge table
  and the `from`, `to` and `value` columns; ribbons are coloured by
  source node (add \[scale_fill_sketch()\] or any fill scale), take any
  `fill_style`, and self-loops are dropped. Pair with
  [`coord_equal()`](https://ggplot2.tidyverse.org/reference/coord_fixed.html).
  No new dependencies (cf. `circlize::chordDiagram()`).

- **Alluvial / Sankey diagrams.**
  [`geom_sketch_alluvial()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_alluvial.md)
  draws two or more categorical axes as stacks of strata, joined by
  flows whose thickness is the frequency of each category combination.
  Give it a wide data frame, the `axes` columns (in order), an optional
  `value` weight, and an optional `fill` column (default: the first
  axis); flows get raised-cosine edges and any `fill_style`. It draws in
  ordinary x/y space – pair with
  [`theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html).
  No new dependencies (cf. `ggalluvial`, `ggsankey`).

- **Motion.**
  [`animate_sketch()`](https://orijitghosh.github.io/ggsketch/reference/animate_sketch.md)
  animates a sketch plot two ways. `type = "boil"` (default) re-renders
  it while shifting every roughening seed per frame, so the whole
  drawing shimmers and re-draws itself like a hand-animated cel (the
  “boiling line” effect); the shift rides on a new global
  `ggsketch.seed_jitter` option that `resolve_seed()` adds to *every*
  resolved seed – explicit or inherited – so a plot boils with no change
  to its code, and frame 1 reproduces the static render exactly.
  `type = "draw_on"` instead reveals the finished drawing progressively,
  as if a hand were drawing it on. The reveal can be a straight wipe
  (`direction` `"lr"`/`"rl"`/`"bt"`/`"tb"`), a diagonal wipe (`"diag"`),
  or a circular iris opening from the centre (`"radial"`), and its
  pacing across frames follows an `easing` curve (`"linear"`,
  `"ease_in"`, `"ease_out"`, `"ease_in_out"`). Frames are stitched into
  a GIF when `gifski` or `magick` is installed (guarded Suggests, no new
  hard dependency); otherwise the frame paths are returned. Fully
  reproducible from `seed`.

- **`rough_frame` now reaches facet strips and the colourbar.**
  `theme_sketch(rough_frame = TRUE)` already drew the gridlines, panel
  border and axis ticks hand-drawn; it now also roughens facet **strip
  backgrounds** and the continuous-scale **colourbar frame and ticks**,
  so a faceted or colour-mapped plot’s whole frame matches the marks.
  These reuse the existing
  [`element_sketch_rect()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md)
  /
  [`element_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md)
  elements (which work directly as `strip.background`, `legend.frame`
  and `legend.ticks` in any theme), so no new function or fragile
  facet/guide subclass is involved.

- **Two new tonal fills: `"stipple"` and `"pencil_shade"`.**
  `fill_style = "stipple"` scatters fine rough dots at random interior
  points (a pointillist tone with no visible lattice, unlike the
  grid-aligned `"dots"`); `fill_style = "pencil_shade"` lays trimmed
  graphite strokes plus a sparser cross set at a small angle for soft
  directional shading. Both work on every polygon-fill geom and respect
  holes on the band geoms (via new multi-ring variants). Density /
  texture follow `hachure_gap` and `roughness` as usual.

- **Ink-into-paper grain now reaches the line media too.** The
  paper-tooth coupling that feathers watercolour washes
  (`theme_sketch(paper = )`) now also roughens the variable-width stroke
  media (ink, brush, pencil, charcoal, …): on a toothy ground (`"aged"`,
  `"kraft"`) their centreline and wet edge pick up extra grain, so a
  drawing reads consistently across line and fill. A no-op on plain
  ground, so existing plots are unchanged.

- **Repelled labels (the sketch answer to ggrepel).**
  [`geom_sketch_text_repel()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text_repel.md)
  and
  [`geom_sketch_label_repel()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text_repel.md)
  place text / boxed labels near their points but nudged apart so they
  no longer overlap each other or cover the data, each tied back to its
  anchor by a hand-drawn leader. A new Layer-1 force solver
  [`repel_layout()`](https://orijitghosh.github.io/ggsketch/reference/repel_layout.md)
  does the placement (run in device inches at draw time, so the
  repulsion is even on any panel aspect): overlapping boxes shove apart,
  boxes slide off the points they cover, and a weak spring keeps each
  label near what it names. The boxes and leaders are roughened like the
  rest of ggsketch; the glyphs stay a handwriting font (ADR-0007). No
  new dependency (cf. `ggrepel`).

- **Callout leader routing.**
  [`geom_sketch_callout()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_callout.md)
  (and
  [`annotate_sketch_callout()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch_callout.md))
  gain `leader =`: `"straight"` (default), `"elbow"` (horizontal then
  vertical, flowchart style) or `"curved"` (a bowed Bezier, sized by
  `curvature`). The arrowhead re-orients to the leader’s end tangent for
  every route. Backed by a new Layer-1
  [`leader_path()`](https://orijitghosh.github.io/ggsketch/reference/leader_path.md).

- **Arrowhead vocabulary.** Arrows and callout leaders now take a
  `head =` argument choosing the head style: `"triangle_open"` (the
  classic two-stroke V), `"triangle_filled"`, `"barb"` (swept-back
  harpoon barbs), `"fishtail"` (a forked swallowtail), `"dot"` (a blob)
  or `"bar"` (a perpendicular tick), and
  [`geom_sketch_arrow()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_arrow.md)
  gains `ends =` (`"last"` / `"first"` / `"both"`) for double-headed
  arrows. One Layer-1 generator
  [`arrowhead()`](https://orijitghosh.github.io/ggsketch/reference/arrowhead.md)
  (listed by
  [`sketch_arrowheads()`](https://orijitghosh.github.io/ggsketch/reference/sketch_arrowheads.md))
  drives
  [`geom_sketch_arrow()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_arrow.md),
  [`annotate_sketch_arrow()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch_arrow.md)
  and
  [`geom_sketch_callout()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_callout.md)
  alike. The old `arrow_type` (`"open"`/`"closed"`) still works and maps
  onto the new styles.

- **Faster boil animations (frame caching).**
  `animate_sketch(type = "boil")` now computes the plot’s build
  (statistics, scales, layout) once and only re-tables / re-draws it per
  frame, instead of rebuilding the whole plot every frame – the boil
  only ever varied at draw time. Output is unchanged (frame 1 still
  equals the static render); heavier plots (stats, large data, contours)
  see the biggest speed-up.

- **gganimate bridge.**
  [`boil_gganimate()`](https://orijitghosh.github.io/ggsketch/reference/boil_gganimate.md)
  renders a gganimate animation – any ggsketch plot plus a
  `transition_*()` – so that, on top of gganimate’s data tweening (bars
  growing, points flying between states, a line drawing itself along
  `x`), the hand-drawn lines *boil*: the roughening seed steps once per
  frame as gganimate draws it, so the marks shimmer while the data
  moves. It is the moving-data companion to
  [`animate_sketch()`](https://orijitghosh.github.io/ggsketch/reference/animate_sketch.md)
  (which boils a static plot), keyed to a per-frame counter so frame 1
  is un-boiled and the run reproduces. gganimate is an optional
  Suggests; frames are stitched with the same `gifski` / `magick`
  backend, or returned as paths.

- **Parallel-coordinates plots.**
  [`geom_sketch_parallel()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_parallel.md)
  draws several numeric columns as vertical axes and every observation
  as a roughened polyline crossing them at its values. Give it the
  `axes` columns (in order); axes scale independently to a common height
  by default, and `colour` maps a column to the lines. No new
  dependencies (cf. `GGally::ggparcoord()`,
  [`MASS::parcoord()`](https://rdrr.io/pkg/MASS/man/parcoord.html)).

- **Mosaic plots.**
  [`geom_sketch_mosaic()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_mosaic.md)
  splits the unit square into columns by the marginal counts of one
  categorical variable, then each column vertically by the conditional
  counts of a second, so every roughened tile’s area is the joint
  frequency. Give it `x`, `y` and an optional `value` weight; colour by
  `y` (default) or `x`. No new dependencies
  (cf. [`graphics::mosaicplot()`](https://rdrr.io/r/graphics/mosaicplot.html),
  `ggmosaic`).

- **Sunburst charts.**
  [`geom_sketch_sunburst()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_sunburst.md)
  draws a hierarchy as nested rings of roughened annular sectors: the
  columns in `levels` define the hierarchy from the inner root ring
  outward, and each deeper ring splits its parent’s angular span by the
  children’s summed `value`, so a child always nests inside its parent.
  Colour by the top-level ancestor (`fill_by = "root"`, the classic
  look), by each node, or by ring. Pair with
  [`coord_equal()`](https://ggplot2.tidyverse.org/reference/coord_fixed.html) +
  [`theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html).
  No new dependencies (cf. `sunburstR`, `plotly`).

- **Arc diagrams.**
  [`geom_sketch_arc_diagram()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_arc_diagram.md)
  lays nodes along a horizontal line and draws every weighted relation
  as a roughened semicircle arching over (or under, `side = "bottom"`)
  the axis between its endpoints - a linear cousin of the chord diagram.
  Edges are coloured by source and their width scales with `value`; node
  points scale with incident weight. No new dependencies
  (cf. `arcdiagram`, `ggraph`).

- **Bump / ranking charts.**
  [`geom_sketch_bump()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bump.md)
  draws each series’ rank at every time point and joins it across
  adjacent times with smooth roughened curves, so a crossing reads as
  one series overtaking another. Give it long data with `x` (time),
  `group` (series) and `value` (ranked within each time); colour by
  series and label the ends. No new dependencies (cf. `ggbump`).

- **Dendrograms.**
  [`geom_sketch_dendrogram()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_dendrogram.md)
  draws a hierarchical-clustering tree with the right-angle elbows
  roughened into a hand-drawn wobble. Pass a ready
  [`stats::hclust()`](https://rdrr.io/r/stats/hclust.html) object or a
  numeric data frame (a tree is then computed via `hclust(dist(...))`,
  with `method`/`distance` controls). Four orientations
  (`up`/`down`/`left`/`right`). Pure base stats; no new dependencies
  (cf. `ggdendro`).

- **Marimekko charts.**
  [`geom_sketch_marimekko()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_marimekko.md)
  draws variable-width stacked bars: each column’s width is one
  category’s (`x`) share of the total and the stacked segments are a
  second category’s (`fill`) shares, so every tile’s area is the joint
  value. The value-weighted, segment-coloured cousin of the mosaic plot
  (and reuses its layout); shows each column’s width percent on top. No
  new dependencies.

- **Coxcomb / Nightingale rose charts.**
  [`geom_sketch_rose()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rose.md)
  gives each category an equal angular wedge whose radius encodes
  `value`; with `area_true = TRUE` the sector *area* (radius
  square-root) encodes value, as in Florence Nightingale’s mortality
  roses. An optional `fill` category stacks radially within each wedge.
  Pair with
  [`coord_equal()`](https://ggplot2.tidyverse.org/reference/coord_fixed.html) +
  [`theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html).
  No new dependencies.

- **Engraving: tonal shading by line density.** A new module shades by
  the *density* of hand-drawn hatch lines, the way an etcher or banknote
  engraver builds a gradient – light areas stay near-blank, shadows
  accumulate dense cross-hatch. Unlike the fill-pattern packages (which
  tile a motif), the tone is *computed* from geometry.
  [`geom_sketch_engrave()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_engrave.md)
  shades an `x`/`y`/`z` surface (high `z` = dark);
  [`geom_sketch_shade()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_engrave.md)
  shades each polygon region with a uniform density set by a `tone`
  aesthetic, so a mapped value reads as darkness. Powered by a new
  Layer-1 engine
  ([`engrave_fill()`](https://orijitghosh.github.io/ggsketch/reference/engrave_fill.md)
  /
  [`engrave_ladder()`](https://orijitghosh.github.io/ggsketch/reference/engrave_ladder.md),
  exposed at Layer 1) that lays down a ladder of hatch layers and keeps
  each only where the tone reaches its threshold, reusing the hole-aware
  scan-line. A pitch floor (`min_gap_in`) keeps the darkest tones from
  exploding into a runaway number of strokes.

  - [`scale_tone_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_tone_continuous.md)
    (alias
    [`scale_engrave()`](https://orijitghosh.github.io/ggsketch/reference/scale_tone_continuous.md))
    rescales a mapped variable to a legible tone band, so
    `aes(tone = z)` works the way
    [`scale_size()`](https://ggplot2.tidyverse.org/reference/scale_size.html)
    does for size; wrap in [`I()`](https://rdrr.io/r/base/AsIs.html) to
    use raw tone.
  - [`geom_sketch_engrave()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_engrave.md)
    takes an `x`/`y`/`z` grid directly, or shades raw points through a
    density stat, e.g.
    `geom_sketch_engrave(stat = "density_2d", contour = FALSE, aes(z = after_stat(density)))`.

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
