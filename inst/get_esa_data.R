# This script generates the data for analysis, found in the ../data folder

journals = c("ecol")
issues = 12:1
vols = 95:75
# Running this loop should take approximately 60 hours
jdata = list()
i = 1
START = Sys.time()
for(journal in journals) {
  for(vol in vols) {
    for(issue in issues) {
      ab_urls = get_esa_abtract_urls(journal, vol, issue)
      blank_count = 0
      if (is.na(ab_urls)) next
        for(ab_url in ab_urls) {
          Sys.sleep(25) #Important! Hitting the server too frequently will get you blocked
          message(paste("Retrieving", journal, "Vol.", vol, "No.", issue,
                        "Article", which(ab_url==ab_urls), "of", length(ab_urls)))
          adata = c(list(journal=journal), get_esa_article_data(ab_url))
          if(length(adata)==7) blank_count = blank_count + 1
          jdata[[i]] = adata
          i = i+1;
        }
      if(blank_count >= length(ab_urls)) break
    }
    if(blank_count >= length(ab_urls)) break 
  }
}
END = Sys.time

require(plyr)
jddata = ldply(jdata, function(x) as.data.frame(x))
saveRDS(jddata, "data/ecology_data.rds")
saveRDS(jdata, "data/ecology_data_list.rds")
