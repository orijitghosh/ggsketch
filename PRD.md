# PRD.md — `{ggsketch}`: Grammar-Native Hand-Drawn Geoms for ggplot2

**Status:** Draft v1
**Working package name:** `ggsketch` (OPEN DECISION D-01 — `ggrough` is taken and dormant; see §1).
**Bundle:** `DEVELOPMENT.md` (binding development rules) · `PRD.md` (this file, scope authority) · `BUILD_PLAN.md` (authoritative checkbox tasks) · `TESTING.md` (invariant catalog) · `DECISIONS.md` (ADRs)

---

## 1. Problem statement and landscape

The hand-drawn / sketchy chart aesthetic (rough.js, Excalidraw) has clear appeal and no good grammar-native R implementation. The existing R options all sit at one of two wrong layers:

| Project | Architecture | Why it leaves the gap open |
|---|---|---|
| `ggrough` (xvrdm) | Converts a finished ggplot → SVG via svglite → re-draws in an HTML Canvas with rough.js (an htmlwidget). | Post-hoc conversion, not geoms. The maintainer himself marks it **dormant**, says it "doesn't work with recent releases of {ggplot2}," and states "a nice way to create sketchy visualisations would be a neat addition to the {ggplot2} ecosystem" — the incumbent author is conceding the gap. Source: https://github.com/xvrdm/ggrough and https://xvrdm.github.io/ggrough/ (fetched this session). Also: HTML-only output, breaks static PDF/PNG, one-plot-per-page bug reported by users. |
| `roughnet`, `roughsf` (schochastics) | rough.js via htmlwidget, domain-specific (igraph networks; sf maps). | Not ggplot2 geoms; narrow domains; JS round-trip. Sources: https://github.com/schochastics/roughnet, https://github.com/schochastics/roughsf (fetched this session). |
| `xkcd` (ToledoEM) | Native ggplot2 geoms, but font+jitter aesthetic only; narrow surface (`geom_xkcdpath`, `xkcdman`, etc.); requires installing the XKCD font; uses `Hmisc::bezier`. | A different (XKCD) look, not the rough.js hachure/double-stroke vocabulary; no hachure fills; small geom set. Sources: https://github.com/ToledoEM/xkcd, https://cran.r-project.org/web/packages/xkcd/index.html (fetched this session). |

**The gap, precisely:** *the rough.js sketch aesthetic (roughened strokes, double-pass, bowing, hachure/cross-hatch/zigzag/dots fills) implemented as pure-R `grid` grobs wrapped in first-class `ggproto` geoms* — composable with `aes()`, stats, scales, faceting, and rendering on every R graphics device (PDF/PNG/SVG/screen) with no browser. No existing package occupies this layer.

### Naming (D-01)
`ggrough` is taken (CRAN-adjacent, GitHub, dormant). Candidates: `ggsketch`, `ggsketchy`, `roughr`, `ggdoodle`, `gghanddrawn`. P0 research task R-01 verifies CRAN + GitHub availability and picks. README must clearly state this is an independent reimplementation, not affiliated with rough.js/ggrough. Working name `ggsketch` used throughout this bundle.

---

## 2. Source-verified algorithm foundation

The rough.js algorithms are documented by their author (Preet Shihn) in "How to emulate hand-drawn shapes / Algorithms behind RoughJS" (https://shihn.ca/posts/2020/roughjs-algorithms/, fetched this session), itself based on the academic paper Wood et al., *Sketchy rendering for information visualization* (giCentre / City University London; referenced in that post). The behavior to reimplement, per the fetched source:

- **Roughness (core primitive):** every point is replaced by a random point within a circle around it; the circle's area is controlled by a numeric `roughness` value. (Source above.)
- **Lines:** randomize the two endpoints by roughness; pick two further random points near the 50% and 75% marks along the line; connect by a curve to produce the *bowing* effect. Lines are drawn **twice** for the sketchy double-stroke. Offset randomness scales with line length, with a **dampening step-function** at longer lengths so big shapes don't look rougher than small ones. (Source above.)
- **Ellipses/circles:** estimate `n` points around the ellipse (n grows with size — auto-adjust to avoid the quadratic roughening artifact); randomize each by roughness; fit a curve through them; deliberately don't close the loop perfectly (second-to-last point joins toward the 2nd/3rd point) for the "ends don't meet" effect; draw a second overlaid ellipse. (Source above.)
- **Hachure fill (scan-line):** fill any polygon with parallel sketch lines using a **scan-line / Active-Edge-Table algorithm** (full pseudocode reproduced in the source: global Edge Table sorted by ymin then xmin; Active Edge Table; step the scanline by the hachure gap; fill between x-pairs; update x by inverse slope). For an arbitrary **hachure angle**, rotate the shape by the angle, scan horizontally, rotate the resulting lines back. Each hachure line is itself drawn with the rough line algorithm. (Source above, including the reproduced AET pseudocode.)
- **Derived fills:** *cross-hatch* = hachure at `angle` then again at `angle + 90°`; *zig-zag* = connect each hachure line to the previous; *dots* = tiny circles sampled along hachure lines. (Source above.)
- **Curves:** points → cubic Bézier curve fitting; randomize endpoints+control points by roughness. To **fill** curves, flatten the curve to a polygon (sample via the cubic Bézier equation; decide sampling by a *flatness/tolerance* test, splitting curvy sections and treating flat sections as lines; reduce points with Ramer–Douglas–Peucker by a `distance` parameter), then scan-line fill. (Source above.)
- **Paths:** normalize SVG-path operations to Move / Line / Cubic-Curve, then apply the line/curve techniques. (Source above; not required for v1 — see scope.)

**Reproducibility addition (ours, not rough.js):** a `seed` parameter feeding a deterministic RNG, so a given plot renders identically across runs/devices/resizes. This is essential for reports, tests, and visual regression and is the most important deviation from rough.js's stateless randomness.

### Licensing (the requested check — verified)
rough.js is **MIT, © Preet Shihn** (confirmed: npm `roughjs` 4.6.6 MIT, and `rough/package.json` `"license":"MIT"` — https://github.com/rough-stuff/rough/blob/master/package.json and https://www.npmjs.com/package/roughjs, both fetched/observed this session). Its helper libs `hachure-fill` and `points-on-path` are also MIT (same author). **We do not vendor or translate rough.js source.** We reimplement the published *algorithms* (above) from scratch in R. Even though MIT would permit porting, clean-room reimplementation is the chosen posture (ADR-0003); `DESCRIPTION` and a `NOTICE`/README credit rough.js and the Wood et al. paper as the algorithmic inspiration without copying code. No JavaScript ships in this package.

---

## 3. Architecture

### 3.1 Three-layer design (DECIDED — ADR-0001)

A strict separation that makes the hard part testable in isolation and keeps the package pure-R:

```
┌──────────────────────────────────────────────────────────────┐
│ Layer 3 — ggproto geoms   geom_sketch_*(): Geom* objects,     │  depends on Layer 2
│                           constructors, draw_key, default_aes  │
├──────────────────────────────────────────────────────────────┤
│ Layer 2 — grid grobs      sketchGrob() with makeContent():     │  depends on Layer 1
│                           re-roughens at actual render         │
│                           resolution on draw/resize            │
├──────────────────────────────────────────────────────────────┤
│ Layer 1 — sketch core     PURE geometry, zero ggplot2/grid     │  no deps
│                           knowledge: roughen_polyline(),       │
│                           rough_ellipse(), hachure_fill(),      │
│                           rough_bezier(), seeded RNG,           │
│                           dampening, RDP, scan-line AET         │
└──────────────────────────────────────────────────────────────┘
```

- **Layer 1** is the genuine novel R contribution and the bulk of the testing effort. It takes plain numeric coordinates (in a normalized space) + parameters and returns plain coordinate lists for strokes and fill-lines. It is unit-tested with golden numeric fixtures and property tests — **no rendering required**. Implemented in vectorized base R; a `{cpp11}` reimplementation of the hot paths (scan-line, point roughening) is an OPTIONAL later optimization (D-06), never a v1 requirement, so the package stays `NeedsCompilation: no` for v1.
- **Layer 2** wraps Layer 1 in `grid` grobs using a `makeContent()` method so roughening is computed at the true device resolution each draw (this is what keeps strokes looking right at any size and on resize — the analog of rough.js's auto-adjust). Grob carries the resolved seed so content is stable.
- **Layer 3** is thin: each geom's `draw_panel`/`draw_group` calls `coord$transform()` then hands native-space coordinates to a Layer-2 grob. This is the standard documented ggplot2 extension path (`ggproto` from `Geom`, override `draw_panel`/`draw_group`, transform via `coord$transform`, emit grid grobs — sources: https://ggplot2.tidyverse.org/reference/Geom.html and https://ggplot2.tidyverse.org/articles/extending-ggplot2.html, fetched this session).

### 3.2 ggplot2 version policy (DECIDED — ADR-0002)

Target **ggplot2 ≥ 3.5** and test against **4.0** in CI. The `ggproto`/`Geom`/`draw_panel`/`coord$transform`/grid-grob API is stable across the 3.x→4.0 boundary, but 4.0 changed internals (e.g. `layout$panel_params` handling) that have already broken some extensions — see tidyverse/ggplot2 issue #6753 (fetched this session). Therefore: use `linewidth` (not `size`) per the 3.4.0 convention (source: https://www.tidyverse.org/blog/2022/08/ggplot2-3-4-0-size-to-linewidth/, fetched this session); pin nothing to private internals; CI matrix runs both the 3.5.x release and 4.0.x to catch drift; any 4.0-only breakage gets a guarded shim, not a fork.

### 3.3 Coordinate & resolution model

Roughening must happen in **device/inch space**, not data space, or the sketch offsets would distort with aspect ratio and axis scales. Pipeline per draw: ggplot maps & stats → `draw_*` receives data → `coord$transform()` to [0,1] panel space → Layer-2 grob, in `makeContent()`, converts to absolute units (inches) via `grid::convertX/Y`, runs Layer-1 roughening in inch space, builds the final stroke/fill grobs. Documented invariant (T-CORE-05): the same logical shape at two physical sizes shows visually consistent roughness (the dampening function is calibrated in inch space).

### 3.4 Seed & reproducibility model

`options(ggsketch.seed=)` global default; per-layer `seed=` arg overrides. The grob stores its seed; `makeContent()` seeds a local RNG stream (independent of the global `.Random.seed`, restored after — never disturbs the user's RNG; T-CORE-06). Re-draw/resize with the same seed reproduces identical geometry up to the resolution conversion (T-CORE-07).

### 3.5 Aesthetic surface

Sketch parameters are exposed both as layer params (constant per layer) and, where meaningful, mappable aesthetics:
- Core params: `roughness` (default 1), `bowing` (default 1), `n_passes` (stroke passes, default 2), `seed`.
- Fill params: `fill_style = c("hachure","cross_hatch","zigzag","zigzag_line","dots","dashed","solid")`, `hachure_angle` (deg), `hachure_gap`, `fill_weight` (fill-line linewidth).
- Standard ggplot2 aesthetics respected: `colour`, `fill`, `linewidth`, `linetype`, `alpha`, plus geom-specific (`size` for points, etc.).
- A `theme_sketch()` + `element_*` sketchy panel/grid/axis treatment, and a handwriting-font helper that is **optional** (Suggests-level via `systemfonts`/`ragg`) with graceful fallback to the default device font — explicitly avoiding `xkcd`'s hard font dependency (ADR-0005).

---

## 4. Geom inventory and phasing (summary; authoritative tasks in BUILD_PLAN.md)

Selection prioritizes demo wow-factor per unit effort and hardening the shared core early. "Fill" = needs Layer-1 scan-line fill.

### Phase 0 — Infrastructure & verification
Skeleton; CI matrix (3 OS × ggplot2 3.5 + 4.0); testthat + vdiffr harness; research tasks (name D-01; confirm ggplot2 4.0 `draw_panel` panel_params behavior with a probe). No geoms yet.

### Phase 1 — Sketch core (Layer 1) — the foundation
Pure-geometry engine, no rendering: seeded RNG stream; `roughen_point()`; `roughen_polyline()` (endpoint + 50%/75% randomization, double-pass, length-based dampening step function); `rough_ellipse()` (size-adaptive n, open-loop, double-pass); cubic-Bézier sampling + flatness/tolerance split + RDP reduction; scan-line **hachure_fill()** via Active-Edge-Table (handles convex AND concave polygons — the rough.js bug-class the source calls out); angle support via rotate→scan→rotate-back; derived fills (cross_hatch, zigzag, zigzag_line, dots, dashed). Golden numeric fixtures + property tests. **This phase is the bulk of the package's correctness risk and gets the most tests.**

### Phase 2 — grid grob layer (Layer 2) + first geoms
`sketchGrob()` with `makeContent()` (inch-space conversion, seed-stable); `geom_sketch_line()` / `geom_sketch_path()` (roughened polylines); `geom_sketch_point()` (rough small ellipses or sketchy marker); `theme_sketch()`. Exit = a real sketchy line+point plot renders identically in PNG (ragg) and PDF.

### Phase 3 — Filled rectangular geoms (the signature look)
`geom_sketch_col()` / `geom_sketch_bar()` / `geom_sketch_rect()` / `geom_sketch_tile()` with hachure & derived fills — the most recognizable rough.js output and the headline demo. `draw_key` legends rendered sketchy too. Bar charts with hachure fill are the hero image.

### Phase 4 — Polygons, areas, ribbons, smooths
`geom_sketch_polygon()` (concave-safe fill), `geom_sketch_area()`, `geom_sketch_ribbon()`, `geom_sketch_density()`, `geom_sketch_smooth()` (sketchy fitted line + optional rough ribbon). Curve-fill path (flatten→scan-line) exercised here.

### Phase 5 — Circular & misc geoms
`geom_sketch_point(shape=)` variants, `geom_sketch_circle()`/`geom_sketch_ellipse()` (annotation-style, radius aesthetic), `geom_sketch_segment()`, `geom_sketch_step()`, `geom_sketch_boxplot()` (composed: rough rects + whisker lines), `annotate_sketch()` helper. `draw_key` polish across all.

### Phase 6 — Theming, fonts, polish, release
`theme_sketch()` full element set (sketchy panel border/gridlines/axis ticks as rough grobs); optional handwriting-font integration via `systemfonts` (Suggests) with fallback + diagnostic; palette helpers; pkgdown gallery (every geom, light + a dark variant); performance pass (Layer-1 vectorization; optional cpp11 spike D-06); CRAN.

### Explicitly out of scope for v1
- SVG-path roughening (`geom_sketch` over arbitrary path-d strings) — v2.
- `sf`/map geoms (covered by `roughsf`; ADR-0007 keeps Layer 1 reusable if revisited).
- Interactive/animated sketch jitter — v2.
- Stats beyond what geoms need (no novel `stat_*` in v1; geoms use existing stats like `stat_smooth`, `stat_bin`).

---

## 5. Acceptance criteria

1. **AC-1 (look)** Each filled geom's hachure/cross-hatch/zigzag/dots output matches a locked `vdiffr` snapshot and passes human review against rough.js reference imagery (subjective sign-off recorded per geom).
2. **AC-2 (grammar-native)** Every geom composes correctly with: `aes()` mappings incl. colour/fill/linewidth/alpha; `facet_wrap`/`facet_grid`; continuous & discrete scales; `coord_cartesian` and at least `coord_flip` (documented behavior under `coord_polar` even if degraded). Verified by rendered snapshots.
3. **AC-3 (devices)** Identical seed → visually consistent output across ragg PNG, grDevices PNG, PDF, and svglite SVG (snapshot per device; geometry stable modulo rasterization).
4. **AC-4 (reproducibility)** Same `seed` → byte-identical Layer-1 geometry across runs and R sessions; rendering twice yields identical vdiffr snapshot; user's global `.Random.seed` is never modified (asserted).
5. **AC-5 (core correctness)** Layer-1 scan-line fill covers convex and concave polygons with no overflow outside the boundary (geometric assertion on fill-line containment within an epsilon); hachure angle/gap/weight behave per spec.
6. **AC-6 (version)** Full test suite green on ggplot2 3.5.x release AND 4.0.x, 3 OS.
7. **AC-7 (purity & check)** Zero-NOTE `R CMD check --as-cran`; `NeedsCompilation: no` for v1; no JavaScript in the package; hard deps minimal (ggplot2, grid, rlang, scales, cli, withr).
8. **AC-8 (performance)** A 50-bar hachure-filled bar chart and a 500-point sketch-point plot each render in < 1.5 s on reference hardware (benchmark harness; advisory threshold).
9. **AC-9 (independence/attribution)** No rough.js code present; README/NOTICE credit rough.js (MIT) and Wood et al. as algorithmic inspiration; non-affiliation stated.

---

## 6. Risks

1. **Concave-polygon fill correctness** — the rough.js source explicitly flags this as a historical bug class. Mitigation: implement the full Active-Edge-Table scan-line (not a naive even-odd ray test), with a dedicated concave-shape fixture suite (AC-5) before any geom uses fill.
2. **Resolution/aspect distortion** — roughening in the wrong coordinate space ruins the look. Mitigation: inch-space roughening in `makeContent()` (§3.3), dampening calibrated in inches, snapshot tests at multiple `fig.asp`.
3. **ggplot2 4.0 internals drift** — issue #6753 shows real breakage. Mitigation: public-API-only; CI on both versions; guarded shims.
4. **vdiffr snapshot fragility** — randomized output + font/AA differences across platforms make naive image snapshots flaky. Mitigation: fixed seed everywhere; snapshot Layer-1 *geometry* (deterministic numbers) as the primary regression gate, with vdiffr image snapshots secondary and tolerance-tuned; document the SVG-based vdiffr approach.
4. **Performance of scan-line fill in pure R** — many fill lines × many bars. Mitigation: vectorize Layer 1; budget (AC-8); cpp11 hot-path spike reserved (D-06) without making v1 compiled.
5. **Name/identity confusion with `ggrough`** — Mitigation: distinct name (D-01) + explicit positioning in README ("native geoms, no browser, works on all devices") vs the dormant converter.

---

## 7. References (verified by web_fetch this session)

- rough.js algorithm description (author Preet Shihn; includes scan-line AET pseudocode, line/ellipse/curve/fill techniques, Wood et al. paper reference): https://shihn.ca/posts/2020/roughjs-algorithms/
- rough.js license MIT (package.json): https://github.com/rough-stuff/rough/blob/master/package.json
- rough.js npm (v4.6.6, MIT): https://www.npmjs.com/package/roughjs
- Incumbent `ggrough` (dormant; maintainer concedes the gap): https://github.com/xvrdm/ggrough and https://xvrdm.github.io/ggrough/
- Domain-specific rough.js R wrappers: https://github.com/schochastics/roughnet , https://github.com/schochastics/roughsf
- Native XKCD-style geoms (different aesthetic, font-dependent): https://github.com/ToledoEM/xkcd , https://cran.r-project.org/web/packages/xkcd/index.html
- ggplot2 Geom extension reference: https://ggplot2.tidyverse.org/reference/Geom.html
- ggplot2 extending vignette: https://ggplot2.tidyverse.org/articles/extending-ggplot2.html
- ggplot2 4.0 ggproto-translation breakage report: https://github.com/tidyverse/ggplot2/issues/6753
- linewidth-not-size convention (3.4.0): https://www.tidyverse.org/blog/2022/08/ggplot2-3-4-0-size-to-linewidth/
- htmlwidgets createWidget (for context on why NOT to use the widget route): https://rdrr.io/cran/htmlwidgets/man/createWidget.html

**Unverified this session (flagged):** Wood et al. paper contents (referenced via the rough.js post, not fetched directly); exact ggplot2 4.0 `panel_params` shape (resolve via P0 probe); `xkcd`/`ggrough`/`reactable` characterizations beyond the fetched pages (community consensus). Architecture and phasing are engineering judgment unless cited above.
