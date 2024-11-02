#' Extract text from a PDF file
#'
#' This function takes a PDF file and extracts all text content from it.
#'
#' @param pdfPath The path to the PDF file.
#' @return A character vector containing the text extracted from the PDF.
#' @export
extractPDFtext <- function(pdfPath) {
  # Load necessary library
  if (!requireNamespace("pdftools", quietly = TRUE)) {
    stop("The 'pdftools' package is required but not installed.")
  }

  # Use pdftools to extract text from the PDF
  text <- pdftools::pdfText(pdfPath)

  # Combine all pages of text into one character vector
  fullText <- paste(text, collapse = "\n")

  return(fullText)
}

# Example usage:
# pdfText <- extractPDFtext("documentPath.pdf")
# print(pdfText)
