# Animate a sketch plot by "boiling" its lines

Renders a ggplot built with ggsketch geoms `nframes` times, shifting
every roughening seed by a per-frame amount, so the whole drawing
shimmers and re-draws itself like a hand-animated cel (the "boiling
line" effect). Because the shift is added to *every* resolved seed –
whether a layer set its own `seed` or inherited the global one – a plot
boils without any change to its code. Frame 1 reproduces the static plot
exactly.

## Usage

``` r
animate_sketch(
  plot,
  nframes = 12L,
  fps = 10,
  type = c("boil", "draw_on"),
  direction = c("lr", "rl", "bt", "tb", "diag", "radial"),
  easing = c("linear", "ease_in", "ease_out", "ease_in_out"),
  file = NULL,
  width = 7,
  height = 5,
  units = "in",
  res = 120,
  background = "white",
  device = NULL,
  seed = NULL,
  renderer = c("auto", "gifski", "magick", "none"),
  loop = TRUE
)
```

## Arguments

- plot:

  A ggplot object using ggsketch geoms.

- nframes:

  Number of frames. Default 12.

- fps:

  Frames per second in the output GIF. Default 10.

- type:

  Motion type: `"boil"` (re-seed the wobble each frame so the whole
  drawing shimmers) or `"draw_on"` (progressively reveal the finished
  drawing behind a moving wipe, as if a hand were drawing it).

- direction:

  For `type = "draw_on"`, how the drawing is revealed: a straight wipe
  `"lr"` (left-to-right, default), `"rl"`, `"bt"` (bottom-to-top) or
  `"tb"`; a diagonal wipe `"diag"` (top-left to bottom-right); or
  `"radial"` (a circular iris opening from the centre).

- easing:

  For `type = "draw_on"`, the pacing of the reveal across frames:
  `"linear"` (constant speed, default), `"ease_in"` (start slow),
  `"ease_out"` (end slow), or `"ease_in_out"` (slow at both ends).

- file:

  Output GIF path. If `NULL` (default), no GIF is written and the frame
  paths are returned invisibly.

- width, height, units, res:

  Frame size and resolution, passed to the graphics device (`units` one
  of `"in"`, `"cm"`, `"mm"`, `"px"`).

- background:

  Frame background colour. Default `"white"`.

- device:

  Graphics device: `"ragg"` (default when installed) or `"png"`.

- seed:

  Base seed (`NULL` uses `getOption("ggsketch.seed", 1L)`).

- renderer:

  GIF backend: `"auto"` (default), `"gifski"`, `"magick"`, or `"none"`
  (always return frame paths).

- loop:

  Loop the GIF forever? Default `TRUE`.

## Value

Invisibly, the GIF path (when written) or a character vector of frame
image paths.

## Details

Frames are stitched into a GIF when gifski or magick is installed
(neither is a hard dependency); otherwise the frame image paths are
returned so you can assemble them yourself. Everything is reproducible:
the same `seed` yields the same animation.

## Examples

``` r
# \donttest{
library(ggplot2)
p <- ggplot(mpg, aes(class)) +
  geom_sketch_bar(fill = "#7BAFD4", seed = 1L) +
  theme_sketch()
# Write a GIF if gifski/magick is available, else get frame paths back:
gif <- animate_sketch(p, nframes = 8, file = tempfile(fileext = ".gif"))
# }
```
