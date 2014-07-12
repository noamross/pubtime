#Aggregate this list by publisher

require(httr)
require(plyr)
require(pubtime)
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


get_pub_history(peerj_dois, file="peerj_data_nr_20140712_NR.csv")
