[![Build Status](https://magnum.travis-ci.com/noamross/pubtime.svg?token=JkBWVYYe2yNqyquByRrv&branch=master)](https://magnum.travis-ci.com/noamross/pubtime)

# pubtime

A package to retreive submission-to-acceptance/publication dates for academic
journals.

This is an in-development project to examine the time-to acceptance of various
journals (starting in ecology), and possibly identify journals using reject-and-resubmit to shorten apparent time to publication..
The theory is that the latter will have a set of oddly short review times that
are likely to fail to line up with the dates encoded in DOI schemes.

The project is organized as an R package.  Ultimately, it will be a *data
package* that contains information scraped from various journals, as well
as containing functions to retrieve data from more journals.

Contributors can help by writing scraping functions for more journals, and doing
time-consuming throttled scraping. See `CONTRIBUTING.md` for more.

## Installation

You can install the package using `devtools`.  Since the project is private,
you need an authorization token which you can get 
[here](https://github.com/settings/tokens/new). You also need to install
`rcrossref` before `pubtime`, as that dependency is not on CRAN.
    
    library(devtools)
    install_github("ropensci/rcrossref")
    install_github("noamross/pubtime", auth_user=GITHUBUSERNAME, auth_token=YOURTOKEN)
    library(pubtime)

## Description

`get_pub_history()`, which takes an
article DOI and returns a list of article metadata and the dates it passed
through the publication process.  The function works by first using
`rcrossref::cr_cn` to retrieve some basic metadata, then scraping the journal
web page for the dates.

`journals` is a built-in data set of journals which are currently supported.

`scrape_dates` is a wrapper for `get_pub_history()` that takes a list of DOIs
and retrieves data in a throttled way, writing information to a file and keeping
an error log.

See `inst/get_journals_data` for an implementation of scraping.

## Cautions

I'm currently keeping this as a private repo for several reasons:

1.  I'm not totally secure about legal/copywright issues regarding scraping
    data from the journal websites.
    
    According to [this guide](https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/315014/copyright-guidance-research.pdf), recent changes
    to UK copyright law explicitly allow this type of text mining to any
    material you otherwise have legal acces to read.  Situation in the U.S.
    remains more murky.
    
2.  I'd like to do some analyses looking at effects at the editor level where
    possible, but we may ultimately want to anonymize the editor data, and I
    want to figure out how exactly to pursue this.
    
3.  It may be worthwhile to give some of the journal editors a sneak peak before
    making some of this work public.

## License

Code in this package is licensed CC-0.The text of analyses (`.md` and `.Rmd` files
found in the `inst` directory), are licensed CC-BY-NC (in anticipation of the need
to comply with UK copyright law for text-ming). Text of licences are in
the `LICENSE` file. 

## TODOs/ Development notes

-   Expand to more journals.  PLoS is next, but their API is down.
-   Need to add some warning/error messages.  Scraping may fail when articles are
    preprints, errata, etc.
-   Documentation
-   Fix month/issue problems.  This field is not reliable. (Or just kill it)
-   Break up functions into files
-   Expand CONTRIBUTING
-   Hidden function to update data with contributed set
-   Function to update existing data sets
    

    
