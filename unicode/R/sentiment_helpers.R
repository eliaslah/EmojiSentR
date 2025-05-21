# =======================================================================
#  sentiment_helpers.R   –  text + emoji sentiment (VADER + Novak)
# =======================================================================

## This file bundles every helper needed for fixed-weight (70 : 30) combined
## sentiment scoring.  The only external requirements are:
##   • vader     – CRAN text-sentiment engine
##   • stringi   – emoji extraction + Unicode tools
## The Novak emoji sentiment table is shipped with the package
## under  inst/extdata/emoji_sentiment_novak_unicode.rds

# ----------------------------  load_novak_table  -----------------------------

#' Load bundled Novak emoji sentiment table
#'
#' Returns a data frame with two columns:
#' \itemize{
#'   \item \code{unicode}   – lowercase hex code-point(s) (e.g. `"1f602"`, `"2764-fe0f"`)
#'   \item \code{sentiment} – numeric polarity (−1 … +1)
#' }
#'
#' @keywords internal
load_novak_table <- function() {
  fn <- system.file("extdata",
                    "emoji_sentiment_novak_unicode.rds",
                    package = utils::packageName())
  if (fn == "")
    stop("Bundled Novak emoji table not found in package.")
  readRDS(fn)
}

# ----------------------------  extract_emoji_unicode  ------------------------

#' Extract emoji(s) and convert to Unicode hex keys
#'
#' @param text Single character string.
#' @return Character vector of hexadecimal Unicode keys (length 0 if no emojis).
#' @keywords internal
extract_emoji_unicode <- function(text) {
  em <- unlist(stringi::stri_extract_all_regex(text, "\\p{Emoji}"))
  em <- em[!is.na(em)]
  if (!length(em)) return(character(0))

  vapply(
    em,
    function(e) paste(sprintf("%x", utf8ToInt(e)), collapse = "-"),
    FUN.VALUE = character(1)
  )
}

# ----------------------------  get_emoji_sentiment  --------------------------

#' Mean Novak sentiment for a set of Unicode keys
#'
#' @param unicodes  Character vector returned by [extract_emoji_unicode()].
#' @param db        Data frame from [load_novak_table()].
#' @return Numeric scalar sentiment (or `NA_real_` if none matched).
#' @keywords internal
get_emoji_sentiment <- function(unicodes, db) {
  if (!length(unicodes)) return(NA_real_)
  mean(db$sentiment[match(unicodes, db$unicode)], na.rm = TRUE)
}

# ----------------------------  blend_fixed  ----------------------------------

#' Fixed 70 / 30 blend of text and emoji sentiment
#'
#' @param text_s  VADER compound score.
#' @param emoji_s Mean Novak emoji score.
#' @param text_w  Weight for text sentiment (default 0.7).
#' @return Numeric blended sentiment.
#' @keywords internal
blend_fixed <- function(text_s, emoji_s, text_w = 0.7) {
  if (is.na(emoji_s)) return(text_s)          # text-only
  if (is.na(text_s))  return(emoji_s)         # emoji-only
  emoji_w <- 1 - text_w                       # default 0.3
  text_w  * text_s + emoji_w * emoji_s
}

# ----------------------------  sentiment_analysis  ---------------------------

#' Combined sentiment (VADER text + Novak emoji) with 70 : 30 weighting
#'
#' @param text_vec   Character vector (e.g., tweets).
#' @param text_weight Numeric in \[0, 1\]; share given to VADER score
#'                    (default **0.7**). Emoji gets the remainder.
#' @param emoji_db   Optional custom emoji table (`unicode`, `sentiment`);
#'                   defaults to the bundled Novak data.
#'
#' @return Data frame with four columns:
#' \itemize{
#'   \item \code{tweet}              – original input text
#'   \item \code{text_sentiment}     – VADER compound score
#'   \item \code{emoji_sentiment}    – mean emoji polarity
#'   \item \code{combined_sentiment} – 0.7 / 0.3 blended score
#' }
#'
#' @examples
#' txt <- c("Love R tidyverse! 😍🔥",
#'          "Awful bug… nothing works 😡",
#'          "Just text, no emoji.")
#' sentiment_analysis(txt)
#'
#' @export
sentiment_analysis <- function(text_vec,
                               text_weight = 0.7,
                               emoji_db    = load_novak_table()) {

  if (!is.numeric(text_weight) || text_weight < 0 || text_weight > 1)
    stop("`text_weight` must be numeric in [0, 1].")

  # ---- Text sentiment via VADER -------------------------------------------
  text_sent <- vader::vader_df(text_vec)$compound   # one row per element

  # ---- Emoji sentiment ----------------------------------------------------
  emoji_sent <- vapply(
    text_vec,
    function(t) {
      uc <- extract_emoji_unicode(t)
      get_emoji_sentiment(uc, emoji_db)
    },
    FUN.VALUE = numeric(1)
  )

  # ---- Fixed-weight blend --------------------------------------------------
  combined <- mapply(blend_fixed, text_sent, emoji_sent,
                     MoreArgs = list(text_w = text_weight))

  # ---- Assemble tidy data frame -------------------------------------------
  data.frame(
    tweet              = text_vec,
    text_sentiment     = round(text_sent,   3),
    emoji_sentiment    = round(emoji_sent,  3),
    combined_sentiment = round(combined,    3),
    stringsAsFactors   = FALSE
  )
}
