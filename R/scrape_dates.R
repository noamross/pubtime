#' Scrape publication dates from many DOIs, with throttling and writing to files
#' 
#' This function runs \code{get_pub_history} repeatedly on many DOIs, pausing in
#' between each request in order to avoid taxing web servers, and writing the
#' results to file rather than returning a value.When provided a list of
#' vectors of DOIs, it will pause between each DOI in a vector, but will rotate
#' between the vectors in different list. This is meant to allow articles hosted
#' in different locations to be in different vectors, so that no host is hit
#' more frequently than the \code{pause} value, but multiple hosts can be
#' scraped efficiently.
#' 
#' \code{scrape_dates} will append to files if they already exist.
#' 
#' @param dois A vector or list vectors of DOIs
#' @param pause The amount of time to wait between requesting articles from a site
#' @param filename The CSV file to write results to
#' @param split_journals When TRUE, results from different journals are written
#' to different CSV files. In this case, the name of the journal will be
#' prepended to \code{filename}.
#' @param errors The name of the file to write the error log to
#' @export
#' @import plyr
#' @importFrom lubridate dseconds
scrape_dates = function(dois, pause=20, filename="_pubtimes.csv",
                        split_journals = TRUE, errors = "pubtime_errs.csv",
                        progress=FALSE, silent_errs=TRUE) {
  
  headers = c("doi", "journal", "volume", names(datenames))
  
  if(!is.list(dois)) dois = list(dois=dois)
  if(progress) {
    etime = max(laply(ag_dois, length))*pause
    n_dois = sum(laply(ag_dois, length))
    curr = 0
    errs = 0 
  }
  if(file.exists(errors)) file.remove(errors)
  for(i in 1:max(laply(dois, length))) {
    next_time = Sys.time() + pause
    for(doi in sapply(dois, function(x) x[i])) {
      if(is.na(doi)) next
      record = try(get_pub_history(doi), silent=silent_errs)
      if(class(record) == "try-error") {
        cat(doi, as.character(Sys.time()), record, sep="," , file=errors, append=TRUE)
        cat("\n", file=errors, append=TRUE)
        if(progress) errs = errs + 1
      } else {
        record[laply(record, class)=="Date"] = llply(record[laply(record, class)=="Date"], strftime)
        if(split_journals) {
          filename2 = paste(record$journal, filename, sep="")
        } else {
          filename2 = filename
        }
        if (!file.exists(filename2)) {
          cat(paste(headers, collapse=","),"\n", sep="", file=filename2)
        }
        cat(paste(record, collapse="," ), "\n", sep="", file=filename2, 
            append=TRUE)
        if(progress) {
          curr = curr + 1
          cat(paste0("\r", curr, " of ", n_dois, "DOIs processed. ",
                     "Estimated ", dseconds(etime - i*pause), " remaining. ", 
                      errs, " errors.       "))
          flush.console()
        }
        
      }
      while(Sys.time() < next_time) {
        dum <- 0
      }
    }
  }
}

