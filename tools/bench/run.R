#!/usr/bin/env Rscript
# AC-8 performance harness (T-PERF-01 / T-PERF-02).
# Advisory thresholds (off-CI): see TESTING.md §7.
#   - 50-bar hachure bar chart   < 1.5 s
#   - 500-point sketch-point     < 1.5 s
#   - filled-area plot           within budget (advisory)
# Records wall time to render each plot to a throwaway PNG. Run with:
#   Rscript tools/bench/run.R

suppressMessages({
  library(ggplot2)
  library(ggsketch)
})

time_render <- function(label, p, budget = 1.5) {
  f <- tempfile(fileext = ".png")
  t <- system.time({
    grDevices::png(f, width = 6, height = 4, units = "in", res = 100)
    print(p)
    grDevices::dev.off()
  })[["elapsed"]]
  unlink(f)
  status <- if (t <= budget) "OK " else "SLOW"
  cat(sprintf("[%s] %-28s %6.3f s  (budget %.1fs)\n", status, label, t, budget))
  invisible(t)
}

cat("ggsketch AC-8 benchmark\n")
cat("R", as.character(getRversion()),
    "| ggplot2", as.character(utils::packageVersion("ggplot2")), "\n")
cat(strrep("-", 60), "\n")

set.seed(1)

# 50-bar hachure bar chart
bars <- data.frame(x = factor(seq_len(50)), y = runif(50, 1, 100))
time_render(
  "50-bar hachure col",
  ggplot(bars, aes(x, y)) + geom_sketch_col(seed = 1L) +
    theme_sketch() + theme(axis.text.x = element_blank())
)

# 500-point sketch-point plot
pts <- data.frame(x = rnorm(500), y = rnorm(500))
time_render(
  "500-point sketch points",
  ggplot(pts, aes(x, y)) + geom_sketch_point(size = 2, seed = 1L) +
    theme_sketch()
)

# filled-area plot (curve-fill bridge)
area_df <- data.frame(x = seq(0, 10, length.out = 200))
area_df$y <- 5 + 4 * sin(area_df$x)
time_render(
  "200-pt filled area",
  ggplot(area_df, aes(x, y)) + geom_sketch_area(seed = 1L) + theme_sketch()
)

# concave polygon fill (T-PERF-02 scan-line scaling)
ang  <- seq(0, 2 * pi, length.out = 41)[-41]
r    <- rep(c(1, 0.5), length.out = 40)
star <- data.frame(x = r * cos(ang), y = r * sin(ang))
time_render(
  "40-vertex concave polygon",
  ggplot(star, aes(x, y)) +
    geom_sketch_polygon(hachure_gap = 0.02, seed = 1L) +
    coord_equal() + theme_sketch()
)

cat(strrep("-", 60), "\n")
cat("Note: thresholds are advisory; hardware/env affect absolute times.\n")
