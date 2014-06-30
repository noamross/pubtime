scraper_loc = system.file("scrapers", package="pubtime")
scraper_files = file.path(scraper_loc, list.files(scraper_loc,
                                                 pattern="[^.]\\.yaml"))
scrapers = plyr::alply(scraper_files, 1, yaml::yaml.load_file)

pubtime_fields = c("doi", "journal", "url", "editor", "received", "accepted", 
"online", "final_version", "issue", "first_decision", "second_decision", 
"third_decision", "fourth_decision", "preprint", "issueonline", 
"revised1", "revised2", "revised3", "revised4")

#' Get publication history from a DOI
#' 
#' This function takes a DOI, or vector of DOIs, and returns a data frame with
#' publication history for supported journals and publishers.  For supported
#' journals and publishers, see the YAML files in the \code{scrapers} directory.
#' 
#' @param doi a DOI or vector of DOIs
#' @param verbose show a progress bar?
#' @param filename If TRUE, will write directly to a CSV file rather than returning
#' a data frame.  If \code{sortdomains==TRUE}, the records will be out of order.
#' @param sortdomains if TRUE, sorts domains so as to not hit the same domain
#' repeatedly.  See \code{slowGET} to see how to control throttling.
#' @import plyr rcrossref
#' @importFrom stringi stri_replace_first_regex
#' @export 
get_pub_history = function(doi, verbose=TRUE, sortdomains=TRUE, filename=NULL) {
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

  if(sortdomains==TRUE) {
    pubhistory_df$orig_order = 1:nrow(pubhistory_df)
    pubhistory_df$domain = factor(stri_replace_first_regex(pubhistory_df$url, 
                              "https?://[^\\.]*\\.([^/\\s]+)/?[^\\s]*", "$1"))
    pubhistory_df = ddply(pubhistory_df, .(domain), transform, counter=1:length(domain))
    pubhistory_df = pubhistory_df[order(pubhistory_df$counter, decreasing=TRUE),]
    orig_order = pubhistory_df$orig_order
    pubhistory_df$orig_order = NULL
    pubhistory_df$domain = NULL
    pubhistory_df$counter = NULL
  }

  pubhistory_df[, c("doi", "url")] = llply(pubhistory_df[, c("doi", "url")], as.character)

  if(verbose) message("Scraping...")
  if(is.null(filename)) {
    pubhistory_df = adply(pubhistory_df, 1, scrape, 
                          .progress=ifelse(verbose, 'time', 'none'))
    if(sortdomains==TRUE) pubhistory_df = pubhistory_df[order(orig_order),]
    if(!is.null(pubhistory_df$editor)) {
      pubhistory_df$editor = clean_editor_names(pubhistory_df$editor)
    }
    pubhistory_df[, c("doi", "url")] = llply(pubhistory_df[, c("doi", "url")], as.character)
    pubhistory_df[,-which(names(pubhistory_df) %in% c("doi", "journal", "url", "editor"))] = 
      llply(pubhistory_df[,-which(names(pubhistory_df) %in% c("doi", "journal", "url", "editor"))], as.Date)
    if(!is.null(pubhistory_df$revised) & !is.null(pubhistory_df$revised1)) {
      pubhistory_df$revised1[is.na(pubhistory_df$revised1)] = pubhistory_df$revised[is.na(pubhistory_df$revised1)]
      pubhistory_df$revised = NULL
    } else if(!is.null(pubhistory_df$revised)) {
      names(pubhistory_df)[names(pubhistory_df)=="revised"] = "revised1"
    }  
    rownames(pubhistory_df) = NULL
    return(pubhistory_df)
  } else {
    cat(paste(pubtime_fields, collapse=","),"\n", sep="", file=filename)
    a_ply(pubhistory_df, 1, function(z) {
      pubhist = scrape(z)
      if(!is.null(pubhist$revised)) {
        names(pubhist)[names(pubhist)=="revised"] = "revised1"
      }
      if(!is.null(pubhist$editor)) {
        pubhist$editor = clean_editor_names(pubhist$editor)
      }
      pubhist[,pubtime_fields[!(pubtime_fields %in% names(pubhist))]] = NA
      pubhist = pubhist[pubtime_fields]
      pubhist = llply(pubhist, as.character)
      cat(paste(pubhist, collapse=","),"\n", sep="", file=filename, append=TRUE)
    }, .progress=ifelse(verbose, 'time', 'none'))
  }
}

#' @import plyr XML httr 
#' @importFrom stringi stri_detect_regex stri_match_all_regex stri_opts_regex
#' stri_detect_fixed
scrape = function(pubhistory) {
  scraper_no = which(laply(scrapers, function(z) {
                             pubhistory$journal %in% names(z$journals)}))
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
    }
      names(text) = NULL

    if(is.null(element$regex)) {
      match = text
    } else {
      match = unlist(stri_match_all_regex(text, element$regex,
                           stri_opts_regex(case_insensitive=TRUE)))
      match = match[!is.na(match)]
    }
    if(length(match)==0) return(NA)
    if(is.null(element$date_format)) {
      val = match 
    } else {
      for(dateform in element$date_format) {
        if(!stri_detect_fixed(dateform, "%d")) {
          dateform = paste0("%d-", dateform)
          match = paste0("01-", match)
        }
        val = as.character(as.Date(match, format=dateform))
        if((class(val)[1] != "try-error") & all(!is.na(val))) {
          break
        }
      }
    }
    
    if(length(val)==0) val = NA
    val = val[order(val)]

    return(val)
  })
  return(cbind(pubhistory, t(as.data.frame(unlist(vals)))))
}