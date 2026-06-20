# ggsketch

> Grammar-native, hand-drawn geoms for **ggplot2** - the rough.js sketch
> aesthetic in **pure R**, with no JavaScript and no browser.

![A sketchy hachure-filled bar chart titled
ggsketch](reference/figures/README-hero.png)

`ggsketch` gives you first-class ggplot2 geoms
([`geom_sketch_col()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md),
[`geom_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_line.md),
[`geom_sketch_point()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_point.md),
…) that render with a wobbly, hand-drawn look: roughened double-stroke
outlines and hachure / cross-hatch / zigzag / dots / dashed fills.
Because the geoms are real grid grobs wrapped in `ggproto`, they compose
with [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html), stats,
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

## The geoms

| Family | Geoms |
|----|----|
| Lines & points | [`geom_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_line.md), [`geom_sketch_path()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_path.md), [`geom_sketch_point()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_point.md) |
| Bars & tiles | [`geom_sketch_col()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md), [`geom_sketch_bar()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md), [`geom_sketch_rect()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md), [`geom_sketch_tile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md) |
| Areas & curves | [`geom_sketch_polygon()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_polygon.md), [`geom_sketch_ribbon()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ribbon.md), [`geom_sketch_area()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ribbon.md), [`geom_sketch_density()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_density.md), [`geom_sketch_smooth()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_smooth.md) |
| Circular & composed | [`geom_sketch_circle()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md), [`geom_sketch_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md), [`geom_sketch_segment()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_segment.md), [`geom_sketch_step()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_segment.md), [`geom_sketch_boxplot()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_boxplot.md) |
| Helpers | [`annotate_sketch()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch.md), [`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md) |

### Shared sketch parameters

| Parameter | Meaning |
|----|----|
| `roughness` | How far points are jittered (0 = ruler-straight, ~1 default, \>3 loose) |
| `bowing` | How much segments bow outward |
| `n_passes` | Overlaid strokes (2 = the classic “double stroke”) |
| `seed` | Integer for reproducible wobble |
| `fill_style` | `"hachure"`, `"cross_hatch"`, `"zigzag"`, `"zigzag_line"`, `"dots"`, `"dashed"`, `"solid"` |
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
