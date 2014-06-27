scraper_loc = system.file("scrapers", package="pubtime")
scraper_files = file.path(scraper_loc, list.files(scraper_loc,
                                                 pattern="[^.]\\.yaml"))
scrapers = plyr::alply(scraper_files, 1, yaml::yaml.load_file)


#' @importFrom rcrossref cr_cn
#' @importFrom plyr ldply adply
#' @export 
get_pub_history = function(doi, verbose=TRUE) {
  #check if doi is in local repo
  #check if doi is in main dataset
  #get info from crossref
  if(verbose) message("Getting crossref metadata")
  citation_xml = cr_cn(doi, "crossref-xml")
  if (!is.list(citation_xml)) citation_xml = list(citation_xml)
  
  pubhistory_df = ldply(citation_xml, function(z) {
                    data.frame(doi = xpathSApply(z, "//journal_article/doi_data/doi", xmlValue),
                               journal = xpathSApply(z, "//journal/journal_metadata/full_title", xmlValue),
                               url = xpathSApply(z, "//journal_article/doi_data/resource", xmlValue))
                        })

  if(verbose) message("Scraping...")
  pubhistory_df = adply(pubhistory_df, 1, scrape, 
                        .progress=ifelse(verbose, 'time', 'none'))
  return(pubhistory_df)
}

#' @importFrom plyr laply
scrape = function(pubhistory) {
  scraper_no = which(laply(scrapers, function(z) {
                             pubhistory$journal %in% z$journals}))
  if(length(scraper_no) == 0) {
    scraper_no = which(laply(scrapers, function(z) {
                               stri_detect_regex(pubhistory$url, z$url) }))
  }
  
  if(length(scraper_no) == 0) stop("Journal not supported")
  
  scraper = scrapers[[scraper_no]]
  
  article_XML = htmlTreeParse(content(slowGET(pubhistory$url), "text"),
                              useInternalNodes=T, asText=TRUE)
  if(!is.null(scraper$full_url)) {
    full_url_node = getNodeSet(article_XML, scraper$full_url$selector)[[1]]
    full_url_val = xmlGetAttr(full_url_node, scraper$full_url$attribute)
    full_XML = htmlTreeParse(content(slowGET(full_url_val), "text"),
                                useInternalNodes=T, asText=TRUE)
  }
  
  vals = llply(scraper$elements, function(element) {
   if(is.null(element$full_url)) {
     page_XML = article_XML
   } else {
     page_XML = full_XML
   }
    node = getNodeSet(page_XML, element$selector)
    if(length(node) == 0) {
      return(NA)
    }
    if(is.null(element$attribute)) {
      text = laply(node, xmlValue)
    } else {
      text = laply(node, xmlGetAttr, element$attribute)
      names(text) = NULL
    }
    if(is.null(element$regex)) {
      match = text
    } else {
      match = unlist(stri_match_all_regex(text, element$regex,
                           stri_opts_regex(case_insensitive=TRUE)))
      match = match[!is.na(match)]
    }
    if(is.null(element$date_format)) {
      val = match 
    } else {
      for(dateform in element$date_format) {
        if(!stri_detect_fixed(dateform, "%d")) {
          dateform = paste0("%d-", dateform)
          match = paste0("01-", match)
        }
        val = as.character(as.Date(match, format=dateform))
        if(class(val) != "try-error") {
          break
        }
      }
    }
    
    val = val[order(val)]
    
    return(val)
  })
  return(cbind(pubhistory, t(as.data.frame(unlist(vals)))))
}