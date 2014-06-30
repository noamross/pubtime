# Tests that data provided is correct
context("Scrapers working on test_dois")
dois = list()
h = 0
for (i in 1:length(pubtime:::scrapers)) {
  scraper = names(pubtime:::scrapers)[i]
  for(j in 1:length(pubtime:::scrapers[[i]]$journals)) {
    journal = names(pubtime:::scrapers[[i]]$journals)[j]
    for(k in 1:length(pubtime:::scrapers[[i]]$journals[[j]]$test_dois)) {
      h = h + 1
      dois[[h]] = pubtime:::scrapers[[i]]$journals[[j]]$test_dois[k]
    }
  }
}
dois = unlist(dois)   

basedata = try(readRDS(system.file("testdata", "testarticles.rds", package="pubtime")))
if(class(basedata) == "try-error") {
  basedata = readRDS(system.file("inst", "testdata", "testarticles.rds", package="pubtime"))
}


for(doi in dois) {

  test_that(paste("get_pub_history works on", doi), {
    testval = get_pub_history(doi, verbose=FALSE)
    for(field in names(testval)) {
      print(expect_equivalent(basedata[basedata$doi == testval$doi, field], testval[[field]]))
    }
  })

}

