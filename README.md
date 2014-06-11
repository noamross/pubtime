# A project to examine journal acceptance times

This is an in-development project to examine the time-to acceptance of various
journals in ecology, and possibly identify journals faking submission times.
The theory is that the latter will have a set of oddly short review times that
are likely to fail to line up with the dates encoded in DOI schemes.

This is organized as an R package, but it's not really useful in that format
yet, though evenentually the aim will be for it to be a data package for easy
reproducibility.  I'm not sure if it will install properly as a private repo,
anyway.  For now I recommend just cloning the repository.

For now, data go into `data/`, functions to scrape data from various journal
sites are in `R/`, scripts for scraping are in `inst/` as R files, and data
analyses should go in `inst/` as `.Rmd` files. 

See `CONTRIBUTING.md` for how you can help.

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


## Development notes

-   Journal submission/accept times are often not part of any formal metadata,
    but must be scraped from the article abstract page.  For bigger publisher
    sites, they are sometimes in formal `<div>`, at least.

-   I've started this by scraping publisher webpages, but it's possible that
    this [CrossRef textmining API](http://tdmsupport.crossref.org/researchers/)
    will be more generally applicable and robust.
    
-   Need to add some warning/error messages.  Scraping may fail when articles are
    preprints, errata, etc.
    
-   TODO: Fix problem with Condor (and others) when cr_citation throws an error
    
## License

Code in this package is licensed CC-0, while the text of analyses (.Rmd files
found in the `inst` directory), are licensed CC-BY.  Text of licences are in
the `LICENSE` file.