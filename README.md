<!-- README.md ---------------------------------------------------------------->

- **Package**: EmojiSentR (aka unicode)
- **Title**: Text & Emoji Sentiment Analysis • Unicode Cleaning • PDF-to-Text
- **Version**: 0.1.0
- **Authors**: Elias Lahrim & Logan Hanson
- **Maintainer**: Elias Lahrim <elahrim@gmail.com>
- **Description**: Blend VADER text sentiment with emoji polarity, strip
  troublesome Unicode, and convert PDFs to tidy UTF-8 in R.
- **License**: AFL-3.0

---

# EmojiSentR

EmojiSentR is a lightweight toolbox for analysts who wrangle messy
social-media text & PDFs.

| Module | What it solves | Core functions |
|--------|----------------|----------------|
| **Sentiment** | Combine word-level VADER scores with emoji polarity from Novak's [*Emoji-Sentiment-Ranking*](https://kt.ijs.si/data/Emoji_sentiment_ranking/index.html) corpus. | `sentiment_vader_hash()` |
| **Unicode clean-up** | Remove, replace, or flag emojis / pictographs / control codes that break CSVs and tokenizers. | `remove_unicode()` |
| **PDF ingestion** | Fast, reproducible text extraction via Poppler’s `pdftotext` (`-layout`, UTF-8). | `clean_with_poppler()`, `save_pdf_as_text()` |

# System requirement – Poppler

`pdftotext` must be on your *PATH*.

| OS | install command |
| Windows | Download the [Poppler for Windows zip](https://github.com/oschwartz10612/poppler-windows/releases) → unzip to `C:\Program Files\Poppler` → add `Poppler\bin` to the PATH.
| macOS | `brew install poppler` |
| Ubuntu/Debian | sudo apt-get install poppler-utils |

# Quick start

```{r}
library(EmojiSentR)

# 1️⃣  Unicode clean-up
txt <- c("Love R tidyverse 😍🔥!", "Awful bug 😡", "ASCII only.")
remove_unicode(txt)
#> "Love R tidyverse !" "Awful bug "          "ASCII only."

# 2️⃣  Hybrid sentiment
sentiment_vader_hash(txt)
#>   text_sent emoji_sent combined
#> 1      0.76       0.93     0.82
#> 2     -0.62      -0.78    -0.67
#> 3      0.00         NA     0.00

# 3️⃣  PDF → text
newsletter <- clean_with_poppler(
  system.file("extdata", "drylab.pdf", package = "EmojiSentR"))
writeLines(newsletter)

# or save alongside the PDF
save_pdf_as_text("report.pdf")
```
