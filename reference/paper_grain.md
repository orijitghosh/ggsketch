# Wash-feathering grain factor for a paper ground

How toothy a
[`sketch_papers()`](https://orijitghosh.github.io/ggsketch/reference/sketch_papers.md)
ground is, as a number a watercolour wash uses to feather its edges (the
`grain` argument of
[`watercolor_wash()`](https://orijitghosh.github.io/ggsketch/reference/watercolor_wash.md)).
Smooth grounds wick little; rough grounds (aged, kraft) wick a lot.
Smooth, machine papers (notebook / graph / dotted) sit low; the textured
grounds climb toward

1.  `theme_sketch(paper = )` reads this so washes drawn on a paper pick
    up its tooth automatically.

## Usage

``` r
paper_grain(kind)
```

## Arguments

- kind:

  A value from
  [`sketch_papers()`](https://orijitghosh.github.io/ggsketch/reference/sketch_papers.md).

## Value

A numeric grain factor in `[0, 1]` (0 for `"none"`).

## See also

Other sketch-paper:
[`element_sketch_paper()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_paper.md),
[`paper_primitives()`](https://orijitghosh.github.io/ggsketch/reference/paper_primitives.md),
[`paper_spec()`](https://orijitghosh.github.io/ggsketch/reference/paper_spec.md),
[`sketch_papers()`](https://orijitghosh.github.io/ggsketch/reference/sketch_papers.md)

## Examples

``` r
paper_grain("kraft")
#> [1] 1
paper_grain("graph")
#> [1] 0.15
```
