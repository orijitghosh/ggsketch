# Sketchy legend keys

`draw_key_*` functions used by the sketch geoms so their legends render
with the same hand-drawn character. Not called directly; passed as the
`draw_key` field of a geom (see
[ggplot2::draw_key](https://ggplot2.tidyverse.org/reference/draw_key.html)).

## Usage

``` r
draw_key_sketch_path(data, params, size)

draw_key_sketch_medium(data, params, size)

draw_key_sketch_point(data, params, size)

draw_key_sketch_polygon(data, params, size)
```

## Arguments

- data:

  A single-row data frame of the key's aesthetics.

- params:

  The layer's parameter list (roughness, seed, fill_style, ...).

- size:

  Key size in mm (unused; kept for the draw_key contract).

## Value

A grid grob.
