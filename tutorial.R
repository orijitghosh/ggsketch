# =============================================================================
#  ggsketch — Interactive Tutorial
# -----------------------------------------------------------------------------
#  Hand-drawn / sketchy geoms for ggplot2, implemented in pure R.
#
#  HOW TO USE THIS FILE IN RSTUDIO
#  --------------------------------
#  Each demo below is a self-contained block separated by a `# ---- Demo N ----`
#  header.  Put your cursor anywhere inside a block and press:
#
#       Ctrl+Enter   (Win/Linux)   /   Cmd+Enter (macOS)   -> run one line
#       Ctrl+Alt+T                  -> run the current code "section"
#
#  ...and the plot appears in the RStudio **Plots** pane on the right.
#  Or just click "Source" to run everything and flip through the plots with
#  the blue back/forward arrows in the Plots pane.
#
#  Every demo uses an explicit `seed = ` so the wobble is reproducible: rerun
#  and you get the exact same hand-drawn strokes.  Change the seed for a new
#  "draw" of the same data.
# =============================================================================

# ---- Setup ------------------------------------------------------------------
# If ggsketch isn't installed yet, from the package root run:
#     devtools::install()    (or:  R CMD INSTALL .)

library(ggplot2)
library(ggsketch)

# A global default seed for any geom that doesn't set one explicitly:
options(ggsketch.seed = 1L)


# ---- Demo 1: the "hello world" sketch line ----------------------------------
# geom_sketch_line() is geom_line() with a hand-drawn wobble + double stroke.

ggplot(economics, aes(date, unemploy)) +
  geom_sketch_line(colour = "steelblue", linewidth = 0.8, seed = 1L) +
  labs(title = "US unemployment", subtitle = "geom_sketch_line()") +
  theme_sketch()


# ---- Demo 2: roughness dial -------------------------------------------------
# `roughness` controls how far points are jittered. 0 = ruler-straight.
# Compare four levels on the same data side by side.

rough_df <- do.call(rbind, lapply(c(0, 0.5, 1.5, 3), function(r) {
  data.frame(x = 1:20, y = cumsum(rnorm(20, 0, 0)) + sin(1:20),
             roughness = factor(paste0("roughness = ", r)))
}))
# (deterministic y, varies only by the geom's roughness param below)
rough_df$y <- rep(sin(seq(0, 4 * pi, length.out = 20)), 4)

ggplot(rough_df, aes(x, y)) +
  geom_sketch_line(linewidth = 0.7, seed = 7L) +
  facet_wrap(~roughness) +
  labs(title = "Turning the roughness dial",
       subtitle = "same data, increasing wobble") +
  theme_sketch()
# NOTE: to actually vary roughness per panel you'd pass roughness= per layer;
# this panel grid is just to show the data. See Demo 3 for the real comparison.


# ---- Demo 3: roughness, the honest comparison -------------------------------
# Stack four explicit layers, each with its own roughness, on a clean series.

base <- data.frame(x = seq(0, 10, length.out = 40))
base$y <- sin(base$x)

ggplot(base, aes(x, y)) +
  geom_sketch_line(aes(colour = "0.0 (straight)"), roughness = 0,   seed = 2) +
  geom_sketch_line(aes(colour = "0.8"),            roughness = 0.8, seed = 2) +
  geom_sketch_line(aes(colour = "2.0"),            roughness = 2.0, seed = 2) +
  geom_sketch_line(aes(colour = "4.0 (loose)"),    roughness = 4.0, seed = 2) +
  scale_colour_brewer("roughness", palette = "Set1") +
  labs(title = "Roughness from tight to loose") +
  theme_sketch()


# ---- Demo 4: sketchy scatter points -----------------------------------------
# geom_sketch_point() draws each point as a small roughened ellipse.

ggplot(mtcars, aes(wt, mpg, colour = factor(cyl))) +
  geom_sketch_point(size = 4, roughness = 0.6, seed = 5) +
  scale_colour_brewer("cylinders", palette = "Dark2") +
  labs(title = "Fuel economy vs weight",
       subtitle = "geom_sketch_point()") +
  theme_sketch()


# ---- Demo 5: line + points together -----------------------------------------
# Sketch geoms compose like any ggplot2 layer.

df5 <- data.frame(x = 1:12, y = c(3, 5, 4, 7, 6, 9, 8, 11, 9, 12, 11, 14))

ggplot(df5, aes(x, y)) +
  geom_sketch_line(colour = "grey40", linewidth = 0.7, seed = 3) +
  geom_sketch_point(size = 4, colour = "firebrick", seed = 8) +
  labs(title = "Trend with markers") +
  theme_sketch()


# ---- Demo 6: the hero geom — sketchy bars -----------------------------------
# geom_sketch_col(): roughened outline + hachure (pencil-shading) fill.

sales <- data.frame(
  product = c("Alpha", "Bravo", "Charlie", "Delta", "Echo"),
  units   = c(34, 51, 22, 47, 39)
)

ggplot(sales, aes(product, units)) +
  geom_sketch_col(fill = "#7BAFD4", seed = 1) +
  labs(title = "Units sold by product",
       subtitle = "geom_sketch_col() with hachure fill") +
  theme_sketch()


# ---- Demo 7: every fill style -----------------------------------------------
# fill_style supports: hachure, cross_hatch, zigzag, zigzag_line, dots,
#                      dashed, solid.

styles <- c("hachure", "cross_hatch", "zigzag", "dots", "dashed", "solid")
fill_df <- do.call(rbind, lapply(styles, function(s) {
  data.frame(style = s, x = c("A", "B", "C"), y = c(4, 6, 3))
}))
fill_df$style <- factor(fill_df$style, levels = styles)

# One panel per style — note fill_style is a *parameter*, set per layer,
# so we build the plot by looping styles into a faceted frame:
library(grid)  # for grid.draw fallback if needed

plots7 <- lapply(styles, function(s) {
  ggplot(subset(fill_df, style == s), aes(x, y)) +
    geom_sketch_col(fill = "#E8A87C", fill_style = s, seed = 4) +
    labs(title = s) +
    theme_sketch(base_size = 9)
})
# Print them one at a time (flip through with the Plots-pane arrows):
for (p in plots7) print(p)


# ---- Demo 8: hachure angle & gap --------------------------------------------
# hachure_angle rotates the shading; hachure_gap sets line spacing (data units).

ggplot(sales, aes(product, units)) +
  geom_sketch_col(fill = "seagreen", fill_style = "hachure",
                  hachure_angle = -30, hachure_gap = 1.5, seed = 1) +
  labs(title = "Steeper, tighter hachure",
       subtitle = "hachure_angle = -30, hachure_gap = 1.5") +
  theme_sketch()


# ---- Demo 9: cross-hatch shading --------------------------------------------

ggplot(sales, aes(product, units, fill = product)) +
  geom_sketch_col(fill_style = "cross_hatch", seed = 6,
                  show.legend = FALSE) +
  scale_fill_brewer(palette = "Pastel1") +
  labs(title = "Cross-hatched bars") +
  theme_sketch()


# ---- Demo 10: bar chart from raw counts (geom_sketch_bar) -------------------
# geom_sketch_bar() counts rows for you, like geom_bar().

ggplot(mpg, aes(class)) +
  geom_sketch_bar(fill = "#C39BD3", seed = 2) +
  labs(title = "Vehicle count by class",
       subtitle = "geom_sketch_bar() with stat = 'count'") +
  theme_sketch() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))


# ---- Demo 11: faceting --------------------------------------------------------
# Sketch geoms respect facets, scales, and coords out of the box.

ggplot(mpg, aes(displ, hwy)) +
  geom_sketch_point(size = 2.5, roughness = 0.5, colour = "#34495E",
                    seed = 9) +
  facet_wrap(~drv, labeller = label_both) +
  labs(title = "Highway mpg vs displacement, by drivetrain") +
  theme_sketch()


# ---- Demo 12: coord_flip ----------------------------------------------------
# Roughening happens in device-inch space, so flipped coords stay crisp.

ggplot(sales, aes(reorder(product, units), units)) +
  geom_sketch_col(fill = "#F1948A", seed = 3) +
  coord_flip() +
  labs(title = "Horizontal sketch bars", x = NULL) +
  theme_sketch()


# ---- Demo 13: same seed = same drawing; new seed = new drawing --------------
# Reproducibility demo. Left/middle identical (seed 10); right differs (seed 99)

d13 <- data.frame(x = 1:8, y = c(2, 5, 3, 8, 6, 9, 7, 10))
print(ggplot(d13, aes(x, y)) + geom_sketch_line(seed = 10) +
        labs(title = "seed = 10 (run A)") + theme_sketch())
print(ggplot(d13, aes(x, y)) + geom_sketch_line(seed = 10) +
        labs(title = "seed = 10 (run B — identical)") + theme_sketch())
print(ggplot(d13, aes(x, y)) + geom_sketch_line(seed = 99) +
        labs(title = "seed = 99 (different wobble)") + theme_sketch())


# ---- Demo 14: a "polished" composite figure ---------------------------------
# Putting it together: titled, themed, multi-layer.

set.seed(123)
econ <- data.frame(
  month = factor(month.abb, levels = month.abb),
  rev   = round(runif(12, 20, 80))
)

ggplot(econ, aes(month, rev)) +
  geom_sketch_col(fill = "#85C1E9", fill_style = "hachure",
                  hachure_angle = 60, seed = 1) +
  geom_sketch_point(aes(y = rev), size = 3, colour = "#1B4F72", seed = 12) +
  labs(title = "Monthly revenue",
       subtitle = "hand-drawn bars + markers, ggsketch",
       x = NULL, y = "revenue ($k)",
       caption = "rendered with ggsketch — pure-R rough.js aesthetic") +
  theme_sketch(base_size = 12)


# =============================================================================
#  Cheat sheet
# -----------------------------------------------------------------------------
#  GEOMS
#    geom_sketch_line(...)    hand-drawn line (sorted by x)
#    geom_sketch_path(...)    hand-drawn path (data order)
#    geom_sketch_point(...)   roughened-ellipse points
#    geom_sketch_col(...)     bars from values (stat = "identity")
#    geom_sketch_bar(...)     bars from counts (stat = "count")
#
#  SHARED SKETCH PARAMETERS (set per layer)
#    roughness   non-negative; 0 = straight, ~1 default, >3 = loose
#    bowing      how much segments bow outward (default 1)
#    n_passes    number of overlaid strokes (default 2 = "double stroke")
#    seed        integer for reproducible wobble
#
#  FILL PARAMETERS (geom_sketch_col / _bar)
#    fill_style    "hachure" | "cross_hatch" | "zigzag" | "zigzag_line" |
#                  "dots" | "dashed" | "solid"
#    hachure_angle shading angle in degrees (default 45)
#    hachure_gap   spacing between fill lines, in data units
#    fill_weight   stroke weight of fill lines (default 0.5)
#
#  THEME
#    theme_sketch(base_size = 11, base_family = "")   paper-toned companion theme
#
#  Set a session-wide default seed with:  options(ggsketch.seed = <int>)
# =============================================================================
