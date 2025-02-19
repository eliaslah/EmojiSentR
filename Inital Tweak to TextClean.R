# Load necessary libraries
library(stringr)    # For regex operations
library(textclean)  # Not needed here because we're using our custom removal function

# 1. Define your emoji sentiment lexicon
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

# 2. Function to extract emojis from text using the lexicon
extract_emojis <- function(text, lexicon) {
  # Build a regex pattern that matches any emoji from our lexicon.
  emoji_pattern <- paste0("[", paste(lexicon$emoji, collapse = ""), "]")
  
  # Extract all matching emojis
  emojis <- unlist(str_extract_all(text, emoji_pattern))
  return(emojis)
}

# 3. Function to calculate the overall emoji sentiment for a given text
emoji_sentiment <- function(text, lexicon) {
  # Extract emojis from the text
  emojis_found <- extract_emojis(text, lexicon)
  
  # If no emojis are found, return a neutral sentiment score (0)
  if (length(emojis_found) == 0) {
    return(0)
  }
  
  # For each emoji found, get its sentiment from the lexicon
  sentiment_scores <- sapply(emojis_found, function(e) {
    score <- lexicon$sentiment[lexicon$emoji == e]
    if (length(score) == 0) return(0) else return(score)
  })
  
  # Aggregate the sentiment scores (summing them here)
  total_score <- sum(sentiment_scores)
  return(total_score)
}

# 4. Custom function to remove emojis from text (instead of replacing them with descriptions)
remove_emojis <- function(text, lexicon) {
  # Build a regex pattern from the lexicon emojis
  emoji_pattern <- paste0("[", paste(lexicon$emoji, collapse = ""), "]")
  # Remove all matching emojis
  cleaned_text <- gsub(emoji_pattern, "", text)
  return(cleaned_text)
}

# 5. Wrapper function to clean text and calculate emoji sentiment
process_text_with_sentiment <- function(text, lexicon) {
  # Remove emojis using our custom removal function
  cleaned_text <- remove_emojis(text, lexicon)
  
  # Calculate the emoji sentiment score using the original text
  sentiment <- emoji_sentiment(text, lexicon)
  
  # Return both the cleaned text and the sentiment score as a list
  return(list(
    cleaned_text = cleaned_text,
    emoji_sentiment = sentiment
  ))
}

# 6. Example usage:
sample_text <- "I feel so amazing today 😀, but sometimes I get really 😢 or even 😡."
result <- process_text_with_sentiment(sample_text, emoji_sentiments)

# Print the result
print(result)
