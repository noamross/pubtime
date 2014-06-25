#' Retreive the publication history of a journal article from its DOI
#' 
#' @param doi The DOI of the journal article
#' @param oa_only When TRUE, the function will not attempt to retreat information
#' from articles whose publication histories are behind a paywall
#' @return A list with the DOI, journal, volume, editor and publication history
#' dates of the article. Unavailable publication history dates will be NA. The
#' possible categories of dates are:
#' 
#' \item{submitted}{The date the article was sent in}
#' \item{decision}{The date an initial decision (e.g., major revisions), was reached on the article}
#' \item{revised}{The date an updated version of the article was sent}
#' \item{accepted}{The date the article was accepted for publication}
#' \item{finalversion}{The date a finalized version was received, following an initial or final acceptance decision}
#' \item{preprint}{The date a pre-typeset version of the article appeared online}
#' \item{online}{The date the article appeared online}
#' \item{issueonline}{The date the issue that the article is in appeared online}
#' \item{issuedate}{The date the issue was published}
#' 
#' Most articles do not have all this information.  In general, one expects to
#' have dates for submission, acceptance, and publication
#' @export
#' @import rcrossref XML
get_pub_history = function(doi, oa_only=FALSE) {
  citation_xml = cr_cn(doi, "crossref-xml")
  
  pubhistory=list()
  pubhistory$doi = doi
  pubhistory$journal = xpathSApply(citation_xml, "//full_title", xmlValue)
  pubhistory$volume = xpathSApply(citation_xml, "//journal_volume/volume",
                                  xmlValue) 
  
  jmatch = journals$name %in% pubhistory$journal
  
  if(!any(jmatch)) {
    stop(paste("Scraping for", pubhistory$journal, "is not (yet) supported"))
  } else if(!journals$open[jmatch] & oa_only) {
    stop(paste("Publication dates for", pubhistory$journal,
         "not available without subscription access"))
  } else {
    pubhistory = c(pubhistory, 
                   do.call(journals$scraper[jmatch], list(doi=pubhistory$doi)))
  }
  
  pubhistory = standardize_datenames(pubhistory)
  return(pubhistory)
}

#' Convert the terms for publications provided by the publishers to standard
#' names
standardize_datenames = function(pubhistory) {
  names(pubhistory) = tolower(names(pubhistory))
  for(i in 1:length(datenames)) {
    matches = names(pubhistory) %in% datenames[[i]]
    if(!any(matches)) {
      pubhistory[[names(datenames)[i]]] = NA
    } else {
      names(pubhistory)[matches] = names(datenames)[i]
    }
  }
  pubhistory = pubhistory[c("doi", "journal", "volume", 
                            names(datenames))]
}
