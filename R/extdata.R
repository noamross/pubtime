#' A typology of publication history terms
#' 
#' A list mapping various publisher descriptions of publication dates to
#' standardized names.  See \code{get_pub_history} for a description of names
#' @name datenames
#' @docType data
#' @format list (stored as YAML file)
#' @import yaml
#' @export
datenames = yaml::yaml.load_file(system.file("journal_data", "datenames.yaml",
                                       package="pubtime"))


#'Supported journals
#'
#'A data frame of journals currently supported by the package.
#' 
#'@name journals
#'@docType data
#'@format data.frame (stored as CSV)
#'@return
#' \item{name}{The journal name, as it appears in CrossRef}
#' \item{shortname}{A shortened journal name for convenience}
#' \item{ISSN}{The journal ISSN}
#' \item{open}{Is publication history for the journal available without a 
#' subscription? That is, is the journal open-acess or does the history appear
#' on a publicly-viewable abstract page?}
#' \item{scraper}{The name of the function to scrape publication dates from
#' the journal website}
#'@export
journals = read.csv(system.file("journal_data", "journals.csv",
                                package="pubtime"),
                    stringsAsFactors = FALSE)