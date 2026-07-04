# Build the vector primitives for a paper ground

Turns a
[`paper_spec()`](https://orijitghosh.github.io/ggsketch/reference/paper_spec.md)
into draw-ready primitives in npc coordinates, spaced for the given
physical panel size. The grob layer
([`element_sketch_paper()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_paper.md))
renders the result; this function stays free of any `grid` dependency.

## Usage

``` r
paper_primitives(kind, width_in = 6, height_in = 4, seed = NULL)
```

## Arguments

- kind:

  A value from
  [`sketch_papers()`](https://orijitghosh.github.io/ggsketch/reference/sketch_papers.md).

- width_in, height_in:

  Panel size in inches (sets the ruling pitch).

- seed:

  Integer seed (for aged blotches).

## Value

A list with `ground` (fill colour) and zero or more of `segs` (a list of
homogeneous line groups, each `list(x0, y0, x1, y1, colour, lwd)`),
`dots` (`list(x, y, r_in, colour)`), and `blotches` (a list of
`list(x, y, fill)` polygons), or `NULL` for `"none"`.

## See also

Other sketch-paper:
[`element_sketch_paper()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_paper.md),
[`paper_grain()`](https://orijitghosh.github.io/ggsketch/reference/paper_grain.md),
[`paper_spec()`](https://orijitghosh.github.io/ggsketch/reference/paper_spec.md),
[`sketch_papers()`](https://orijitghosh.github.io/ggsketch/reference/sketch_papers.md)
