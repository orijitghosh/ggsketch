# The available drawing media

The valid values for the `medium` argument of the path-like sketch
geoms. `"pen"` is the default and reproduces the classic constant-width
double stroke; the others render through the variable-width
[`stroke_ribbon()`](https://orijitghosh.github.io/ggsketch/reference/stroke_ribbon.md)
engine.

## Usage

``` r
sketch_media()
```

## Value

A character vector of medium names.

## See also

Other sketch-media:
[`scale_medium_discrete()`](https://orijitghosh.github.io/ggsketch/reference/scale_medium_discrete.md)

## Examples

``` r
sketch_media()
#>  [1] "pen"          "ink"          "fountain_pen" "ballpoint"    "brush"       
#>  [6] "pencil"       "charcoal"     "pastel"       "chalk"        "marker"      
#> [11] "highlighter"  "crayon"       "spray"       
```
