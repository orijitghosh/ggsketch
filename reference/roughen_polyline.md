# Roughen a polyline (multiple connected segments)

Converts a multi-vertex polyline into `n_passes` roughened stroke paths.
Each path is a matrix with columns `x` and `y` (inch coordinates). Uses
a seeded local RNG so the user's `.Random.seed` is never mutated
(T-CORE-06).

## Usage

``` r
roughen_polyline(x, y, roughness = 1, bowing = 1, n_passes = 2L, seed = NULL)
```

## Arguments

- x, y:

  Numeric vectors of polyline vertices in inch space. Must have the same
  length \>= 2.

- roughness:

  Non-negative roughness radius (inches at scale). Default 1.

- bowing:

  Non-negative bowing multiplier. Default 1.

- n_passes:

  Positive integer number of stroke passes (default 2).

- seed:

  Integer seed for reproducibility (ADR-0004).

## Value

A list of `n_passes` matrices (columns `x`, `y`), one per pass.

## See also

Other sketch-core:
[`curve_fill()`](https://orijitghosh.github.io/ggsketch/reference/curve_fill.md),
[`hachure_fill()`](https://orijitghosh.github.io/ggsketch/reference/hachure_fill.md),
[`rough_arc()`](https://orijitghosh.github.io/ggsketch/reference/rough_arc.md),
[`rough_bezier()`](https://orijitghosh.github.io/ggsketch/reference/rough_bezier.md),
[`rough_ellipse()`](https://orijitghosh.github.io/ggsketch/reference/rough_ellipse.md),
[`sketch_fill()`](https://orijitghosh.github.io/ggsketch/reference/sketch_fill.md)
