# TESTING.md — `{ggsketch}` Invariant Catalog

Stable IDs; normative statements; methods: **TT** testthat (logic/geometry) · **GS** geometry snapshot (deterministic Layer-1 numbers — the PRIMARY visual-regression gate) · **VD** vdiffr image snapshot (secondary, fixed-seed, tolerance-tuned) · **CI** dedicated workflow · **BM** benchmark · **HM** human sign-off. BUILD_PLAN tasks cite these. Release ledger §9.

> **Snapshot philosophy (DEVELOPMENT.md R8):** randomized image output is platform-fragile, so correctness is gated primarily on deterministic Layer-1 *geometry* (GS), with vdiffr images (VD) as a secondary human-facing check on Linux CI. Never make VD the sole gate for a correctness property.

## 1. Architecture & package (T-ARCH / T-PKG)
- **T-ARCH-01** Layer purity: `R/core-*.R` contains no `grid::`/`ggplot2::` symbols and no drawing/unit-conversion calls (static-scan lint). [CI]
- **T-ARCH-02** Layer 1 functions are pure: same inputs ⇒ same outputs, no global state touched (incl. `.Random.seed`). [TT]
- **T-PKG-01** Zero-error/warning/NOTE `R CMD check --as-cran`, 3 OS × {ggplot2 3.5 release, 4.0}. [CI]
- **T-PKG-02** `NeedsCompilation: no`; no `src/`; no `.js` files anywhere in the package. [CI grep]
- **T-PKG-03** Imports exactly match the phase manifest; all exports documented with runnable `@examples`. [CI]
- **T-PKG-04** `inst/NOTICE` present, crediting rough.js (MIT) + Wood et al., stating non-affiliation; no rough.js source strings present (grep against known rough.js identifiers). [CI]

## 2. Sketch core — Layer 1 (T-CORE) — the correctness heart
- **T-CORE-01** `roughen_polyline()`: golden geometry fixtures for representative inputs; endpoints/50%/75% displaced within the roughness radius; `n_passes` produces the right number of stroke polylines. [GS]
- **T-CORE-02** `rough_ellipse()`: point count `n` grows with radius (scale-invariance — concentric circles share roughness character); open-loop gap present; double overlay present. [GS + TT]
- **T-CORE-03** Bézier sampling: flatness/tolerance split adds points on curvy sections, RDP removes redundant points on flat sections; output count responds monotonically to `distance`. [GS + TT]
- **T-CORE-04** `hachure_fill()` convex: fill lines parallel at `hachure_angle`, spaced by `hachure_gap`, count matches expected for the shape's extent. [GS]
- **T-CORE-05** Inch-space roughening: the same logical shape rendered at two physical sizes / aspect ratios shows consistent roughness character (dampening calibrated in inches), NOT proportional-to-data distortion. [GS at multiple fig.asp + VD]
- **T-CORE-06** RNG hygiene: every randomized routine restores state; user's global `.Random.seed` is byte-identical before/after any `ggsketch` call (asserted via `withr` snapshot). [TT]
- **T-CORE-07** Determinism: identical `(inputs, seed)` ⇒ byte-identical Layer-1 output across runs and fresh R sessions. [GS + TT]
- **T-CORE-08** Derived fill styles: cross_hatch = two hachure passes at angle and angle+90°; zigzag connects consecutive lines; dots are circles centered along hachure lines; dashed segments hachure lines; solid bypasses. [GS]
- **T-CORE-09** Curve fill: arbitrary curved boundary flattens to a polygon then fills via scan-line with no overflow. [GS + AC-5 containment]
- **T-CORE-10** `roughness = 0` ⇒ output geometry equals the exact input (no displacement) — the identity law. [TT]

## 3. AC-5 fill correctness (T-FILL)
- **T-FILL-01 (concave)** Concave-polygon fixture suite (incl. the rough.js bug-class shapes: stars, arrows, C-shapes): every fill line segment lies inside the polygon within epsilon (point-in-polygon containment on sampled fill points). No segment crosses outside. [TT geometric]
- **T-FILL-02 (self-touching / collinear edges)** Degenerate edges (horizontal edges, vertices on scanlines, collinear runs) handled by the AET without dropped or doubled spans (off-by-one suite). [TT]
- **T-FILL-03 (angle)** Rotated-hachure correctness: fill at angle θ equals fill computed by rotate→horizontal-scan→rotate-back to within epsilon. [TT]
- **T-FILL-04 (holes, v1 policy)** Polygons with holes either fill correctly or fail with a clear documented error (no silent overflow); policy recorded in spec. [TT]

## 4. Grob layer — Layer 2 (T-GROB)
- **T-GROB-01** `makeContent()` produces strokes/fills in correct absolute positions; re-invoking on resize re-roughens at the new size with the SAME seed ⇒ same character, correct scale. [VD at two sizes + GS of intermediate]
- **T-GROB-02** Grob carries and reuses its resolved seed; two draws of the same grob are identical. [VD]
- **T-GROB-03** Fill lines and outline are separate child grobs with correct gpar (fill lines use `fill_weight`; outline uses `linewidth`). [TT grob-tree inspection]

## 5. Geom layer — Layer 3 (T-GEOM)
- **T-GEOM-line / point / rect / col / poly / area** Per-geom: renders with default aes; respects mapped colour/fill/linewidth/alpha/size; correct `draw_key`; constructor matches the canonical signature; `stat`/`position` args work. [VD + TT]
- **T-GEOM-COMPOSE (AC-2)** Each geom composes with `facet_wrap`/`facet_grid`, discrete + continuous scales, `coord_cartesian`, `coord_flip`; documented (possibly degraded) behavior under `coord_polar`. [VD matrix]
- **T-GEOM-KEY** Every legend key renders sketchy and matches the geom's body style. [VD]
- **T-GEOM-EMPTY** Empty data and single-row data don't error (return `zeroGrob()` / minimal grob). [TT]
- **T-GEOM-NA** `na.rm` behavior matches ggplot2 conventions; missing aesthetics handled. [TT]

## 6. Devices & reproducibility (T-DEV)
- **T-DEV-01 (AC-3)** Same seed renders consistently across ragg PNG, grDevices PNG, PDF (grDevices), svglite SVG — geometry stable modulo rasterization; one snapshot per device. [VD per device]
- **T-DEV-02 (AC-4)** Rendering the same plot twice ⇒ identical vdiffr snapshot; Layer-1 geometry byte-identical. [VD + GS]
- **T-DEV-03** Font fallback: with no handwriting font installed, plots render with the default device font and emit at most one informative message, never an error (ADR-0005). [TT]

## 7. Version & performance (T-VER / T-PERF)
- **T-VER-01 (AC-6)** Full suite green on ggplot2 3.5.x release AND 4.0.x (CI runs both); any version-guarded shim is exercised on both. [CI]
- **T-VER-02** The P0-R2 probe's recorded `draw_panel` contract still holds (re-run probe in CI; alert on drift). [CI]
- **T-PERF-01 (AC-8)** 50-bar hachure bar chart < 1.5 s; 500-point sketch-point plot < 1.5 s; filled-area plot within budget — reference hardware, env manifest recorded (advisory threshold off-CI). [BM]
- **T-PERF-02** Scan-line fill scales acceptably: fill time grows ~linearly with (polygon extent / hachure_gap); no pathological blowup on many bars. [BM]

## 8. Look validation (T-LOOK)
- **T-LOOK-01 (AC-1)** Per filled geom × fill style: locked vdiffr snapshot + recorded human sign-off comparing against rough.js reference imagery in `tools/reference-imagery/` (images only, no code). [VD + HM]
- **T-LOOK-02** Dark-mode variant of the gallery renders correctly. [VD]

## 9. Release ledger
At Phase 6 exit produce `tests/LEDGER.md` mapping AC-1..AC-9 and the PRD goals to concrete passing artifacts (test paths, CI runs on both ggplot2 versions, BM results + env manifest, HM sign-off records). Release blocks on a complete ledger and on AC-4/AC-5/AC-6 being green (the non-deferrable set).
