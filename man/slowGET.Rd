\name{slowGET}
\alias{slowGET}
\title{A throttled version of GET}
\usage{
slowGET(url, pause = NULL, ...)
}
\arguments{
  \item{pause}{The time between calls to a domain. Defaults
  to 10. Can be set generally with
  \code{options(SlowGetPause=VALUE)}.}

  \item{url}{URL to getch}

  \item{...}{other arguments to pass to \code{httr::GET}}
}
\description{
This uses \code{httr::GET} to fetch a web page, but
throttles based on domains.
}
\details{
\code{slowGET} keeps a list of domains recently accessed by
itself in a separate environment.  If a domain has been
accessed since \code{pause} seconds ago, it will delay
execution until that time has passed
}

