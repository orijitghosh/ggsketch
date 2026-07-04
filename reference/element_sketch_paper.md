# Paper-ground theme element

A panel-background element that paints a simulated paper texture behind
the data: ruled notebook lines, a graph grid, a dot grid, aged blotches,
or a blueprint / chalkboard / kraft ground. Use it as `panel.background`
in
[`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html),
or – more simply – via `theme_sketch(paper = )`. Everything is drawn as
vector primitives, so it reproduces on every device.

## Usage

``` r
element_sketch_paper(kind = "notebook", ground = NULL, seed = NULL, ...)
```

## Arguments

- kind:

  A paper from
  [`sketch_papers()`](https://orijitghosh.github.io/ggsketch/reference/sketch_papers.md).

- ground:

  Optional override for the ground (fill) colour.

- seed:

  Integer seed for the aged blotches.

- ...:

  Passed to
  [`ggplot2::element_rect()`](https://ggplot2.tidyverse.org/reference/element.html).

## Value

A ggplot2 theme element carrying an `element_sketch_paper` subclass.

## See also

Other sketch-paper:
[`paper_grain()`](https://orijitghosh.github.io/ggsketch/reference/paper_grain.md),
[`paper_primitives()`](https://orijitghosh.github.io/ggsketch/reference/paper_primitives.md),
[`paper_spec()`](https://orijitghosh.github.io/ggsketch/reference/paper_spec.md),
[`sketch_papers()`](https://orijitghosh.github.io/ggsketch/reference/sketch_papers.md)

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_sketch_point(seed = 1L) +
  theme_sketch() +
  theme(panel.background = element_sketch_paper("graph"))
```
