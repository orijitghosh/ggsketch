# Palette + layout spec for a paper ground

Pure data: the ground colour, a suggested ink colour, whether the ground
is dark (so text should flip light), and the ruling/grid/dot layout.

## Usage

``` r
paper_spec(kind)
```

## Arguments

- kind:

  A value from
  [`sketch_papers()`](https://orijitghosh.github.io/ggsketch/reference/sketch_papers.md).

## Value

A named list describing the paper, or `NULL` for `"none"`.

## See also

Other sketch-paper:
[`element_sketch_paper()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_paper.md),
[`paper_grain()`](https://orijitghosh.github.io/ggsketch/reference/paper_grain.md),
[`paper_primitives()`](https://orijitghosh.github.io/ggsketch/reference/paper_primitives.md),
[`sketch_papers()`](https://orijitghosh.github.io/ggsketch/reference/sketch_papers.md)
