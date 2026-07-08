# Boil a gganimate animation (sketch wobble + data transitions)

Render a gganimate animation - any plot built with ggsketch geoms plus a
`transition_*()` - so that, on top of gganimate's data tweening, the
hand-drawn lines *boil*: every roughening seed is shifted once per
frame, so the drawing shimmers and re-draws itself like a hand-animated
cel while the bars grow, points fly, or a line draws itself along `x`.
It is the moving-data companion to
[`animate_sketch()`](https://orijitghosh.github.io/ggsketch/reference/animate_sketch.md),
which boils a static plot.

## Usage

``` r
boil_gganimate(
  animation,
  nframes = 100L,
  fps = 10,
  intensity = 1,
  detail = 1L,
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

- animation:

  A gganimate animation: a ggplot using ggsketch geoms with a
  `transition_*()` added (class `gganim`).

- nframes:

  Number of frames. Default 100 (gganimate's default).

- fps:

  Frames per second in the output. Default 10.

- intensity:

  Boil strength: scales how far the seed jitter steps each frame. 1
  (default) matches
  [`animate_sketch()`](https://orijitghosh.github.io/ggsketch/reference/animate_sketch.md);
  higher shimmers more.

- detail:

  Tween sub-frames per frame, passed through to gganimate's prerender
  for smoother motion (rendered frames are sampled back down to
  `nframes`). Default 1.

- file:

  Output path (e.g. a `.gif`). If `NULL` (default), no file is written
  and the frame paths are returned invisibly.

- width, height, units, res:

  Frame size and resolution. `units` one of `"in"`, `"cm"`, `"mm"`,
  `"px"`.

- background:

  Frame background colour. Default `"white"`.

- device:

  Graphics device: `NULL` (default; `"ragg"` when installed, else
  `"png"`), `"ragg"`/`"png"`, or any device string gganimate accepts
  (`"ragg_png"`, `"svglite"`, ...).

- seed:

  Integer offset for the boil sequence (`NULL` = 0, so frame 1 is
  un-boiled). Change it to vary the shimmer without touching the plot.

- renderer:

  GIF backend: `"auto"` (default), `"gifski"`, `"magick"`, or `"none"`
  (always return frame paths).

- loop:

  Loop the output forever? Default `TRUE`.

## Value

Invisibly, the output path (when written) or a character vector of frame
image paths.

## Details

The boil rides on the global `ggsketch.seed_jitter` option (the same
lever
[`animate_sketch()`](https://orijitghosh.github.io/ggsketch/reference/animate_sketch.md)
uses), advanced by a per-frame counter so frame 1 is the un-boiled
drawing and the whole animation is reproducible. Frames are stitched
with the same backend as
[`animate_sketch()`](https://orijitghosh.github.io/ggsketch/reference/animate_sketch.md)
(gifski or magick); if neither is installed the frame paths are
returned. gganimate itself is an optional dependency.

## See also

[`animate_sketch()`](https://orijitghosh.github.io/ggsketch/reference/animate_sketch.md)
for boiling or drawing-on a static plot.

## Examples

``` r
# \donttest{
library(ggplot2)
library(gganimate)
p <- ggplot(mpg, aes(class, fill = drv)) +
  geom_sketch_bar(position = "dodge", seed = 1L) +
  scale_fill_sketch() +
  theme_sketch() +
  transition_states(drv, transition_length = 2, state_length = 1)
boil_gganimate(p, nframes = 30, file = tempfile(fileext = ".gif"))
# }
```
