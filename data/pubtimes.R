pubtimes = utils::read.csv("pubtimes.ccv")
pubtimes$doi = as.character(pubtimes$doi)
pubtimes[,5:13] = lapply(pubtimes[,5:13], as.Date)
