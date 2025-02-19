library(dplyr)
library(stringr)
library(purrr)
library(sentimentr)
library(text2vec)
library(tidyr)

# --- Emoji Extraction Function ---
extract_emojis <- function(text_column) {
  emoji_regex <- "[\\p{Emoji}]"

  tibble::tibble(
    original_text = text_column,
    emojis = str_extract_all(text_column, emoji_regex),
    clean_text = str_remove_all(text_column, emoji_regex)
  ) %>%
    mutate(
      emojis = map_chr(emojis, ~paste(.x, collapse = " "))
    )
}

# --- Sentiment Scoring with sentimentr ---
score_text_sentiment <- function(clean_text) {
  sentimentr::sentiment_by(clean_text)$ave_sentiment
}

# --- Dynamic Emoji Scoring with text2vec Context ---
score_emoji_sentiment <- function(original_text, emojis, text_sentiment) {
  # Load sample emoji lexicon (replace with your data)
  emoji_lexicon <- tibble::tribble(
    ~emoji, ~sentiment,
    "🌧️",  -0.7,
    "😡",  -0.9
  )

  # Base emoji scores
  base_scores <- map_dbl(
    str_split(emojis, " "),
    ~sum(emoji_lexicon$sentiment[match(.x, emoji_lexicon$emoji)], na.rm = TRUE)
  )

  # --- text2vec Context Analysis ---
  # Create word embeddings and find contextual modifiers
  tokens <- word_tokenizer(tolower(original_text))
  it <- itoken(tokens)
  v <- create_vocabulary(it)
  vectorizer <- vocab_vectorizer(v)
  dtm <- create_dtm(it, vectorizer)

  # Find negation contexts
  negation_weights <- as.matrix(dtm[, c("not", "no", "never")]) %*%
    matrix(c(-1, -0.8, -0.7), ncol = 1)

  # Combine with text sentiment
  context_factor <- 1 + (0.5 * text_sentiment) + (0.3 * negation_weights[, 1])

  # Apply dynamic adjustment
  base_scores * context_factor
}

# --- Combined Sentiment ---
combine_sentiment <- function(text_score, emoji_score,
                              text_weight = 0.7, emoji_weight = 0.3) {
  (text_weight * text_score) + (emoji_weight * emoji_score)
}

# --- Example Workflow ---
data <- tibble::tibble(
  text = c("I love rainy days! 🌧️", "This is not good 😡 but maybe...")
)

processed_data <- data %>%
  mutate(
    extracted = map(text, extract_emojis) # Apply extract_emojis() to each text entry
  ) %>%
  unnest_wider(extracted) %>%  # Expands the tibble output into separate columns
  mutate(
    text_sentiment = score_text_sentiment(clean_text),
    emoji_sentiment = score_emoji_sentiment(
      original_text = original_text,
      emojis = emojis,
      text_sentiment = text_sentiment
    ),
    combined_sentiment = combine_sentiment(text_sentiment, emoji_sentiment)
  )

# --- View Results ---
processed_data %>%
  select(original_text, clean_text, emojis,
         text_sentiment, emoji_sentiment, combined_sentiment)
