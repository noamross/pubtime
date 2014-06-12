require(devtools)
#install_github("ropensci/rcrossref")
#install_github("noamross/journaltimes", auth_token="2b5301f334fceb4ba3037372c370027b1485727e")
require(rcrossref)
require(rplos)
require(plyr)
require(stringr)
require(journaltimes)

#First, get DOIs for all of the journals of interest

# Ecology Letters
ecollet_query = "1461-0248" #Ecology Letters ISSN
ecollet_dois = cr_search(query=ecollet_query, sort="year", type="Journal Article",
                 rows=1500)
ecollet_dois$year = as.integer(ecollet_dois$year)
ecollet_dois = subset(ecollet_dois, year >= 2005)
ecollet_dois = str_replace(ecollet_dois$doi, "http://dx.doi.org/", "")

# American Naturalist
years = 2012:2014
amnat_query = "1537-5323"
amnat_dois = adply(years, 1, function(i) {
    cr_search(query=amnat_query, sort="year", type="Journal Article",
              rows=200, year=i)
  })
amnat_dois = str_replace(amnat_dois$doi, "http://dx.doi.org/", "")

# Ecology
years = 2005:2014
ecol_query = "0012-9658"
ecol_dois = adply(years, 1, function(i) {
    cr_search(query=ecol_query, sort="year", type="Journal Article",
              rows=1000, year=i)
  })
ecol_dois = str_replace(ecol_dois$doi, "http://dx.doi.org/", "")


# The Condor

years = 2007:2014
condor_query = "1938-5129"
condor_dois = adply(years, 1, function(i) {
    cr_search(query=condor_query, sort="year", type="Journal Article",
              rows=1000, year=i)
  })
condor_dois = str_replace(condor_dois$doi, "http://dx.doi.org/", "")

#Ecosphere

years = 2010:2014
ecosph_query = "2150-8925"
ecosph_dois = adply(years, 1, function(i) {
    cr_search(query=ecosph_query, sort="year", type="Journal Article",
              rows=1000, year=i)
  })
ecosph_dois = str_replace(ecosph_dois$doi, "http://dx.doi.org/", "")


#PeerJ Ecology

peerj_ecol_url = "https://peerj.com/articles/index.json?subject=1100"

peerj_dois = list()

repeat {
  ecol_json = content(GET(peerj_ecol_url))
  peerj_dois = c(peerj_dois, (laply(ecol_json$`_items`, function(x) x$doi)))
  if(is.null(ecol_json$`_links`$`next`$href)) break
  peerj_ecol_url = ecol_json$`_links`$`next`$href
}

peerj_dois = unlist(peerj_dois)

#PLOS

#years = 2005:2014
#plos_dois = aaply(years, 1, function(i) {
#  searchplos(q=paste0("subject:Ecology AND year:", i), fl=c("id","year"),
#             sort="year")
#})

doi_list = list(ecollet_dois=ecollet_dois, # amnat_dois=amnat_dois,
                ecol_dois=ecol_dois, ecosph_dois=ecosph_dois,
                condor_dois=condor_dois, peerj_dois=peerj_dois)


WAITTIME = 30 #seconds between calling the same journal to avoid rate limits

#We just want to retrieve a sample sub-set for now.
doi_sample_list = llply(doi_list, function(x) {sample(x, 5)})

#Create files for both output and en error log:

headers = c("doi", "journal", "volume", "issue", "editor", "submitted", 
            "revised", "decision", "accepted", "online", "finalversion", 
            "issueonline", "issuedate")
cat(headers, sep=", ", file="sample_records.csv")
cat("\n",file="sample_records.csv", append=TRUE)
cat("Errors\n======\n\n", file="sample_errors.csv")

# Retrieve results and write them to the files, 
# looping through journals
for(i in 1:max(laply(doi_sample_list, length))) {
  next_time = Sys.time() + WAITTIME
  for(doi in sapply(doi_sample_list, function (x) x[i])) {
    record = try(get_pub_history(doi))
    if(class(record) == "try-error") {
      cat(doi, Sys.time(), record, sep=", ", file="sample_errors.csv", append=TRUE)
      cat("\n", file="sample_errors.csv", append=TRUE)
    } else {
     record[laply(record, class)=="Date"] = llply(record[laply(record, class)=="Date"], strftime)
     cat(paste(record, collapse=", "), file="sample_records.csv", append=TRUE)
     cat("\n",file="sample_records.csv", append=TRUE)
    }
  }
  while(Sys.time() < next_time) {
    dum <- 0
  }
}


jrec = read.csv("sample_records.csv")