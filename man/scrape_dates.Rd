\name{scrape_dates}
\alias{scrape_dates}
\title{Scrape publication dates from many DOIs, with throttling and writing to files}
\usage{
scrape_dates(dois, pause = 20, filename = "_pubtimes.csv",
  split_journals = TRUE, errors = "pubtime_errs.csv", progress = FALSE,
  silent_errs = TRUE)
}
\arguments{
  \item{dois}{A vector or list vectors of DOIs}

  \item{pause}{The amount of time to wait between
  requesting articles from a site}

  \item{filename}{The CSV file to write results to}

  \item{split_journals}{When TRUE, results from different
  journals are written to different CSV files. In this
  case, the name of the journal will be prepended to
  \code{filename}.}

  \item{errors}{The name of the file to write the error log
  to}
}
\description{
This function runs \code{get_pub_history} repeatedly on
many DOIs, pausing in between each request in order to
avoid taxing web servers, and writing the results to file
rather than returning a value.When provided a list of
vectors of DOIs, it will pause between each DOI in a
vector, but will rotate between the vectors in different
list. This is meant to allow articles hosted in different
locations to be in different vectors, so that no host is
hit more frequently than the \code{pause} value, but
multiple hosts can be scraped efficiently.
}
\details{
\code{scrape_dates} will append to files if they already
exist.
}

