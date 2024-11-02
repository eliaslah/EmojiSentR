#' Remove Unicode characters from text
#'
#' This function removes Unicode characters from a given text string.
#'
#' @param text A character vector or string containing text data.
#' @return A character vector with Unicode characters removed.
#' @export

removeUnicode <- function(text) {

  # Regular expression to match any Unicode character (emojis and other symbols)
  emojiPattern <- "[\\p{So}\\p{Cn}]"

  # Replace Unicode characters with an empty string
  cleanedText <- gsub(emojiPattern, "", text, perl = TRUE)

  return(cleanedText)
}

# Example usage:
sampleText <- "This is a test 😊 with some text! 👍"
cleanedText <- removeUnicode(sampleText)
print(cleanedText)
