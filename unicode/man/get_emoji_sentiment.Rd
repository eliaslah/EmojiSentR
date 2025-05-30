% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sentiment_helpers.R
\name{get_emoji_sentiment}
\alias{get_emoji_sentiment}
\title{Mean Novak sentiment for a set of Unicode keys}
\usage{
get_emoji_sentiment(unicodes, db)
}
\arguments{
\item{unicodes}{Character vector returned by [extract_emoji_unicode()].}

\item{db}{Data frame from [load_novak_table()].}
}
\value{
Numeric scalar sentiment (or `NA_real_` if none matched).
}
\description{
Mean Novak sentiment for a set of Unicode keys
}
\keyword{internal}
