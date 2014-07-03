# Script for first major scrape, created July 3, 2014
install.packages("devtools")
require(devtools)
install_github("ropensci/crossref")
install_github("noamross/pubtime", auth_user="YOURUSERNAME", auth_token="YOURAUTHTOKEN")
require(pubtime)
require(stringi)

#Load in the appropriate file:
DOIS_FILE = # Set to either "ross_dois.txt", or "alex_dois.txt"

# Get DOIs
dois = scan(system.file("scraper_scripts", DOIS_FILE, package="pubtime"),
            what=character(), sep="\n")

# Split into sample and main samples
sample_vals = sample(1:length(dois), 150)
sample_dois = dois[sample_vals]                     
main_dois = dois[-sample_vals]

# TESTING: Run this prior to the main run to check everything is OK.
# Estimated time: 20 mins
# -----------------------
get_pub_history(dois_sample, 
                file=paste0(stri_match_first_regex(DOIS_FILE, "\\w+(?=.txt)"),
                            "_sample.csv"))
# Save the session data
writeLines(paste("##", capture.output(sessionInfo())), 
           paste0(DOIS_FILE, "_sample_sessionInfo.txt"))
          

# MAIN RUN:
# Estimated time: 30 hours
# -------------------------
get_pub_history(main_dois, 
                file=paste0(stri_match_first_regex(DOIS_FILE, "\\w+(?=.txt)"),
                            "_main.csv"))
writeLines(paste("##", capture.output(sessionInfo())), 
           paste0(DOIS_FILE, "_main_sessionInfo.txt"))

                
                            
                                                  