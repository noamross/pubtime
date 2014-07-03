throttle = new.env(parent = emptyenv())
throttle$recent = data.frame(domain =  character(), last_visit = character())

#' A throttled version of GET
#' 
#' This uses \code{httr::GET} to fetch a web page, but throttles based on domains.
#' 
#' \code{slowGET} keeps a list of domains recently accessed by itself in a 
#' separate environment.  If a domain has been accessed since \code{pause}
#' seconds ago, it will delay execution until that time has passed
#' 
#' @param pause The time between calls to a domain. Defaults to 10. Can be set
#' generally with \code{options(SlowGetPause=VALUE)}.
#' @param url URL to getch
#' @param ... other arguments to pass to \code{httr::GET}
#' 
#' @import httr
#' @importFrom stringi stri_replace_first_regex
#' @export
slowGET = function(url, pause=NULL, ...) {
  
  if(is.null(pause)) pause = getOption("SlowGetPause")
  if(is.null(pause)) pause = 12
  
  domain = stri_replace_first_regex(url, "https?://[^\\.]*\\.([^/\\s]+)/?[^\\s]*", "$1")
  if(domain %in% throttle$recent$domain) {
      next_time = throttle$recent$last_visit[domain == throttle$recent$domain] + 
                    pause
      while(Sys.time() < next_time) {
          dum <- 0
        }
      throttle$recent$last_visit[domain == throttle$recent$domain] = Sys.time()
  } else {
    throttle$recent = rbind(throttle$recent,
                      data.frame(domains = domain, last_visit = Sys.time()))
  }

  throttle$recent = throttle$recent[throttle$recent$last_visit > (Sys.time() - pause),]
  GET(url, ...)
}