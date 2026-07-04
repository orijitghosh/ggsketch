# Register a handwriting font for reproducible sketch text

Registers a font file under a family name with systemfonts so that
[`geom_sketch_text()`](https://orijitghosh.github.io/ggsketch/reference/geom_sketch_text.md),
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)
(`base_family = "auto"`), and the font resolver can find it on
font-aware devices (ragg, svglite, cairo) without installing the font
system-wide. Call it once per session (e.g. in a script or `.Rprofile`);
ship the `.ttf`/`.otf` alongside your project for fully reproducible
output.

## Usage

``` r
register_sketch_font(
  family,
  plain,
  bold = plain,
  italic = plain,
  bolditalic = plain,
  ...
)
```

## Arguments

- family:

  Family name to register the font under (e.g. `"Caveat"`). This is the
  name you then pass to `family =` or `base_family =`.

- plain:

  Path to the regular/plain font file (`.ttf` or `.otf`).

- bold, italic, bolditalic:

  Optional paths to the bold/italic faces; default to `plain`.

- ...:

  Passed to
  [`systemfonts::register_font()`](https://systemfonts.r-lib.org/reference/register_font.html).

## Value

Invisibly, the registered `family` name.

## See also

Other sketch-theme:
[`CoordSketch`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch.md),
[`CoordSketchPolar`](https://orijitghosh.github.io/ggsketch/reference/coord_sketch_polar.md),
[`element_sketch_line()`](https://orijitghosh.github.io/ggsketch/reference/element_sketch_line.md),
[`ggsketch_check_fonts()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_check_fonts.md),
[`ggsketch_save()`](https://orijitghosh.github.io/ggsketch/reference/ggsketch_save.md),
[`scale_pressure_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_pressure_continuous.md),
[`scale_roughness_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_roughness_continuous.md),
[`scale_sketch`](https://orijitghosh.github.io/ggsketch/reference/scale_sketch.md),
[`scale_tone_continuous()`](https://orijitghosh.github.io/ggsketch/reference/scale_tone_continuous.md),
[`sketch_palette()`](https://orijitghosh.github.io/ggsketch/reference/sketch_palette.md),
[`theme_sketch()`](https://orijitghosh.github.io/ggsketch/reference/theme_sketch.md)

## Examples

``` r
# Register any font file under a family name you choose. Here we reuse a font
# already on the system; in practice point `plain` at a handwriting .ttf/.otf
# (e.g. Caveat from Google Fonts).
f <- systemfonts::system_fonts()$path[1]
register_sketch_font("MySketchFont", f)
#> ✔ Registered font family "MySketchFont".
```
