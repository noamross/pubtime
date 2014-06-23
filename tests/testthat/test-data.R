# Tests that data provided is correct
context("functions")

test_that("get_pub_history works", {
  testval = structure(list(doi = "10.1098/rspb.2005.3311", journal = "Proceedings of the Royal Society B: Biological Sciences", 
    volume = "273", editor = NA, submitted = structure(12975, class = "Date"), 
    revised = NA, decision = NA, accepted = structure(13025, class = "Date"), 
    preprint = NA, finalversion = NA, online = structure(NA_real_, class = "Date"), 
    issueonline = NA, issuedate = structure(13186, class = "Date")), .Names = c("doi", 
"journal", "volume", "editor", "submitted", "revised", "decision", 
"accepted", "preprint", "finalversion", "online", "issueonline", 
"issuedate"))
  testpub = get_pub_history("10.1098/rspb.2005.3311")
  expect_identical(testval, testpub)
})
  
#
#context("data")
#
#test_that("Provided data has correct columns", {
#})
#
#test_that("All dates are in correct format" {
#})