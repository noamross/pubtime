require(pubtime)
require(stringi)
require(plyr)

journals = read.table("inst/notebook/2014-07-02-journal-list.md", header=TRUE,
                      sep="|", strip.white=TRUE, stringsAsFactors=FALSE)
names(journals)[4] = "Notes"

journals = journals[-c(1, 15, 16),]  #Remove PeerJ, PLoS
journals$startyear = pmax(2004, stri_match_first_regex(journals$Notes,
                                                       "(?:19|20)\\d{2}"),
                          na.rm=TRUE)


rownames(journals) = journals$Journal
sp_journals = subset(journals, Journal %in% c("Oecologia", "Ecosystems"))

dois_list = dlply(journals, .(Journal), function(journal) {
  dois = get_dois(journal$ISSN, journal$startyear:2013)
  return(dois)
}, .progress="time")

laply(dois_list, length)

sp_dois_list = dlply(sp_journals, .(Journal), function(journal) {
  dois = get_dois(journal$ISSN, journal$startyear:2013)
  return(dois)
}, .progress="time")
ross_journals = c("American Naturalist", "Oecologia", "Ecosystems",
                  "Proceedings of the Royal Society B: Biological Sciences")
ross_dois = do.call(c, dois_list[ross_journals])
alex_dois = do.call(c, dois_list[!(names(dois_list) %in% ross_journals)])

cat(ross_dois, file="inst/scraper_scripts/ross_dois.txt", sep="\n")
cat(alex_dois, file="inst/scraper_scripts/alex_dois.txt", sep="\n")



springer_dois = do.call(c, sp_dois_list)
cat(springer_dois, file="inst/scraper_scripts/springer_dois.txt", sep="\n")

