# Probe whether a cairo-backed device actually works on this machine.
# capabilities("cairo") reports compile-time support, which can be TRUE on a
# build whose cairo shared library fails to load at run time (e.g. a headless
# macOS runner missing X11's libXrender / libSM). So open the device for real,
# promoting any load warning to an error, draw through grid (no base-graphics
# margins to trip over), and confirm the device flushed a non-empty file.
cairo_device_works <- function(device, ext) {
  tmp    <- tempfile(fileext = ext)
  before <- grDevices::dev.cur()
  ok <- tryCatch(
    withr::with_options(list(warn = 2L), {
      device(tmp, width = 2, height = 2)
      grid::grid.newpage()
      grid::grid.rect()
      TRUE
    }),
    error = function(e) FALSE
  )
  if (grDevices::dev.cur() != before) try(grDevices::dev.off(), silent = TRUE)
  good <- isTRUE(ok) && file.exists(tmp) && file.size(tmp) > 0
  unlink(tmp)
  good
}
