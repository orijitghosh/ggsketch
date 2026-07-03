# Layer 3 - geom_sketch_calendar() (v2.0)
# A calendar heatmap (GitHub-contribution style): one roughened tile per day,
# laid out as weeks (columns) x weekdays (rows) and coloured by a value.
# StatSketchCalendar turns a `date` aesthetic into the (week, weekday) grid;
# drawing reuses GeomSketchTile. For multiple years, add a year column and
# facet. No new dependencies.

# ---- StatSketchCalendar ------------------------------------------------------

#' @rdname geom_sketch_calendar
#' @export
StatSketchCalendar <- ggplot2::ggproto(
  "StatSketchCalendar", ggplot2::Stat,

  required_aes = "date",

  # No `...`: ggplot2 reads recognised stat params from these formals.
  compute_panel = function(data, scales,
                            week_start = c("sunday", "monday"),
                            na.rm = FALSE) {
    if (nrow(data) == 0L) return(data)
    week_start <- match.arg(week_start)
    shift <- if (week_start == "monday") 1L else 0L

    d    <- as.Date(data$date, origin = "1970-01-01")
    yr   <- format(d, "%Y")
    jan1 <- as.Date(paste0(yr, "-01-01"))

    dow  <- (as.integer(format(d,    "%w")) - shift) %% 7L   # 0 = week start
    off  <- (as.integer(format(jan1, "%w")) - shift) %% 7L
    week <- floor((as.integer(d - jan1) + off) / 7) + 1L

    data$x    <- week
    data$y    <- 7L - dow            # first weekday at the top
    data$week <- week
    data$wday <- dow
    data
  }
)

# ---- axis scales -------------------------------------------------------------

# Weekday (y) and month (x) axis scales for the calendar grid. The stat plots
# week numbers and weekday rows as bare integers; these scales relabel them.
# Month breaks are placed at the week each month starts, computed from the
# day-of-year with the mid-range week offset (3), so they are exact to within
# one week for any year without needing to see the data.
calendar_axis_scales <- function(week_start = c("sunday", "monday")) {
  week_start <- match.arg(week_start)
  shift <- if (week_start == "monday") 1L else 0L
  days  <- c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
  wd    <- days[((0:6 + shift) %% 7L) + 1L]          # row 7 (top) = week start
  doy   <- c(1L, 32L, 60L, 91L, 121L, 152L, 182L, 213L, 244L, 274L, 305L, 335L)
  wk    <- floor((doy + 2L) / 7L) + 1L
  list(
    ggplot2::scale_x_continuous(name = NULL, breaks = wk, labels = month.abb),
    ggplot2::scale_y_continuous(name = NULL, breaks = 1L:7L, labels = rev(wd))
  )
}

# ---- geom_sketch_calendar ----------------------------------------------------

#' Sketchy calendar heatmap
#'
#' Draws a hand-drawn calendar heatmap in the GitHub-contributions style: one
#' roughened tile per day, arranged as weeks (columns) and weekdays (rows), with
#' the tile colour given by a value, and the axes labelled with weekday and
#' month names. Map `date` (a `Date`) and `fill` (the value).
#' Tiles are drawn with [geom_sketch_tile()]; the default `fill_style = "solid"`
#' lets the colour gradient read as a heatmap. For more than one year, add a year
#' column to your data and facet on it (each panel covers one year). No new
#' dependencies.
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()]. Requires
#'   `date`; usually map `fill` to the value.
#' @param data Data to display.
#' @param stat Statistical transformation. Default `"sketch_calendar"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param week_start `"sunday"` (default) or `"monday"`: which weekday is the top
#'   row.
#' @param labels Label the axes with weekday and month names instead of the raw
#'   grid numbers? Default `TRUE`; it returns the layer together with x/y
#'   scales, so set `FALSE` if you want to supply your own scales. Month
#'   positions are exact to within one week (they are computed without seeing
#'   the year).
#' @param width,height Tile size in grid units (gaps appear below 1). Default
#'   0.9.
#' @param colour Tile outline colour. Default `"grey75"` (set `NA` for none).
#' @param fill_style Tile fill style; see [geom_sketch_rect()]. Default
#'   `"solid"` (best for a colour-graded heatmap).
#' @param roughness,bowing,n_passes,seed Sketch parameters.
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend Logical; include in legend?
#' @param inherit.aes Override default aesthetics?
#' @param ... Other arguments passed on to the layer.
#' @return A `ggplot2` layer object (with `labels = TRUE`, a list of the layer
#'   plus weekday/month axis scales).
#' @family sketch-geoms
#' @export
#' @examples
#' library(ggplot2)
#' df <- data.frame(day = as.Date("2024-01-01") + 0:120)
#' df$value <- runif(nrow(df))
#' ggplot(df, aes(date = day, fill = value)) +
#'   geom_sketch_calendar(seed = 1L) +
#'   coord_equal() +
#'   theme_sketch()
geom_sketch_calendar <- function(mapping     = NULL,
                                 data        = NULL,
                                 stat        = "sketch_calendar",
                                 position    = "identity",
                                 ...,
                                 week_start  = "sunday",
                                 labels      = TRUE,
                                 width       = 0.9,
                                 height      = 0.9,
                                 colour      = "grey75",
                                 fill_style  = "solid",
                                 roughness   = 1,
                                 bowing      = 1,
                                 n_passes    = 2L,
                                 seed        = NULL,
                                 na.rm       = FALSE,
                                 show.legend = NA,
                                 inherit.aes = TRUE) {
  params <- list(
    week_start = week_start, width = width, height = height,
    fill_style = fill_style, roughness = roughness, bowing = bowing,
    n_passes = as.integer(n_passes), seed = seed, na.rm = na.rm, ...
  )
  if (!is.null(colour)) params$colour <- colour
  lyr <- ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomSketchTile,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = params
  )
  if (!isTRUE(labels)) return(lyr)
  c(list(lyr), calendar_axis_scales(week_start))
}
