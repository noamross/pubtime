#' @import plyr
#' @export
read_pubtimes_csv = function(file) {
  pubhistory_df = read.csv(file, stringsAsFactors=FALSE)
  pubhistory_df[, c("doi", "url")] = llply(pubhistory_df[, c("doi", "url")], as.character)
  pubhistory_df[, c("journal", "editor")] = llply(pubhistory_df[, c("journal", "editor")], as.factor)
  pubhistory_df$error = as.logical(pubhistory_df$error)
  pubhistory_df[,-which(names(pubhistory_df) %in% c("doi", "journal", "url", "editor", "error"))] = 
      llply(pubhistory_df[,-which(names(pubhistory_df) %in% c("doi", "journal", "url", "editor", "error"))], as.Date)
  return(pubhistory_df)
}
