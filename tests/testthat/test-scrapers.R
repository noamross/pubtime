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

test_that("basedata is loaded", {
  expect_equal(class(basedata), "data.frame")
  expect_equal(nrow(basedata), 42)
  expect_equal(ncol(basedata), 20)
})

context("Scraping test sites")
testdata = get_pub_history(dois)

for(doi in dois) {

context(paste("Testing against data from", doi))
  
  test_that(paste("Fields match test set on", doi), {
    testval = subset(testdata, doi==doi)
    for(field in names(testval)) {
      expect_equivalent(basedata[basedata$doi == testval$doi, field], testval[[field]])
    }
  })

}



