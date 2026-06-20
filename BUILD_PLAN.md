# BUILD_PLAN.md — `{ggsketch}` Phased Build Plan

Authoritative task list. Tick per DEVELOPMENT.md §1. Invariant IDs → TESTING.md. `⏱` = time-box (work sessions). Phase manifests state the only allowed `DESCRIPTION` Imports additions. **Layer order is enforced (DEVELOPMENT.md §1): Phase 1 = Layer 1, Phase 2 = Layer 2 + first geoms, Phases 3-5 = more Layer 3.**

---

## Phase 0 — Infrastructure & verification ⏱ 3
Imports manifest: ggplot2, grid, rlang, scales, cli, withr.

- [x] P0-T1 Package skeleton, MIT license, `inst/NOTICE` (rough.js + Wood et al. credit, non-affiliation), CI matrix (3 OS × ggplot2 3.5 release + 4.0).
- [x] P0-T2 Test harness: testthat; vdiffr wired with svglite writer + tolerance config; geometry-snapshot helper (`expect_snapshot_geometry()` that serializes Layer-1 numeric output deterministically); lint workflow incl. the Layer-purity check (T-ARCH-01).
- [x] P0-R1 Name decision (D-01): CRAN + GitHub availability scan for `ggsketch`/alternates; record in ADR-0008. _(Repo reservation pending first push — not yet a git repo.)_
- [x] P0-R2 ggplot2 4.0 probe: `tools/probes/ggplot2-4-panelparams.R` renders a trivial custom geom under 3.5 and 4.0; record the observed `draw_panel(data, panel_params, coord)` contract and any `panel_params` differences (ref issue #6753) in ADR-0002.
- [x] P0-T3 Skeleton smoke: a do-nothing `GeomSketchNull` returning `grid::nullGrob()` builds and checks zero-NOTE on both ggplot2 versions.

**Exit:** CI green on both ggplot2 versions; zero-NOTE; harnesses proven; ADR-0002 and ADR-0008 Accepted.

---

## Phase 1 — Sketch core (Layer 1, PURE geometry) ⏱ 10
Imports additions: none. **This is the correctness heart of the package; most tests live here.**

- [x] P1-T1 `specs/roughen.md`: line + ellipse + curve math, dampening step-function, all citing rough.js source sections. Review gate.
- [x] P1-T2 `core-rng.R`: seeded local RNG stream helpers (withr-based); guarantee no global `.Random.seed` mutation (T-CORE-06).
- [x] P1-T3 `roughen_point()` + `roughen_polyline()`: endpoint + 50%/75% randomization, bowing curve, `n_passes` double-stroke, length-based dampening calibrated to a reference unit. Golden geometry fixtures (T-CORE-01).
- [x] P1-T4 `rough_ellipse()`: size-adaptive point count `n`, open-loop "ends don't meet," double overlay. Fixtures incl. scale-invariance check (T-CORE-02).
- [x] P1-T5 Cubic-Bézier sampling + flatness/tolerance split + Ramer–Douglas–Peucker reduction (`distance` param). `rough_bezier()` for sketchy curves. (T-CORE-03)
- [x] P1-T6 `specs/hachure.md`: Active-Edge-Table scan-line pseudocode (from source), angle rotate→scan→rotate-back, derived styles. Review gate.
- [x] P1-T7 `hachure_fill()`: full AET scan-line; **convex AND concave** polygons with containment guarantee; `hachure_angle`/`hachure_gap`/`fill_weight`. Concave fixture suite is mandatory (T-CORE-04, AC-5).
- [x] P1-T8 Derived fill styles from hachure: `cross_hatch` (angle + angle+90°), `zigzag`, `zigzag_line`, `dots` (circles sampled along lines), `dashed`, `solid` passthrough. (T-CORE-08)
- [x] P1-T9 Curve-fill bridge: flatten curve→polygon→scan-line fill (for area/ribbon/density later). (T-CORE-09)
- [x] P1-T10 Property tests: determinism per seed; roughness=0 ⇒ exact original geometry; offsets bounded by roughness radius; fill lines ⊂ polygon (+ε). (T-CORE-07, AC-4, AC-5)

**Exit:** every Layer-1 invariant green; concave fill proven; zero ggplot2/grid symbols in `core-*.R` (T-ARCH-01); no geom code yet; tag v0.0.1 (internal).

---

## Phase 2 — Grob layer (Layer 2) + first geoms ⏱ 7
Imports additions: none.

- [x] P2-T1 `grob-sketch.R`: `sketch_path_grob()` / `sketch_polygon_grob()` with `makeContent()` — inch-space conversion via `convertX/Y`, call Layer 1, build `polylineGrob`/`pathGrob`/`polygonGrob` (+ fill lines as a child polylineGrob); seed stored on grob; stable across resize. (T-GROB-01..03)
- [x] P2-T2 `specs/geom-contract.md`: the shared default_aes, param list, `draw_key` contract, constructor signature every geom follows. Review gate.
- [x] P2-T3 `geom_sketch_path()` / `geom_sketch_line()`: `draw_group` → coord$transform → Layer-2 path grob; respects colour/linewidth/linetype/alpha; `draw_key_path`. (T-GEOM-line)
- [x] P2-T4 `geom_sketch_point()`: rough small marker (ellipse-based or sketchy shape); `size` aesthetic; `draw_key_point`. (T-GEOM-point)
- [x] P2-T5 `theme_sketch()` v1 (typography + panel basics; sketchy elements deferred to Phase 6).
- [x] P2-T6 Device matrix snapshot: a line+point plot renders consistently across ragg PNG, grDevices PNG, PDF, svglite (AC-3); multi-aspect snapshots (Risk 2 / T-CORE-05). _(`test-device-matrix.R`)_

**Exit:** AC-3 + AC-4 hold for line/point; both ggplot2 versions green; tag v0.1.0.

---

## Phase 3 — Filled rectangular geoms (signature look) ⏱ 7
Imports additions: none.

- [x] P3-T1 `geom_sketch_rect()` / `geom_sketch_tile()`: hachure-filled rects via Layer-1 fill + rough outline. (T-GEOM-rect) _(`test-geom-rect.R`)_
- [x] P3-T2 `geom_sketch_col()` / `geom_sketch_bar()` (`stat_count`): the hero geom; all fill styles; per-bar seed offset so bars don't look identical; sketchy `draw_key` swatches. (T-GEOM-col, AC-1) _(`test-geom-col.R`)_
- [x] P3-T3 Fill-style coverage snapshots: each of hachure/cross_hatch/zigzag/zigzag_line/dots/dashed/solid on a bar — geometry snapshots locked (`test-fill-style-coverage.R`). _vdiffr image + human sign-off vs `tools/reference-imagery/` deferred to Phase 6 (T-LOOK-01)._
- [x] P3-T4 `coord_flip` + faceting + discrete/continuous fill scale composition snapshots. (AC-2) _(`test-composition.R`)_

**Exit:** AC-1 (rect/col) + AC-2 green; tag v0.2.0; first CRAN dry-run (`--as-cran`) clean.

---

## Phase 4 — Polygons, areas, ribbons, smooths ⏱ 8

- [x] P4-T1 `geom_sketch_polygon()`: concave-safe hachure fill + rough outline (exercises P1-T7 hard). (T-GEOM-poly) _(`test-geom-polygon.R`; concave-star fill verified)_
- [x] P4-T2 `geom_sketch_area()` / `geom_sketch_ribbon()`: curve-fill bridge (P1-T9). (T-GEOM-area) _(`test-geom-area.R`)_
- [x] P4-T3 `geom_sketch_density()` (`stat_density`). _(`test-geom-area.R`)_
- [x] P4-T4 `geom_sketch_smooth()`: sketchy fitted line + optional rough confidence ribbon (`stat_smooth`). _(`test-geom-smooth.R`)_
- [x] P4-T5 Composition snapshots across the above; performance check on filled areas (AC-8). _(`tools/bench/run.R` — all renders < 0.35 s vs 1.5 s budget)_

**Exit:** AC gates green; tag v0.3.0.

---

## Phase 5 — Circular & composed geoms ⏱ 7

- [x] P5-T1 `geom_sketch_circle()` / `geom_sketch_ellipse()` (radius aesthetic, annotation-style). _(`test-geom-circle.R`; scales expand to fit radius via `setup_data` xmin/xmax/ymin/ymax)_
- [x] P5-T2 `geom_sketch_segment()` / `geom_sketch_step()`. _(`test-geom-segment.R`; step supports `direction = "hv"`/`"vh"`)_
- [x] P5-T3 `geom_sketch_boxplot()`: composed rough rects + whisker/median lines (`stat_boxplot`). _(`test-geom-boxplot.R`; rough IQR box + thick median + whiskers + sketch outlier points)_
- [x] P5-T4 `annotate_sketch()` helper for sketchy annotation layers. _(`R/annotate-sketch.R`, `test-annotate.R`; dispatches to point/line/path/segment/rect/polygon/circle/ellipse)_
- [x] P5-T5 `draw_key` audit across the full geom set (legends all render sketchy and correct). _(`R/draw-key.R`: `draw_key_sketch_path`/`_point`/`_polygon`; wired into every geom; `test-draw-key.R`)_

**Exit:** AC gates green; tag v0.4.0.

---

## Phase 6 — Theming, fonts, polish, release ⏱ 6

- [x] P6-T1 `theme_sketch()`: light + dark presets, paper/ink palette, full element styling, `base_family="auto"` font resolution. _(`test-theme.R`)_ _Rough-grob theme elements (gridlines/border as sketch grobs) deferred to v1.1 — needs custom `element_grob` S3 methods; not release-blocking._
- [x] P6-T2 Optional handwriting font: `systemfonts` integration (Suggests) with graceful fallback + `ggsketch_check_fonts()` + `resolve_sketch_font()`; never a hard dependency (ADR-0005). _(T-DEV-03 in `test-theme.R`)_
- [x] P6-T3 Palette + scale helpers — **cut** (ADR-0011): `fill_style` lives on the geom; users compose existing `scale_fill_*`. No new scale exports.
- [x] P6-T4 Performance pass vs AC-8; benchmark recorded; **no cpp11 needed** (ADR-0006 addendum). _(`tools/bench/run.R`)_
- [x] P6-T5 Docs: README (positioning vs ggrough, non-affiliation, hero image), `vignettes/ggsketch.Rmd` intro, `_pkgdown.yml`. _Standalone `gallery.Rmd` folded into the intro vignette + README; expand in v1.1._
- [x] P6-T6 Cross-platform vdiffr review: `test-vdiffr.R` (12 baselines, seed 42); Linux CI documented as snapshot source of truth (header note + cran-comments).
- [x] P6-T7 NEWS.md, cran-comments.md, README, version 1.0.0, hero image. _(GIF deferred — optional launch asset, not release-blocking.)_

**Exit:** `R CMD check --as-cran` clean (2 environmental NOTEs only: clock-sync + unpublished URLs); full suite green on local R 4.4.3 / ggplot2 4.0.3. **Remaining for actual CRAN release (needs the repo pushed): both-version CI run (AC-6), pkgdown deploy, `devtools::submit_cran()`.**

---

## Cut-line policy
Overrun >50% of a phase ⏱ → flag lowest-priority tasks `defer:v1.1` (never silently dropped). Deferral order: `geom_sketch_boxplot`, `geom_sketch_step`, `zigzag_line`/`dashed` fill styles, `scale_fill_sketch`, dark-theme preset, `annotate_sketch`. Never deferrable: Layer-1 correctness, concave fill (AC-5), reproducibility (AC-4), both-version CI (AC-6).
