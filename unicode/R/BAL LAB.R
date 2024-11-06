library(tidyverse)
library(readxl)
library(tidytext)
library(SnowballC)
library(gridExtra)
library(grid)

# Read in data Instagram
okcupid_data <- read_xlsx("okcupid_data.xlsx")

Instagram.words <- okcupid_data %>%
  unnest_tokens(word, `Instagram`) %>%
  mutate(word = str_extract(word, "[0-9a-z']+"),
         word.stem = wordStem(word))

Instagram.words <- Instagram.words %>%
  anti_join(stop_words, by = "word")

word.count <- Instagram.words %>%
  group_by(word) %>%
  summarize(word.count = n()) %>%
  arrange(desc(word.count)) %>% drop_na()

print(word.count)

#Incorporating "Stop" words
new_stop_words <- tibble(word = c("lot", "live", "mind", 
                                  "head", "awesome", "meu", "im","stuff","thinking"))

Instagram.words <- Instagram.words %>%
  anti_join(new_stop_words, by = "word")

new.word.count <- Instagram.words %>%
  group_by(word) %>%
  summarize(count = n()) %>%
  arrange(desc(count)) %>%
  drop_na()


# Read in data Snapchat
okcupid_data <- read_xlsx("okcupid_data.xlsx")

Snapchat.words <- okcupid_data %>%
  unnest_tokens(word, `Snapchat`) %>%
  mutate(word = str_extract(word, "[0-9a-z']+"),
         word.stem = wordStem(word))

Snapchat.words <- Snapchat.words %>%
  anti_join(stop_words, by = "word")

word.count <- Snapchat.words %>%
  group_by(word) %>%
  summarize(word.count = n()) %>%
  arrange(desc(word.count)) %>% drop_na()

print(word.count)

#Incorporating "Stop" words
new_stop_words <- tibble(word = c("lot", "live", "mind", 
                                  "head", "awesome", "meu", "im","stuff","thinking"))

Snapchat.words <- Snapchat.words %>%
  anti_join(new_stop_words, by = "word")

new.word.count <- Snapchat.words %>%
  group_by(word) %>%
  summarize(count = n()) %>%
  arrange(desc(count)) %>%
  drop_na()

