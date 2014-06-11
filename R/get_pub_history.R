#  Get publication date from journals

#' @import httr stringi plyr XML
get_ecollet_pub_history = function(doi) {
  page = GET(paste0("http://onlinelibrary.wiley.com/doi/", doi, "/abstract"))
  ab_XML = htmlTreeParse(content(page, "text"), useInternalNodes=T, asText=TRUE)
  out = list(doi = xpathApply(ab_XML, '//meta[@name="citation_doi"]', xmlGetAttr, "content")[[1]],
             journal = xpathApply(ab_XML, '//meta[@name="citation_journal_title"]', xmlGetAttr, "content")[[1]],
             volume = as.integer(xpathApply(ab_XML, '//meta[@name="citation_volume"]', xmlGetAttr, "content")[[1]]),
             issue = as.integer(xpathApply(ab_XML, '//meta[@name="citation_issue"]', xmlGetAttr, "content")[[1]]),
             issuedate = as.Date(xpathApply(ab_XML, '//meta[@name="citation_publication_date"]', xmlGetAttr, "content")[[1]]),
             onlinedate = as.Date(xpathApply(ab_XML, '//meta[@name="citation_online_date"]', xmlGetAttr, "content")[[1]])
             )     
  pubhistory = unlist(xpathApply(ab_XML, '//div[@id="publicationHistoryDetails"]/ol/li', xmlValue))
  editor = stri_match_all_regex(pubhistory, "[eE]ditor[[:punct:]\\s]+([[:alpha:][:punct:]]+\\s[[:alpha:][:punct:]]+)[^\\w]")
  out$editor = try(editor[unlist(llply(editor, function(x) !any(is.na(x))))][[1]][2], silent=TRUE)
  if (class(out$editor) =="try-error") out$editor = NA
  dates = stri_match_all_regex(pubhistory, "([[:alpha:]\\s]+):\\s+(\\d{1,2}\\s+[[:alpha:]]+\\s+\\d{4})")
  dates2 = stri_match_all_regex(pubhistory, "([[:upper:]][[:lower:]\\s]+)\\s+(\\d{1,2}\\s+[[:alpha:]]+\\s+\\d{4})")
  dates3 = do.call(rbind, c(dates, dates2))
  dates3 = matrix(dates3[!is.na(dates3)], ncol=3)
  pubdates = as.list(as.Date(dates3[,3], "%d %b %Y"))
  names(pubdates) = dates3[,2]
  return(c(out, pubdates))
}

#' @import httr stringi plyr XML
get_condor_pub_history = function(doi) {
  page = GET(paste0("http://www.bioone.org/doi/abs/", doi))
  ab_XML = htmlTreeParse(content(page, "text"), useInternalNodes=T, asText=TRUE)
  out = list(doi = xpathApply(ab_XML, '//meta[@name="dc.Identifier" and @scheme="doi"]', xmlGetAttr, "content")[[1]],  
             volume = as.integer(stri_match_first_regex(content(page, "text"), "Volume\\s+(\\d{1,3})[^\\w]")[2]),
             issue = as.integer(stri_match_first_regex(content(page, "text"), "Issue\\s+(\\d{1,3})[^\\w]")[2]),
             onlinedate = as.Date(xpathApply(ab_XML, '//meta[@name="dc.Date" and @scheme="WTN8601"]', xmlGetAttr, "content")[[1]]),  
             recieveddate = as.Date(stri_match_first_regex(content(page, "text"), "Received:\\s+</strong>([[:alpha:]]+\\s+\\d{1,2},\\s+\\d{4})")[2], "%B %d, %Y"),
             acceptdate = as.Date(stri_match_first_regex(content(page, "text"), "Accepted:\\s+</strong>([[:alpha:]]+\\s+\\d{1,2},\\s+\\d{4})")[2], "%B %d, %Y"),
             issuedate = as.Date(paste("1", stri_match_first_regex(content(page, "text"), "[[:upper:]][[:lower:]]{2} \\d{4}")), "%d %b %Y")
  )
  return(out)
}

#' @import rplos XML
get_plos_pub_history = function(doi) {
  ft_XML = xmlParse(plos_fulltext(doi), useInternalNodes=T, asText=TRUE)
  out = list(
      volume = as.integer(xpathApply(ft_XML, '//article-meta//volume', xmlValue)),
      issue = as.integer(xpathApply(ft_XML, '//article-meta//issue', xmlValue)),
      receiveddate = as.Date(paste0(xpathApply(ft_XML, '//history/date[@date-type="received"]/*', xmlValue), collapse="-"), "%d-%m-%Y"),
      acceptdate = as.Date(paste0(xpathApply(ft_XML, '//history/date[@date-type="accepted"]/*', xmlValue), collapse="-"), "%d-%m-%Y"),
      onlinedate = as.Date(paste0(xpathApply(ft_XML, '//article-meta//pub-date[@pub-type="epub"]/*', xmlValue), collapse="-"), "%d-%m-%Y"),
      editor = paste(rev(unlist(xpathApply(ft_XML, '//contrib[@contrib-type="editor"]/name/*', xmlValue))), collapse=" ")
  )
  return(out)
}

#' @import httr stringi plyr XML
get_peerj_pub_history = function(doi) {
  ft_XML = GET(paste0("https://peerj.com/articles/", stri_match_first_regex(doi, "(?<=peerj\\.)\\d+$"), ".xml"))
  ft_XML = xmlParse(content(ft_XML, "text"), useInternalNodes=T, asText = TRUE)
  out = list(
      volume = as.integer(xpathApply(ft_XML, '//article-meta//volume', xmlValue)),
      receiveddate = as.Date(paste0(xpathApply(ft_XML, '//history/date[@date-type="received"]/*', xmlValue), collapse="-"), "%d-%m-%Y"),
      acceptdate = as.Date(paste0(xpathApply(ft_XML, '//history/date[@date-type="accepted"]/*', xmlValue), collapse="-"), "%d-%m-%Y"),
      onlinedate = as.Date(paste0(xpathApply(ft_XML, '//article-meta//pub-date[@pub-type="epub"]/*', xmlValue), collapse="-"), "%d-%m-%Y"),
      editor = paste(rev(unlist(xpathApply(ft_XML, '//contrib[@contrib-type="editor"]/name/*', xmlValue))), collapse=" ")
  )
}

#' @import httr stringi plyr XML
get_amnat_pub_history = function(doi) {
  page = GET(paste0("http://www.jstor.org/stable/info/", doi))
  ab_XML = htmlTreeParse(content(page, "text"), useInternalNodes=T, asText=TRUE)
  out = list(doi = xpathApply(ab_XML, '//meta[@name="dc.Identifier" and @scheme="doi"]', xmlGetAttr, "content")[[1]],  
             volume = as.integer(stri_match_first_regex(content(page, "text"), "Vol.\\s+(\\d{1,3})[^\\w]")[2]),
             issue = as.integer(stri_match_first_regex(content(page, "text"), "No.\\s+(\\d{1,3})[^\\w]")[2]),
             issuedate = as.Date(xpathApply(ab_XML, '//meta[@name="dc.Date" and @scheme="WTN8601"]', xmlGetAttr, "content")[[1]], "%B %d, %Y")
            )
  datestring = xpathApply(ab_XML, '//p[@class="articleBody_submissionDate"]/span[@class="string-date"]', xmlValue)[[1]]
  if(!is.null(datestring)) {
    datevals = stri_match_all_regex(datestring, "([[:upper:]][[:lower:]\\s]+)\\s+([[:alpha:]]+\\s+\\d{1,2},\\s+\\d{4})")[[1]]
    dates = as.list(as.Date(datevals[,3], "%B %d, %Y"))
    names(dates) = datevals[,2]
    return(c(out,dates))
  } else {
    return(out)
  }
}


#' @import httr stringi plyr XML
get_esa_pub_history = function(doi) {
  page = content(GET(paste0("http://www.esajournals.org/doi/abs/", doi)), "text")
  ab_XML = htmlTreeParse(page, useInternalNodes=T, asText=TRUE)
  out = list(doi = doi,
             volume = as.integer(stri_match_first_regex(page, 'Volume ([0-9]{1,2}),')[,2]),
             issue = as.integer(stri_match_first_regex(page, 'Issue ([0-9]{1,2})')[,2]),
             issuedate = as.Date(paste("01", stri_match_first_regex(page, 'Issue [0-9]{1,2} \\(([[:alpha:]]+ [[:digit:]]{4})\\)')[,2]), "%d %B %Y"),
             onlinedate = as.Date(xpathApply(ab_XML, '//meta[@name="dc.Date" and @scheme="WTN8601"]', xmlGetAttr, "content")[[1]]),
             editor = stri_match_first_regex(page, 'Editor: ((?:[[:upper:]]\\.\\s?)*[^\\.<$]+)[^\\.<$]')[,2]
  )
  dates = stri_match_all_regex(page, '(Received|Revised|Accepted|Final version received|<b>Received</b>|revised|accepted|final version received|<b>published</b>): ([[:alnum:][:space:],]+)[;<\\.]')
  if (all(is.na(dates[[1]]))) {
    return(out)
  } else {
    datefields = as.list(as.Date(dates[[1]][,3], "%B %d, %Y"))
    names(datefields) = dates[[1]][,2]
  }
  return(c(out, datefields))
}

#' @import httr stringi plyr XML
get_ecosph_pub_history = function(doi) {
  page = content(GET(paste0("http://www.esajournals.org/doi/abs/", doi)), "text")
  ab_XML = htmlTreeParse(page, useInternalNodes=T, asText=TRUE)
  out = list(doi = doi,
             volume = as.integer(stri_match_first_regex(page, 'Volume ([0-9]{1,2}),')[,2]),
             issue = as.integer(stri_match_first_regex(page, 'Issue ([0-9]{1,2})')[,2]),
             issuedate = as.Date(paste("01", stri_match_first_regex(page, 'Issue [0-9]{1,2} \\(([[:alpha:]]+ [[:digit:]]{4})\\)')[,2]), "%d %B %Y"),
             onlinedate = as.Date(xpathApply(ab_XML, '//meta[@name="dc.Date" and @scheme="WTN8601"]', xmlGetAttr, "content")[[1]]),
             editor = stri_match_first_regex(page, 'Editor: ([^<]*)\\.<')[,2]
  )
  dates = stri_match_all_regex(page, '(Received|Revised|Accepted|Final version received|<b>Received</b>|revised|accepted|final version received|<b>published</b>):? ([[:alnum:][:space:],]+)[;<\\.]')
  if (all(is.na(dates[[1]]))) {
    return(out)
  } else {
    datefields = as.list(as.Date(dates[[1]][,3], "%d %B %Y"))
    names(datefields) = dates[[1]][,2]
  }
  return(c(out, datefields))
}

#' @export
#' @import rcrossref
get_pub_history = function(doi, oa_only=TRUE) {
  citation = cr_citation(doi)
  closed = c("The American Naturalist")
  if(citation$journal %in% closed & oa_only) return(closed_journal(citation))
  pubhistory = switch(citation$journal,
        `PLoS ONE` = get_plos_pub_history(doi),
        `Ecology Letters` = get_ecollet_pub_history(doi),
        `Ecology` = get_esa_pub_history(doi),
        `Ecosphere` = get_ecosph_pub_history(doi),
        `Ecological Applications` = get_esa_pub_history(doi),
        `Ecological Monographs` = get_esa_pub_history(doi),
        `The Condor` = get_condor_pub_history(doi),
        `The American Naturalist` = get_amnat_pub_history(doi),
        `PeerJ` = get_peerj_pub_history(doi),
         return(unsupported_pub_history(citation))
  )
  pubhistory$journal = citation$journal
  pubhistory$volume = citation$volume
  pubhistory = standardize_datenames(pubhistory)
  return(pubhistory)
}

unsupported_pub_history = function(citation) {
  warning(paste(citation$journal), "is not yet supported. Returning NA values for dates.")
  return(list(doi = citation$doi, journal = citation$journal, volume= citation$volume, issue=citation$month))
}

closed_journal = function(citation) {
  warning(paste(citation$journal), "requires a subscription to access this data. Returning NA values for dates.")
  return(list(doi = citation$doi, journal = citation$journal, volume= citation$volume, issue=citation$month))
}
  
standardize_datenames = function(pubhistory) {
  names(pubhistory) = tolower(names(pubhistory))
  datenames = list(
    submitted = c("received", "submitted", "recieveddate", "<b>received</b>", "manuscript received"),
    revised = c("revised"),
    decision = c("first decision", "decision", "first decision made"),
    accepted = c("accepted", "acceptdate", "manuscript accepted"),
    online = c("electronically published", "published online", "onlinedate", "article first published online", "online", "<b>published</b>"),
    finalversion = c("final version received", "finalversion"),
    issueonline = c("issue published online", "issueonline"),
    issuedate = c("issue published", "issuedate", "issuedate"),
    editor = c("editor")
  )
  for(i in 1:length(datenames)) {
    matches = names(pubhistory) %in% datenames[[i]]
    if(!any(matches)) {
      pubhistory[[names(datenames)[i]]] = NA
    } else {
      names(pubhistory)[matches] = names(datenames)[i]
    }
  }
  pubhistory = pubhistory[c("doi", "journal", "volume", "issue", "editor", "submitted",
                            "revised", "decision", "accepted", "online", "finalversion",
                            "issueonline", "issuedate")]
}