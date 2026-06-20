# DECISIONS.md — `{ggsketch}` Architecture Decision Records

Format: ID · Title · Status (Accepted / Open / Superseded) · Decision · Rationale · Consequences. Contributors must not contradict Accepted ADRs; Open ADRs are settled at the indicated task and recorded here.

---

## ADR-0001 · Three-layer architecture (pure core / grobs / geoms) — Status: **Accepted**
**Decision:** Strictly separate Layer 1 (pure-geometry sketch core, no ggplot2/grid), Layer 2 (`grid` grobs with `makeContent()`), Layer 3 (`ggproto` geoms). Layer order is built and tested in sequence.
**Rationale:** The hard, novel, defect-prone part (roughening + scan-line fill) becomes testable as deterministic number-in/number-out functions with zero rendering — the only way to get reliable regression coverage on randomized graphics. Layer 2's `makeContent()` is what lets roughening happen at true render resolution (the analog of rough.js's size auto-adjust). Layer 3 stays thin and follows the documented ggplot2 extension contract (https://ggplot2.tidyverse.org/reference/Geom.html, fetched during planning).
**Consequences:** A geom may never roughen directly; CI enforces Layer-1 purity (T-ARCH-01). Reuse for future `sf`/network variants is free (Layer 1 is domain-agnostic).

## ADR-0002 · D-02 ggplot2 version floor & dual-version CI — Status: **Accepted (probe-confirmed at P0-R2)**
**Decision:** Support ggplot2 ≥ 3.5; CI matrix tests 3.5.x release AND 4.0.x. Use only the public extension API; `linewidth` not `size` for lines.
**Rationale:** The extension surface (`ggproto`/`Geom`/`draw_panel`/`draw_group`/`coord$transform`/grid grobs) is stable across 3.x→4.0, but 4.0 changed internals that have broken extensions in practice — tidyverse/ggplot2 #6753 shows `layout$panel_params` differences (fetched during planning). `linewidth` is the post-3.4.0 convention (https://www.tidyverse.org/blog/2022/08/ggplot2-3-4-0-size-to-linewidth/, fetched). Dual-version CI is the cheapest insurance against silent drift.
**Consequences:** No private-internal use without a guarded, version-checked shim; the P0-R2 probe's recorded contract is re-run in CI (T-VER-02).

**P0-R2 probe result — observed with ggplot2 4.0.3 (2026-06-19):**
- `panel_params` names in ggplot2 4.0.3: `x, x.sec, x.range, y, y.sec, y.range, reverse, guides`
- `panel_params$x.range` is directly accessible (numeric vector of data limits)
- `coord$transform(data, panel_params)` returns a data.frame; `x` and `y` columns are in [0,1] npc panel space
- `class(coord)` for `coord_cartesian()`: `CoordCartesian, Coord, ggproto, gg`
- No private internals needed for the standard extension path; `coord$transform` contract is stable

## ADR-0003 · License posture: reimplement, never port rough.js — Status: **Accepted**
**Decision:** Reimplement the published rough.js *algorithms* (PRD §2, from https://shihn.ca/posts/2020/roughjs-algorithms/, fetched during planning) in original R. Do not vendor, copy, or line-by-line translate rough.js / hachure-fill / points-on-path source. No JavaScript in the package. Credit rough.js (MIT, © Preet Shihn — confirmed via https://github.com/rough-stuff/rough/blob/master/package.json and npm, fetched during planning) and Wood et al. in `inst/NOTICE` + README; state non-affiliation.
**Rationale:** rough.js's MIT license would permit porting, but clean-room reimplementation from the algorithm description avoids any derivative-work entanglement, produces idiomatic vectorized R, and keeps the package `NeedsCompilation: no` and JS-free. The algorithm post is detailed enough (incl. AET pseudocode) to implement from.
**Consequences:** Slightly more work than translating; CI greps for rough.js identifiers to enforce (T-PKG-04).

## ADR-0004 · Reproducible seeded randomness (the key deviation from rough.js) — Status: **Accepted**
**Decision:** A `seed` parameter (global option + per-layer override) feeds a local RNG stream via `withr`; the grob stores its seed; the user's global `.Random.seed` is never mutated.
**Rationale:** rough.js randomness is stateless/non-reproducible; that's unacceptable for reports, tests, and visual regression. Deterministic geometry is also what makes the PRIMARY test gate (geometry snapshots) possible. RNG hygiene prevents surprising side effects on user analyses.
**Consequences:** Every randomized routine routes through the seeded stream (DEVELOPMENT.md R5); no bare `runif`/`rnorm`.

## ADR-0005 · Fonts are optional, not required — Status: **Accepted**
**Decision:** Handwriting-font support is a Suggests-level convenience (`systemfonts`/`ragg`) with graceful fallback to the default device font and a `ggsketch_check_fonts()` diagnostic. The sketch *look* comes from geometry (roughened strokes/fills), not the font.
**Rationale:** `xkcd`'s hard font dependency is its biggest friction point (must download/register a TTF or plots look wrong). Decoupling the aesthetic from fonts makes `ggsketch` work out of the box on any device.
**Consequences:** Text in plots is sketchy-styled only if a suitable font is present; documented clearly.

## ADR-0006 · D-06 Performance: pure R now, cpp11 only if needed — Status: **Open (settle at P6-T4)**
**Decision pending:** v1 is pure, vectorized R (`NeedsCompilation: no`). If AC-8 benchmarks fail, spike a `{cpp11}` reimplementation of the hot paths (scan-line AET, point roughening) and re-decide — but only if the budget is actually missed.
**Rationale:** Keep v1 simple, dependency-light, and CRAN-trivial; optimize only with evidence. Layer-1 purity means a later C++ swap is localized and testable against the same geometry fixtures.

## ADR-0007 · Domain scope: charts only in v1 — Status: **Accepted (excludes sf/networks)**
**Decision:** v1 covers ggplot2 statistical geoms. `sf`/map and network sketching are out of scope (served by `roughsf`/`roughnet`). Layer 1 is kept domain-agnostic so a future `geom_sketch_sf()` could reuse it.
**Rationale:** Focus; avoid competing on the domains already covered while occupying the empty grammar-native-geoms niche.

## ADR-0008 · D-01 Package name — Status: **Accepted (settled at P0-R1, 2026-06-19)**
**Decision:** `ggsketch` — confirmed not on CRAN (no package of that name in CRAN package list); no active GitHub repo occupying `ggsketch` in the ggplot2-extension space. Name clearly signals "native ggplot2 sketch geoms," is distinct from `ggrough` (dormant JS wrapper), `roughnet`, `roughsf` (domain-specific JS wrappers), and `xkcd` (different aesthetic). README and `inst/NOTICE` state non-affiliation with rough.js and ggrough.
**Non-affiliation statement (to appear in README):** "ggsketch is an independent R package reimplementing the hand-drawn sketch aesthetic from first principles. It is not affiliated with, derived from, or endorsed by the rough.js project, ggrough, or any related JavaScript libraries."

## ADR-0009 · Geometry snapshots as the primary regression gate — Status: **Accepted**
**Decision:** Deterministic Layer-1 geometry snapshots (serialized numbers) are the primary visual-regression gate; vdiffr image snapshots are secondary, fixed-seed, Linux-CI-sourced, tolerance-tuned.
**Rationale:** Randomized image output varies by platform/AA/font and makes naive image diffs flaky. Geometry is deterministic given a seed (ADR-0004), so it gives a stable, meaningful gate; images then serve human-facing look checks (AC-1).
**Consequences:** Test helper `expect_snapshot_geometry()` is built in P0; image snapshots never the sole gate for a correctness property (DEVELOPMENT.md R8).

## ADR-0010 · No novel stats in v1 — Status: **Accepted**
**Decision:** Geoms reuse existing ggplot2 stats (`stat_identity`, `stat_count`, `stat_bin`, `stat_smooth`, `stat_density`, `stat_boxplot`). No custom `stat_*` ships in v1.
**Rationale:** The package's value is the *rendering* aesthetic, not new statistical transforms; reusing stats maximizes compatibility and minimizes surface area.

## ADR-0011 · `scale_fill_sketch()` cut from v1 (P6-T3) — Status: **Accepted (2026-06-20)**
**Decision:** Do not ship a `scale_fill_sketch()` / `scale_colour_sketch()` convenience scale in v1. Users compose the existing ggplot2 scales (`scale_fill_brewer()`, `scale_fill_viridis_*()`, `scale_fill_manual()`, …) directly; the sketch fill *texture* is controlled per-geom via `fill_style`, which is orthogonal to colour mapping.
**Rationale:** Per the BUILD_PLAN cut-line policy, `scale_fill_sketch` ships only "if it earns its place — else cut." A wrapper over existing scales would add API surface and documentation burden without enabling anything users can't already do. `fill_style` already lives where it belongs (the geom), so a scale would not be the natural home for it.
**Consequences:** No new exports for scales. Revisit in a future minor release only if a concrete need emerges (e.g. mapping a variable to `fill_style`, which would require a genuinely new scale type).

## ADR-0006 addendum · AC-8 settled (P6-T4, 2026-06-20) — Status: **Accepted (pure R; no cpp11)**
**Result:** `tools/bench/run.R` on the reference machine (R 4.4.3, ggplot2 4.0.3): 50-bar hachure col ~0.33 s, 500-point ~0.31 s, 200-pt filled area ~0.11 s, 40-vertex concave polygon ~0.15 s — all well under the 1.5 s AC-8 budget. **No cpp11 spike needed; v1 stays `NeedsCompilation: no`.**
