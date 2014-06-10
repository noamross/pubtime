# Get data from Wiley Journals, esp. Ecology letters

#' Get the DOIs of a journal for a date range
#' @export
#' @import RCurl stringi
#giet_all_wiley_dois(journal, date_range) 

#' Get the data from an article DOI
#' @export
#' @import httr stringi plyr XML
get_wiley_article_data = function(page) {
  page = GET(paste0("http://dx.doi.org/", doi))
  ab_XML = htmlTreeParse(content(page, "text"), useInternalNodes=T, asText=TRUE)
  out = list(doi = xpathApply(ab_XML, '//meta[@name="citation_doi"]', xmlGetAttr, "content")[[1]],
             journal = xpathApply(ab_XML, '//meta[@name="citation_journal_title"]', xmlGetAttr, "content")[[1]],
             vol = as.integer(xpathApply(ab_XML, '//meta[@name="citation_volume"]', xmlGetAttr, "content")[[1]]),
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

get_bioone_pub_history = function(page) {
  page = GET(paste0("http://dx.doi.org/", doi))
  ab_XML = htmlTreeParse(content(page, "text"), useInternalNodes=T, asText=TRUE)
  out = list(doi = xpathApply(ab_XML, '//meta[@name="dc.Identifier" and @scheme="doi"]', xmlGetAttr, "content")[[1]],  
             volume = as.integer(stri_match_first_regex(content(page, "text"), "Volume\\s+(\\d{1,3})[^\\w]")[2]),
             issue = as.integer(stri_match_first_regex(content(page, "text"), "Issue\\s+(\\d{1,3})[^\\w]")[2]),
             onlinedate = as.Date(xpathApply(ab_XML, '//meta[@name="dc.Date" and @scheme="WTN8601"]', xmlGetAttr, "content")[[1]]),  
             recieveddate = as.Date(stri_match_first_regex(content(page, "text"), "Received:\\s+</strong>([[:alpha:]]+\\s+\\d{1,2},\\s+\\d{4})")[2], "%B %d, %Y"),
             acceptdate = as.Date(stri_match_first_regex(content(page, "text"), "Accepted:\\s+</strong>([[:alpha:]]+\\s+\\d{1,2},\\s+\\d{4})")[2], "%B %d, %Y")
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
}

get_peerj_pub_history = function(doi) {
  ft_XML = GET(gsub("/$", ".xml", HEAD(paste0("http://dx.doi.org/", doi))$url))
  ft_XML = xmlParse(content(ft_XML, "text"), useInternalNodes=T, asText = TRUE)
  out = list(
      volume = as.integer(xpathApply(ft_XML, '//article-meta//volume', xmlValue)),
      receiveddate = as.Date(paste0(xpathApply(ft_XML, '//history/date[@date-type="received"]/*', xmlValue), collapse="-"), "%d-%m-%Y"),
      acceptdate = as.Date(paste0(xpathApply(ft_XML, '//history/date[@date-type="accepted"]/*', xmlValue), collapse="-"), "%d-%m-%Y"),
      onlinedate = as.Date(paste0(xpathApply(ft_XML, '//article-meta//pub-date[@pub-type="epub"]/*', xmlValue), collapse="-"), "%d-%m-%Y"),
      editor = paste(rev(unlist(xpathApply(ft_XML, '//contrib[@contrib-type="editor"]/name/*', xmlValue))), collapse=" ")
  )

get_pub_history = function(doi, oa_only=TRUE) {
  citation = cr_citation("10.1371/journal.pone.0086169")
  page = GET(paste0("http://dx.doi.org/", doi))
  domain = stri_match_first_regex(page$url, "(http|https)://([^\\/]+)[\\/$]")[3]
  pubhistory = switch(citation$journal,
        `PLoS ONE` = get_plos_pub_history(doi),
        `Ecology Letters` = get_wiley_pub_history(doi),
        `Ecology` = get_esa_pub_history(doi),
        `The Condor` = get_bioone_pub_history(doi)
  return(pubhistory)
}
    

}