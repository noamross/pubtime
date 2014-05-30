# A project to examine journal acceptance times

I'm currently keeping this as a private repo for several reasons:

1.  I'm not totally secure about legal/copywright issues regarding scraping
    data from the journal websites. I suspect ESA won't be a problem, and PeerJ
    and PLoS will be fine, but I'd like to grab additional data from others.
    
2.  I'd like to do some analyses looking at effects at the editor level where
    possible, but we may ultimately want to anonymize the editor data, and I
    want to figure out how exactly to pursue this.
    
3.  It may be worthwhile to give some of the journal editors a sneak peak before
    making some of this work public.

---

## Development notes

-   I've started this by scraping publisher webpages, but it's possible that
    this [CrossRef textmining API](http://tdmsupport.crossref.org/researchers/)
    will be more generally applicable and robust
    
## License

Code in this package is licensed CC-0, while the text of analyses (.Rmd files
found in the `inst` directory), are licensed CC-BY.