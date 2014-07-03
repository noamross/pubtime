install.packages("devtools")
require(devtools)
install_github("ropensci/rcrossref")
install_github("noamross/pubtime", auth_user="albnd", auth_token="f703aa29de3b4e5161342ddbe7fe51b35d331e78")
require(pubtime)

dois = c("10.1525/cond.2013.110151", "10.1525/cond.2009.080086", "10.1890/12-0229.1", 
"10.1890/02-0266", "10.1890/12-1881.1", "10.1890/04-1677", "10.1890/09-1541.1", 
"10.1890/02-0297", "10.1890/ES13-00269.1", "10.1890/ES10-00002.1", 
"10.1093/beheco/arg025", "10.1093/beheco/art063", "10.7717/peerj.338", 
"10.7717/peerj.407", "10.1371/journal.pone.0041809", "10.1371/journal.pone.0023528", 
"10.1371/journal.pcbi.1000286", "10.1371/journal.pcbi.1002791", 
"10.1371/journal.pbio.1001487", "10.1371/journal.pbio.0000037", 
"10.1371/journal.pmed.0050194", "10.1371/journal.pmed.1000303", 
"10.1371/journal.ppat.1001068", "10.1371/journal.ppat.1002796", 
"10.1371/journal.pntd.0001658", "10.1371/journal.pntd.0000552", 
"10.1371/journal.pgen.0030047", "10.1371/journal.pgen.0030163", 
"10.1098/rspb.2013.2286", "10.1098/rspb.2012.0230", "10.1098/rsbl.2014.0206", 
"10.1098/rsbl.2011.1059", "10.1111/ele.12233", "10.1046/j.1461-0248.2003.00475.x", 
"10.1111/1365-2745.12168", "10.1046/j.1365-2745.2002.00707.x", 
"10.1111/1365-2656.12200", "10.1111/j.0021-8790.2004.00821.x", 
"10.1111/1365-2664.12125", "10.1111/j.1365-2664.2005.01101.x", 
"10.1111/2041-210X.12144", "10.1111/j.2041-210X.2009.00007.x")

paywall_dois = c("10.1086/675716", "10.1086/648554", "10.1007/s10021-002-0108-6",
"10.1007/s10021-012-9541-3", "10.1007/s12080-008-0023-3", "10.1007/s12080-013-0198-0",
"10.1007/s00442-004-1679-z", "10.1007/s00442-014-2955-1")

test_data = get_pub_history(dois)  #Test 1
test_data2 = get_pub_history(paywall_dois) # Test 2, should return lots of empty rows if there's no access, but complete anyway
get_pub_history(c(dois, paywall_dois), filename="pubtime_test.csv") #Test 3, should write both filled and empty rows to file.
test_data3 = read.csv("pubtime_test.csv")  #read in the csv, check it out