# =======================================================================
#  pdf_poppler.R        –  lightweight wrappers around pdftotext
# =======================================================================

# ----------------------------  clean_with_poppler  ----------------------------

#' Extract text from a PDF with Poppler
#'
#' Lightweight wrapper for **`pdftotext`** (Poppler). Returns the entire PDF as
#' a single UTF-8 string, preserving multi-column layout with `-layout`.
#'
#' @param pdf_path   Path to the PDF file.
#' @param pdftotext  Executable name or full path to `pdftotext`
#'                   (default `"pdftotext"` must be on `PATH`).
#' @param quiet      Logical. If `TRUE`, silences Poppler warnings by sending
#'                   `stderr` to `FALSE`.
#'
#' @return `character(1)`, page text concatenated with `\\n`.
#' @details **Poppler requirement**
#'   * **Windows**: OSchwartz build or *Chocolatey* `poppler`
#'   * **macOS** : `brew install poppler`
#'   * **Linux** : `sudo apt-get install poppler-utils`
#'
#' @export
#' @examples
#' \dontrun{
#' pdf <- system.file("extdata", "example.pdf", package = "yourpackage")
#' txt <- clean_with_poppler(pdf)
#' writeLines(txt)
#' }
clean_with_poppler <- function(pdf_path,
                               pdftotext = "pdftotext",
                               quiet     = TRUE) {

  if (!file.exists(pdf_path))
    stop("File not found: ", pdf_path)

  if (Sys.which(pdftotext) == "")
    stop("`pdftotext` not found. Install Poppler and/or add it to PATH.")

  cmd_out <- system2(
    pdftotext,
    c("-layout", "-nopgbrk", shQuote(pdf_path), "-"),
    stdout = TRUE,
    stderr = !quiet
  )
  paste(cmd_out, collapse = "\n")
}

# ----------------------------  save_pdf_as_text  ------------------------------

#' Save a PDF as plain text (via Poppler)
#'
#' Converts *pdf_path* to UTF-8 text and writes it to *out_path*.
#'
#' @inheritParams clean_with_poppler
#' @param out_path   Destination `.txt`.  Default: same name as PDF.
#' @param use_layout Keep multi-column spacing with `-layout`. Set `FALSE` for
#'                   linear reading order (`pdftotext`’s default).
#'
#' @return (Invisibly) the path to the written text file.
#' @export
#' @examples
#' \dontrun{
#' pdf <- system.file("extdata", "example.pdf", package = "yourpackage")
#' save_pdf_as_text(pdf)                   # writes example.txt
#' }
save_pdf_as_text <- function(pdf_path,
                             out_path   = NULL,
                             use_layout = TRUE,
                             pdftotext  = "pdftotext",
                             quiet      = TRUE) {

  if (!file.exists(pdf_path))
    stop("File not found: ", pdf_path)

  if (Sys.which(pdftotext) == "")
    stop("`pdftotext` not found. Install Poppler and/or add it to PATH.")

  if (is.null(out_path))
    out_path <- sub("\\.[Pp][Dd][Ff]$", ".txt", pdf_path)

  flags <- if (use_layout) c("-layout", "-nopgbrk") else character(0)
  args  <- c(flags, "-enc", "UTF-8", shQuote(pdf_path), shQuote(out_path))

  status <- system2(pdftotext, args, stdout = FALSE, stderr = !quiet)
  if (status != 0)
    stop("`pdftotext` returned non-zero exit status (", status, ").")

  message("✓ Text saved to ", normalizePath(out_path))
  invisible(out_path)
}
