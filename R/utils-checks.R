#' Validate a numeric scalar in \[lo, hi\]
#' @noRd
check_number_in <- function(x, lo, hi, arg = rlang::caller_arg(x),
                             call = rlang::caller_env()) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || x < lo || x > hi) {
    cli::cli_abort(
      "{.arg {arg}} must be a single number in [{lo}, {hi}], not {.val {x}}.",
      call = call
    )
  }
  invisible(x)
}

#' Validate that x is a non-negative scalar
#' @noRd
check_non_negative <- function(x, arg = rlang::caller_arg(x),
                                call = rlang::caller_env()) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || x < 0) {
    cli::cli_abort(
      "{.arg {arg}} must be a non-negative number, not {.val {x}}.",
      call = call
    )
  }
  invisible(x)
}

#' Validate fill_style choice
#' @noRd
check_fill_style <- function(x, arg = rlang::caller_arg(x),
                              call = rlang::caller_env()) {
  choices <- c("hachure", "cross_hatch", "zigzag", "zigzag_line",
               "dots", "dashed", "solid")
  if (!is.character(x) || length(x) != 1L || !x %in% choices) {
    cli::cli_abort(
      "{.arg {arg}} must be one of {.or {choices}}, not {.val {x}}.",
      call = call
    )
  }
  invisible(x)
}
