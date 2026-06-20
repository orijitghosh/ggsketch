# DEVELOPMENT.md — contributor guide for {ggsketch}

These are the engineering conventions for the package. When a rule
conflicts with convenience, the rule wins. When two rules conflict, stop
and record an open item in `DECISIONS.md`.

## 1. Phase discipline

- Strict phase order; no Phase N+1 work before Phase N exit criteria are
  green. **Layer order is sacred: Layer 1 (core) is fully built and
  tested before Layer 2 (grobs), which is built before Layer 3
  (geoms).** A geom may never implement roughening logic directly — only
  through Layer 1.
- “Done” = code + roxygen + tests + cited invariants passing + zero-NOTE
  `devtools::check()` + checkbox ticked with a commit reference.

## 2. Hard rules

- **R1 Zero-NOTE** `R CMD check --as-cran` at every checkbox commit;
  Imports grow only per the BUILD_PLAN phase manifest.
  **`NeedsCompilation: no` for all of v1** (no C/C++; cpp11 is a post-v1
  spike only).
- **R2 Clean-room implementation (license posture, ADR-0003):** never
  vendor, copy, or line-by-line translate rough.js / hachure-fill /
  points-on-path source. Reimplement the *published algorithms* (PRD §2,
  sourced from <https://shihn.ca/posts/2020/roughjs-algorithms/>) in
  original R. No JavaScript ships. README + `inst/NOTICE` credit
  rough.js (MIT) and Wood et al. as inspiration; state non-affiliation.
- **R3 Layer purity:** Layer 1 (`R/core-*.R`) imports nothing from
  ggplot2 or grid and performs no drawing — it maps numbers→numbers. Any
  drawing or unit conversion lives in Layer 2+. CI lint asserts no
  `grid::`/`ggplot2::` symbols in `R/core-*.R` (T-ARCH-01).
- **R4 Roughen in inch space, never data space.** All point displacement
  and dampening happen after conversion to absolute units inside
  `makeContent()`. A geom that roughens in native/data units is a defect
  (T-CORE-05).
- **R5 Determinism:** every randomized routine draws from a seeded local
  RNG stream via
  [`withr::with_seed()`](https://withr.r-lib.org/reference/with_seed.html)
  (or an explicit stream); it must restore and never mutate the user’s
  global `.Random.seed` (T-CORE-06). No bare `runif`/`rnorm` in package
  code.
- **R6 Public ggplot2 API only:** extend via `ggproto`/`Geom`,
  `draw_panel`/`draw_group`, `coord$transform`, `draw_key`, documented
  `layer()` construction. Never touch private internals
  (`layout$panel_params` shape, etc.) without a guarded shim and a
  version check; CI tests ggplot2 3.5 AND 4.0.
- **R7 `linewidth` not `size`** for line widths (3.4.0 convention);
  points use `size`. Match ggplot2’s default_aes conventions exactly so
  layers compose.
- **R8 Snapshot discipline:** the PRIMARY regression gate is
  deterministic Layer-1 *geometry* snapshots (numbers), not images.
  vdiffr image snapshots are secondary, fixed-seed, tolerance-tuned.
  Update either only with a `SNAPSHOT-UPDATE:` commit trailer explaining
  the intended visual change.
- **R9 Never edit generated docs** (`man/`, `NAMESPACE`); edit roxygen
  and run `devtools::document()`.
- **R10 Upstream claims need provenance:** any algorithmic or API claim
  in specs/ADRs cites a source URL or is marked `UNVERIFIED:`. The PRD
  §7 list is the standing source set. Where ggplot2 4.0 behavior is
  uncertain, write a probe under `tools/probes/` and record observed
  behavior (“observed with ggplot2 X.Y.Z”), never “documented.”

## 3. Repository layout (fixed)

    ggsketch/
    ├── R/
    │   ├── core-rng.R core-roughen.R core-ellipse.R core-bezier.R
    │   ├── core-hachure.R core-fill-styles.R           # Layer 1 — PURE, no grid/ggplot2
    │   ├── grob-sketch.R                                # Layer 2 — makeContent grobs
    │   ├── geom-sketch-line.R geom-sketch-col.R ...     # Layer 3 — one geom family per file
    │   ├── theme-sketch.R aes-params.R draw-key.R
    │   ├── utils-checks.R zzz.R
    ├── specs/         hachure.md roughen.md geom-contract.md
    ├── tests/testthat/
    │   ├── _snaps/                                      # geometry + vdiffr snapshots
    │   ├── test-core-*.R test-grob-*.R test-geom-*.R
    ├── tools/         probes/  bench/  reference-imagery/
    ├── vignettes/     ggsketch.Rmd
    ├── inst/          NOTICE
    └── .github/workflows/  check.yaml  (matrix: ggplot2 3.5 + 4.0)  vdiffr.yaml  lint.yaml  pkgdown.yaml

## 4. Code style

- **R:** tidyverse style; `rlang`/`cli` for argument checking + errors
  ([`cli::cli_abort`](https://cli.r-lib.org/reference/cli_abort.html));
  one geom family per file; `@family` roxygen groups; runnable
  `@examples`; constructors follow the canonical
  `geom_*(mapping, data, stat, position, ..., na.rm, show.legend, inherit.aes)`
  shape.
- **Layer 1 functions** are plain, side-effect-free, fully typed in
  docs, and individually benchmarkable.
- Naming: geoms `geom_sketch_<thing>`; params `roughness`, `bowing`,
  `n_passes`, `fill_style`, `hachure_angle`, `hachure_gap`,
  `fill_weight`, `seed`; theme
  [`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md);
  core fns `roughen_*`, `rough_*`, `hachure_fill`.

## 5. Canonical commands

    Rscript -e 'devtools::document(); devtools::test()'
    Rscript -e 'devtools::check(args = "--as-cran")'
    Rscript -e 'vdiffr::manage_cases()'        # review image snapshots
    Rscript tools/bench/run.R                   # AC-8 harness
    Rscript tools/probes/ggplot2-4-panelparams.R   # version-behavior probe

CI runs the suite twice: once with the ggplot2 3.5.x release, once with
4.0.x.

## 6. Spec-first work

`specs/<name>.md` is completed + reviewed before implementing:
`roughen.md` (line/ellipse/curve math + dampening), `hachure.md`
(scan-line AET, angle rotation, derived styles), `geom-contract.md` (the
shared default_aes/param/draw_key contract every geom follows). Each
spec cites the source section it implements (R10) and lists the fixture
cases.

## 7. Escalation

Stop and write an open DECISIONS.md entry when: R2 (license posture)
would be strained; a probe shows ggplot2 4.0 needs private internals;
concave-fill correctness can’t meet AC-5 with the chosen algorithm; a
dependency seems unavoidable; or an acceptance criterion is unmeasurable
as written.

## 8. Commits

Conventional commits (`feat(core): hachure scan-line`,
`feat(geom): geom_sketch_col`, `test(core): concave fill fixtures`);
every checkbox commit references its task ID (e.g. `P3-T2`).
