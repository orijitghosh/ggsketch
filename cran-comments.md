## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission (the package is not currently on CRAN).

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
* The `boil_gganimate` example is wrapped in `\donttest{}` and guarded with
  `@examplesIf requireNamespace(...)` because it renders a GIF animation via the
  suggested 'gganimate' and 'gifski' packages (slow, and only runnable when
  those are installed). No `\dontrun{}` is used anywhere in the package. The
  function is also exercised by the test suite.

## Previous review feedback

An earlier version (1.6.0) received review comments but was not published.
This submission addresses them:

* Added missing `\value` documentation to all exported functions (e.g.
  `geom_sketch_density`), describing the class and meaning of each return.
* Replaced `\dontrun{}` with `\donttest{}` (the `boil_gganimate` example above);
  the other flagged examples (`geom_sketch_text`, `register_sketch_font`) now
  run unwrapped.

## Downstream dependencies

There are currently no downstream dependencies.
