# Sketchy text and labels

`geom_sketch_text()` and `geom_sketch_label()` add text in a handwriting
font, the sketch counterparts of
[`ggplot2::geom_text()`](https://ggplot2.tidyverse.org/reference/geom_text.html)
and
[`ggplot2::geom_label()`](https://ggplot2.tidyverse.org/reference/geom_text.html).
Unlike the other geoms the strokes are not geometrically roughened — the
hand-drawn feel comes from the font (see
[`ggsketch_check_fonts()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_check_fonts.md)
for which faces are available). If no handwriting font is installed they
render with the device default family.

## Usage

``` r
geom_sketch_text(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  family = NULL,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

geom_sketch_label(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  family = NULL,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)
```

## Arguments

- mapping:

  Set of aesthetic mappings created by
  [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html). If
  specified and `inherit.aes = TRUE` (the default), it is combined with
  the default mapping at the top level of the plot. You must supply
  `mapping` if there is no plot mapping.

- data:

  The data to be displayed in this layer. There are three options:

  If `NULL`, the default, the data is inherited from the plot data as
  specified in the call to
  [`ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html).

  A `data.frame`, or other object, will override the plot data. All
  objects will be fortified to produce a data frame. See
  [`fortify()`](https://ggplot2.tidyverse.org/reference/fortify.html)
  for which variables will be created.

  A `function` will be called with a single argument, the plot data. The
  return value must be a `data.frame`, and will be used as the layer
  data. A `function` can be created from a `formula` (e.g.
  `~ head(.x, 10)`).

- stat:

  The statistical transformation to use on the data for this layer. When
  using a `geom_*()` function to construct a layer, the `stat` argument
  can be used to override the default coupling between geoms and stats.
  The `stat` argument accepts the following:

  - A `Stat` ggproto subclass, for example `StatCount`.

  - A string naming the stat. To give the stat as a string, strip the
    function name of the `stat_` prefix. For example, to use
    [`stat_count()`](https://ggplot2.tidyverse.org/reference/geom_bar.html),
    give the stat as `"count"`.

  - For more information and other ways to specify the stat, see the
    [layer
    stat](https://ggplot2.tidyverse.org/reference/layer_stats.html)
    documentation.

- position:

  A position adjustment to use on the data for this layer. This can be
  used in various ways, including to prevent overplotting and improving
  the display. The `position` argument accepts the following:

  - The result of calling a position function, such as
    [`position_jitter()`](https://ggplot2.tidyverse.org/reference/position_jitter.html).
    This method allows for passing extra arguments to the position.

  - A string naming the position adjustment. To give the position as a
    string, strip the function name of the `position_` prefix. For
    example, to use
    [`position_jitter()`](https://ggplot2.tidyverse.org/reference/position_jitter.html),
    give the position as `"jitter"`.

  - For more information and other ways to specify the position, see the
    [layer
    position](https://ggplot2.tidyverse.org/reference/layer_positions.html)
    documentation.

- ...:

  Other arguments passed on to
  [`layer()`](https://ggplot2.tidyverse.org/reference/layer.html)'s
  `params` argument. These arguments broadly fall into one of 4
  categories below. Notably, further arguments to the `position`
  argument, or aesthetics that are required can *not* be passed through
  `...`. Unknown arguments that are not part of the 4 categories below
  are ignored.

  - Static aesthetics that are not mapped to a scale, but are at a fixed
    value and apply to the layer as a whole. For example,
    `colour = "red"` or `linewidth = 3`. The geom's documentation has an
    **Aesthetics** section that lists the available options. The
    'required' aesthetics cannot be passed on to the `params`. Please
    note that while passing unmapped aesthetics as vectors is
    technically possible, the order and required length is not
    guaranteed to be parallel to the input data.

  - When constructing a layer using a `stat_*()` function, the `...`
    argument can be used to pass on parameters to the `geom` part of the
    layer. An example of this is
    `stat_density(geom = "area", outline.type = "both")`. The geom's
    documentation lists which parameters it can accept.

  - Inversely, when constructing a layer using a `geom_*()` function,
    the `...` argument can be used to pass on parameters to the `stat`
    part of the layer. An example of this is
    `geom_area(stat = "density", adjust = 0.5)`. The stat's
    documentation lists which parameters it can accept.

  - The `key_glyph` argument of
    [`layer()`](https://ggplot2.tidyverse.org/reference/layer.html) may
    also be passed on through `...`. This can be one of the functions
    described as [key
    glyphs](https://ggplot2.tidyverse.org/reference/draw_key.html), to
    change the display of the layer in the legend.

- family:

  Font family. By default the first installed handwriting face is used;
  pass an explicit family to override, or `""` for the device default.

- na.rm:

  If `FALSE`, the default, missing values are removed with a warning. If
  `TRUE`, missing values are silently removed.

- show.legend:

  logical. Should this layer be included in the legends? `NA`, the
  default, includes if any aesthetics are mapped. `FALSE` never
  includes, and `TRUE` always includes. It can also be a named logical
  vector to finely select the aesthetics to display. To include legend
  keys for all levels, even when no data exists, use `TRUE`. If `NA`,
  all levels are shown in legend, but unobserved levels are omitted.

- inherit.aes:

  If `FALSE`, overrides the default aesthetics, rather than combining
  with them. This is most useful for helper functions that define both
  data and aesthetics and shouldn't inherit behaviour from the default
  plot specification, e.g.
  [`annotation_borders()`](https://ggplot2.tidyverse.org/reference/annotation_borders.html).

## Value

A `ggplot2` layer object.

## See also

Other sketch-geoms:
[`GeomSketchAbline`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_abline.md),
[`GeomSketchBoxplot`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_boxplot.md),
[`GeomSketchCol`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_col.md),
[`GeomSketchCurve`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_curve.md),
[`GeomSketchEllipse`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_circle.md),
[`GeomSketchHex`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_hex.md),
[`GeomSketchLine`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_line.md),
[`GeomSketchLinerange`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_linerange.md),
[`GeomSketchPath`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_path.md),
[`GeomSketchPoint`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_point.md),
[`GeomSketchPolygon`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_polygon.md),
[`GeomSketchRect`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rect.md),
[`GeomSketchRibbon`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_ribbon.md),
[`GeomSketchRug`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_rug.md),
[`GeomSketchSegment`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_segment.md),
[`GeomSketchSmooth`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_smooth.md),
[`GeomSketchSpoke`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_spoke.md),
[`GeomSketchViolin`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_violin.md),
[`annotate_sketch()`](https://orijitghosh.github.io/ggsketch/reference/annotate_sketch.md),
[`geom_sketch_bin2d()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_bin2d.md),
[`geom_sketch_contour()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_contour.md),
[`geom_sketch_count()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_count.md),
[`geom_sketch_density()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_density.md),
[`geom_sketch_density2d()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_density2d.md),
[`geom_sketch_function()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_function.md),
[`geom_sketch_histogram()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_histogram.md),
[`geom_sketch_jitter()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_jitter.md),
[`geom_sketch_qq()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_qq.md),
[`geom_sketch_quantile()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_quantile.md)

## Examples

``` r
library(ggplot2)
df <- data.frame(x = c(1, 2, 3), y = c(2, 3, 1),
                 lab = c("alpha", "bravo", "charlie"))
ggplot(df, aes(x, y, label = lab)) +
  geom_sketch_text(size = 6) +
  theme_sketch()
```
