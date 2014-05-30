# Functions to extract article data from the ESA website

#' Pull all the URLs of abstracts from an ESA journal table of contents
#' @export
#' @import httr stringr
get_esa_abtract_urls = function(journal, vol, issue) {
  URL = paste0("http://www.esajournals.org/toc/", journal, "/", vol, "/", issue)
  toc_page =getURL(URL, cookiejar=tempfile(), followlocation=TRUE)
  ab_urls = str_match_all(toc_page,
                          '(/doi/abs/10\\.[0-9]{4,}/[0-9\\.-]+)">Abstract</a>'
                          )[[1]][,2]
  ab_urls = paste0("http://www.esajournals.org", ab_urls)
  return(ab_urls)
}

#' Get some (limited) data on an ESA journal article
#' @export
#' @import httr stringr
get_esa_article_data = function(url) {
  ab_page = getURL(url, cookiejar=tempfile(), followlocation=TRUE)
  out = list(doi = str_match(ab_page, '<meta name="dc.Identifier" scheme="doi" content="(10\\.[0-9]{4,}/[0-9\\.-]+)" />')[,2],
             vol = str_match(ab_page, 'Volume ([0-9]{1,2}),')[,2],
             issue = str_match(ab_page, 'Issue ([0-9]{1,2})')[,2],
             publishdate = str_match(ab_page, '<meta name="dc.Date" scheme="WTN8601" content="([0-9-]+)" />')[,2],
             editor = str_match(ab_page, 'Editor: (.*)\\.</p>')[,2])  #consider using md5::md5(raw("editor")) to anonymize
  dates = str_match_all(ab_page, '(Received|Revised|Accepted|Final version received): ([[:alnum:][:space:],]+)[;<]')
  datefields = as.list(dates[[1]][,3])
  names(datefields) = dates[[1]][,2]
  return(c(out, datefields))
}