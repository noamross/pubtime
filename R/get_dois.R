#' Use crossref metadata search to get all DOIs for a journal over a time period
#' @param ISSN The journal ISSN number
#' @param years a vector of years for which
#' @export
#' @import rcrossref plyr
#' @importFrom stringi stri_replace_first_fixed
get_dois = function(ISSN, years) {
  dois = adply(years, 1, function(i) {
                d = cr_search(query=ISSN, sort="year", type="Journal Article",
                    rows=1000, year=i)
                if(class(d) == "character") return(NULL) else return(d) 
          })
  return(stri_replace_first_fixed(dois$doi, "http://dx.doi.org/", ""))
}

