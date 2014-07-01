\name{get_pub_history}
\alias{get_pub_history}
\title{Get publication history from a DOI}
\usage{
get_pub_history(doi, verbose = TRUE, sortdomains = TRUE, filename = NULL)
}
\arguments{
  \item{doi}{a DOI or vector of DOIs}

  \item{verbose}{show a progress bar?}

  \item{filename}{If TRUE, will write directly to a CSV
  file rather than returning a data frame.  If
  \code{sortdomains==TRUE}, the records will be out of
  order.}

  \item{sortdomains}{if TRUE, sorts domains so as to not
  hit the same domain repeatedly.  See \code{slowGET} to
  see how to control throttling.}
}
\description{
This function takes a DOI, or vector of DOIs, and returns a
data frame with publication history for supported journals
and publishers.  For supported journals and publishers, see
the YAML files in the \code{scrapers} directory.
}
\details{
The data frame has an \code{error} field which will be
\code{TRUE} if there was a problem scraping the page.
}

