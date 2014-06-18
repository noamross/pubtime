\name{get_pub_history}
\alias{get_pub_history}
\title{Retreive the publication history of a journal article from its DOI}
\usage{
get_pub_history(doi, oa_only = FALSE)
}
\arguments{
  \item{doi}{The DOI of the journal article}

  \item{oa_only}{When TRUE, the function will not attempt
  to retreat information from articles whose publication
  histories are behind a paywall}
}
\value{
A list with the DOI, journal, volume, editor and
publication history dates of the article. Unavailable
publication history dates will be NA. The possible
categories of dates are:

\item{submitted}{The date the article was sent in}
\item{decision}{The date an initial decision (e.g., major
revisions), was reached on the article} \item{revised}{The
date an updated version of the article was sent}
\item{accepted}{The date the article was accepted for
publication} \item{finalversion}{The date a finalized
version was received, following an initial or final
acceptance decision} \item{preprint}{The date a pre-typeset
version of the article appeared online} \item{online}{The
date the article appeared online} \item{issueonline}{The
date the issue that the article is in appeared online}
\item{issuedate}{The date the issue was published}

Most articles do not have all this information.  In
general, one expects to have dates for submission,
acceptance, and publication
}
\description{
Retreive the publication history of a journal article from
its DOI
}

