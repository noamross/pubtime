# Functions for scraping dates from various journals

#' @import httr XML
#' @importFrom stringi stri_match_first_regex
get_royal_pub_history = function(doi) {
  page = GET(paste0("http://dx.doi.org/", doi))
  ab_XML = htmlTreeParse(content(page, "text"), useInternalNodes=T, asText=TRUE)
  out = list(receiveddate = as.Date(xpathApply(ab_XML, '//li[@class="received"]', xmlGetAttr, "hwp:start")[[1]]),
             acceptdate = as.Date(xpathApply(ab_XML, '//li[@class="accepted"]', xmlGetAttr, "hwp:start")[[1]]),
             issuedate = as.Date(xpathApply(ab_XML, '//meta[@name="DC.Date"]', xmlGetAttr, "content")[[1]]),
             onlinedate = as.Date(stri_match_first_regex(xpathApply(ab_XML, '//div[@id="slugline"]', xmlValue)[[1]], "\\d{2} [[:alpha:]]+ \\d{4}"), "%d %B %Y")
             )
  return(out)
}

#' @import httr XML
get_springer_pub_history = function(doi) {
  page = GET(paste0("http://dx.doi.org/", doi))
  ab_XML = htmlTreeParse(content(page, "text"), useInternalNodes=T, asText=TRUE)
  out = list(receiveddate = as.Date(xpathApply(ab_XML, '//span[@class="History HistoryReceived"]/span[@class="HistoryDate"]', xmlValue)[[1]], "%d %B %Y"),
             acceptdate = as.Date(xpathApply(ab_XML, '//span[@class="History HistoryAccepted"]/span[@class="HistoryDate"]', xmlValue)[[1]], "%d %B %Y"),
             issuedate = as.Date(xpathApply(ab_XML, '//meta[@name="DC.Date"]', xmlGetAttr, "content")[[1]]),
             onlinedate = as.Date(xpathApply(ab_XML, '//span[@class="History HistoryOnlineDate"]/span[@class="HistoryDate"]', xmlValue)[[1]], "%d %B %Y"),
             )
  return(out)
}

#' @import httr plyr XML
#' @importFrom stringi stri_match_all_regex
get_wiley_pub_history = function(doi) {
  page = GET(paste0("http://onlinelibrary.wiley.com/doi/", doi, "/abstract"))
  ab_XML = htmlTreeParse(content(page, "text"), useInternalNodes=T, asText=TRUE)
  out = list(onlinedate = as.Date(xpathApply(ab_XML, '//meta[@name="citation_online_date"]', xmlGetAttr, "content")[[1]])             )     
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

#' @import httr plyr XML
#' @importFrom stringi stri_match_first_regex
get_condor_pub_history = function(doi) {
  page = GET(paste0("http://www.bioone.org/doi/abs/", doi))
  ab_XML = htmlTreeParse(content(page, "text"), useInternalNodes=T, asText=TRUE)
  out = list(onlinedate = as.Date(xpathApply(ab_XML, '//meta[@name="dc.Date" and @scheme="WTN8601"]', xmlGetAttr, "content")[[1]]),  
             receiveddate = as.Date(stri_match_first_regex(content(page, "text"), "Received:\\s+</strong>([[:alpha:]]+\\s+\\d{1,2},\\s+\\d{4})")[2], "%B %d, %Y"),
             acceptdate = as.Date(stri_match_first_regex(content(page, "text"), "Accepted:\\s+</strong>([[:alpha:]]+\\s+\\d{1,2},\\s+\\d{4})")[2], "%B %d, %Y"),
             issuedate = as.Date(paste("1", stri_match_first_regex(content(page, "text"), "[[:upper:]][[:lower:]]{2} \\d{4}")), "%d %b %Y")
  )
  return(out)
}

#' @import rplos XML
get_plos_pub_history = function(doi) {
  ft_XML = xmlParse(plos_fulltext(doi), useInternalNodes=T, asText=TRUE)
  out = list(
      receiveddate = as.Date(paste0(xpathApply(ft_XML, '//history/date[@date-type="received"]/*', xmlValue), collapse="-"), "%d-%m-%Y"),
      acceptdate = as.Date(paste0(xpathApply(ft_XML, '//history/date[@date-type="accepted"]/*', xmlValue), collapse="-"), "%d-%m-%Y"),
      onlinedate = as.Date(paste0(xpathApply(ft_XML, '//article-meta//pub-date[@pub-type="epub"]/*', xmlValue), collapse="-"), "%d-%m-%Y"),
      editor = paste(rev(unlist(xpathApply(ft_XML, '//contrib[@contrib-type="editor"]/name/*', xmlValue))), collapse=" ")
  )
  return(out)
}

#' @import httr XML
get_peerj_pub_history = function(doi) {
  ft_XML = GET(paste0("https://peerj.com/articles/", stri_match_first_regex(doi, "(?<=peerj\\.)\\d+$"), ".xml"))
  ft_XML = xmlParse(content(ft_XML, "text"), useInternalNodes=T, asText = TRUE)
  out = list(receiveddate = as.Date(paste0(xpathApply(ft_XML, '//history/date[@date-type="received"]/*', xmlValue), collapse="-"), "%d-%m-%Y"),
             acceptdate = as.Date(paste0(xpathApply(ft_XML, '//history/date[@date-type="accepted"]/*', xmlValue), collapse="-"), "%d-%m-%Y"),
             onlinedate = as.Date(paste0(xpathApply(ft_XML, '//article-meta//pub-date[@pub-type="epub"]/*', xmlValue), collapse="-"), "%d-%m-%Y"),
             editor = paste(rev(unlist(xpathApply(ft_XML, '//contrib[@contrib-type="editor"]/name/*', xmlValue))), collapse=" ")
            )
}

#' @import httr XML
#' @importFrom stringi stri_match_first_regex stri_match_all_regex
get_amnat_pub_history = function(doi) {
  page = GET(paste0("http://www.jstor.org/stable/info/", doi))
  ab_XML = htmlTreeParse(content(page, "text"), useInternalNodes=T, asText=TRUE)
  out = list(issuedate = as.Date(xpathApply(ab_XML, '//meta[@name="dc.Date" and @scheme="WTN8601"]', xmlGetAttr, "content")[[1]], "%B %d, %Y"))
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

#' @import httr XML
#' @importFrom stringi stri_match_first_regex stri_match_all_regex
get_esa_pub_history = function(doi) {
  page = content(GET(paste0("http://www.esajournals.org/doi/abs/", doi)), "text")
  ab_XML = htmlTreeParse(page, useInternalNodes=T, asText=TRUE)
  out = list(issuedate = as.Date(paste("01", stri_match_first_regex(page, 'Issue [0-9]{1,2} \\(([[:alpha:]]+ [[:digit:]]{4})\\)')[,2]), "%d %B %Y"),
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

#' @import httr XML
#' @importFrom stringi stri_match_first_regex stri_match_all_regex
get_ecosph_pub_history = function(doi) {
  page = content(GET(paste0("http://www.esajournals.org/doi/abs/", doi)), "text")
  ab_XML = htmlTreeParse(page, useInternalNodes=T, asText=TRUE)
  out = list(issuedate = as.Date(paste("01", stri_match_first_regex(page, 'Issue [0-9]{1,2} \\(([[:alpha:]]+ [[:digit:]]{4})\\)')[,2]), "%d %B %Y"),
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
