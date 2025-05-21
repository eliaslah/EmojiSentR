# =======================================================================
#  unicode_utils.R      –  strip / replace / flag troublesome characters
# =======================================================================

# -------------------------------  remove_unicode  -------------------------------

#' Strip, replace, or flag Unicode symbols (emoji, pictographs, control chars)
#'
#' Useful for sanitising Twitter/X text, PDFs converted to text, or any source
#' that contains emojis, dingbats, private-use characters, or hidden
#' control bytes that break CSV/parsers.
#'
#' @param text  A character vector *or* a data.frame/tibble when
#'   `mode = "flag"`.
#' @param mode  `"strip"` (delete symbols), `"replace"` (swap for
#'   `replacement`), or `"flag"` (return logical or add `has_unicode` column).
#' @param replacement String inserted when `mode = "replace"`.
#' @param keep_newline Keep line/tab (`\\r\\n\\t`) even though they are
#'   control characters.  Default `TRUE`.
#' @param keep_ascii   When `mode = "strip"`, keep ASCII control bytes
#'   `0x00–0x1F` & `0x7F`.  Default `TRUE`.
#'
#' @details The default regex matches three Unicode properties
#'   • `\\p{So}` «Symbol, other»   • `\\p{Cn}` «Unassigned»   • `\\p{Cc}` «Control».
#'   Edit `unicode_re` in the source if you want more or fewer classes.
#'
#' @return
#' * **strip / replace** → character vector (same length as input)
#' * **flag** → logical vector *or* original data.frame plus `has_unicode`
#'   column.
#'
#' @examples
#' sample <- c("hello 😊", "plain ASCII", "snowman ⛄︎")
#' remove_unicode(sample)
#' remove_unicode(sample, mode = "replace", replacement = "<sym>")
#' df <- data.frame(txt = sample)
#' remove_unicode(df, mode = "flag")
#' @export
remove_unicode <- function(text,
                           mode         = c("strip", "replace", "flag"),
                           replacement  = "",
                           keep_newline = TRUE,
                           keep_ascii   = TRUE) {

  mode <- match.arg(mode)

  # ------------------------------------------------------------------------
  # If flagging a data.frame, add logical column and return immediately
  # ------------------------------------------------------------------------
  if (is.data.frame(text) && mode == "flag") {
    unicode_re <- "[\\p{So}\\p{Cn}\\p{Cc}]"
    text$has_unicode <- apply(text, 1L, function(row)
      any(grepl(unicode_re, row, perl = TRUE, useBytes = TRUE)))
    return(text)
  }

  if (!is.character(text))
    stop("`text` must be character (or data.frame when mode = 'flag').")

  # ------------------------------------------------------------------------
  # Build search pattern
  # ------------------------------------------------------------------------
  unicode_re <- "[\\p{So}\\p{Cn}\\p{Cc}]"
  if (keep_newline)
    unicode_re <- paste0("(?:(?<![\\r\\n\\t])", unicode_re, ")")

  # ------------------------------------------------------------------------
  # strip / replace
  # ------------------------------------------------------------------------
  if (mode == "strip") {
    out <- stringi::stri_replace_all_regex(text, unicode_re, "", FALSE)
    if (!keep_ascii)
      out <- gsub("[\\x00-\\x1F\\x7F]", "", out, perl = TRUE)
    return(out)
  }

  if (mode == "replace") {
    return(stringi::stri_replace_all_regex(text, unicode_re,
                                           replacement, FALSE))
  }

  # ------------------------------------------------------------------------
  # flag on vector
  # ------------------------------------------------------------------------
  grepl(unicode_re, text, perl = TRUE, useBytes = TRUE)
}

# ---------------------------  mutate_unicode_cols  -----------------------------

#' Add _clean and _unicode columns to a data-frame
#'
#' Quickly create two new columns next to a text column:
#' * `<colname>_clean` – stripped/replaced version
#' * `<colname>_unicode` – all matched symbols concatenated (or `NA`)
#'
#' @param df        A data.frame / tibble.
#' @param text_col  Unquoted column name containing the text.
#' @param ...       Additional arguments passed to [remove_unicode()]
#'   (`mode`, `replacement`, `keep_newline`, `keep_ascii`).
#'
#' @return Original data with two new columns.
#' @examples
#' tweets <- data.frame(text = c("Hi 😊", "Plain"))
#' mutate_unicode_cols(tweets, text)
#' @export
mutate_unicode_cols <- function(df, text_col, ...) {
  tc <- rlang::ensym(text_col)
  col_name <- rlang::as_name(tc)
  txt <- df[[col_name]]

  # cleaned text using passed args
  cleaned <- remove_unicode(txt, ...)

  # extract the unicode bits for reference
  unicode_re <- "[\\p{So}\\p{Cn}\\p{Cc}]"
  extracted <- stringi::stri_extract_all_regex(txt, unicode_re, simplify = FALSE)
  extracted <- vapply(extracted, function(v)
    if (length(v) == 0) NA_character_ else paste(v, collapse = ""), character(1))

  dplyr::mutate(df,
                !!paste0(col_name, "_clean")   := cleaned,
                !!paste0(col_name, "_unicode") := extracted)
}
