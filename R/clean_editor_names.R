#' Clean up editor names
#' 
#' Takes a vector of names, trims white spaceremoves accents and errant
#' punctuation, separates initials with a space.
#' 
#' @importFrom magrittr %>%
#' @importFrom stringi stri_replace_all_regex stri_trim_both
#' @export
clean_editor_names <- function(editors) {
  editors2 = editors %>% stri_trim_both %>%
               iconv(to="ASCII//TRANSLIT") %>%
               stri_replace_all_regex("[.'`\"]", "") %>%
               stri_replace_all_regex("\\s(?!II)([[:upper:]])([[:upper:]])([[:upper:]])([[:upper:]])\\s",
                        " $1 $2 $3 $4 ") %>%
               stri_replace_all_regex("\\s(?!II)([[:upper:]])([[:upper:]])([[:upper:]])\\s",
                        " $1 $2 $3 ") %>%
               stri_replace_all_regex("\\s(?!II)([[:upper:]])([[:upper:]])\\s",
                        " $1 $2 ")
  return(editors2)
}