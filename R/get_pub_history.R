scraper_loc = system.file("scrapers", package="pubtime")
scraper_files = file.path(scraper_loc, list.files(scraper_loc,
                                                 pattern="[^.]\\.yaml"))
scrapers = plyr::alply(scraper_files, 1, yaml::yaml.load_file)

pubtime_fields = c("doi", "journal", "url", "editor", "received", "accepted", 
"online", "final_version", "issue", "first_decision", "second_decision", 
"third_decision", "fourth_decision", "preprint", "issueonline", 
"revised1", "revised2", "revised3", "revised4", "error")

#' Get publication history from a DOI
#' 
#' This function takes a DOI, or vector of DOIs, and returns a data frame with
#' publication history for supported journals and publishers.  For supported
#' journals and publishers, see the YAML files in the \code{scrapers} directory.
#' 
#' The data frame has an \code{error} field which will be \code{TRUE} if there
#' was a problem scraping the page. 
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
  
  pubhistory_df = adply(1:length(citation_xml), 1, function(z) {
                         if(!("error" %in% names(citation_xml[[z]]))) {
                           pubhistory = try(data.frame(doi = xpathSApply(citation_xml[[z]], "//journal_article/doi_data/doi", xmlValue),
                                          journal = xpathSApply(citation_xml[[z]], "//journal/journal_metadata/full_title", xmlValue),
                                          url = xpathSApply(citation_xml[[z]], "//journal_article/doi_data/resource", xmlValue)),
                                          silent=TRUE)
                           if(("try-error" %in% class(pubhistory)) || (nrow(pubhistory)==0)) {
                             pubhistory = data.frame(doi=doi[z], journal=as.factor(NA), url=as.character(NA), error=TRUE)
                           } 
                         } else {
                           pubhistory = data.frame(doi=doi[z], journal=as.factor(NA), url=as.character(NA), error=TRUE)
                         }
                         return(pubhistory)
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
    pubhistory_df = adply(pubhistory_df, 1, function(pubhistory) {
                           out = try(scrape(pubhistory))
                           if(class(out)=="try-error") {
                              out = pubhistory
                              out$error = TRUE
                            } else {
                              out$error = FALSE
                            }
                           return(out)
    }, .progress=ifelse(verbose, 'time', 'none'))
    
    if(sortdomains==TRUE) pubhistory_df = pubhistory_df[order(orig_order),]

    pubhistory_df = clean_pubhistory_df(pubhistory_df)
    return(pubhistory_df)
  } else {
    cat(paste(pubtime_fields, collapse=","),"\n", sep="", file=filename)
    a_ply(pubhistory_df, 1, function(z) {
      pubhist = try(scrape(z))
      if(class(pubhist)=="try-error") {
        pubhist = z
        pubhist$error = TRUE
      } else {
        pubhist$error = FALSE
      }
      pubhist = clean_pubhistory_df(pubhist)
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

clean_pubhistory_df = function(pubhistory_df) {
    if(!is.null(pubhistory_df$editor)) {
      pubhistory_df$editor = clean_editor_names(pubhistory_df$editor)
    }
    pubhistory_df[,pubtime_fields[!(pubtime_fields %in% names(pubhistory_df))]] = NA
    if(!is.null(pubhistory_df$revised)) {
      pubhistory_df = pubhistory_df[c(pubtime_fields, "revised")]
    } else {
      pubhistory_df = pubhistory_df[pubtime_fields]
    }
    pubhistory_df[, c("doi", "url")] = llply(pubhistory_df[, c("doi", "url")], as.character)
    pubhistory_df[, c("journal", "editor")] = llply(pubhistory_df[, c("journal", "editor")], as.factor)
    pubhistory_df$error = as.logical(pubhistory_df$error)
    pubhistory_df[,-which(names(pubhistory_df) %in% c("doi", "journal", "url", "editor", "error"))] = 
      llply(pubhistory_df[,-which(names(pubhistory_df) %in% c("doi", "journal", "url", "editor", "error"))], as.Date)
    if(!is.null(pubhistory_df$revised) & !is.null(pubhistory_df$revised1)) {
      pubhistory_df$revised1[is.na(pubhistory_df$revised1)] = pubhistory_df$revised[is.na(pubhistory_df$revised1)]
      pubhistory_df$revised = NULL
    } else if(!is.null(pubhistory_df$revised)) {
      names(pubhistory_df)[names(pubhistory_df)=="revised"] = "revised1"
    }  
    rownames(pubhistory_df) = NULL
    return(pubhistory_df)
}