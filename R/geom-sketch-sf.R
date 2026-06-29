# Tier B flagship: geom_sketch_sf() - hand-drawn simple-features maps.
#
# sf has no pure-R substitute for parsing geometry, so it is a hard (guarded)
# requirement here. To stay clear of ggplot2's CoordSf/stat_sf internals, the
# constructor extracts coordinates from the sf object up front (walking the sfg
# structure, no CRS maths) and returns a list of ordinary sketch layers:
# polygons -> a hole-aware band grob, lines -> sketch paths, points -> sketch
# points. It therefore plots in planar coordinates - pre-project lon/lat data
# with sf::st_transform() for a faithful map.

# ---- geometry extraction (structure walk, no sf functions needed) -----------

# An sfg's class is c("XY", "<TYPE>", "sfg"); unclass() exposes the nested
# matrices/vectors. We pull (multi)polygon rings, (multi)line pieces, and
# (multi)points without any coordinate-reference maths.
sfg_type <- function(g) class(g)[[2L]]

sfg_rings <- function(g) {
  m <- unclass(g)
  switch(sfg_type(g),
    POLYGON      = m,                 # list of ring matrices
    MULTIPOLYGON = do.call(c, m),     # flatten polygons -> list of rings
    list()
  )
}

sfg_lines <- function(g) {
  m <- unclass(g)
  switch(sfg_type(g),
    LINESTRING      = list(m),
    MULTILINESTRING = m,
    list()
  )
}

sfg_points <- function(g) {
  m <- unclass(g)
  switch(sfg_type(g),
    POINT      = matrix(m, nrow = 1L),
    MULTIPOINT = m,
    matrix(numeric(0), 0L, 2L)
  )
}

# Bind a list of coordinate matrices into a long data frame, tagging each with a
# feature id, a piece id, and recycling that feature's attribute row.
bind_pieces <- function(pieces, feature_id, piece_offset, attr_row) {
  if (length(pieces) == 0L) return(NULL)
  out <- lapply(seq_along(pieces), function(k) {
    m <- pieces[[k]]
    if (is.null(dim(m)) || nrow(m) == 0L) return(NULL)
    df <- data.frame(x = m[, 1L], y = m[, 2L],
                     feature_id = feature_id,
                     piece_id   = piece_offset + k)
    if (!is.null(attr_row) && ncol(attr_row) > 0L) {
      df <- cbind(df, attr_row[rep(1L, nrow(df)), , drop = FALSE])
    }
    df
  })
  do.call(rbind, out)
}

# ---- GeomSketchSfPolygon (hole-aware) ---------------------------------------

#' @rdname geom_sketch_sf
#' @export
GeomSketchSfPolygon <- ggplot2::ggproto(
  "GeomSketchSfPolygon", ggplot2::Geom,

  required_aes = c("x", "y"),

  default_aes = ggplot2::aes(
    colour    = "grey30",
    fill      = "grey80",
    linewidth = 0.4,
    linetype  = 1,
    alpha     = NA,
    subgroup  = NULL
  ),

  draw_key = draw_key_sketch_polygon,

  parameters = function(self, extra = FALSE) {
    c("roughness", "bowing", "n_passes", "seed",
      "fill_style", "hachure_angle", "hachure_gap", "fill_weight", "na.rm")
  },

  draw_group = function(data, panel_params, coord,
                         roughness     = 1,
                         bowing        = 1,
                         n_passes      = 2L,
                         seed          = NULL,
                         fill_style    = "hachure",
                         hachure_angle = 45,
                         hachure_gap   = NULL,
                         fill_weight   = 0.5,
                         ...) {
    if (nrow(data) < 3L) return(nullGrob())
    coords <- coord$transform(data, panel_params)
    sp     <- resolve_sketch_params(roughness, bowing, n_passes, seed)
    first  <- data[1L, , drop = FALSE]

    # Split into rings by subgroup (holes / multipolygon parts); the band grob
    # fills with an even-odd rule so nested rings cut out as holes.
    sg <- coords$subgroup %||% rep(1L, nrow(coords))
    rings <- lapply(split(seq_len(nrow(coords)), sg), function(ix) {
      list(x = coords$x[ix], y = coords$y[ix])
    })
    rings <- Filter(function(r) length(r$x) >= 3L, rings)
    if (length(rings) == 0L) return(nullGrob())

    allx <- unlist(lapply(rings, function(r) r$x))
    ally <- unlist(lapply(rings, function(r) r$y))
    gap  <- hachure_gap %||%
      (0.07 * sqrt(diff(range(allx))^2 + diff(range(ally))^2))
    gap  <- max(gap, 1e-3)

    sketch_band_grob(
      rings         = rings,
      roughness     = sp$roughness, bowing = sp$bowing,
      n_passes      = sp$n_passes,  seed   = sp$seed,
      fill_style    = fill_style, hachure_angle = hachure_angle,
      hachure_gap   = gap, fill_weight = fill_weight,
      fill_col      = scales::alpha(first$fill, first$alpha),
      outline_gp    = gpar(
        col = scales::alpha(first$colour, first$alpha),
        lwd = first$linewidth * ggplot2::.pt,
        lty = first$linetype, lineend = "round", linejoin = "round"
      )
    )
  }
)

# ---- geom_sketch_sf ---------------------------------------------------------

#' Sketchy simple-features (sf) maps
#'
#' A hand-drawn take on [ggplot2::geom_sf()]. Roughens the boundaries of sf
#' geometry: `(MULTI)POLYGON` features are filled with a hole-aware hachure (or
#' any `fill_style`), `(MULTI)LINESTRING` features become sketch paths, and
#' `(MULTI)POINT` features become sketch points. One call draws whichever
#' geometry types are present.
#'
#' Requires the \pkg{sf} package. Unlike `geom_sf()`, this does not integrate
#' with `coord_sf()`; it plots in **planar coordinates**, so pre-project
#' longitude/latitude data with [sf::st_transform()] for an undistorted map. The
#' `data` argument must be given explicitly (an `sf` or `sfc` object); aesthetics
#' in `mapping` refer to columns of that object.
#'
#' @param mapping Aesthetic mappings created by [ggplot2::aes()], referring to
#'   columns of `data` (e.g. `aes(fill = pop)`). The geometry column is handled
#'   automatically - do not map it.
#' @param data An `sf` or `sfc` object (required).
#' @param fill_style Fill style for polygons; see [geom_sketch_polygon()].
#'   Default `"hachure"`.
#' @param roughness,bowing,n_passes,seed Sketch parameters; see
#'   [geom_sketch_path()].
#' @param na.rm Remove missing values silently? Default `FALSE`.
#' @param show.legend,inherit.aes Standard layer arguments. `inherit.aes`
#'   defaults to `FALSE` (as for `geom_sf()`).
#' @param ... Other arguments passed on to the underlying layers.
#' @return A list of `ggplot2` layers (one per geometry kind present).
#' @family sketch-geoms
#' @export
#' @examplesIf requireNamespace("sf", quietly = TRUE)
#' library(ggplot2)
#' nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#' ggplot() +
#'   geom_sketch_sf(data = nc, aes(fill = AREA), seed = 1L) +
#'   scale_fill_viridis_c() +
#'   theme_void()
geom_sketch_sf <- function(mapping     = ggplot2::aes(),
                           data        = NULL,
                           ...,
                           fill_style  = "hachure",
                           roughness   = 1,
                           bowing      = 1,
                           n_passes    = 2L,
                           seed        = NULL,
                           na.rm       = FALSE,
                           show.legend = NA,
                           inherit.aes = FALSE) {
  if (!requireNamespace("sf", quietly = TRUE)) {
    cli::cli_abort(c(
      "{.pkg sf} is required for {.fn geom_sketch_sf}.",
      "i" = 'Install it with {.run install.packages("sf")}.'
    ))
  }
  if (is.null(data) || !inherits(data, c("sf", "sfc"))) {
    cli::cli_abort(c(
      "{.arg data} must be an {.cls sf} or {.cls sfc} object.",
      "i" = "Pass it explicitly, e.g. {.code geom_sketch_sf(data = my_sf)}."
    ))
  }

  # Geometry column + attribute table.
  if (inherits(data, "sf")) {
    geom_col <- attr(data, "sf_column")
    sfc      <- data[[geom_col]]
    attrs    <- sf::st_drop_geometry(data)
  } else {
    sfc   <- data
    attrs <- NULL
  }

  # Drop a mapped geometry aesthetic if the user added one.
  mapping[["geometry"]] <- NULL

  poly_rows <- list(); line_rows <- list(); point_rows <- list()
  for (i in seq_along(sfc)) {
    g  <- sfc[[i]]
    ar <- if (!is.null(attrs)) attrs[i, , drop = FALSE] else NULL

    rings <- sfg_rings(g)
    if (length(rings)) {
      # Holes/parts of one feature share feature_id; piece_id marks the ring.
      poly_rows[[length(poly_rows) + 1L]] <-
        bind_pieces(rings, feature_id = i, piece_offset = 0L, attr_row = ar)
    }
    lines <- sfg_lines(g)
    if (length(lines)) {
      line_rows[[length(line_rows) + 1L]] <-
        bind_pieces(lines, feature_id = i, piece_offset = 0L, attr_row = ar)
    }
    pts <- sfg_points(g)
    if (length(pts)) {
      point_rows[[length(point_rows) + 1L]] <-
        bind_pieces(list(pts), feature_id = i, piece_offset = 0L, attr_row = ar)
    }
  }

  poly_df  <- if (length(poly_rows))  do.call(rbind, poly_rows)  else NULL
  line_df  <- if (length(line_rows))  do.call(rbind, line_rows)  else NULL
  point_df <- if (length(point_rows)) do.call(rbind, point_rows) else NULL

  common <- list(...)
  layers <- list()

  if (!is.null(poly_df)) {
    m <- utils::modifyList(
      ggplot2::aes(x = .data$x, y = .data$y,
                   group = .data$feature_id, subgroup = .data$piece_id),
      mapping
    )
    layers <- c(layers, list(ggplot2::layer(
      data = poly_df, mapping = m, stat = "identity",
      geom = GeomSketchSfPolygon, position = "identity",
      show.legend = show.legend, inherit.aes = inherit.aes,
      params = c(list(fill_style = fill_style, roughness = roughness,
                      bowing = bowing, n_passes = as.integer(n_passes),
                      seed = seed, na.rm = na.rm), common)
    )))
  }

  if (!is.null(line_df)) {
    # group by feature *and* piece so multiline parts stay separate.
    line_df$.grp <- interaction(line_df$feature_id, line_df$piece_id,
                                drop = TRUE)
    m <- utils::modifyList(
      ggplot2::aes(x = .data$x, y = .data$y, group = .data$.grp),
      mapping
    )
    layers <- c(layers, list(do.call(geom_sketch_path, c(
      list(data = line_df, mapping = m, roughness = roughness, bowing = bowing,
           n_passes = as.integer(n_passes), seed = seed, na.rm = na.rm,
           show.legend = show.legend, inherit.aes = inherit.aes), common
    ))))
  }

  if (!is.null(point_df)) {
    m <- utils::modifyList(
      ggplot2::aes(x = .data$x, y = .data$y), mapping
    )
    layers <- c(layers, list(do.call(geom_sketch_point, c(
      list(data = point_df, mapping = m, seed = seed, na.rm = na.rm,
           show.legend = show.legend, inherit.aes = inherit.aes), common
    ))))
  }

  if (length(layers) == 0L) {
    cli::cli_warn("{.fn geom_sketch_sf}: no drawable geometry found in {.arg data}.")
    return(ggplot2::geom_blank())
  }
  layers
}
