pubtime
=======

[![Build
Status](https://magnum.travis-ci.com/noamross/pubtime.svg?token=JkBWVYYe2yNqyquByRrv&branch=master)](https://magnum.travis-ci.com/noamross/pubtime)

A package to retreive submission-to-acceptance/publication dates for academic
journals.

This is an in-development project to examine the time-to acceptance of various
journals (starting in ecology), and possibly identify journals using
reject-and-resubmit to shorten apparent time to publication.. The theory is that
the latter will have a set of oddly short review times that are likely to fail
to line up with the dates encoded in DOI schemes.

The project is organized as an R package. Ultimately, it will be a *data
package* that contains information scraped from various journals, as well as
containing functions to retrieve data from more journals.

Contributors can help by writing scraping functions for more journals, and doing
time-consuming throttled scraping. See
[`CONTRIBUTING.md`](https://github.com/noamross/pubtime/blob/master/CONTRIBUTING.md)
for more.

Installation
------------

You can install the package using `devtools`. Since the project is private, you
need an authorization token which you can get
[here](https://github.com/settings/tokens/new). You also need to install
`rcrossref` before `pubtime`, as that dependency is not on CRAN.

    library(devtools)
    install_github("ropensci/rcrossref")
    install_github("noamross/pubtime", auth_user=GITHUBUSERNAME, auth_token=YOURTOKEN)
    library(pubtime)
    
You also need to set PLoS API key to scrape PLoS articles.  Use mine for now by
setting this environment variable prior to scraping:

    options(PlosApiKey = "rkfDr76z75benY3pytM1")

Description
-----------

`data(pubtimes)` is the main data set.

`get_pub_history()` is the main package function. It takes an article DOI, or a vector of DOIs and
returns a list of article metadata and the dates it passed through the
publication process. The function works by first using `rcrossref::cr_cn` to
retrieve some basic metadata, then scraping the journal web page for the dates.
See `?get_pub_history` for more.

You can test `get_pub_history` with this list of DOIs, which cover all currently
supported journals:

`
c("10.1525/cond.2013.110151", "10.1525/cond.2009.080086", "10.1890/12-0229.1", 
"10.1890/02-0266", "10.1890/12-1881.1", "10.1890/04-1677", "10.1890/09-1541.1", 
"10.1890/02-0297", "10.1890/ES13-00269.1", "10.1890/ES10-00002.1", 
"10.1086/675716", "10.1086/648554", "10.7717/peerj.338", "10.7717/peerj.407", 
"10.1371/journal.pone.0041809", "10.1371/journal.pone.0023528", 
"10.1371/journal.pcbi.1000286", "10.1371/journal.pcbi.1002791", 
"10.1371/journal.pbio.1001487", "10.1371/journal.pbio.0000037", 
"10.1371/journal.pmed.0050194", "10.1371/journal.pmed.1000303", 
"10.1371/journal.ppat.1001068", "10.1371/journal.ppat.1002796", 
"10.1371/journal.pntd.0001658", "10.1371/journal.pntd.0000552", 
"10.1371/journal.pgen.0030047", "10.1371/journal.pgen.0030163", 
"10.1098/rspb.2013.2286", "10.1098/rspb.2012.0230", "10.1098/rsbl.2014.0206", 
"10.1098/rsbl.2011.1059", "10.1007/s10021-002-0108-6", "10.1007/s10021-012-9541-3", 
"10.1007/s12080-008-0023-3", "10.1007/s12080-013-0198-0", "10.1111/ele.12233", 
"10.1046/j.1461-0248.2003.00475.x", "10.1111/1365-2745.12168", 
"10.1046/j.1365-2745.2002.00707.x")
`

In addition `get_dois(ISSN, years)` will search crossref and return a vector
of all DOIs from a journal over a period of years.

Cautions
--------

I'm currently keeping this as a private repo for several reasons:

1.  I'm not totally secure about legal/copywright issues regarding scraping data
    from the journal websites.

    According to [this
    guide](https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/315014/copyright-guidance-research.pdf),
    recent changes to UK copyright law explicitly allow this type of text mining
    to any material you otherwise have legal acces to read. Situation in the
    U.S. remains more murky.

2.  I'd like to do some analyses looking at effects at the editor level where
    possible, but we may ultimately want to anonymize the editor data, and I
    want to figure out how exactly to pursue this.

3.  It may be worthwhile to give some of the journal editors a sneak peak before
    making some of this work public.

License
-------

Code in this package is licensed CC-0.The text of analyses (`.md` and `.Rmd`
files found in the `inst` directory), are licensed CC-BY-NC (in anticipation of
the need to comply with UK copyright law for text-ming). Text of licences are in
the `LICENSE` file.

TODOs/ Development notes
------------------------

-   Need to add some warning/error messages. Scraping may fail when articles are
    preprints, errata, etc.
-   Documentation
-   Break up functions into files
-   Hidden function to update data with contributed set
-   Function to update existing data sets

----
Additional tests to add:



3.  Loaded properly, classes of the data frame are
```
c("character", "factor", "integer", "factor", "Date", "Date", 
"Date", "Date", "Date", "Date", "Date", "Date", "Date", "integer", 
"integer", "integer")
```
4. There are no entries with only NA in all the date columns


