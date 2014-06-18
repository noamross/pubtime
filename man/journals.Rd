\docType{data}
\name{journals}
\alias{journals}
\title{Supported journals}
\format{data.frame (stored as CSV)}
\usage{
journals
}
\value{
\item{name}{The journal name, as it appears in CrossRef}
\item{shortname}{A shortened journal name for convenience}
\item{ISSN}{The journal ISSN} \item{open}{Is publication
history for the journal available without a subscription?
That is, is the journal open-acess or does the history
appear on a publicly-viewable abstract page?}
\item{scraper}{The name of the function to scrape
publication dates from the journal website}
}
\description{
A data frame of journals currently supported by the
package.
}
\keyword{datasets}

