## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Test environments

* Local: Windows 11, R 4.4.3, ggplot2 4.0.3
* GitHub Actions (see `.github/workflows/check.yaml`): Linux / macOS / Windows,
  R release, against ggplot2 3.5.x and ggplot2 4.0.x.

## Notes

* `NeedsCompilation: no` — the package is pure R.
* The hand-drawn algorithms are reimplemented in original R from published
  algorithm descriptions; no third-party (rough.js) source code is included.
  See `inst/NOTICE` and the README for attribution and the non-affiliation
  statement.
* Image-based (vdiffr) snapshot tests are skipped on CRAN and on platforms whose
  rendering toolchain differs from the reference; the primary regression gate is
  deterministic numeric geometry snapshots.
* Two help files (`geom_sketch_text`, `register_sketch_font`) use `\dontrun{}`
  because the examples require a handwriting font file installed on the system,
  which is not guaranteed in the check environment. The functions themselves are
  exercised by the test suite.

## Downstream dependencies

There are currently no downstream dependencies.
