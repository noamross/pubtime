# pubtime

A package to retreive submission-to-acceptance/publication dates for academic
journals.

This is an in-development project to examine the time-to acceptance of various
journals in ecology, and possibly identify journals faking submission times.
The theory is that the latter will have a set of oddly short review times that
are likely to fail to line up with the dates encoded in DOI schemes.

See `CONTRIBUTING.md` for how you can help.

## Installation

You can install the package using `devtools`.  Since the project is private,
you need an authorization token which you can get 
[here](https://github.com/settings/tokens/new).
    
    library(devtools)
    install_github("noamross/pubtime", auth_token=YOURTOKEN)
    library(pubtime)

## Description

The package basically has one function, `get_pub_history()`, which takes an
article DOI and returns a list of article metadata and the dates it passed
through the publication process.  The function works by first using
`rcrossref::cr_cn` to retrieve some basic metadata, then scraping the journal
web page for the dates.

Since publication history dates aren't stored in any standard location or
format, sub-functions (e.g., `get_condor_pub_history`) are needed for each
journal.  Currently the package supports retrieval from:

-   Ecology
-   Ecology Letters
-   Ecological Applications
-   Ecological Monographs
-   Ecosphere
-   The Condor
-   PeerJ
-   American Naturalist (requires subscription access)

Journals to come:

-   PLoS (mostly there but having access problems to their API)
-   Proceedings of the Royal Society B
-   Biology Letters

Scraping journal websites is legally ambigous in the U.S., though legal in the
U.K., and is a slow process because of rate limits. For this reason, the package
will eventually include data scraped.

See `inst/get_journals_date` for an implementation of scraping.

## Cautions

I'm currently keeping this as a private repo for several reasons:

1.  I'm not totally secure about legal/copywright issues regarding scraping
    data from the journal websites. I suspect ESA won't be a problem, and PeerJ
    and PLoS will be fine, but I'd like to grab additional data from others.
    
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
    
-   Need to add some warning/error messages.  Scraping may fail when articles are
    preprints, errata, etc.
    
-   Documentation

-   Expand to more journals.  PLoS is next, but their API is  
    
