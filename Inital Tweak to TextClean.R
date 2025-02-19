
library(stringr)    # For regex operations
library(textclean)  # Not needed here because we're using our custom removal function


emoji_sentiments <- data.frame(
  emoji = c("😡", "🤬", "😭",  # Most negative
            "😞", "😟", "😢", "😩", "😫",  # Negative
            "😐", "😑", "😶",            # Neutral
            "🙂", "🙃", "😉",            # Mildly positive
            "😀", "😃", "😄", "😁", "😆", "😊", "😍",  # Most positive
            "😎"),  # Adjust as needed
  sentiment = c(-2, -2, -2,   # Very negative
                -1, -1, -1, -1, -1,   # Negative
                0,  0,  0,           # Neutral
                1,  1,  1,           # Mildly positive
                2,  2,  2,  2,  2,  2,  2,   # Very positive
                1),
  stringsAsFactors = FALSE
)


extract_emojis <- function(text, lexicon) {

  emoji_pattern <- paste0("[", paste(lexicon$emoji, collapse = ""), "]")
  

  emojis <- unlist(str_extract_all(text, emoji_pattern))
  return(emojis)
}

emoji_sentiment <- function(text, lexicon) {

  emojis_found <- extract_emojis(text, lexicon)
  

  if (length(emojis_found) == 0) {
    return(0)
  }
  

  sentiment_scores <- sapply(emojis_found, function(e) {
    score <- lexicon$sentiment[lexicon$emoji == e]
    if (length(score) == 0) return(0) else return(score)
  })
  

  total_score <- sum(sentiment_scores)
  return(total_score)
}


remove_emojis <- function(text, lexicon) {
 
  emoji_pattern <- paste0("[", paste(lexicon$emoji, collapse = ""), "]")

  cleaned_text <- gsub(emoji_pattern, "", text)
  return(cleaned_text)
}


process_text_with_sentiment <- function(text, lexicon) {

  cleaned_text <- remove_emojis(text, lexicon)
  

  sentiment <- emoji_sentiment(text, lexicon)
  

  return(list(
    cleaned_text = cleaned_text,
    emoji_sentiment = sentiment
  ))
}


sample_text <- "I feel so amazing today 😀, but sometimes I get really 😢 or even 😡."
result <- process_text_with_sentiment(sample_text, emoji_sentiments)


print(result)
