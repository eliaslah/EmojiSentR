% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/remove_unicode.R
\name{remove_unicode}
\alias{remove_unicode}
\title{Strip, replace, or flag Unicode symbols (emoji, pictographs, control chars)}
\usage{
remove_unicode(
  text,
  mode = c("strip", "replace", "flag"),
  replacement = "",
  keep_newline = TRUE,
  keep_ascii = TRUE
)
}
\arguments{
\item{text}{A character vector *or* a data.frame/tibble when
`mode = "flag"`.}

\item{mode}{`"strip"` (delete symbols), `"replace"` (swap for
`replacement`), or `"flag"` (return logical or add `has_unicode` column).}

\item{replacement}{String inserted when `mode = "replace"`.}

\item{keep_newline}{Keep line/tab (`\\r\\n\\t`) even though they are
control characters.  Default `TRUE`.}

\item{keep_ascii}{When `mode = "strip"`, keep ASCII control bytes
`0x00–0x1F` & `0x7F`.  Default `TRUE`.}
}
\value{
* **strip / replace** → character vector (same length as input)
* **flag** → logical vector *or* original data.frame plus `has_unicode`
  column.
}
\description{
Useful for sanitising Twitter/X text, PDFs converted to text, or any source
that contains emojis, dingbats, private-use characters, or hidden
control bytes that break CSV/parsers.
}
\details{
The default regex matches three Unicode properties
  • `\\p{So}` «Symbol, other»   • `\\p{Cn}` «Unassigned»   • `\\p{Cc}` «Control».
  Edit `unicode_re` in the source if you want more or fewer classes.
}
\examples{
sample <- c("hello 😊", "plain ASCII", "snowman ⛄︎")
remove_unicode(sample)
remove_unicode(sample, mode = "replace", replacement = "<sym>")
df <- data.frame(txt = sample)
remove_unicode(df, mode = "flag")
}
