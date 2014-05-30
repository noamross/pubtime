# Functions to extract article data from the ESA website

#' Pull all the URLs of abstracts from an ESA journal table of contents
#' @export
#' @import RCurl stringi
get_esa_abtract_urls = function(journal, vol, issue) {
  URL = paste0("http://www.esajournals.org/toc/", journal, "/", vol, "/", issue)
  toc_page =getURL(URL, cookiejar=tempfile(), followlocation=TRUE)
  ab_urls = stri_match_all_regex(toc_page,
                          '(/doi/abs/10\\.[0-9]{4,}/[[:alnum:]\\.-]+)">Abstract</a>'
                          )[[1]][,2]
  if (is.na(ab_urls)) return(NA)
  ab_urls = paste0("http://www.esajournals.org", ab_urls)
  return(ab_urls)
}

#' Get some (limited) data on an ESA journal article
#' @export
#' @import RCurl stringi
get_esa_article_data = function(url) {
  ab_page = getURL(url, cookiejar=tempfile(), followlocation=TRUE)
  out = list(doi = stri_match_first_regex(ab_page, '<meta name="dc.Identifier" scheme="doi" content="(10\\.[0-9]{4,}/[0-9\\.-]+)" />')[,2],
             vol = stri_match_first_regex(ab_page, 'Volume ([0-9]{1,2}),')[,2],
             issue = stri_match_first_regex(ab_page, 'Issue ([0-9]{1,2})')[,2],
             issuedate = stri_match_first_regex(ab_page, 'Issue [0-9]{1,2} \\(([[:alpha:]]+ [[:digit:]]{4})\\)')[,2],
             onlinedate = stri_match_first_regex(ab_page, '<meta name="dc.Date" scheme="WTN8601" content="([0-9-]+)" />')[,2],
             editor = stri_match_first_regex(ab_page, 'Editor: (.*)\\.</p>')[,2])  #consider using md5::md5(raw("editor")) to anonymize  
  dates = stri_match_all_regex(ab_page, '(Received:|Revised:|Accepted:|Final version received:|<b>Received</b>|revised|accepted|final version received|<b>published</b>) ([[:alnum:][:space:],]+)[;<\\.]')
  if (all(is.na(dates[[1]]))) {
    return(out)
  } else {
    datefields = as.list(dates[[1]][,3])
    names(datefields) = dates[[1]][,2]
  }
  return(c(out, datefields))
}