#load and concatenate all of the journal data files.
data_locs = c(file.path("..", "inst", "journal_data"),
              file.path("..", "journal_data"),
              file.path("journal_data"),
              file.path("inst", "journal_data"))


data_loc = data_locs[file.exists(data_locs)]


pubtime_files = file.path(data_loc, 
                          list.files(data_loc, pattern=".*_pubtimes\\.csv"))


pubtime_list = lapply(pubtime_files, utils::read.csv)


if(length(pubtime_list) > 1) {
  pubtimes = do.call(rbind, pubtime_list)
} else {
  pubtimes = pubtime_list[[1]]
}

rm(data_locs, data_loc, pubtime_files, pubtime_list)
pubtimes[,5:13] = lapply(pubtimes[,5:13], as.Date)
write.csv(pubtimes, file=file.path("data", "pubtimes.ccv"), sep=",",
          row.names=FALSE)
