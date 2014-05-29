# Functions to extract article data from the ESA website

#' @export
#' @import httr stringr
get_esa_abtract_urls <- function(journal, vol, issue) {
  URL = paste0("http://www.esajournals.org/toc/", journal, "/", vol, "/" issue)
  toc_page = GET(URL)
  abstracts = str_extract_all(toc_page, "<a class="ref nowrap " href="/doi/abs/10.1890/12-1339.1">Abstract</a>"
}