
emoji_sentiment <- c(
  "😀" = 1,
  "😢" = -1,
  "😡" = -2,
  "❤️" = 2,
  "😂" = 1)


calculate_sentiment <- function(text) {
 
 chars <- strsplit(text, split = "")[[1]]
  
 matched_scores <- emoji_sentiment[chars]
  
 matched_scores <- matched_scores[!is.na(matched_scores)]
  
  if (length(matched_scores) == 0) {
0
    return(50)
  }
  
 scaled_scores <- ((matched_scores + 2) / 4) * 100
  
  average_score <- mean(scaled_scores)
  
return(average_score)
}


sample_text <- "I am so happy today! 😀❤️"
sentiment_score <- calculate_sentiment(sample_text)
print(paste("Sentiment Score:", sentiment_score))