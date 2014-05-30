# This script generates the data for analysis, found in the ../data folder

journals = c("ecol")
issues = 12:1
vols = 95:95

jdata = list()

for(journal in journals) {
  for(vol in vols) {
    for(issue in issues) {
      ab_urls = get_esa_abtract_urls(journal, vol, issue)
      if (is.na(ab_urls)) next
        for(ab_url in ab_urls) {
          message(paste("Retrieving", journal, "Vol.", vol, "No.", issue,
                        "Article", which(ab_url==ab_urls), "of", length(ab_urls)))
          adata = c(list(journal=journal, get_esa_article_data(ab_url))
          jdata = c(jdata, adata)
          Sys.sleep(25)
        }
    }
  }
}