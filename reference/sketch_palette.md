# The ggsketch qualitative colour palette

Eight muted ink-on-paper colours led by the package primary (Carolina
blue, `#7BAFD4`), ordered for maximal separation.

## Usage

``` r
sketch_palette(n = NULL)
```

## Arguments

- n:

  Number of colours to return (max 8). If `NULL`, all are returned.

## Value

A character vector of hex colours.

## See also

Other sketch-theme:
[`element_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md),
[`ggsketch_check_fonts()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_check_fonts.md),
[`register_sketch_font()`](https://orijitghosh.github.io/ggsketch/reference/register_sketch_font.md),
[`scale_sketch`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md),
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)

## Examples

``` r
sketch_palette(4)
#> [1] "#7BAFD4" "#C8553D" "#88B398" "#9B6FB0"
```
