# ggsketch

> Grammar-native, hand-drawn geoms for **ggplot2** - the rough.js sketch
> aesthetic in **pure R**, with no JavaScript and no browser.

![Sketchy hachure-filled violin plots of highway mpg by vehicle class,
with a handwriting-font title](reference/figures/README-hero.png)

`ggsketch` gives you ggplot2 geoms
([`geom_sketch_col()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md),
[`geom_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_line.md),
[`geom_sketch_point()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_point.md),
…) that render with a wobbly, hand-drawn look: roughened double-stroke
outlines and hachure / cross-hatch / zigzag / dots / dashed fills. It
even shades by **tonal engraving** — continuous tone built from
hatch-line density, the way an etcher or banknote engraver works
([`geom_sketch_engrave()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_engrave.md)),
something the fill-pattern packages can’t do because they tile a motif
rather than compute tone. Because the geoms are real grid grobs wrapped
in `ggproto`, they compose with
[`aes()`](https://ggplot2.tidyverse.org/reference/aes.html), stats,
scales, facets, and coords, and draw correctly on **every** R graphics
device — screen, PNG, PDF, and SVG.

## Why another sketch package?

|  | ggsketch | [ggrough](https://github.com/xvrdm/ggrough) |
|----|----|----|
| Approach | **Native ggplot2 geoms** (grid grobs) | Post-hoc convert a finished plot to SVG, redraw in HTML Canvas |
| Output | Any device: screen / PNG / **PDF** / SVG | HTML widget only (breaks static PDF/PNG) |
| Composes with [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html) / stats / scales / facets | Yes | No (operates on the rendered plot) |
| JavaScript / browser | None | Requires rough.js in a browser |
| Status | Active | Maintainer marks it dormant (“doesn’t work with recent releases of ggplot2”) |

The `ggrough` maintainer himself notes that “a nice way to create
sketchy visualisations would be a neat addition to the {ggplot2}
ecosystem.” `ggsketch` fills that gap with native geoms.

## Installation

``` r

# install.packages("pak")
pak::pak("orijitghosh/ggsketch")
```

`ggsketch` is pure R (`NeedsCompilation: no`); its only hard
dependencies are ggplot2, grid, rlang, scales, cli, and withr.

Full documentation and a gallery of every geom:
<https://orijitghosh.github.io/ggsketch/>.

## Quick start

``` r

library(ggplot2)
library(ggsketch)

df <- data.frame(product = c("Alpha","Bravo","Charlie","Delta"),
                 units   = c(34, 51, 22, 47))

ggplot(df, aes(product, units)) +
  geom_sketch_col(fill = "#7BAFD4", seed = 1L) +
  labs(title = "Units sold") +
  theme_sketch()
```

Every randomized routine is seeded, so a given `seed` always produces
the same wobble — your plots are reproducible. Set a session-wide
default with `options(ggsketch.seed = 1L)`.

## Showcase

Discrete fills map straight through `aes(fill = …)`, and any geom
accepts a stat - roughened columns coloured by a Brewer palette, and an
Old Faithful histogram:

![Hand-drawn bar chart with bars coloured by a discrete fill
scale](reference/figures/README-mapped-fill.png)![Sketchy histogram of
Old Faithful eruption times](reference/figures/README-histogram.png)

Points, a marginal rug, and a hand-drawn linear fit compose like any
other layers;
[`geom_sketch_bracket()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bracket.md)
adds significance brackets for pairwise comparisons:

![Sketchy scatter of weight vs mpg with a marginal rug and a roughened
linear fit](reference/figures/README-rug.png)![Sketchy boxplots by
drivetrain annotated with hand-drawn significance
brackets](reference/figures/README-brackets.png)

Every fill style works on every filled geom - here
`fill_style = "hachure"` boxplots across vehicle classes:

![Hachure-filled sketch boxplots of highway mpg by vehicle
class](reference/figures/README-boxplot.png)

The 2.0 line adds whole chart families that compose with `+` — here a
hierarchy as a hand-drawn sunburst, and weighted flows as a chord
diagram:

![Hand-drawn sunburst chart of headcount nested by region, department
and team](reference/figures/README-sunburst.png)![Hand-drawn chord
diagram of trade flows between
continents](reference/figures/README-chord.png)

It also simulates the *medium*, not just the line. The `"watercolor"`
fill paints translucent washes that bleed wet-on-wet where regions
overlap — mingling into new colours — and feather along the paper tooth
set by `theme_sketch(paper = )`:

![Overlapping translucent watercolour petals that blend into new colours
where they meet, feathered against an aged-paper
ground](reference/figures/README-watercolor.png)

## The geoms

| Family | Geoms |
|----|----|
| Lines & points | [`geom_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_line.md), [`geom_sketch_path()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_path.md), [`geom_sketch_point()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_point.md) |
| Bars & tiles | [`geom_sketch_col()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md), [`geom_sketch_bar()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md), [`geom_sketch_rect()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md), [`geom_sketch_tile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md), [`geom_sketch_lollipop()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_lollipop.md) |
| Areas & curves | [`geom_sketch_polygon()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_polygon.md), [`geom_sketch_ribbon()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ribbon.md), [`geom_sketch_area()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ribbon.md), [`geom_sketch_density()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_density.md), [`geom_sketch_smooth()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_smooth.md) |
| Distributions | [`geom_sketch_histogram()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_histogram.md), [`geom_sketch_violin()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_violin.md), [`geom_sketch_boxplot()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_boxplot.md), [`geom_sketch_beeswarm()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_beeswarm.md), [`geom_sketch_ridgeline()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ridgeline.md), [`geom_sketch_dotplot()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_dotplot.md), [`geom_sketch_ecdf()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ecdf.md) |
| Comparisons & change | [`geom_sketch_dumbbell()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_dumbbell.md), [`geom_sketch_slope()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_slope.md), [`geom_sketch_bump()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bump.md), [`geom_sketch_waterfall()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_waterfall.md), [`geom_sketch_funnel()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_funnel.md), [`geom_sketch_pyramid()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_pyramid.md) |
| Circular & composed | [`geom_sketch_circle()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md), [`geom_sketch_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md), [`geom_sketch_segment()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_segment.md), [`geom_sketch_step()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_segment.md) |
| Engraving & tone | [`geom_sketch_engrave()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_engrave.md) (shade an `x`/`y`/`z` surface by hatch-line density), [`geom_sketch_shade()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_engrave.md) (`aes(tone = …)` value → density), [`scale_engrave()`](https://orijitghosh.github.io/ggsketch/reference/scale_tone_continuous.md) |
| Charts & diagrams | [`geom_sketch_pie()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_pie.md), [`geom_sketch_waffle()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_waffle.md), [`geom_sketch_treemap()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_treemap.md), [`geom_sketch_sunburst()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_sunburst.md), [`geom_sketch_radar()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_radar.md), [`geom_sketch_chord()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_chord.md), [`geom_sketch_arc_diagram()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_arc_diagram.md), [`geom_sketch_alluvial()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_alluvial.md), [`geom_sketch_parallel()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_parallel.md), [`geom_sketch_mosaic()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_mosaic.md), [`geom_sketch_marimekko()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_marimekko.md), [`geom_sketch_rose()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rose.md), [`geom_sketch_calendar()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_calendar.md), [`geom_sketch_gantt()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_gantt.md), [`geom_sketch_dendrogram()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_dendrogram.md) |
| Networks & maps | [`geom_sketch_edge()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_edge.md) / [`sketch_graph()`](https://orijitghosh.github.io/ggsketch/reference/sketch_graph.md) (force-directed layout, no graph dep), [`geom_sketch_sf()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_sf.md) (hand-drawn simple-features maps) |
| Motion | [`animate_sketch()`](https://orijitghosh.github.io/ggsketch/reference/animate_sketch.md) (boiling-line shimmer or draw-on reveal → GIF) |
| Helpers & annotation | [`annotate_sketch()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch.md), [`geom_sketch_bracket()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bracket.md) (significance brackets), [`annotate_sketch_arrow()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch_arrow.md) / [`annotate_sketch_callout()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch_callout.md) (content-aware pointers), [`annotate_sketch_highlight()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch_highlight.md) / [`annotate_sketch_underline()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch_highlight.md) (marker emphasis), [`geom_sketch_text_repel()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text_repel.md) (non-overlapping labels), [`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md), [`sketch_style()`](https://orijitghosh.github.io/ggsketch/reference/sketch_style.md) (one-call style presets), [`ggsketch_save()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_save.md) |
| Frame & scales | [`element_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md), [`element_sketch_rect()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md) (via `theme_sketch(rough_frame = TRUE)`), [`coord_sketch()`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch.md) / [`coord_sketch_polar()`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch_polar.md), [`scale_colour_sketch()`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md), [`scale_fill_sketch()`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md), [`scale_medium_discrete()`](https://orijitghosh.github.io/ggsketch/reference/scale_medium_discrete.md) (mappable drawing media), [`register_sketch_font()`](https://orijitghosh.github.io/ggsketch/reference/register_sketch_font.md) |

### Shared sketch parameters

| Parameter | Meaning |
|----|----|
| `roughness` | How far points are jittered (0 = ruler-straight, ~1 default, \>3 loose) |
| `bowing` | How much segments bow outward |
| `n_passes` | Overlaid strokes (2 = the classic “double stroke”) |
| `seed` | Integer for reproducible wobble |
| `fill_style` | `"hachure"`, `"cross_hatch"`, `"zigzag"`, `"zigzag_line"`, `"scribble"`, `"dots"`, `"dashed"`, `"stipple"`, `"pencil_shade"`, `"solid"`, `"watercolor"` |
| `hachure_angle`, `hachure_gap`, `fill_weight` | Fill line angle, spacing, and weight |

## How it works

Three layers, kept strictly separate:

1.  **Layer 1 — pure geometry** (`R/core-*.R`): numbers → numbers.
    Seeded roughening, ellipse/Bézier sampling, and an Active-Edge-Table
    scan-line hachure filler that handles **concave** polygons. No grid,
    no ggplot2.
2.  **Layer 2 — grid grobs** (`R/grob-*.R`): `makeContent()` converts to
    device inches and re-roughens at the real render size, so resizing
    re-draws cleanly.
3.  **Layer 3 — ggproto geoms** (`R/geom-*.R`): standard ggplot2
    extension API.

Roughening always happens in **inch space**, so the look is consistent
across aspect ratios and devices.

## Credits & non-affiliation

The algorithms are reimplemented in original R from the **published
descriptions** of the [rough.js](https://github.com/rough-stuff/rough)
algorithms ([Preet Shihn,
2020](https://shihn.ca/posts/2020/roughjs-algorithms/)) and the hachure
approach of Wood et al. **No rough.js source is vendored, copied, or
translated, and no JavaScript ships in this package.** See
[`inst/NOTICE`](https://orijitghosh.github.io/ggsketch/inst/NOTICE).

> **ggsketch is an independent R package reimplementing the hand-drawn
> sketch aesthetic from first principles. It is not affiliated with,
> derived from, or endorsed by the rough.js project, ggrough, or any
> related JavaScript libraries.**

rough.js is © Preet Shihn and licensed MIT. ggsketch is licensed MIT.
