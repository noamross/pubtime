# Script for second attempt at major scrape by Alex, created July 5 2014 by Noam
#install.packages("devtools")
require(devtools)
install_github("hadley/httr")
install_github("noamross/rcrossref")
install_github("noamross/pubtime", auth_user="albnd", auth_token="f703aa29de3b4e5161342ddbe7fe51b35d331e78")
require(pubtime)
require(stringi)

#Load in the appropriate file:
DOIS_FILE = "alex_dois.txt" # Set to either "ross_dois.txt", or "alex_dois.txt"

# Get DOIs
main_dois = scan(system.file("scraper_scripts", DOIS_FILE, package="pubtime"),
            what=character(), sep="\n")

# MAIN RUN:
# Estimated time: 30 hours
# -------------------------
get_pub_history(main_dois, 
                file=paste0(stri_match_first_regex(DOIS_FILE, "\\w+(?=.txt)"),
                            "_main2.csv"),
                verbose=TRUE)
writeLines(paste("##", capture.output(sessionInfo())), 
           paste0(DOIS_FILE, "_main_sessionInfo2.txt"))
