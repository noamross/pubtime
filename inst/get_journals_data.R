require(devtools)
#install_github("ropensci/rcrossref")
#install_github("noamross/pubtime", auth_token="2b5301f334fceb4ba3037372c370027b1485727e")
require(pubtime)
require(plyr)
                    

# Leave out some journals that still have issues
pubs = which(!(journals$shortname %in% c("PLoS ONE", "Am Naturalist", "PeerJ",
                                                  "Methods in Ecol and Evo",
                                                  "J Ecology", "Ecosystems")))
ISSNs = journals$ISSN[pubs]
names(ISSNs) = journals$shortname[pubs]

#Get list of DOIs
years = 2004:2013
dois = alply(ISSNs, 1, function(x) get_dois(x, years))

dois = llply(dois, sample, size=10)  #For testing, remove this later
names(dois) = names(ISSNs)

# Aggregate by publisher
ag_dois = dlply(journals[pubs,], .(publisher), function(x) x$shortname)
ag_dois = llply(ag_dois, function(x) unlist(dois[names(dois) %in% x],
                                            use.names=FALSE))

scrape_dates(ag_dois, progress=TRUE)

jdata = do.call(rbind, alply(list.files(pattern=".*pubtimes.csv"), 1, read.csv))
