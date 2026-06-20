# P0-R2: ggplot2 draw_panel contract probe
# Observes the shape of `data`, `panel_params`, and `coord` as delivered to
# draw_panel under the installed ggplot2 version.
# Run with: Rscript tools/probes/ggplot2-4-panelparams.R
# Record observed behavior in DECISIONS.md (ADR-0002).

suppressPackageStartupMessages({
  library(ggplot2)
  library(grid)
})

cat("ggplot2 version:", as.character(packageVersion("ggplot2")), "\n")

# ------------------------------------------------------------------
# Probe geom: captures and prints the contract received by draw_panel
# ------------------------------------------------------------------
ProbeGeom <- ggproto("ProbeGeom", Geom,
  required_aes = c("x", "y"),
  default_aes = aes(colour = "black", size = 1, linetype = 1,
                    alpha = NA, shape = 19, fill = NA, stroke = 0.5),
  draw_key = draw_key_point,
  draw_panel = function(data, panel_params, coord) {
    cat("\n--- draw_panel() contract probe ---\n")
    cat("class(data):", paste(class(data), collapse = ", "), "\n")
    cat("names(panel_params):", paste(names(panel_params), collapse = ", "), "\n")
    cat("class(panel_params):", paste(class(panel_params), collapse = ", "), "\n")
    cat("class(coord):", paste(class(coord), collapse = ", "), "\n")

    # Test coord$transform
    transformed <- coord$transform(data, panel_params)
    cat("coord$transform() works:", is.data.frame(transformed), "\n")
    cat("transformed names:", paste(names(transformed), collapse = ", "), "\n")
    cat("x range after transform:", range(transformed$x), "\n")
    cat("y range after transform:", range(transformed$y), "\n")

    # Test that x.range / y.range are available (3.5 vs 4.0 location)
    xr <- panel_params$x.range %||% panel_params[["x"]]$limits %||% NULL
    cat("x.range accessible:", !is.null(xr), "\n")
    if (!is.null(xr)) cat("x.range value:", xr, "\n")

    nullGrob()
  }
)

`%||%` <- function(a, b) if (is.null(a)) b else a

geom_probe <- function(mapping = NULL, data = NULL,
                        stat = "identity", position = "identity",
                        ..., na.rm = FALSE, show.legend = NA,
                        inherit.aes = TRUE) {
  layer(
    data = data, mapping = mapping,
    stat = stat, geom = ProbeGeom,
    position = position,
    show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}

# Render a trivial plot to trigger draw_panel
set.seed(1)
df <- data.frame(x = 1:5, y = c(2, 1, 4, 3, 5))
p <- ggplot(df, aes(x, y)) + geom_probe()
png(tempfile(fileext = ".png"), width = 4, height = 3, units = "in", res = 72)
print(p)
dev.off()

cat("\n--- Probe complete (ggplot2", as.character(packageVersion("ggplot2")), ")---\n")
cat("Record these observations in DECISIONS.md ADR-0002.\n")
