#' Process and score sentiment from text with emojis
#'
#' This function extracts emojis, calculates text and emoji sentiment, and combines them.
#'
#' @param text_vec A character vector of raw text (e.g., from tweets, bios, etc.)
#' @param emoji_weight Numeric weight for emoji sentiment in combined score (default 0.3)
#' @param text_weight Numeric weight for text sentiment in combined score (default 0.7)
#' @param use_context_adjustment Logical; if TRUE, modifies emoji sentiment using negation context
#' @return A tibble with cleaned text, emojis, text sentiment, emoji sentiment, and combined sentiment
#' @export
analyze_sentiment_pipeline <- function(text_vec, text_weight = 0.7, emoji_weight = 0.3, use_context_adjustment = TRUE) {
  library(dplyr)
  library(stringr)
  library(sentimentr)
  library(purrr)
  library(tibble)
  library(text2vec)
  library(tidyr)

  # Load internal dataset
  data("emoji_lexicon", envir = environment())

  emoji_regex <- "[\U0001F600-\U0001F64F\U0001F300-\U0001F5FF\U0001F680-\U0001F6FF]"

  tibble(text = text_vec) %>%
    mutate(
      emojis = map_chr(str_extract_all(text, emoji_regex), ~ {
        if (length(.x) == 0) NA_character_ else paste(.x, collapse = " ")
      }),
      clean_text = str_remove_all(text, emoji_regex),
      text_sentiment = sentimentr::sentiment_by(clean_text)$ave_sentiment,
      emoji_sentiment = map2_dbl(text, emojis, function(original_text, emoji_str) {
        if (is.na(emoji_str)) return(NA_real_)
        emoji_list <- str_split(emoji_str, " ")[[1]]
        base_score <- mean(emoji_lexicon$sentiment[match(emoji_list, emoji_lexicon$emoji)], na.rm = TRUE)
        if (is.nan(base_score)) return(NA_real_)

        if (use_context_adjustment) {
          tokens <- text2vec::word_tokenizer(tolower(original_text))
          it <- text2vec::itoken(tokens)
          v <- text2vec::create_vocabulary(it)
          vectorizer <- text2vec::vocab_vectorizer(v)
          dtm <- text2vec::create_dtm(it, vectorizer)

          negation_terms <- c("not", "no", "never")
          present_terms <- intersect(negation_terms, colnames(dtm))

          if (length(present_terms) > 0) {
            weights <- matrix(rep(-1, length(present_terms)), ncol = 1)
            negation_weights <- as.matrix(dtm[, present_terms]) %*% weights
            context_factor <- 1 + (0.5 * mean(base_score)) + (0.3 * negation_weights[1])
            return(base_score * context_factor)
          }
        }

        return(base_score)
      }),
      combined_sentiment = ifelse(
        is.na(emoji_sentiment),
        text_sentiment,
        (text_weight * text_sentiment) + (emoji_weight * emoji_sentiment)
      )
    ) %>%
    select(clean_text, emojis, text_sentiment, emoji_sentiment, combined_sentiment)
}
