# Script to scrape data from all articles in PLoS journals in the "Ecology"
# category.
#
# PLoS Provides an API to access this data, so the PLoS scraper function is
# Not used here.  ROpenSci's `rplos` package is used to access this data.
#
# This requires the PLoS API key environment variable to be set with
#     options(PlosApiKey = "KEY")

require(rplos)
require(stringi)
require(plyr)

plos_dat= searchplos(q=paste0("subject:Ecology"), fq='doc_type:full', 
                     limit = 7000,
                     fl=c("id", "journal", "volume", "editor", "received_date",
                          "accepted_date", "publication_date"))

#Clean up Editor names
plos_dat$editor = stri_trim_both(stri_replace_all_regex(stri_replace_all_regex(iconv(plos_dat$editor, to="ASCII//TRANSLIT"), "[.'`\"]", "")))


# Standardize types
plos_dat[,3:5] = llply(plos_dat[,3:5], function(z) {
  as.Date(stri_extract_first_regex(z, "\\d{4}-\\d{2}-\\d{2}"))
})


plos_dat[c("journal", "editor")] = llply(plos_dat[c("journal", "editor")],
                                         as.factor)
plos_dat$volume = as.integer(plos_dat$volume)

# Some articles are missing journal names, but these can be extracted from the
# DOIs

abbrev_list = stri_extract_first_regex(plos_dat[plos_dat$journal == "none",]$id,
                                       "(?<=\\.)p[a-z]{3}(?=\\.)")
j_abbrevs = unique(abbrev_list)
journals = c("PLoS ONE", "PLoS Computational Biology", "PLoS Biology", 
             "PLoS Medicine", "PLoS Pathogens", "PLoS Neglected Tropical Diseases",
             "PLoS Genetics")

abbrev_jlist = factor(rep(NA, length(abbrev_list)), levels=journals)

for(i in 1:length(j_abbrevs)) {
  abbrev_jlist[abbrev_list == j_abbrevs[i]] = journals[i]
}

plos_dat[plos_dat$journal == "none",]$journal = abbrev_jlist


#Change names, re-arrange columns, and put in empty fields
names(plos_dat) = c("doi", "journal", "online", "submitted", "accepted",
                    "editor", "volume")

  
plos_dat[names(datenames)[!(names(datenames) %in% names(plos_dat))]] = as.Date(NA)

plos_dat = plos_dat[,c("doi", "journal", "volume", names(datenames))]

write.csv(plos_dat, file.path("inst", "journal_data", "plos_pubtimes.csv"),
          row.names=FALSE)

