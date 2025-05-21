<!-- README.md ---------------------------------------------------------------->

- **Package**: EmojiSentR (working title: **unicode**)
- **Title**: Text & Emoji Sentiment Analysis • Unicode Cleaning • PDF-to-Text
- **Version**: 0.1.0
- **Authors**: Elias Lahrim & Logan Hanson
- **Maintainer**: Elias Lahrim <elahrim@gmail.com>
- **Description**: Blend VADER text sentiment with emoji polarity, strip
  troublesome Unicode, and convert PDFs to tidy UTF-8 — all from pure R.
- **License**: AFL-3.0

<!-- badges: start -->
![R-CMD-check](https://github.com/eliaslah/EmojiSentR/actions/workflows/R-CMD-check.yaml/badge.svg)
[![CRAN status](https://www.r-pkg.org/badges/version-last-release/EmojiSentR)](https://cran.r-project.org/package=EmojiSentR)
<!-- badges: end -->

---

# EmojiSentR

EmojiSentR is a lightweight toolbox for analysts who wrangle messy
social-media text & PDFs.

| Module | What it solves | Core functions |
|--------|----------------|----------------|
| **Sentiment** | Combine word-level VADER scores with emoji polarity from the *Emoji-Sentiment-Ranking* corpus (≈ 2 000 symbols). | `sentiment_vader_hash()` |
| **Unicode clean-up** | Remove, replace, or flag emojis / pictographs / control codes that break CSVs and tokenizers. | `remove_unicode()` |
| **PDF ingestion** | Fast, reproducible text extraction via Poppler’s `pdftotext` (`-layout`, UTF-8). | `clean_with_poppler()`, `save_pdf_as_text()` |

No Python, Java, or heavyweight models required.

---

## Installation

```r
install.packages("remotes")             # if not already
remotes::install_github("eliaslah/EmojiSentR")
