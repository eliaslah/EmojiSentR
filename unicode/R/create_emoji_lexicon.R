library(readr)
library(dplyr)

# Load EmoTag1200 CSV
emoji_scores <- read_csv("EmoTag1200-scores.csv")

# Compute average sentiment across all 8 emotions
emoji_lexicon <- emoji_scores %>%
  rowwise() %>%
  mutate(sentiment = mean(c_across(c(anger, anticipation, disgust, fear, joy, sadness, surprise, trust)), na.rm = TRUE)) %>%
  ungroup() %>%
  select(emoji, sentiment) %>%
  distinct()

# Save to internal package data
usethis::use_data(emoji_lexicon, overwrite = TRUE)
