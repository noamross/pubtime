# Tests that data provided is correct
context("data")
library(stringi)
#for these tests, load the csv files from journal_data
data_path = file.path(system.file("journal_data", package="pubtime"))
pubtimes_files = list.files(data_path, pattern=".*_pubtimes\\.csv")
pubtimes_list = lapply(file.path(data_path, pubtimes_files), utils::read.csv)
names(pubtimes_list) = pubtimes_files

for(filename in names(pubtimes_list)) {

  test_that(paste(filename, "has correct headers"), {
    
    expect_that(names(pubtimes_list[[filename]]), is_identical_to(
      c("doi", "journal", "volume", "editor", "submitted", "revised",
        "decision", "accepted", "preprint", "finalversion", "online",
        "issueonline", "issuedate")))
  })
  
  test_that(paste(filename, "has no empty rows"), {
    expect_that(all(apply(pubtimes_list[[filename]][4:13],1,
                          function(x)any(!is.na(x)))), is_true())
  })
  
  test_that(paste(filename, "has correctly formatted editors"), {
    expect_that(!any(stri_detect_regex(pubtimes_list[[filename]]$editor, 
                                       "['\"`]")), is_true())
    expect_that(!any(stri_detect_regex(pubtimes_list[[filename]]$editor,
                                       "\\s(?!II)[[:upper:]]{2}\\s")), is_true())
  })

    test_that(paste(filename, "has correctly formatted dates"), {
    expect_that(!any(stri_detect_regex(pubtimes_list[[filename]]$editor, 
                                       "['\"`]")), is_true())
    expect_that(!any(stri_detect_regex(pubtimes_list[[filename]]$editor,
                                       "\\s(?!II)[[:upper:]]{2}\\s")), is_true())
  })
           
  
}
